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

#define URL_API @"http://api.sandbox.mov.io/movioapi.php"
#define URL_WEBSITE @"http://sandbox.mov.io/?source=iphone"

// Use this for production only!
// #define URL_API @"http://api.mov.io/api_ext.php"
// #define URL_WEBSITE @"http://www.mov.io/?source=iphone"

#define kUsername @"k_username"
#define kPassword @"k_password"
#define kHostName @"k_host"

#define GET_CONFIG_STRING(v) [[NSUserDefaults standardUserDefaults] stringForKey:v]
#define SET_CONFIG_STRING(k,v) [[NSUserDefaults standardUserDefaults] setObject:v forKey:k]
#define SYNC_CONFIG [[NSUserDefaults standardUserDefaults] synchronize]

#define XASSIGN
#define XRETAIN 
#define XCOPY 
#define XATOMIC 
#define XREADONLY
#define XIBOUTLET

#import "XBase.h"
#import "XHTTPRequest.h"
#import "JSON.h"
