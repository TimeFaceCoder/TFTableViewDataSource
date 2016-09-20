//
//  LoadDataOperation.h
//  TFTableViewDataSource
//
//  Created by zguanyu on 16/9/20.
//  Copyright © 2016年 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFTableViewDataSource.h"
@class TFTableViewDataRequest;
@interface LoadDataOperation : NSOperation {
    BOOL        executing;
    BOOL        finished;
}
- (instancetype)initWithRequest:(TFTableViewDataRequest*)request dataLoadPolocy:(TFDataLoadPolicy)policy firstLoadOver:(BOOL)firstLoadOver;

@property (nonatomic, strong)NSDictionary *result;
@property (nonatomic, strong)TFTableViewDataRequest* request;
/**
 *  网络数据加载工具
 */
@property (nonatomic, assign) TFDataLoadPolicy policy;
@property (nonatomic, assign) BOOL firstLoadOver;
@end
