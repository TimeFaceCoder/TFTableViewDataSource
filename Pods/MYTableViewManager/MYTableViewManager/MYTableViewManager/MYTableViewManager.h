//
//  MYTableViewManager.h
//  MYTableViewManager
//
//  Created by Melvin on 12/15/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <AsyncDisplayKit/ASAssert.h>
#include <stdlib.h>
#import "MYTableViewItem.h"
#import "MYTableViewCell.h"
#import "MYTableViewSection.h"

@protocol MYTableViewManagerDelegate;

@interface MYTableViewManager : NSObject<ASTableViewDataSource, ASTableViewDelegate>

@property (nonatomic, strong) NSArray *sections;

/**
 *  ASTableView
 */
@property (weak, nonatomic) ASTableView *tableView;
@property (assign, nonatomic) id<MYTableViewManagerDelegate> delegate;
@property (strong, nonatomic) NSMutableDictionary *registeredClasses;



- (instancetype)initWithTableView:(ASTableView *)tableView delegate:(id<MYTableViewManagerDelegate>)delegate;
- (void)registerClass:(NSString *)objectClass forCellWithReuseIdentifier:(NSString *)identifier;
- (Class)classForCellAtIndexPath:(NSIndexPath *)indexPath;
- (id)objectAtKeyedSubscript:(id <NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

- (void)addSection:(MYTableViewSection *)section;
- (void)addSectionsFromArray:(NSArray *)array;
- (void)insertSection:(MYTableViewSection *)section atIndex:(NSUInteger)index;
- (void)insertSections:(NSArray *)sections atIndexes:(NSIndexSet *)indexes;
- (void)removeSection:(MYTableViewSection *)section;
- (void)removeAllSections;
- (void)removeSectionIdenticalTo:(MYTableViewSection *)section inRange:(NSRange)range;
- (void)removeSectionIdenticalTo:(MYTableViewSection *)section;
- (void)removeSectionsInArray:(NSArray *)otherArray;
- (void)removeSectionsInRange:(NSRange)range;
- (void)removeSection:(MYTableViewSection *)section inRange:(NSRange)range;
- (void)removeLastSection;
- (void)removeSectionAtIndex:(NSUInteger)index;
- (void)removeSectionsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceSectionAtIndex:(NSUInteger)index withSection:(MYTableViewSection *)section;
- (void)replaceSectionsWithSectionsFromArray:(NSArray *)otherArray;
- (void)replaceSectionsAtIndexes:(NSIndexSet *)indexes withSections:(NSArray *)sections;
- (void)replaceSectionsInRange:(NSRange)range withSectionsFromArray:(NSArray *)otherArray range:(NSRange)otherRange;
- (void)replaceSectionsInRange:(NSRange)range withSectionsFromArray:(NSArray *)otherArray;
- (void)exchangeSectionAtIndex:(NSUInteger)idx1 withSectionAtIndex:(NSUInteger)idx2;
- (void)sortSectionsUsingFunction:(NSInteger (*)(id, id, void *))compare context:(void *)context;
- (void)sortSectionsUsingSelector:(SEL)comparator;


@end



@protocol MYTableViewManagerDelegate <ASTableViewDelegate>

/**
 *  列表是否需要加载更多数据
 *
 *  @param tableView
 *
 *  @return
 */
- (BOOL)shouldBatchFetchForTableView:(ASTableView *)tableView;
/**
 *  列表开始加载更多数据
 *
 *  @param tableView
 *  @param context
 */
- (void)tableView:(ASTableView *)tableView willBeginBatchFetchWithContext:(ASBatchContext *)context;

@optional

/*
 Tells the delegate the table view is about to layout a cell for a particular row.
 
 @param tableView The table-view object informing the delegate of this impending event.
 @param cell A table-view cell object that tableView is going to use when drawing the row.
 @param indexPath An index path locating the row in tableView.
 */
- (void)my_tableView:(ASTableView *)tableView willDisplayNodeForRowAtIndexPath:(NSIndexPath *)indexPath;



/*
 Tells the delegate the table view is about to create a cell for a particular row and make it reusable.
 
 @param tableView The table-view object informing the delegate of this impending event.
 @param cell A table-view cell object that tableView is going to create.
 @param indexPath An index path locating the row in tableView.
 */
- (void)my_tableView:(UITableView *)tableView willLoadCell:(MYTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

/*
 Tells the delegate the table view has created a cell for a particular row and made it reusable.
 
 @param tableView The table-view object informing the delegate of this event.
 @param cell A table-view cell object that tableView has created.
 @param indexPath An index path locating the row in tableView.
 */
- (void)my_tableView:(UITableView *)tableView didLoadCell:(MYTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

@end
