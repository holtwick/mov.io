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

#import "XBase.h"

#define kDefaultCachePolicy NSURLCacheStorageNotAllowed
#define kDefaultTimeout 60.0

#if TARGET_OS_IPHONE
void XRequestStart();
void XRequestStop();
#endif

@interface XHTTPRequest : NSObject {    
    XRETAIN NSMutableURLRequest *request_;    
    XRETAIN NSURL *url_;
    XRETAIN NSMutableData *data_;
    XRETAIN NSURLConnection *connection_;
    XRETAIN NSURLResponse *response_;
    XRETAIN NSError *error_;
    XRETAIN NSMutableDictionary *parameters_;
    XRETAIN NSMutableArray *files_;
    
    XASSIGN id target_;
    XASSIGN SEL action_, progressAction_;
    XASSIGN NSURLRequestCachePolicy cachePolicy_;
    XASSIGN NSTimeInterval timeoutInterval_;
    XASSIGN NSInteger totalBytesWritten_, totalBytesExpectedToWrite_;
    XASSIGN BOOL synchronous_;
    
    // Put your own stuff into this object
    XRETAIN id reference_;
}

@property (nonatomic, assign) SEL action;
@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) NSError *error;
@property (nonatomic, retain) NSMutableArray *files;
@property (nonatomic, retain) NSMutableDictionary *parameters;
@property (nonatomic, assign) SEL progressAction;
@property (nonatomic, retain) id reference;
@property (nonatomic, retain) NSMutableURLRequest *request;
@property (nonatomic, retain) NSURLResponse *response;
@property (nonatomic, assign) BOOL synchronous;
@property (nonatomic, assign) id target;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, assign) NSInteger totalBytesExpectedToWrite;
@property (nonatomic, assign) NSInteger totalBytesWritten;
@property (nonatomic, retain) NSURL *url;

+ (XHTTPRequest *)httpRequest;
+ (XHTTPRequest *)httpRequestWithTarget:(id)target action:(SEL)action;
+ (XHTTPRequest *)httpRequestWithURLString:(NSString *)url parameters:(NSMutableDictionary *)parameters target:(id)target action:(SEL)action;
+ (XHTTPRequest *)httpRequestWithURLString:(NSString *)url;
+ (XHTTPRequest *)startHttpRequestWithURLString:(NSString *)url parameters:(NSMutableDictionary *)parameters target:(id)target action:(SEL)action;
- (BOOL)success;
- (BOOL)successElseAlert;
- (NSData *)responseData;
- (NSMutableDictionary*)parameters;
- (NSString *)responseUTF8String;
- (XHTTPRequest *)startSynchronous;
- (id)init;
- (id)initWithURLString:(NSString *)url parameters:(NSMutableDictionary *)parameters target:(id)target action:(SEL)action;
- (void)addFile:(NSData*)data mimeType:(NSString*)mimeType fileName:(NSString*)fileName;
- (void)setURLString:(NSString *)url;
- (void)start;
- (void)stop;

@end
