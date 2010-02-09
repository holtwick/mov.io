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

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "Definitions.h"
#import "movioTwitterAccountPicker.h"

#define kLoginNone 0
#define kLoginOK 1
#define kLoginFailed 2

@interface movioViewController : UIViewController <UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UITextViewDelegate> {
    
    XIBOUTLET UIProgressView *progress;
    XIBOUTLET UIButton *bVideoCam, *bVideoLib;
    XIBOUTLET UIView *pageHome, *pageMessage, *pageUpload, *pageDone, *pageStart, *cameraOverlay;    
    XIBOUTLET UILabel *labelProgress, *labelTime, *labelCharsLeft;
    XIBOUTLET UITextView *message;
    XIBOUTLET UIImageView *logoImageView;
    
    int loginStatus;
    BOOL showLoginAtStartup;
    
    CGFloat lastQt;        
    UIImagePickerController *picker;
    
    XRETAIN NSTimer *recordTimer;    
    XRETAIN CLLocationManager *locationManager;
    XRETAIN XHTTPRequest *req;
    XRETAIN XHTTPRequest *xreq;
    
    XCOPY NSString *uniqueId;
    
    XASSIGN BOOL isAppeared;
    
    XRETAIN NSMutableArray *images;
}

@property (nonatomic, retain) IBOutlet UIButton *bVideoCam;
@property (nonatomic, retain) IBOutlet UIButton *bVideoLib;
@property (nonatomic, retain) IBOutlet UIView *cameraOverlay;
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, assign) BOOL isAppeared;
@property (nonatomic, retain) IBOutlet UILabel *labelCharsLeft;
@property (nonatomic, retain) IBOutlet UILabel *labelProgress;
@property (nonatomic, retain) IBOutlet UILabel *labelTime;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) IBOutlet UIImageView *logoImageView;
@property (nonatomic, retain) IBOutlet UITextView *message;
@property (nonatomic, retain) IBOutlet UIView *pageDone;
@property (nonatomic, retain) IBOutlet UIView *pageHome;
@property (nonatomic, retain) IBOutlet UIView *pageMessage;
@property (nonatomic, retain) IBOutlet UIView *pageStart;
@property (nonatomic, retain) IBOutlet UIView *pageUpload;
@property (nonatomic, retain) IBOutlet UIProgressView *progress;
@property (nonatomic, retain) NSTimer *recordTimer;
@property (nonatomic, retain) XHTTPRequest *req;
@property (nonatomic, copy) NSString *uniqueId;
@property (nonatomic, retain) XHTTPRequest *xreq;

- (IBAction)doCancelMessage;
- (IBAction)doCancelUpload;
- (IBAction)doOpenWebsite;
- (IBAction)doPrepareUpload;
- (IBAction)doSendMessage;
- (IBAction)doStartAgain;
- (IBAction)doUpload;
- (IBAction)showLogin;
- (IBAction)showVideoLibraryPicker;
- (IBAction)showVideoPicker;

@end

