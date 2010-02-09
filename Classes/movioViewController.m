//    Copyright 2009 Dirk Holtwick, holtwick.it
//
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.

#import "movioViewController.h"

@implementation movioViewController

@synthesize bVideoCam;
@synthesize bVideoLib;
@synthesize cameraOverlay;
@synthesize images;
@synthesize isAppeared;
@synthesize labelCharsLeft;
@synthesize labelProgress;
@synthesize labelTime;
@synthesize locationManager;
@synthesize logoImageView;
@synthesize message;
@synthesize pageDone;
@synthesize pageHome;
@synthesize pageMessage;
@synthesize pageStart;
@synthesize pageUpload;
@synthesize progress;
@synthesize recordTimer;
@synthesize req;
@synthesize uniqueId;
@synthesize xreq;

- (void)viewDidLoad {
    [super viewDidLoad]; 
    
    BOOL videoAvailable = [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(id)kUTTypeMovie];
    BOOL cameraAvailable = [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera] containsObject:(id)kUTTypeMovie];
    
    bVideoLib.enabled = videoAvailable;
    bVideoCam.enabled = cameraAvailable;

#if !TARGET_IPHONE_SIMULATOR
    if(!videoAvailable) {
        XALERT(@"Your device needs to support videos!"); 
    }
#endif
        
    isAppeared = NO;    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(!isAppeared) {
        isAppeared = YES;
        if((!([GET_CONFIG_STRING(kUsername) length] && [GET_CONFIG_STRING(kPassword) length]))) {            
            // Need to handle login later...
            ;
        } else {
            
            // Test user credentials
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           GET_CONFIG_STRING(kUsername), @"username",
                                           GET_CONFIG_STRING(kPassword), @"password",
                                           [[NSLocale currentLocale] localeIdentifier], @"lang",
                                           @"submit", @"submit", 
                                           @"auth", @"mode",                            
                                           nil];        
            self.xreq = [XHTTPRequest startHttpRequestWithURLString:URL_API
                                                         parameters:params 
                                                             target:self 
                                                             action:@selector(didTestUserData:)];        
        }
    }
}

- (void)didTestUserData:(XHTTPRequest *)request {    
    // Response from auth request
    if(request.data) {
        NSDictionary *dict = [[[[NSString alloc] initWithData:request.data encoding:NSUTF8StringEncoding] autorelease] JSONValue];
        int code = [[[[dict objectForKey:@"movio_response"] objectForKey:@"status"] valueForKey:@"resultcode"] intValue];
        if(code==4) {
            loginStatus = kLoginOK;

            // Get location
            self.locationManager = [[[CLLocationManager alloc] init] autorelease];
            [locationManager setDelegate:self];
            [locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
            [locationManager startUpdatingLocation];
        } else {
            loginStatus = kLoginFailed;            
        }        
    } else {            
        XALERTINFO(@"Error", @"An internet connection is needed to use this service.");
        loginStatus = kLoginFailed;
    }
}

// MARK: String helper

- (NSString *)stringUniqueID {
    CFUUIDRef uuidObj = CFUUIDCreate(nil);    
    NSString *newUUID = (NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return [newUUID autorelease];
}   

// MARK: Login Picker

- (IBAction)showLogin {    
    movioTwitterAccountPicker *controller = [[[movioTwitterAccountPicker alloc] init] autorelease];
	controller.delegate = self;
	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:controller animated:!showLoginAtStartup];	
}

- (void)movioTwitterAccountPickerDidFinish:(movioTwitterAccountPicker *)controller { 
    // Picker only returns if login was ok, so let's use this info
    loginStatus = kLoginOK;
}

// MARK: Video Actions

- (IBAction)showVideoPicker {
    picker = [[[UIImagePickerController alloc] init] autorelease];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;    
    picker.mediaTypes = [NSArray arrayWithObject:(id)kUTTypeMovie];
    [picker setCameraOverlayView:cameraOverlay];
    [self presentModalViewController:picker animated:YES];                
}

- (IBAction)showVideoLibraryPicker {
    picker = [[[UIImagePickerController alloc] init] autorelease];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;    
    picker.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:picker.sourceType]; 
    [self presentModalViewController:picker animated:YES];    
}

