//
//  SCNewAddressViewController.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/19/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <SimiCartbundle/SimiViewController.h>
#import <SimiCartBundle/SimiTableView.h>
#import <SimiCartBundle/SimiAddressModelCollection.h>
#import <SimiCartBundle/SimiAddressModel.h>
#import <SimiCartBundle/SCCountryStateViewController.h>
#import <SimiCartBundle/SCNewAddressViewController.h>
#import "AddressAutofill.h"

@interface SCNewAddressViewControllerAutofill : NSObject
@end

@interface SCNewAddressViewControllerAutofillObject : NSObject<AddressAutofillDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) SCNewAddressViewController *anAddressView;
@property (strong, nonatomic) AddressAutofill *autofill;

@end
