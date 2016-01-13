//
//  SCPaypalExpressAddressReviewViewController.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/22/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SimiCartBundle/SimiTableView.h>
#import <SimiCartBundle/SimiAddressModel.h>
#import <SimiCartBundle/SimiViewController.h>
#import "SCPaypalExpressModel.h"
#import "SCPaypalExpressModelCollection.h"

@interface SCPaypalExpressAddressReviewViewController : SimiViewController <UITableViewDataSource, UITableViewDelegate>

@property SCPaypalExpressModel * paypalModel;
@property SCPaypalExpressModelCollection * paypalModelCollection;

@property SimiTableView * addressTableView;
@property SimiAddressModel * shippingAddress;
@property SimiAddressModel * billingAddress;

@end
