//
//  SCProductLabel.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/10/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <Foundation/Foundation.h>

//Position of label
/*
    7 - Bottom-right    6 - Middle-right        1 - Top-left
    6 - Bottom-center   5 - Middle-center       2 - Top-center
    7 - Bottom-left     4 - Middle-left         3 - Top-right
 */
typedef NS_ENUM(NSInteger, LabelPosition){
    LabelPositionNone,
    LabelPositionLeftTop,
    LabelPositionCenterTop,
    LabelPositionRightTop,
    LabelPositionLeftMiddle,
    LabelPositionCenterMiddle,
    LabelPositionRightMiddle,
    LabelPositionLeftBottom,
    LabelPositionCenterBottom,
    LabelPositionRightBottom,
};

@interface SCProductLabel : NSObject

@end
