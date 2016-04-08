//
//  TFTableViewDataRequest.h
//  TFTableViewDataSource
//
//  Created by Melvin on 4/6/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <TFNetwork/TFNetwork.h>

@interface TFTableViewDataRequest : TFRequest

@property (nonatomic ,copy) NSString *requestURL;
@property (nonatomic ,strong) NSDictionary *requestArgument;
@property (nonatomic ,assign) NSInteger cacheTimeInSeconds;
- (instancetype)initWithRequestURL:(NSString *)url params:(NSDictionary *)params;

@end
