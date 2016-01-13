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
#import "SCPaypalExpressModelCollection.h"

@interface SCPaypalExpressShippingMethodViewController : SimiViewController <UITableViewDataSource, UITableViewDelegate>

@property UITableView * shippingMethodTableView;
@property SCPaypalExpressModel * paypalModel;
@property SCPaypalExpressModelCollection * paypalModelCollection;

@end
