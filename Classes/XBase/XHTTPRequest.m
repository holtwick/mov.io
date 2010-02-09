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

#import "XHTTPRequest.h"

#if TARGET_OS_IPHONE
static int gNetworkTaskCount = 0;

void XRequestStart() {
    if (gNetworkTaskCount++ == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

void XRequestStop() {
    if (--gNetworkTaskCount == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}
#endif

@implementation XHTTPRequest

@synthesize action = action_;
@synthesize cachePolicy = cachePolicy_;
@synthesize connection = connection_;
@synthesize data = data_;
@synthesize error = error_;
@synthesize files = files_;
@synthesize parameters = parameters_;
@synthesize progressAction = progressAction_;
@synthesize reference = reference_;
@synthesize request = request_;
@synthesize response = response_;
@synthesize synchronous = synchronous_;
@synthesize target = target_;
@synthesize timeoutInterval = timeoutInterval_;
@synthesize totalBytesExpectedToWrite = totalBytesExpectedToWrite_;
@synthesize totalBytesWritten = totalBytesWritten_;
@synthesize url = url_;

// MARK: Class

XPUBLIC
+ (XHTTPRequest *)httpRequest {
    return [[[XHTTPRequest alloc] init] autorelease];
}

XPUBLIC
+ (XHTTPRequest *)httpRequestWithTarget:(id)target action:(SEL)action {
    XHTTPRequest *req = [XHTTPRequest httpRequest];
    [req setTarget:target];
    [req setAction:action];
    return req;
}

XPUBLIC
+ (XHTTPRequest *)httpRequestWithURLString:(NSString *)url parameters:(NSMutableDictionary *)parameters target:(id)target action:(SEL)action {
    XHTTPRequest *req = [[[XHTTPRequest alloc] initWithURLString:url parameters:parameters target:target action:action] autorelease];   
    return req;
}

XPUBLIC
+ (XHTTPRequest *)httpRequestWithURLString:(NSString *)url {
    XHTTPRequest *req = [XHTTPRequest httpRequest];
    [req setURLString:url];
    return req;
}

XPUBLIC
+ (XHTTPRequest *)startHttpRequestWithURLString:(NSString *)url parameters:(NSMutableDictionary *)parameters target:(id)target action:(SEL)action {
    XHTTPRequest *req = [[[XHTTPRequest alloc] initWithURLString:url parameters:parameters target:target action:action] autorelease];
    [req start];
    return req;
}

// MARK: Init

XPUBLIC
- (id)init {
    self = [super init];
    if (self != nil) {
        // self.parameters = [NSMutableDictionary dictionary];        
        cachePolicy_ = kDefaultCachePolicy;
        timeoutInterval_ = kDefaultTimeout;
    }
    return self;
}

XPUBLIC
- (id)initWithURLString:(NSString *)url parameters:(NSMutableDictionary *)parameters target:(id)target action:(SEL)action {
    self = [self init];
    if (self != nil) {
        [self setTarget:target];
        [self setAction:action];
        [self setURLString:url];
        [self setParameters:parameters];

        if(parameters) {
            [[self parameters] addEntriesFromDictionary:parameters];
        }
        
        XLog(@"Request URL %@ with parameters %@", url, parameters);
    }
    return self;    
}

// MARK: Setter / Getter

XPUBLIC
- (void)setURLString:(NSString *)url {
    self.url = [NSURL URLWithString:url];
}

XPUBLIC
- (NSMutableDictionary*)parameters {
    if (!parameters_) {
        XLog(@"Init parameters");
        parameters_ = [[NSMutableDictionary alloc] init];
    }
    return parameters_;
}

// MARK: Post Body

static NSString* kStringBoundary = @"3i2ndDfv2rTHiSisAbouNdArYfORhtTPEefj3q2fXHTTPRequest";

- (NSData*)generatePostBody {
    
    NSMutableData *body = [NSMutableData data];

    // [body appendData:[[NSString stringWithFormat:@"--%@\r\n", kStringBoundary]
    //               dataUsingEncoding:NSUTF8StringEncoding]];
    
    for (id key in [parameters_ keyEnumerator]) {
        NSString* value = [parameters_ valueForKey:key];
        [body appendData:[[NSString
                           stringWithFormat:@"\r\n--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n", 
                           kStringBoundary,
                           key]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    for (NSInteger i = 0; i < [files_ count]; i += 3) {
        NSData* data = [files_ objectAtIndex:i];
        NSString* mimeType = [files_ objectAtIndex:i+1];
        NSString* fileName = [files_ objectAtIndex:i+2];
        
        [body appendData:[[NSString stringWithFormat:
                           @"\r\n--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",
                           kStringBoundary,
                           fileName, 
                           fileName]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Length: %d\r\n", data.length]
                          dataUsingEncoding:NSUTF8StringEncoding]];  
        [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimeType]
                          dataUsingEncoding:NSUTF8StringEncoding]];  
        [body appendData:data];
    }
        
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", kStringBoundary]
                      dataUsingEncoding:NSUTF8StringEncoding]];
    
    XObject(XDATA2UTF8STRING(body))
    
    return body;
}

XPUBLIC
- (void)addFile:(NSData*)data mimeType:(NSString*)mimeType fileName:(NSString*)fileName {
    if (!files_) {
        files_ = [[NSMutableArray alloc] init];
    }
    
    [files_ addObject:data];
    [files_ addObject:mimeType];
    [files_ addObject:fileName];
}

// MARK: Actions

XPUBLIC
- (void)stop {
    if(connection_) {
        [connection_ cancel];
        XREQSTOP
    }
    
    self.connection = nil;
    self.response = nil;
    
    if(synchronous_) {
        return;
    }
    
    self.data = nil;
    self.error = nil;
}

- (void)performResponseOnTarget {

    XLog(@"performResponseOnTarget");
    
    if(!synchronous_) {
        
        XLog(@"Trying to send result to %s", sel_getName(action_));
        
        @try {
            if([target_ respondsToSelector:action_]) {
                [target_ performSelector:action_ withObject:self];
            } else {
                XError(@"Failed to send result to %s", sel_getName(action_));
            }        
        }
        @catch (NSException *e) {
            XException(e)
        }
        @finally {
            ;
        }
        
        // The request is not needed any more    
    }
    
    [self stop];
    
}

- (BOOL)prepareRequest {
    
    [self stop];
    
    if(!request_) {        
        
        if(!url_) {       
            XError(@"You have to provide an URL at least!");
            return NO;
        }
        
        self.request = [NSMutableURLRequest requestWithURL:url_
                                               cachePolicy:cachePolicy_
                                           timeoutInterval:timeoutInterval_];
                
        if([parameters_ count]) {            
            [request_ 
             setValue:[NSString stringWithFormat: @"multipart/form-data; boundary=%@", kStringBoundary]
             forHTTPHeaderField:@"Content-Type"];            
            [request_ setHTTPMethod:@"POST"]; 
            [request_ setHTTPBody:[self generatePostBody]];
        }
    }
    return YES;
}

- (void)start:(BOOL)sync {
    self.synchronous = sync;
    if([self prepareRequest]) {        
        self.connection = [[NSURLConnection alloc] initWithRequest:request_ delegate:self];
        if (connection_) {
            
            self.data = [NSMutableData data];
            
            XREQSTART
            
            [connection_ start];            
            
        } else {
            XError(@"Connection could not be established!");
        }
    }
}


XPUBLIC
- (void)start {
    [self start:NO];
}

XPUBLIC
- (XHTTPRequest *)startSynchronous {
    
    if(NO) {
        
        [self start:YES];    
        
        // Waiting for termination
        
        // http://stackoverflow.com/questions/149646/best-way-to-make-nsrunloop-wait-for-a-flag-to-be-set
        // http://stackoverflow.com/questions/572274/cocoa-can-i-purposely-block-in-a-loop-to-wait-for-an-asynchronous-callback-to-fi/705212#705212
        
        /* 
         *  We don't use the `sendSynchronousRequest` of NSURLConnection because
         *  this way we can handle custom Cookies and do other more perfomant
         *  things with it like streaming from or to disk, better redirection etc.
         */
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        while (connection_ && [runLoop runMode:NSDefaultRunLoopMode 
                                    beforeDate:[NSDate distantFuture]]);
    }
    
    if([self prepareRequest]) {        
        NSURLResponse *_response = nil;
        NSError *_error = nil;

        XREQSTART        
        self.data = (NSMutableData *)[NSURLConnection sendSynchronousRequest:request_ 
                                                           returningResponse:&_response                                                                        
                                                                       error:&_error];
        XREQSTOP
                
        self.response = _response;
        
        if(_error) {
            XError(@"Connection failed! Error - %@ %@",
                   [_error localizedDescription],
                   [[_error userInfo] objectForKey:NSErrorFailingURLStringKey]);
            self.error = _error;
        }
    } 
      
    return self;
     
}         
         
// MARK: Convienince

XPUBLIC
- (NSString *)responseUTF8String {
	if (!data_) {
		return nil;
	}	
    return [[[NSString alloc] initWithData:data_ encoding:NSUTF8StringEncoding] autorelease];
}

XPUBLIC
- (NSData *)responseData {
    return data_;
}


// MARK: Connection Delegates

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [data_ setLength:0];
    self.response = (id)response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [data_ appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    XError(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
    self.error = error;
    
    XREQSTOP
    [self performResponseOnTarget];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    XLog(@"Succeeded! Received %d bytes of data",[data_ length]);
    self.connection = nil;    

    XREQSTOP
    [self performResponseOnTarget];
}

- (void)connection:(NSURLConnection *)connection 
   didSendBodyData:(NSInteger)bytesWritten 
 totalBytesWritten:(NSInteger)totalBytesWritten 
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {

    totalBytesWritten_ = totalBytesWritten;
    totalBytesExpectedToWrite_ = totalBytesExpectedToWrite;

    if(progressAction_) {
        @try {
            if([target_ respondsToSelector:progressAction_]) {
                [target_ performSelector:progressAction_ withObject:self];
            } else {
                XError(@"Failed to send result to %s", sel_getName(progressAction_));
            }        
        }
        @catch (NSException *e) {
            XException(e)
        }
        @finally {
            ;
        }        
    }
    
    XLog(@"Wrote %d of %d bytes", totalBytesWritten, totalBytesExpectedToWrite);
}

 // Redirects

- (NSURLRequest *)connection:(NSURLConnection *)connection 
             willSendRequest:(NSURLRequest *)request 
            redirectResponse:(NSURLResponse *)redirectResponse {
    
    XError(@"Redirect %@ %@", [request URL], [redirectResponse URL]);
    
    NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:[request URL]
                                                              cachePolicy:cachePolicy_
                                                          timeoutInterval:timeoutInterval_];
    [newRequest setAllHTTPHeaderFields:[request allHTTPHeaderFields]];
    [newRequest setHTTPMethod:[request HTTPMethod]];
    [newRequest setHTTPBody:[request HTTPBody]];
    
    return newRequest;    
}

// MARK: Feedback

XPUBLIC
- (BOOL)success {
    return error_ == nil;
}

XPUBLIC
- (BOOL)successElseAlert {
    if(error_ != nil) {
        NSString *e = [NSString stringWithFormat:@"%@\n%@", 
                       [error_ localizedDescription],
                       [[error_ userInfo] objectForKey:NSErrorFailingURLStringKey]];
        XALERTINFO(@"Network Error", e);
        return NO;
    }
    return YES;
}


// MARK: Memory

- (void)dealloc{ 
    [connection_ cancel];
    [connection_ release];
    [data_ release];
    [error_ release];
    [files_ release];
    [parameters_ release];
    [reference_ release];
    [request_ release];
    [response_ release];
    [url_ release];
    [super dealloc];
}

@end
