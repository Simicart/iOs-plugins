//
//  LocationPickupWorker.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/17/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "LocationPickupWorker.h"
#import <SimiCartBundle/SCNewAddressViewController.h>
#import <CoreLocation/CoreLocation.h>
@implementation LocationPickupWorker
{
    SCNewAddressViewController *newAddressViewController;
    SimiAddressAutofillModel *addressModel;
}
- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:SCRegisterViewController_DidInitForm object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:SCNewAddressViewController_DidInitForm object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SimiFormMapAPI_DidGetAddress" object:nil];
    }
    return self;
}

- (void)getAddressWithParams:(NSDictionary*)params
{
    if (addressModel == nil) {
        addressModel = [SimiAddressAutofillModel new];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetAddress:) name:@"DidGetAddress" object:addressModel];
    [addressModel getAddressWithParams:params];
}

- (void)didGetAddress:(NSNotification*)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    if (responder.status == SUCCESS) {
        if (addressModel.countryId) {
            [newAddressViewController.country updateFormData:addressModel.countryId];
        }
        if (addressModel.countryName) {
            [newAddressViewController.form setValue:addressModel.countryName forKey:@"country_name"];
        }
        if (addressModel.region) {
            [newAddressViewController.form setValue:addressModel.region forKey:@"region"];
        }
        if (addressModel.regionId) {
            NSString *regionID = addressModel.regionId;
            [newAddressViewController.form setValue:regionID forKey:@"region_id"];
            if (newAddressViewController.stateId.dataSource.count > 0 && [newAddressViewController.form.fields containsObject:newAddressViewController.stateId]) {
                for (NSDictionary *state in newAddressViewController.stateId.dataSource) {
                    if ([[NSString stringWithFormat:@"%@",[state valueForKey:@"state_code"]] isEqualToString:regionID]) {
                        [newAddressViewController.form setValue:[state valueForKey:@"state_id"] forKey:@"region_id"];
                        break;
                    }
                }
            }
        }
        if (addressModel.city) {
            [newAddressViewController.form setValue:addressModel.city forKey:@"city"];
        }
        if (addressModel.street) {
            [newAddressViewController.form setValue:addressModel.street forKey:@"street"];
        }
        if (addressModel.postcode) {
            [newAddressViewController.form setValue:addressModel.postcode forKey:@"postcode"];
        }
        [newAddressViewController.form sortFormFields];
        [newAddressViewController.tableViewAddress reloadData];
    }
    [self removeObserverForNotification:noti];
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:SCRegisterViewController_DidInitForm] || [noti.name isEqualToString:SCNewAddressViewController_DidInitForm]) {
        newAddressViewController = [noti.userInfo valueForKey:@"newAddressView"];
        [newAddressViewController.form addField:@"MapAPI" config:@{@"name": @"latlng",
                                                                  @"title": SCLocalizedString(@"Country"),
                                                                   @"sort_order":@10000,
                                                                   @"height":[NSNumber numberWithFloat:[SimiGlobalVar scaleValue:250]]}];
    }else if([noti.name isEqualToString:@"SimiFormMapAPI_DidGetAddress"])
    {
        NSDictionary *params = noti.object;
        [self getAddressWithParams:params];
    }
}
@end
