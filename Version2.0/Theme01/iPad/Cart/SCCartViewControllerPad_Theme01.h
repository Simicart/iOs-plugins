//
//  SCCartViewControllerPad_Theme01.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/11/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <SimiCartBundle/SimiViewController.h>

#import "SCCartDetailControllerPad_Theme01.h"
#import "SCCartTotalControllerPad_Theme01.h"
#import "SCProductViewControllerPad_Theme01.h"

@interface SCCartViewControllerPad_Theme01 : SimiViewController<UIScrollViewDelegate, SCCartDetailControllerPad_Theme01_Delegate, SCCartTotalControllerPad_Theme01_Delegate, UIPopoverControllerDelegate, SCAddressDelegate, UIActionSheetDelegate, SCLoginViewController_Theme01_Delegate, SCNewAddressDelegate>

@property (strong, nonatomic) SCCartDetailControllerPad_Theme01 *cartDetailController;
@property (strong, nonatomic) SCCartTotalControllerPad_Theme01 *cartTotalController;
@property (strong, nonatomic) UIPopoverController *popController;
@property (nonatomic) BOOL isNewCustomer;

@property (strong, nonatomic) UIView *clearView;

+ (instancetype)sharedInstance;
@end
