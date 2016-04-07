//
//  MYTableViewLoadingItem.h
//  MYTableViewManager
//
//  Created by Melvin on 12/22/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import "MYTableViewItem.h"

@interface MYTableViewLoadingItem : MYTableViewItem

@property (nonatomic ,copy) NSString *title;

+ (MYTableViewLoadingItem*)itemWithTitle:(NSString *)title;

@end
