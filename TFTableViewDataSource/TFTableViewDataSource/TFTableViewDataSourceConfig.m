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

- (void)mapWithListType:(NSInteger)listType mappingInfo:(NSDictionary *)mappingInfo {
    [self mapWithListType:listType mappingInfo:mappingInfo dataSourceClass:NSClassFromString(@"TFTableViewDataSource")];
}

- (void)mapWithListType:(NSInteger)listType mappingInfo:(NSDictionary *)mappingInfo dataSourceClass:(Class)dataSourceClass {
    self.dataSourceClass = dataSourceClass;
    if ([self validatorMappingInfo:mappingInfo]) {
        [_mappingInfo setObject:mappingInfo forKey:[NSNumber numberWithInteger:listType]];
    }
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

- (BOOL)validatorMappingInfo:(NSDictionary *)mappingInfo {
    if ([mappingInfo isKindOfClass:[NSDictionary class]]) {
        if (![mappingInfo objectForKey:kTFTableViewDataRequestURLKey]) {
            NSAssert(NO, @"mapping info must have an object with kTFTableViewDataRequestURLKey");
            return NO;
        }
        if (![mappingInfo objectForKey:kTFTableViewDataManagerClassKey]) {
            NSAssert(NO, @"mapping info must have an object with kTFTableViewDataManagerClassKey");
            return NO;
        }
    }
    else {
        return NO;
    }
    return YES;
}

@end
