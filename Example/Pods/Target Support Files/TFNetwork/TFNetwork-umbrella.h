#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AFGzipRequestSerializer.h"
#import "AFGzipResponseSerializer.h"
#import "NSData+TFNGZIP.h"
#import "TFBaseRequest.h"
#import "TFBatchRequest.h"
#import "TFBatchRequestAgent.h"
#import "TFChainRequest.h"
#import "TFChainRequestAgent.h"
#import "TFNetwork.h"
#import "TFNetworkAgent.h"
#import "TFNetworkConfig.h"
#import "TFNetworkPrivate.h"
#import "TFRequest.h"
#import "TFRequestProtocol.h"

FOUNDATION_EXPORT double TFNetworkVersionNumber;
FOUNDATION_EXPORT const unsigned char TFNetworkVersionString[];

