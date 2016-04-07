//
//  MYTableViewItem.h
//  MYTableViewManager
//
//  Created by Melvin on 12/15/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MYTableViewSection;

@interface MYTableViewItem : NSObject

@property (nonatomic, strong) UIColor *dividerColor;
@property (nonatomic, weak) MYTableViewSection *section;
@property (assign, readwrite, nonatomic) UITableViewCellStyle style;
@property (assign, readwrite, nonatomic) UITableViewCellSeparatorStyle separatorStyle;
@property (assign, readwrite, nonatomic) UITableViewCellSelectionStyle selectionStyle;
@property (assign, readwrite, nonatomic) UITableViewCellAccessoryType accessoryType;
@property (assign, readwrite, nonatomic) UITableViewCellEditingStyle editingStyle;
@property (strong, readwrite, nonatomic) UIView *accessoryView;
@property (nonatomic, copy) void (^selectionHandler)(id item);
@property (nonatomic, copy) void (^accessoryButtonTapHandler)(id item);
@property (nonatomic, copy) void (^insertionHandler)(id item);
@property (nonatomic, copy) void (^deletionHandler)(id item);
@property (nonatomic, copy) void (^deletionHandlerWithCompletion)(id item, void (^)(void));
@property (nonatomic, copy) BOOL (^moveHandler)(id item, NSIndexPath *sourceIndexPath, NSIndexPath *destinationIndexPath);
@property (nonatomic, copy) void (^moveCompletionHandler)(id item, NSIndexPath *sourceIndexPath, NSIndexPath *destinationIndexPath);
@property (nonatomic, copy) void (^cutHandler)(id item);
@property (nonatomic, copy) void (^copyHandler)(id item);
@property (nonatomic, copy) void (^pasteHandler)(id item);

+ (instancetype)item;

- (NSIndexPath *)indexPath;

///-----------------------------
/// @name Manipulating table view row
///-----------------------------

- (void)selectRowAnimated:(BOOL)animated;
- (void)selectRowAnimated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;
- (void)deselectRowAnimated:(BOOL)animated;
- (void)reloadRowWithAnimation:(UITableViewRowAnimation)animation;
- (void)deleteRowWithAnimation:(UITableViewRowAnimation)animation;

@end