// MARK: Video picker delegates and stuff

- (void)didRotate:(NSNotification *)notification {	
    // Rotation of logo in video cam view
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];        
    if (orientation == UIDeviceOrientationLandscapeLeft) {
        [logoImageView setHidden:NO];
        [logoImageView setFrame:CGRectMake(320-54+18-2, 18+2, 54, 18)];
        [logoImageView setTransform:CGAffineTransformMakeRotation(M_PI/2)];
    } else if (orientation == UIDeviceOrientationLandscapeRight) {
        [logoImageView setHidden:YES];
    } else {
        [logoImageView setHidden:NO];
        [logoImageView setTransform:CGAffineTransformMakeRotation(0)];
        [logoImageView setFrame:CGRectMake(2, 2, 54, 18)];
    }   
}

- (void)video:(NSString *)videoPath didFinishSavingWithError: (NSError *)error contextInfo:(void *)contextInfo {
    // Finished saving the video
    [picker dismissModalViewControllerAnimated:NO];
    [self doUpload];        
}

- (void)imagePickerController:(UIImagePickerController *)thePicker didFinishPickingMediaWithInfo:(NSDictionary *)info {   

    // Test for video type
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        XALERT(@"This is an image.\nPlease select a video.");
        return;
    }

    // Prepare request
    [self doPrepareUpload];
    
    NSURL *movieUrl = [info objectForKey:UIImagePickerControllerMediaURL];    
    NSData *movieData = [NSData dataWithContentsOfURL:movieUrl]; 
    
    [req.parameters setValue:@"upload_video" forKey:@"mode"];
    [req.parameters setValue:@"1" forKey:@"piccounter"];        
    [req.parameters setValue:uniqueId forKey:@"streamid"];        
    [req addFile:movieData mimeType:@"application/octect-stream" fileName:@"mov"];        
            
    // Save in local video library
    NSString *localUrl = [movieUrl path];    
    if((thePicker.sourceType != UIImagePickerControllerSourceTypePhotoLibrary) && UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(localUrl)) {    
        UISaveVideoAtPathToSavedPhotosAlbum(localUrl, self, @selector(video:didFinishSavingWithError:contextInfo:), thePicker);
        return;
    } 
    
    [thePicker dismissModalViewControllerAnimated:NO];        
    [self doUpload];    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)thePicker {    
    [thePicker dismissModalViewControllerAnimated:YES];    
}

// MARK: Upload

- (IBAction)doPrepareUpload {      
    self.uniqueId = [self stringUniqueID];    
    self.req = [XHTTPRequest httpRequestWithTarget:self action:@selector(doSendMessage:)];
    [req setURLString:URL_API];
    [req setProgressAction:@selector(doProgress:)];
    [req.parameters setValue:GET_CONFIG_STRING(kUsername) forKey:@"username"];
    [req.parameters setValue:GET_CONFIG_STRING(kPassword) forKey:@"password"];
    [req.parameters setValue:uniqueId forKey:@"streamid"];       
    lastQt = 0.0;
}

- (void)doProgress:(XHTTPRequest *)theReq {
    CGFloat qt = ((CGFloat)theReq.totalBytesWritten / (CGFloat)theReq.totalBytesExpectedToWrite);
    if((qt - lastQt) > 0.01) {
        int percent = (int)round(qt * 100);
        [progress setProgress:qt];
        if(percent < 100) {
            [labelProgress setText:[NSString stringWithFormat:@"%d%%", percent]];
        }
        lastQt = qt;
    }         
}

