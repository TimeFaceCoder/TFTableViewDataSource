//
//  TimeLineTableViewItemCell.h
//  TFTableViewDataSource
//
//  Created by Melvin on 4/6/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFTableViewItemCell.h"
#import "TimeLineTableViewItem.h"

@interface TimeLineTableViewItemCell : TFTableViewItemCell

@property (nonatomic ,readwrite ,strong) TimeLineTableViewItem *tableViewItem;

@end
