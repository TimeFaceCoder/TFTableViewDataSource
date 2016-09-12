//
//  TimeLineTableViewItemCell.h
//  TFTableViewDataSource
//
//  Created by Melvin on 4/6/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <TFTableViewItemCellNode.h>
#import "TimeLineTableViewItem.h"

@interface TimeLineTableViewItemCellNode : TFTableViewItemCellNode

@property (nonatomic ,readwrite ,strong) TimeLineTableViewItem *tableViewItem;

@end
