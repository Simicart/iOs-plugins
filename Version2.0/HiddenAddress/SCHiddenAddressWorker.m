//
//  SCHiddenAddressWorker.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/4/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCHiddenAddressWorker.h"
#import "SCHiddenAddressModel.h"
#import "SCHiddenAddressKey.h"
#import <SimiCartBundle/SCNewAddressViewController.h>
@implementation SCHiddenAddressWorker
{
    SCNewAddressViewController *newAddressController;
    SCHiddenAddressModel *hiddenAddressModel;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCNewAddressViewController-ViewDidLoadBefore" object:nil];
    }
    return self;
}

- (BOOL)hasField:(NSString *)fieldName
{
    if (fieldName == nil) {
        return NO;
    }
    if ([fieldName isKindOfClass:[NSString class]] && (
                                                       [fieldName isEqualToString:@"req"] || [fieldName isEqualToString:@"opt"]
                                                       )) {
        return YES;
    }
    return NO;
}

-(void)didReceiveNotification:(NSNotification*)noti
{
    if ([noti.name isEqualToString:@"SCNewAddressViewController-ViewDidLoadBefore"]) {
        newAddressController = noti.object;
        newAddressController.isDiscontinue = YES;
        newAddressController.country = nil;
        newAddressController.stateId = nil;
        newAddressController.stateName = nil;
        [newAddressController.form.fields removeAllObjects];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCHiddenAddress_DidGetAddressHide" object:nil];
        hiddenAddressModel = [[SCHiddenAddressModel alloc]init];
        [hiddenAddressModel getAddressHideWithParams:@{}];
    } else if ([noti.name isEqualToString:@"SCHiddenAddress_DidGetAddressHide"]) {
        SimiFormBlock *form = newAddressController.form;
        
        newAddressController.country = nil;
        newAddressController.stateId = nil;
        newAddressController.stateName = nil;
        [form.fields removeAllObjects];
        
        if ([self hasField:[hiddenAddressModel valueForKey:scHiddenAddress_prefix]]) {
            [form addField:@"Text"
                    config:@{
                             @"name" : @"prefix",
                             @"title": SCLocalizedString(@"Prefix"),
                             @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:scHiddenAddress_prefix] isEqualToString:@"req"]]
                             }];
        }
        
        [form addField:@"Name"
                config:@{
                         @"name": @"name",
                         @"title": SCLocalizedString(@"Full Name"),
                         @"required": @1
                         }];
        
        if ([self hasField:[hiddenAddressModel valueForKey:scHiddenAddress_suffix]]) {
            [form addField:@"Text"
                    config:@{
                             @"name" : @"suffix",
                             @"title": SCLocalizedString(@"Suffix"),
                             @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:scHiddenAddress_suffix] isEqualToString:@"req"]]
                             }];
        }
        
        if ([self hasField:[hiddenAddressModel valueForKey:scHiddenAddress_company]]) {
            [form addField:@"Text"
                    config:@{
                             @"name" : @"company",
                             @"title": SCLocalizedString(@"Company"),
                             @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:scHiddenAddress_company] isEqualToString:@"req"]]
                             }];
        }
        
        if ([self hasField:[hiddenAddressModel valueForKey:scHiddenAddress_fax]]) {
            [form addField:@"Text"
                    config:@{
                             @"name" : @"fax",
                             @"title": SCLocalizedString(@"Fax"),
                             @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:scHiddenAddress_fax] isEqualToString:@"req"]]
                             }];
        }
        
        if ([self hasField:[hiddenAddressModel valueForKey:scHiddenAddress_street]]) {
            [form addField:@"Text"
                    config:@{
                             @"name" : @"street",
                             @"title": SCLocalizedString(@"Street"),
                             @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:scHiddenAddress_street] isEqualToString:@"req"]]
                             }];
        }
        
        if ([self hasField:[hiddenAddressModel valueForKey:scHiddenAddress_city]]) {
            [form addField:@"Text"
                    config:@{
                             @"name" : @"city",
                             @"title": SCLocalizedString(@"City"),
                             @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:scHiddenAddress_city] isEqualToString:@"req"]]
                             }];
        }
        
        if ([self hasField:[hiddenAddressModel valueForKey:scHiddenAddress_state]]) {
            newAddressController.stateName = (SimiFormText *)[form addField:@"Text"
                                                                     config:@{
                                                                              @"name": @"state_name",
                                                                              @"title": SCLocalizedString(@"State"),
                                                                              @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:scHiddenAddress_state] isEqualToString:@"req"]]
                                                                              }];
            newAddressController.stateId = (SimiFormSelect *)[form addField:@"Select"
                                                                     config:@{
                                                                              @"name": @"state_id",
                                                                              @"title": SCLocalizedString(@"State"),
                                                                              @"option_type": SimiFormOptionNavigation,
                                                                              @"nav_controller": newAddressController.navigationController,
                                                                              @"value_field": @"state_id",
                                                                              @"label_field": @"state_name",
                                                                              @"index_titles": @1,
                                                                              @"searchable": @1,
                                                                              @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:scHiddenAddress_state] isEqualToString:@"req"]]
                                                                              }];
        }
        
        if ([self hasField:[hiddenAddressModel valueForKey:scHiddenAddress_zipcode]]) {
            [form addField:@"Text"
                    config:@{
                             @"name": @"zip",
                             @"title": SCLocalizedString(@"Post/Zip Code"),
                             @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:scHiddenAddress_zipcode] isEqualToString:@"req"]]
                             }];
        }
        
        if ([self hasField:[hiddenAddressModel valueForKey:scHiddenAddress_country]]) {
            newAddressController.country = (SimiFormSelect *)[form addField:@"Select"
                                                                     config:@{
                                                                              @"name": @"country_code",
                                                                              @"title": SCLocalizedString(@"Country"),
                                                                              @"option_type": SimiFormOptionNavigation,
                                                                              @"nav_controller": newAddressController.navigationController,
                                                                              @"value_field": @"country_code",
                                                                              @"label_field": @"country_name",
                                                                              @"index_titles": @1,
                                                                              @"searchable": @1,
                                                                              @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:scHiddenAddress_country] isEqualToString:@"req"]]
                                                                              }];
        }
        
        if ([self hasField:[hiddenAddressModel valueForKey:scHiddenAddress_telephone]]) {
            [form addField:@"Phone"
                    config:@{
                             @"name": @"phone",
                             @"title": SCLocalizedString(@"Phone"),
                             @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:scHiddenAddress_telephone] isEqualToString:@"req"]]
                             }];
        }
        
        if ([self hasField:[hiddenAddressModel valueForKey:scHiddenAddress_birthday]]) {
            [form addField:@"Date"
                    config:@{
                             @"name": @"dob",
                             @"title": SCLocalizedString(@"Date of Birth"),
                             @"date_type": @"date",
                             @"date_format": @"yyyy-MM-dd",
                             @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:scHiddenAddress_birthday] isEqualToString:@"req"]]
                             }];
        }
        
        if ([self hasField:[hiddenAddressModel valueForKey:scHiddenAddress_gender]]) {
            [form addField:@"Select"
                    config:@{
                             @"name": @"gender",
                             @"title": SCLocalizedString(@"Gender"),
                             @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:scHiddenAddress_gender] isEqualToString:@"req"]],
                             @"source": @[@{@"value":@"123",@"label":SCLocalizedString(@"Male")},@{@"value":@"234",@"label":SCLocalizedString(@"Female")}]
                             }];
        }
        
        if ([self hasField:[hiddenAddressModel valueForKey:scHiddenAddress_taxvat]]) {
            [form addField:@"Text"
                    config:@{
                             @"name": @"taxvat",
                             @"title": SCLocalizedString(@"VAT Number"),
                             @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:scHiddenAddress_taxvat] isEqualToString:@"req"]]
                             }];
        }
        
        [form addField:@"Email"
                config:@{
                         @"name": @"email",
                         @"title": SCLocalizedString(@"Email"),
                         @"required": @1
                         }].enabled = ![[SimiGlobalVar sharedInstance] isLogin];
        
        if (newAddressController.isNewCustomer) {
            [form addField:@"Password"
                    config:@{
                             @"name": @"customer_password",
                             @"title": SCLocalizedString(@"Password"),
                             @"required": @1
                             }];
            [form addField:@"Password"
                    config:@{
                             @"name": @"confirm_password",
                             @"title": SCLocalizedString(@"Confirm Password"),
                             @"required": @1
                             }];
        }
        
        // Remove state before get country
        newAddressController.form.view = newAddressController.tableViewAddress;
        [newAddressController.form showView];
        [newAddressController.view addSubview:newAddressController.tableViewAddress];
        
        [form.fields removeObject:newAddressController.stateId];
        [form.fields removeObject:newAddressController.stateName];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHiddenAddress_DidGetAddressHide" object:nil];
        
        //  Liam ADD 150402
        [newAddressController didGetCountries];
        //  Liam 150402
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
