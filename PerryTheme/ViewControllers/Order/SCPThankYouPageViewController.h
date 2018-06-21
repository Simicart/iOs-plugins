//
//  SCPThankYouPageViewController.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 6/19/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SCThankYouPageViewController.h>
#import "SCPGlobalVars.h"
#import "SCPButton.h"

@interface SCPThankYouPageViewController : SCThankYouPageViewController{
    float paddingX, buttonHeight;
}
- (void)continueShopping:(UIButton *)sender;
- (void)viewOrderDetail:(UIButton *)sender;
@end
