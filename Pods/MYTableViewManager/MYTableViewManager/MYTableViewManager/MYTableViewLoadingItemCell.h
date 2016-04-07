//
//  MYTableViewLoadingItemCell.h
//  MYTableViewManager
//
//  Created by Melvin on 12/22/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import "MYTableViewCell.h"
#import "MYTableViewLoadingItem.h"

@interface MYTableViewLoadingItemCell : MYTableViewCell

@property (strong, readwrite, nonatomic) MYTableViewLoadingItem *tableViewItem;

@end
