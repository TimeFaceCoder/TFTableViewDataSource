//
//  TFTableViewDataSourceConfig.m
//  TFTableViewDataSource
//
//  Created by Melvin on 4/5/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFTableViewDataSourceConfig.h"

NSString *const kTFTableViewDataRequestURLKey = @"kTFTableViewDataRequestURLKey";
NSString *const kTFTableViewDataManagerClassKey = @"kTFTableViewDataManagerClassKey";
NSString *const kTFTableViewDataSourceClassKey = @"kTFTableViewDataSourceClassKey";
NSInteger const kTFTableViewActionTypeCellSelection  = -1;

@interface TFTableViewDataSourceConfig() {
    
}

@property (nonatomic ,strong) NSMutableDictionary *mappingInfo;

@end

@implementation TFTableViewDataSourceConfig

+ (void)enableLog {
    isEnable = YES;
}

+ (void)disableLog {
    isEnable = NO;
}

+ (BOOL)isLogEnable {
    return isEnable;
}

+ (void)setPageSize:(NSInteger)size {
    kTFPageSize = size;
}

+ (NSInteger)pageSize {
    return kTFPageSize;
}

+ (TFTableViewDataSourceConfig *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _mappingInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)mapWithMappingInfo:(NSDictionary *)mapInfo {
    [_mappingInfo setValuesForKeysWithDictionary:mapInfo];
}

- (NSString *)classNameByListType:(NSInteger)listType {
    NSDictionary *entry = [_mappingInfo objectForKey:[NSNumber numberWithInteger:listType]];
    if (!entry) {
        return nil;
    }
    return [entry objectForKey:kTFTableViewDataManagerClassKey];
}
- (NSString *)requestURLByListType:(NSInteger)listType {
    NSDictionary *entry = [_mappingInfo objectForKey:[NSNumber numberWithInteger:listType]];
    if (!entry) {
        return nil;
    }
    return [entry objectForKey:kTFTableViewDataRequestURLKey];
}

- (Class)dataSourceByListType:(NSInteger)listType {
    NSDictionary *entry = [_mappingInfo objectForKey:[NSNumber numberWithInteger:listType]];
    NSString *dataSourceClassName =[entry objectForKey:kTFTableViewDataSourceClassKey];
    if (!dataSourceClassName) {
        dataSourceClassName = @"TFTableViewDataSource";
    }
    return NSClassFromString(dataSourceClassName);
}

@end
