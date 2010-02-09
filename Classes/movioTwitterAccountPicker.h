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
#import "Definitions.h"

@interface movioTwitterAccountPicker : UIViewController <UITextFieldDelegate> {
    XASSIGN id delegate;   
    XIBOUTLET UIButton *bOkay;
    XIBOUTLET UITextField *fUser, *fPassword;
    XIBOUTLET UIView *pageLogin, *pageProgress, *pageOk, *pageFail;
    XRETAIN XHTTPRequest *xreq;
}

@property (nonatomic, retain) IBOutlet UIButton *bOkay;
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) IBOutlet UITextField *fPassword;
@property (nonatomic, retain) IBOutlet UITextField *fUser;
@property (nonatomic, retain) IBOutlet UIView *pageFail;
@property (nonatomic, retain) IBOutlet UIView *pageLogin;
@property (nonatomic, retain) IBOutlet UIView *pageOk;
@property (nonatomic, retain) IBOutlet UIView *pageProgress;
@property (nonatomic, retain) XHTTPRequest *xreq;

- (IBAction)doDismissDialog;
- (IBAction)doInputAgain;
- (IBAction)done;
- (IBAction)fieldContentChanged;

@end
