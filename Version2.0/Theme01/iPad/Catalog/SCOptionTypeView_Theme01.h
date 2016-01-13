//
//  SCOptionTypeView_Theme01.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/29/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiView.h>
#import "SimiGlobalVar+Theme01.h"

@interface SCOptionTypeView_Theme01 : SimiView
@property (nonatomic, strong) UILabel *lblOptionName;
@property (nonatomic, strong) UILabel *lblRequire;
@property (nonatomic, strong) UILabel *lblOptionPrice;
@property (nonatomic, strong) UIImageView *imageDropdown;

- (void)changeLocation;
@end
