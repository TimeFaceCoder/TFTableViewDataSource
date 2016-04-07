//
//  TimeLineTextStyle.m
//  TimeFaceV3
//
//  Created by Melvin on 12/21/15.
//  Copyright © 2015 timeface. All rights reserved.
//

#import "TimeLineTextStyle.h"

@implementation TimeLineTextStyle

+ (NSDictionary *)nickNameStyle {
    return @{NSFontAttributeName : [UIFont boldSystemFontOfSize:14],
             NSForegroundColorAttributeName:[UIColor darkTextColor]};
}

+ (NSDictionary *)subTextStyle {
    return @{NSFontAttributeName:[UIFont systemFontOfSize:12],
             NSForegroundColorAttributeName:[UIColor lightGrayColor]};
}
+ (NSDictionary *)titleStyle {
    return @{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],
             NSForegroundColorAttributeName:[UIColor darkTextColor]};
}
+ (NSDictionary *)contentStyle {
    return @{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],
             NSForegroundColorAttributeName:[UIColor darkTextColor]};
}
+ (NSDictionary *)contentLinkStyle {
    return @{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],
             NSForegroundColorAttributeName:[UIColor blueColor]};
}
+ (NSDictionary *)bookTitleStyle {
    return @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12],
             NSForegroundColorAttributeName:[UIColor darkTextColor]};
}
+ (NSDictionary *)cellControlStyle {
    return @{NSFontAttributeName : [UIFont systemFontOfSize:12.0],
             NSForegroundColorAttributeName:[UIColor darkTextColor]};
}

+ (NSDictionary *)circleControlStyle {
    return @{NSFontAttributeName : [UIFont systemFontOfSize:10.0],
             NSForegroundColorAttributeName : [UIColor darkTextColor]};
}

+ (NSDictionary *)cellTextColoredStyle{
    return @{NSFontAttributeName : [UIFont systemFontOfSize:12.0],
             NSForegroundColorAttributeName:[UIColor whiteColor]};
}
@end
