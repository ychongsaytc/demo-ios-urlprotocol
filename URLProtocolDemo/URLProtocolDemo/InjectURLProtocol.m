#import "InjectURLProtocol.h"

@implementation InjectURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSString *scheme = request.URL.scheme;

    if ([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame || [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame) {
        if ([NSURLProtocol propertyForKey:@"URLProtocolHandledKey" inRequest:request]) {
            return NO;
        }

        if ([request.HTTPMethod isEqualToString:@"GET"] && (
            [request.URL.lastPathComponent hasSuffix:@".js"] ||
            [request.URL.lastPathComponent hasSuffix:@".css"]
        ) && [self isWebPrecacheFileExists:request.URL.lastPathComponent]) {
            return YES;
        }

        if ([request.HTTPMethod isEqualToString:@"POST"] || [request.HTTPMethod isEqualToString:@"PUT"] || [request.HTTPMethod isEqualToString:@"PATCH"]) {
            return YES;
        }
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return [request getRequestIncludesBody];
}

- (void)startLoading {
    NSMutableURLRequest *mutableRequest = self.request.mutableCopy;
    [NSURLProtocol setProperty:@YES forKey:@"URLProtocolHandledKey" inRequest:mutableRequest];

    NSString *fileName = self.request.URL.lastPathComponent;

    if ([self.request.HTTPMethod isEqualToString:@"GET"] && [InjectURLProtocol isWebPrecacheFileExists:fileName]) {
        NSLog(@"Inject static file: %@", fileName);

        NSData *data = [InjectURLProtocol getWebPrecacheFileData:fileName];
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:self.request.URL
                                                            MIMEType:[InjectURLProtocol getMimeTypeFromFileName:fileName]
                                               expectedContentLength:data.length
                                                    textEncodingName:nil];

        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];

        return;
    }

    NSLog(@"Passing request: %@ %@", self.request.HTTPMethod, self.request.URL.absoluteString);

    self.dataTask = [NSURLSession.sharedSession dataTaskWithRequest:mutableRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            [self.client URLProtocol:self didFailWithError:error];
            return;
        }

        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];
    }];

    [self.dataTask resume];
}

- (void)stopLoading {
}

+ (BOOL)isWebPrecacheFileExists:(NSString *)fileName {
    NSString *filePath = [self getWebPrecacheFilePath:fileName];

    return [self isFileExists:filePath];
}

+ (NSData *)getWebPrecacheFileData:(NSString *)fileName {
    NSString *filePath = [self getWebPrecacheFilePath:fileName];

    return [NSData dataWithContentsOfFile:filePath];
}

+ (NSString *)getWebPrecacheFilePath:(NSString *)fileName {
    NSString *bundlePath = [[NSBundle.mainBundle bundlePath] stringByAppendingPathComponent:@"WebPrecache"];
    NSString *filePath = [bundlePath stringByAppendingPathComponent:fileName];

    return filePath;
}

+ (BOOL)isFileExists:(NSString *)filePath {
    NSFileManager *fileManager = NSFileManager.defaultManager;
    return [fileManager fileExistsAtPath:filePath isDirectory:FALSE];
}

+ (NSString *)getMimeTypeFromFileName:(NSString *)fileName {
    if ([[fileName pathExtension] isEqualToString:@"js"]) {
        return @"application/javascript";
    }
    if ([[fileName pathExtension] isEqualToString:@"css"]) {
        return @"text/css";
    }
    return nil;
}

@end
