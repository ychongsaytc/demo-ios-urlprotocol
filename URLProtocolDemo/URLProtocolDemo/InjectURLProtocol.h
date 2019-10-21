#import <Foundation/Foundation.h>
#import "NSURLRequest+NSURLProtocolExtension.h"

@interface InjectURLProtocol : NSURLProtocol

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

@end
