//
//  TFTableViewItem.h
//  TFTableViewDataSource
//
//  Created by Melvin on 3/30/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <MYTableViewManager/MYTableViewManager.h>

@interface TFTableViewItem : MYTableViewItem

@property (nonatomic ,strong) NSObject *model;
@property (nonatomic ,copy) void (^onViewClickHandler)(TFTableViewItem *item,NSInteger actionType);

+ (instancetype)itemWithModel:(NSObject *)model
                     clickHandler:(void(^)(TFTableViewItem *item,NSInteger actionType))clickHandler;

@end
