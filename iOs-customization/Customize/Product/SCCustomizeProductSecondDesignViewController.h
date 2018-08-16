//
//  SCCustomizeProductSecondDesignViewController.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 2/4/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SCProductSecondDesignViewController.h>
#import "SCCustomizeLoginViewController.h"

#define PRODUCT_DESCRIPTION_DETAIL @"PRODUCT_DESCRIPTION_DETAIL"

@interface SCCustomizeProductSecondDesignViewController : SCProductSecondDesignViewController
@property (strong, nonatomic) SimiButton *callForPriceButton;
@property (strong, nonatomic) SimiButton *loginButton;
@end
