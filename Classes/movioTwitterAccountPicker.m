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

#import "movioTwitterAccountPicker.h"

@implementation movioTwitterAccountPicker

@synthesize bOkay;
@synthesize delegate;
@synthesize fPassword;
@synthesize fUser;
@synthesize pageFail;
@synthesize pageLogin;
@synthesize pageOk;
@synthesize pageProgress;
@synthesize xreq;

- (void)viewDidLoad {    
    [super viewDidLoad];    
}

- (void)viewWillAppear:(BOOL)animated {
    fUser.text = GET_CONFIG_STRING(kUsername);
    fPassword.text = GET_CONFIG_STRING(kPassword);
    [self fieldContentChanged];    
    [fUser becomeFirstResponder];
}

// MARK: Actions

- (IBAction)doInputAgain {    
    self.view = pageLogin;
    [pageFail removeFromSuperview];
    [self fieldContentChanged];    
    [fUser becomeFirstResponder];
}

- (IBAction)doDismissDialog {    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)done {
    SET_CONFIG_STRING(kUsername, fUser.text);
    SET_CONFIG_STRING(kPassword, fPassword.text);
    SYNC_CONFIG;    
    
    [fUser resignFirstResponder];
    [fPassword resignFirstResponder];
    
    [self.view addSubview:pageProgress];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   fUser.text, @"username",
                                   fPassword.text, @"password",
                                  [[NSLocale currentLocale] localeIdentifier], @"lang",                                  
                                   @"submit", @"submit", 
                                   @"auth", @"mode",                            
                                   nil];
    
    self.xreq = [XHTTPRequest startHttpRequestWithURLString:URL_API 
                                                 parameters:params
                                                     target:self 
                                                     action:@selector(didTestUserData:)];
}

- (void)didTestUserData:(XHTTPRequest *)req {    
    [pageProgress removeFromSuperview];

    if([req successElseAlert]) {
        
        NSLog(@"JSON %@", [req responseUTF8String]);
        
        NSDictionary *dict = [[req responseUTF8String] JSONValue];        
        int code = [[[[dict objectForKey:@"movio_response"] objectForKey:@"status"] valueForKey:@"resultcode"] intValue];
        if(code==4) {
            self.view = pageOk;
            //[self dismissModalViewControllerAnimated:YES];
            //XALERT(@"Valid user data");
        } else {
            if(code==[[[[dict objectForKey:@"movio_response"] objectForKey:@"status"] objectForKey:@"errorCode"] intValue]) {
                self.view = pageFail;        
            } else {            
                NSString *error = [[[dict objectForKey:@"movio_response"] objectForKey:@"status"] objectForKey:@"errorstring"];
                error = [NSString stringWithFormat:@"%@\n\nPlease try again.", error];
                XALERTINFO(@"Error", error);         
                return;
            }
        }        
    } else {            
        return;
    }    
    
    if ([self.delegate respondsToSelector:@selector(movioTwitterAccountPickerDidFinish:)]) {
        [self.delegate performSelector:@selector(movioTwitterAccountPickerDidFinish:) withObject:self];
    }    
    
}

// MARK: User settings

- (IBAction)fieldContentChanged {
    [bOkay setEnabled:([fUser.text length] && [fPassword.text length])];    
}

// MARK: Keyboard events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self resignFirstResponder];
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if([textField isEqual:fUser])
    {
        [fUser resignFirstResponder];       
        [fPassword becomeFirstResponder];
    } else{
        if([fUser.text length] && [fPassword.text length]) {
            [self done];
        } else {
            XALERT(@"You need to fill out both fields.");
        }
    } 
    return YES;
}

// MARK: Memory

- (void)viewDidUnload{
    [super viewDidUnload];
    self.bOkay = XNIL;
    self.fPassword = XNIL;
    self.fUser = XNIL;
    self.pageFail = XNIL;
    self.pageLogin = XNIL;
    self.pageOk = XNIL;
    self.pageProgress = XNIL;
}

- (void)dealloc{ 
    [bOkay release];
    [fPassword release];
    [fUser release];
    [pageFail release];
    [pageLogin release];
    [pageOk release];
    [pageProgress release];
    [xreq release];
    [super dealloc];
}

@end
