//
//  SCPaypalExpressShippingMethodViewController.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/22/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiViewController.h>
#import "SCPaypalExpressModel.h"

@interface SCPaypalExpressShippingMethodViewController : SimiViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView * shippingMethodTableView;
@property (strong, nonatomic) SCPaypalExpressModel *paypalModel;
@property (strong, nonatomic) SCPaypalExpressModel *paypalShippingModel;

- (void)getShippingMethod;

@end
