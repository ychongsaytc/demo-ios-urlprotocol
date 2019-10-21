#import "NSURLRequest+NSURLProtocolExtension.h"

@implementation NSURLRequest (NSURLProtocolExtension)

- (NSURLRequest *)getRequestIncludesBody {
    if (self.HTTPBody) return self;

    if ([self.HTTPMethod isEqualToString:@"OPTIONS"]) return self;
    if ([self.HTTPMethod isEqualToString:@"HEAD"]) return self;
    if ([self.HTTPMethod isEqualToString:@"GET"]) return self;
    if ([self.HTTPMethod isEqualToString:@"DELETE"]) return self;

    return [[self getMutableRequestIncludesBody] copy];
}

- (NSMutableURLRequest *)getMutableRequestIncludesBody {
    NSMutableURLRequest *req = [self mutableCopy];

    NSInputStream *stream = self.HTTPBodyStream;
    [stream open];

    NSMutableData *body = [[NSMutableData alloc] init];

    NSInteger bufferLength = 1024;
    uint8_t buffer[bufferLength];
    BOOL endOfStreamReached = NO;
    while (!endOfStreamReached) {
        NSInteger bytesRead = [stream read:buffer maxLength:bufferLength];
        if (bytesRead == 0) {
            endOfStreamReached = YES;
        } else if (bytesRead == -1) {
            endOfStreamReached = YES;
        } else if (stream.streamError == nil) {
            [body appendBytes:(void *)buffer length:bytesRead];
        }
    }

    req.HTTPBody = [body copy];

    [stream close];

    return req;
}

@end
