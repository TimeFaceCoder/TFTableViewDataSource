//
//  TFNetworkPrivate.h
//  TFNetwork
//
//  Created by Melvin on 3/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFBaseRequest.h"
#import "TFBatchRequest.h"
#import "TFChainRequest.h"

FOUNDATION_EXPORT void TFNLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

@interface TFNetworkPrivate : NSObject

+ (BOOL)checkJson:(id)json withValidator:(id)validatorJson;

+ (NSString *)urlStringWithOriginUrlString:(NSString *)originUrlString
                          appendParameters:(NSDictionary *)parameters;

+ (void)addDoNotBackupAttribute:(NSString *)path;

+ (NSString *)md5StringFromString:(NSString *)string;

+ (NSString *)appVersionString;

@end

@interface TFBaseRequest (RequestAccessory)

- (void)toggleAccessoriesWillStartCallBack;
- (void)toggleAccessoriesWillStopCallBack;
- (void)toggleAccessoriesDidStopCallBack;

@end

@interface TFBatchRequest (RequestAccessory)

- (void)toggleAccessoriesWillStartCallBack;
- (void)toggleAccessoriesWillStopCallBack;
- (void)toggleAccessoriesDidStopCallBack;

@end

@interface TFChainRequest (RequestAccessory)

- (void)toggleAccessoriesWillStartCallBack;
- (void)toggleAccessoriesWillStopCallBack;
- (void)toggleAccessoriesDidStopCallBack;

@end