//
//  TFTableViewClassList.h
//  TFTableViewDataSource
//
//  Created by Melvin on 4/6/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFTableViewClassList : NSObject

+ (NSArray*)subclassesOfClass:(Class)parentClass;

@end
