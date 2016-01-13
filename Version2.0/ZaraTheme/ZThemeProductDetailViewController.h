//
//  ZThemeProductDetailViewController.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 6/5/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SCProductDetailViewController.h>
#import <SimiCartBundle/SCReviewDetailController.h>

#import "ZThemeProductInfoView.h"

@interface ZThemeProductDetailViewController : SCProductDetailViewController<SimiTabViewDataSource, SimiTabViewDelegate, ZThemeProductInfoView_Delegate>

@end
