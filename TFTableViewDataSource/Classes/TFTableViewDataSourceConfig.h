//
//  TFTableViewDataSourceConfig.h
//  TFTableViewDataSource
//
//  Created by Melvin on 4/5/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TFTableViewLogDebug(frmt, ...)\
if ([TFTableViewDataSourceConfig isLogEnable]) {\
NSLog(@"[TFTableViewDataSource Debug]: %@", [NSString stringWithFormat:(frmt), ##__VA_ARGS__]);\
}
static BOOL isEnable = YES;

static NSInteger kTFPageSize = 20;

extern NSString *const kTFTableViewDataRequestURLKey;

extern NSString *const kTFTableViewDataManagerClassKey;

extern NSString *const kTFTableViewDataSourceClassKey;

extern NSInteger const kTFTableViewActionTypeCellSelection;

@interface TFTableViewDataSourceConfig : NSObject


+ (void)enableLog;

+ (void)disableLog;

+ (BOOL)isLogEnable;

+ (void)setPageSize:(NSInteger)size;

+ (NSInteger)pageSize;

+ (TFTableViewDataSourceConfig *)sharedInstance;

- (void)mapWithMappingInfo:(NSDictionary *)mapInfo;

- (NSString *)classNameByListType:(NSInteger)listType;

- (NSString *)requestURLByListType:(NSInteger)listType;

- (Class)dataSourceByListType:(NSInteger)listType;

@end
