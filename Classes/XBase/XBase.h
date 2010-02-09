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

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#  import <UIKit/UIKit.h>
#else
#  import <Cocoa/Cocoa.h>
#endif

#include <math.h>

// Little helper for the 'xobjc' convienience tool:
// http://github.com/holtwick/xobjc/tree/ 

#define XASSIGN
#define XRETAIN 
#define XCOPY 
#define XATOMIC 
#define XREADONLY
#define XIBOUTLET

#define XNIL nil

#define XPUBLIC
#define XPRIVATE

// Set in "Preprocessor Macros"

#if (DEBUG || XDEBUG)
#  define XLog(fmt, ...) NSLog((@" %@:%d  %s\n\n    " fmt @"\n\n"), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__);
#  define XObject(obj) NSLog((@" %@:%d  %s\n\n    OBJECT: %@\n\n"), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, obj);
#  define XDump(obj)      NSLog((@" %@:%d  %s\n\n{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{\n%@\n}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}\n\n"), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, obj);
#else
#  define XLog(...)
#  define XObject(obj)
#  define XDump(obj)
#endif

#if (DEBUG || XDEBUG || XERROR)
#  define XError(fmt, ...) NSLog((@" %@:%d  %s\n\n###############################################################################\n    " fmt @"\n###############################################################################\n\n"), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__);
#  define XException(obj) NSLog((@" %@:%d  %s\n\n###############################################################################\n    EXCEPTION: %@\n###############################################################################\n\n"), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, obj);
#else
#  define XError(...)
#  define XException(obj)
#endif

// Loading

#if TARGET_OS_IPHONE
#  define XREQSTART XRequestStart();
#  define XREQSTOP XRequestStop();
#else
#  define XREQSTART 
#  define XREQSTOP
#endif

// Alerts

#if TARGET_OS_IPHONE
#  define XALERT(msg) [[[[UIAlertView alloc] initWithTitle:@"Alert" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
#  define XALERTINFO(title, msg) [[[[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
#  define XALERTCRITICAL(msg) [[[[UIAlertView alloc] initWithTitle:@"Alert" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
#else
#  define XALERT(msg) NSRunCriticalAlertPanel(@"Alert", msg, @"OK", nil, nil);
#  define XALERTINFO(title, msg) NSRunInformationalAlertPanel(title, msg, @"OK", nil, nil);
#  define XALERTCRITICAL(msg) NSRunCriticalAlertPanel(@"Alert", msg, @"OK", nil, nil);
#  define XCONFIRM(msg) (0 != NSRunCriticalAlertPanel(@"Confirm", msg,@"OK", @"Cancel", nil))
#endif

// String

#define XURLESCAPE(v) [(NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[[v mutableCopy] autorelease], NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"),kCFStringEncodingUTF8) autorelease]

// #define XURL(v) [NSURL URLWithString:v]

// Images
// Filename without suffix!

#if TARGET_OS_IPHONE
#  define XIMAGE_PNG(filename) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"png"]];
#  define XIMAGE_JPG(filename) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"jpg"]];
#endif

// Archiving

#define XSERIALIZE(obj) [NSKeyedArchiver archivedDataWithRootObject:obj] 
#define XUNSERIALIZE(data) [NSKeyedUnarchiver unarchiveObjectWithData:data]

// Config 

#define XGET_OBJECT(v) [[NSUserDefaults standardUserDefaults] objectForKey:v]
#define XSET_OBJECT(k,v) [[NSUserDefaults standardUserDefaults] setObject:v forKey:k]
#define XGET_STRING(v) [[NSUserDefaults standardUserDefaults] stringForKey:v]
#define XSET_STRING(k,v) [[NSUserDefaults standardUserDefaults] setObject:v forKey:k]
#define XGET_FLOAT(v) [[NSUserDefaults standardUserDefaults] floatForKey:v]
#define XSET_FLOAT(k,v) [[NSUserDefaults standardUserDefaults] setFloat:v forKey:k]
#define XGET_BOOL(v) [[NSUserDefaults standardUserDefaults] boolForKey:v]
#define XSET_BOOL(k,v) [[NSUserDefaults standardUserDefaults] setBool:v forKey:k]
#define XGET_INT(v) [[NSUserDefaults standardUserDefaults] integerForKey:v]
#define XSET_INT(k,v) [[NSUserDefaults standardUserDefaults] setInteger:v forKey:k]
#define XSYNC [[NSUserDefaults standardUserDefaults] synchronize]

// Language

#define XAPPLY(target, sel)  if([target respondsToSelector:@selector(sel)]) { [target performSelector:@selector(sel)]; }
#define XAPPLY1(target, sel, obj)  if([target respondsToSelector:@selector(sel:)]) { [target performSelector:@selector(sel:) withObject:obj]; }

#define XDATA2UTF8STRING(data) [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]