- (void)doSendMessage:(XHTTPRequest *)theReq {
    
    if(![theReq successElseAlert]) {
        [self doStartAgain];
        return;
    }
    
    // Send the message
    [labelProgress setText:@"99%"];    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   GET_CONFIG_STRING(kUsername), @"username",
                                   GET_CONFIG_STRING(kPassword), @"password",
                                   @"settext", @"mode",  
                                   [message text], @"txtmsg",
                                   uniqueId, @"streamid",
                                   nil];    
    if(self.locationManager) {
        CLLocationCoordinate2D location = locationManager.location.coordinate;
        [params setValue:[NSString stringWithFormat:@"%f", location.latitude] forKey:@"location_latitude"];
        [params setValue:[NSString stringWithFormat:@"%f", location.longitude] forKey:@"location_longitude"];
    }          
    self.xreq = [XHTTPRequest startHttpRequestWithURLString:URL_API
                                                 parameters:params 
                                                     target:self 
                                                     action:@selector(didSendMessage:)];          
}

- (void)didSendMessage:(XHTTPRequest *)theReq {
    if([theReq successElseAlert]) {
        NSDictionary *dict = [[theReq responseUTF8String] JSONValue];        
        NSString *error = [[[dict objectForKey:@"movio_response"] objectForKey:@"status"] objectForKey:@"errorstring"];
        if(error) {
            XALERTINFO(@"Error", error);         
            [self doStartAgain];
            return;
        }                
    } else {
        [self doStartAgain];
        return;
    }
    self.view = pageDone;
}

- (IBAction)doUpload {       
    self.view = pageMessage;    
    [message setDelegate:self];
    [message setText:@""];
    [self textViewDidChange:message];    
    if(loginStatus == kLoginOK) {            
        [message becomeFirstResponder];
    } else {        
        [self showLogin];
    }
}

- (IBAction)doCancelUpload {
    [req stop];
    self.req = nil;
    [self doStartAgain];
}

- (IBAction)doCancelMessage {
    [message resignFirstResponder];
    [req stop];    
    self.req = nil;
    [self doStartAgain];
}

- (IBAction)doStartAgain {
    self.view = pageHome;
}

- (IBAction)doSendMessage {
    self.view = pageUpload;
    [labelProgress setText:@"0%"];
    [progress setProgress:0];       
    [req start];
}

- (void)textViewDidChange:(UITextView *)textView {
    int length = [textView.text length];    
    int remainingCharacters = 120 - length;
    labelCharsLeft.text = [NSString stringWithFormat:@"%d left", remainingCharacters];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    XError(@"error(%d, '%@');", error.code, error);      
    [locationManager stopUpdatingLocation];      
    self.locationManager = nil;        
}

// MARK: Specials

- (IBAction)doOpenWebsite {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_WEBSITE]];
}

// MARK: Memory

- (void)viewDidUnload{
    [super viewDidUnload];
    self.bVideoCam = XNIL;
    self.bVideoLib = XNIL;
    self.cameraOverlay = XNIL;
    self.labelCharsLeft = XNIL;
    self.labelProgress = XNIL;
    self.labelTime = XNIL;
    self.logoImageView = XNIL;
    self.message = XNIL;
    self.pageDone = XNIL;
    self.pageHome = XNIL;
    self.pageMessage = XNIL;
    self.pageStart = XNIL;
    self.pageUpload = XNIL;
    self.progress = XNIL;
}

- (void)dealloc{ 
    [bVideoCam release];
    [bVideoLib release];
    [cameraOverlay release];
    [images release];
    [labelCharsLeft release];
    [labelProgress release];
    [labelTime release];
    [locationManager release];
    [logoImageView release];
    [message release];
    [pageDone release];
    [pageHome release];
    [pageMessage release];
    [pageStart release];
    [pageUpload release];
    [progress release];
    [recordTimer release];
    [req release];
    [uniqueId release];
    [xreq release];
    [super dealloc];
}

@end
