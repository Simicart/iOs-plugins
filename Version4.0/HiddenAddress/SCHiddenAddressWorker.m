//
//  SCHiddenAddressWorker.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/4/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCHiddenAddressWorker.h"
#import <SimiCartBundle/SCNewAddressViewController.h>
@implementation SCHiddenAddressWorker
{
    SCNewAddressViewController *newAddressController;
    SimiModel *hiddenAddressModel;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCNewAddressViewControllerViewDidLoad" object:nil];
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
    if ([noti.name isEqualToString:@"SCNewAddressViewControllerViewDidLoad"]) {
        newAddressController = noti.object;
        if ([[SimiGlobalVar sharedInstance].customerConfig valueForKey:@"address_fields_config"]) {
            hiddenAddressModel = [[SimiModel alloc]initWithDictionary:[[SimiGlobalVar sharedInstance].customerConfig valueForKey:@"address_fields_config"]];
            if (hiddenAddressModel.count > 0) {
                self.available = YES;
            }
        }
        if (self.available) {
            SimiFormBlock *form = newAddressController.form;
            newAddressController.country = nil;
            newAddressController.stateId = nil;
            newAddressController.stateName = nil;
            [form.fields removeAllObjects];
            SimiGlobalVar *config = [SimiGlobalVar sharedInstance];
            if ([self hasField:[hiddenAddressModel valueForKey:@"prefix_show"]]) {
                [form addField:@"Text"
                        config:@{
                                 @"name" : @"prefix",
                                 @"title": SCLocalizedString(@"Prefix"),
                                 @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"prefix"] isEqualToString:@"req"]]
                                 }];
            }
            
            [form addField:@"Name"
                    config:@{
                             @"name": @"firstname",
                             @"title": SCLocalizedString(@"First Name"),
                             @"required": @1
                             }];
            if (![[config middleNameShow] isEqualToString:@""]) {
                [form addField:@"Name"
                        config:@{
                                 @"name": @"middlename",
                                 @"title": SCLocalizedString(@"Middle Name"),
                                 @"required": @0
                                 }];
            }
            
            [form addField:@"Name"
                    config:@{
                             @"name": @"lastname",
                             @"title": SCLocalizedString(@"Last Name"),
                             @"required": @1
                             }];
            
            if ([self hasField:[hiddenAddressModel valueForKey:@"suffix_show"]]) {
                [form addField:@"Text"
                        config:@{
                                 @"name" : @"suffix",
                                 @"title": SCLocalizedString(@"Suffix"),
                                 @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"suffix"] isEqualToString:@"req"]]
                                 }];
            }
            if ([self hasField:[hiddenAddressModel valueForKey:@"company_show"]]) {
                [form addField:@"Text"
                        config:@{
                                 @"name" : @"company",
                                 @"title": SCLocalizedString(@"Company"),
                                 @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"company"] isEqualToString:@"req"]]
                                 }];
            }
            
            if (![[SimiGlobalVar sharedInstance] isLogin]) {
                [form addField:@"Email"
                        config:@{
                                 @"name": @"email",
                                 @"title": SCLocalizedString(@"Email"),
                                 @"required": @1
                                 }];
            }
            
            if ([self hasField:[hiddenAddressModel valueForKey:@"street_show"]]) {
                [form addField:@"Text"
                        config:@{
                                 @"name" : @"street",
                                 @"title": SCLocalizedString(@"Street"),
                                 @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"street"] isEqualToString:@"req"]]
                                 }];
            }
            
            
            if ([self hasField:[hiddenAddressModel valueForKey:@"city_show"]]) {
                [form addField:@"Text"
                        config:@{
                                 @"name" : @"city",
                                 @"title": SCLocalizedString(@"City"),
                                 @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"city"] isEqualToString:@"req"]]
                                 }];
            }
            
            if ([self hasField:[hiddenAddressModel valueForKey:@"country_id_show"]]) {
                newAddressController.country = (SimiFormSelect *)[form addField:@"Select"
                                                                         config:@{
                                                                                  @"name": @"country_id",
                                                                                  @"title": SCLocalizedString(@"Country"),
                                                                                  @"option_type": SimiFormOptionNavigation,
                                                                                  @"nav_controller": newAddressController.navigationController,
                                                                                  @"value_field": @"country_code",
                                                                                  @"label_field": @"country_name",
                                                                                  @"index_titles": @1,
                                                                                  @"searchable": @1,
                                                                                  @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"country_id"] isEqualToString:@"req"]]
                                                                                  }];
            }

            
            if ([self hasField:[hiddenAddressModel valueForKey:@"region_id_show"]]) {
                newAddressController.stateName = (SimiFormText *)[form addField:@"Text"
                                                                         config:@{
                                                                                  @"name": @"region",
                                                                                  @"title": SCLocalizedString(@"State"),
                                                                                  @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"region_id"] isEqualToString:@"req"]]
                                                                                  }];
                newAddressController.stateId = (SimiFormSelect *)[form addField:@"Select"
                                                                         config:@{
                                                                                  @"name": @"region_id",
                                                                                  @"title": SCLocalizedString(@"State"),
                                                                                  @"option_type": SimiFormOptionNavigation,
                                                                                  @"nav_controller": newAddressController.navigationController,
                                                                                  @"value_field": @"state_id",
                                                                                  @"label_field": @"state_name",
                                                                                  @"index_titles": @1,
                                                                                  @"searchable": @1,
                                                                                  @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"region_id"] isEqualToString:@"req"]]
                                                                                  }];
            }
            
            
            if ([self hasField:[hiddenAddressModel valueForKey:@"zipcode_show"]]) {
                [form addField:@"Text"
                        config:@{
                                 @"name": @"postcode",
                                 @"title": SCLocalizedString(@"Post/Zip Code"),
                                 @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"zipcode"] isEqualToString:@"req"]]
                                 }];
            }
            
            if ([self hasField:[hiddenAddressModel valueForKey:@"telephone_show"]]) {
                [form addField:@"Phone"
                        config:@{
                                 @"name": @"telephone",
                                 @"title": SCLocalizedString(@"Phone"),
                                 @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"telephone"] isEqualToString:@"req"]]
                                 }];
            }
            
            if ([self hasField:[hiddenAddressModel valueForKey:@"fax_show"]]) {
                [form addField:@"Text"
                        config:@{
                                 @"name" : @"fax",
                                 @"title": SCLocalizedString(@"Fax"),
                                 @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"fax"] isEqualToString:@"req"]]
                                 }];
            }
            if (![SimiGlobalVar sharedInstance].isLogin) {
                if ([self hasField:[hiddenAddressModel valueForKey:@"dob_show"]]) {
                    [form addField:@"Date"
                            config:@{
                                     @"name": @"dob",
                                     @"title": SCLocalizedString(@"Date of Birth"),
                                     @"date_type": @"date",
                                     @"date_format": @"yyyy-MM-dd",
                                     @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"dob"] isEqualToString:@"req"]]
                                     }];
                }
                
                NSMutableArray *genderValues = [[NSMutableArray alloc]initWithArray:[[[[SimiGlobalVar sharedInstance]customerConfig]valueForKey:@"address_option"]valueForKey:@"gender_value"]];
                
                if (genderValues.count == 2) {
                    NSDictionary *dict01 = [[NSDictionary alloc]initWithDictionary:[genderValues objectAtIndex:0]];
                    NSDictionary *dict02 = [[NSDictionary alloc]initWithDictionary:[genderValues objectAtIndex:1]];
                    if ([self hasField:[hiddenAddressModel valueForKey:@"gender_show"]]) {
                        [form addField:@"Select"
                                config:@{
                                         @"name": @"gender",
                                         @"title": SCLocalizedString(@"Gender"),
                                         @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"gender"] isEqualToString:@"req"]],
                                         @"source": @[@{@"value":[dict01 valueForKey:@"value"],@"label":SCLocalizedString([dict01 valueForKey:@"label"])},@{@"value":[dict02 valueForKey:@"value"] ,@"label":SCLocalizedString([dict02 valueForKey:@"label"])}]
                                         }];
                    }
                }
                
                if ([self hasField:[hiddenAddressModel valueForKey:@"taxvat_show"]]) {
                    [form addField:@"Text"
                            config:@{
                                     @"name": @"taxvat",
                                     @"title": SCLocalizedString(@"Tax/VAT number"),
                                     @"required": [NSNumber numberWithBool:[[config taxvatShow] isEqualToString:@"req"]]
                                     }];
                }
                
            }
            
            
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
            [form.fields removeObject:newAddressController.stateId];
            [form.fields removeObject:newAddressController.stateName];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHiddenAddress_DidGetAddressHide" object:nil];
            
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
