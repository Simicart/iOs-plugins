//
//  ZThemeRow.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 4/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiRow.h>

@interface ZThemeRow : SimiRow
@property (nonatomic) BOOL hasChild;
@property (nonatomic, strong) NSMutableDictionary *zThemeContentRow;
@end
