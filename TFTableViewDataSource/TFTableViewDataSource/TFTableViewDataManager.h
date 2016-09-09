//
//  TFTableViewDataManager.h
//  TFTableViewDataSource
//
//  Created by Melvin on 3/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFTableViewDataManagerProtocol.h"
#import "TFTableViewDataSource.h"
#import <TFTableViewItem.h>

@interface TFTableViewDataManager : NSObject<TFTableViewDataManagerProtocol>

@property (nonatomic ,weak) TFTableViewDataSource *tableViewDataSource;
@property (nonatomic ,strong) NSIndexPath *currentIndexPath;
@property (nonatomic ,assign) NSInteger listType;
@property (nonatomic ,copy) CellClickHandler cellClickHandler;
@property (nonatomic ,copy) DeletionHandlerWithCompletion deletionHandler;
- (void)clearCompletionBlock;
@end
