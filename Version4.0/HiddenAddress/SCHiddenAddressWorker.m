//
//  SCHiddenAddressWorker.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/4/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCHiddenAddressWorker.h"

@implementation SCConfigureNewAddressViewController{
    SimiModel *hiddenAddressModel;
}
- (BOOL)hasField:(NSString *)fieldName
{
    if (fieldName == nil) {
        return NO;
    }
    if ([fieldName isKindOfClass:[NSString class]] && ([fieldName isEqualToString:@"req"] || [fieldName isEqualToString:@"opt"])) {
        return YES;
    }
    return NO;
}

- (void)addFieldsToFormBlock{
    hiddenAddressModel = hiddenAddressModel = [[SimiModel alloc]initWithModelData:[GLOBALVAR.storeView.customer valueForKey:@"address_fields_config"]];
    SimiGlobalVar *config = [SimiGlobalVar sharedInstance];
    if ([self hasField:[hiddenAddressModel valueForKey:@"prefix_show"]]) {
        [self.form addField:@"Text"
                config:@{
                         @"name" : @"prefix",
                         @"title": SCLocalizedString(@"Prefix"),
                         @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"prefix_show"] isEqualToString:@"req"]]
                         }];
    }
    
    [self.form addField:@"Name"
            config:@{
                     @"name": @"firstname",
                     @"title": SCLocalizedString(@"First Name"),
                     @"required": @1
                     }];
    if (![[config middleNameShow] isEqualToString:@""]) {
        [self.form addField:@"Name"
                config:@{
                         @"name": @"middlename",
                         @"title": SCLocalizedString(@"Middle Name"),
                         @"required": @0
                         }];
    }
    
    [self.form addField:@"Name"
            config:@{
                     @"name": @"lastname",
                     @"title": SCLocalizedString(@"Last Name"),
                     @"required": @1
                     }];
    
    if ([self hasField:[hiddenAddressModel valueForKey:@"suffix_show"]]) {
        [self.form addField:@"Text"
                config:@{
                         @"name" : @"suffix",
                         @"title": SCLocalizedString(@"Suffix"),
                         @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"suffix_show"] isEqualToString:@"req"]]
                         }];
    }
    if ([self hasField:[hiddenAddressModel valueForKey:@"company_show"]]) {
        [self.form addField:@"Text"
                config:@{
                         @"name" : @"company",
                         @"title": SCLocalizedString(@"Company"),
                         @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"company_show"] isEqualToString:@"req"]]
                         }];
    }
    
    if ([self hasField:[hiddenAddressModel valueForKey:@"taxvat_show"]]) {
        [self.form addField:@"Text"
                     config:@{
                              @"name" : @"vat_id",
                              @"title": SCLocalizedString(@"VAT Number"),
                              @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"taxvat_show"] isEqualToString:@"req"]]
                              }];
    }
    
    if (![[SimiGlobalVar sharedInstance] isLogin]) {
        [self.form addField:@"Email"
                config:@{
                         @"name": @"email",
                         @"title": SCLocalizedString(@"Email"),
                         @"required": @1
                         }];
    }
    
    if ([self hasField:[hiddenAddressModel valueForKey:@"street_show"]]) {
        [self.form addField:@"Text"
                config:@{
                         @"name" : @"street",
                         @"title": SCLocalizedString(@"Street"),
                         @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"street_show"] isEqualToString:@"req"]]
                         }];
    }
    
    
    if ([self hasField:[hiddenAddressModel valueForKey:@"city_show"]]) {
        [self.form addField:@"Text"
                config:@{
                         @"name" : @"city",
                         @"title": SCLocalizedString(@"City"),
                         @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"city_show"] isEqualToString:@"req"]]
                         }];
    }
    
    if ([self hasField:[hiddenAddressModel valueForKey:@"country_id_show"]]) {
        self.country = (SimiFormSelect *)[self.form addField:@"Select"
                                                                 config:@{
                                                                          @"name": @"country_id",
                                                                          @"title": SCLocalizedString(@"Country"),
                                                                          @"option_type": SimiFormOptionNavigation,
                                                                          @"nav_controller": self.navigationController,
                                                                          @"value_field": @"country_code",
                                                                          @"label_field": @"country_name",
                                                                          @"index_titles": @1,
                                                                          @"searchable": @1,
                                                                          @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"country_id_show"] isEqualToString:@"req"]]
                                                                          }];
    }
    
    
    if ([self hasField:[hiddenAddressModel valueForKey:@"region_id_show"]]) {
        self.stateName = (SimiFormText *)[self.form addField:@"Text"
                                                                 config:@{
                                                                          @"name": @"region",
                                                                          @"title": SCLocalizedString(@"State"),
                                                                          @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"region_id_show"] isEqualToString:@"req"]]
                                                                          }];
        self.stateId = (SimiFormSelect *)[self.form addField:@"Select"
                                                                 config:@{
                                                                          @"name": @"region_id",
                                                                          @"title": SCLocalizedString(@"State"),
                                                                          @"option_type": SimiFormOptionNavigation,
                                                                          @"nav_controller": self.navigationController,
                                                                          @"value_field": @"state_id",
                                                                          @"label_field": @"state_name",
                                                                          @"index_titles": @1,
                                                                          @"searchable": @1,
                                                                          @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"region_id_show"] isEqualToString:@"req"]]
                                                                          }];
    }
    
    
    if ([self hasField:[hiddenAddressModel valueForKey:@"zipcode_show"]]) {
        [self.form addField:@"Text"
                config:@{
                         @"name": @"postcode",
                         @"title": SCLocalizedString(@"Post/Zip Code"),
                         @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"zipcode_show"] isEqualToString:@"req"]]
                         }];
    }
    
    if ([self hasField:[hiddenAddressModel valueForKey:@"telephone_show"]]) {
        [self.form addField:@"Phone"
                config:@{
                         @"name": @"telephone",
                         @"title": SCLocalizedString(@"Phone"),
                         @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"telephone_show"] isEqualToString:@"req"]]
                         }];
    }
    
    if ([self hasField:[hiddenAddressModel valueForKey:@"fax_show"]]) {
        [self.form addField:@"Text"
                config:@{
                         @"name" : @"fax",
                         @"title": SCLocalizedString(@"Fax"),
                         @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"fax_show"] isEqualToString:@"req"]]
                         }];
    }
    if (![SimiGlobalVar sharedInstance].isLogin) {
        if ([self hasField:[hiddenAddressModel valueForKey:@"dob_show"]]) {
            [self.form addField:@"Date"
                    config:@{
                             @"name": @"dob",
                             @"title": SCLocalizedString(@"Date of Birth"),
                             @"date_type": @"date",
                             @"date_format": @"yyyy-MM-dd",
                             @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"dob_show"] isEqualToString:@"req"]]
                             }];
        }
        
        NSMutableArray *genderValues = [[NSMutableArray alloc]initWithArray:[[GLOBALVAR.storeView.customer valueForKey:@"address_option"]valueForKey:@"gender_value"]];
        
        if (genderValues.count) {
            NSMutableArray *source = [NSMutableArray new];
            for(NSDictionary *gender in genderValues){
                if([gender objectForKey:@"label"] && [gender objectForKey:@"value"]){
                    [source addObject:@{@"label":SCLocalizedString([gender objectForKey:@"label"]),@"value":[gender objectForKey:@"value"]}];
                }
            }
            if ([self hasField:[hiddenAddressModel valueForKey:@"gender_show"]]) {
                [self.form addField:@"Select"
                        config:@{
                                 @"name": @"gender",
                                 @"title": SCLocalizedString(@"Gender"),
                                 @"required": [NSNumber numberWithBool:[[hiddenAddressModel valueForKey:@"gender_show"] isEqualToString:@"req"]],
                                 @"source": source
                                 }];
            }
        }
        
        if (![[GLOBALVAR taxvatShow] isEqualToString:@""]) {
            [self.form addField:@"Text"
                    config:@{
                             @"name": @"taxvat",
                             @"title": SCLocalizedString(@"Tax/VAT number"),
                             @"required": [NSNumber numberWithBool:[[GLOBALVAR taxvatShow] isEqualToString:@"req"]]
                             }];
        }
    }
    
    
    if (self.isNewCustomer) {
        [self.form addField:@"Password"
                config:@{
                         @"name": @"customer_password",
                         @"title": SCLocalizedString(@"Password"),
                         @"required": @1
                         }];
        [self.form addField:@"Password"
                config:@{
                         @"name": @"confirm_password",
                         @"title": SCLocalizedString(@"Confirm Password"),
                         @"required": @1
                         }];
    }
    
    if ([[hiddenAddressModel valueForKey:@"custom_fields"] isKindOfClass:[NSArray class]]) {
        NSArray *customFields = [hiddenAddressModel valueForKey:@"custom_fields"];
        for (int i = 0; i < customFields.count; i++) {
            NSDictionary *fieldDict = [customFields objectAtIndex:i];
            NSString *fieldType = [NSString stringWithFormat:@"%@",[fieldDict valueForKey:@"type"]];
            NSString *fieldTitle = [NSString stringWithFormat:@"%@",[fieldDict valueForKey:@"title"]];
            NSNumber *fieldRequire = [NSNumber numberWithBool:NO];
            if ([[fieldDict valueForKey:@"required"] isEqualToString:@"req"]) {
                fieldRequire = [NSNumber numberWithBool:YES];
            }
            NSString *fieldName = [NSString stringWithFormat:@"%@",[fieldDict valueForKey:@"code"]];
            int fieldPossition = [[fieldDict valueForKey:@"position"]intValue] *100 - 99;
            if ([fieldType isEqualToString:@"text"]) {
                [self.form addField:@"Text"
                        config:@{
                                 @"name": fieldName,
                                 @"title": SCLocalizedString(fieldTitle),
                                 @"sort_order": [NSNumber numberWithInt:fieldPossition],
                                 @"required": fieldRequire
                                 }];
            }else if ([fieldType isEqualToString:@"number"]) {
                [self.form addField:@"Number"
                        config:@{
                                 @"name": fieldName,
                                 @"title": SCLocalizedString(fieldTitle),
                                 @"sort_order": [NSNumber numberWithInt:fieldPossition],
                                 @"required": fieldRequire
                                 }];
            }else if ([fieldType isEqualToString:@"single_option"]) {
                NSArray *optionArray = [fieldDict valueForKey:@"option_array"];
                NSMutableArray *sources = [NSMutableArray new];
                if ([optionArray count] > 0) {
                    if ([[optionArray objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
                        for (NSDictionary *value in optionArray){
                            [sources addObject:@{@"value":[value objectForKey:@"value"],@"label":[value objectForKey:@"label"]}];
                        }
                    }else{
                        for (NSString *value in optionArray){
                            [sources addObject:@{@"value":value,@"label":value}];
                        }
                    }
                }
                [self.form addField:@"Select"
                        config:@{
                                 @"name": fieldName,
                                 @"title": SCLocalizedString(fieldTitle),
                                 @"sort_order": [NSNumber numberWithInt:fieldPossition],
                                 @"source": sources,
                                 @"required": fieldRequire
                                 }];
            }
        }
    }
    if (self.address == nil) {
        self.address = [[SimiAddressModel alloc] init];
        [self.address setValue:@"" forKey:@"address_id"];
    } else {
        // Prepare Data for Form
        //       DOB
        //       state_id
        if ([self.address objectForKey:@"region_id"] && [[self.address objectForKey:@"region_id"] isKindOfClass:[NSNumber class]]) {
            [self.address setValue:[[self.address objectForKey:@"region_id"] stringValue] forKey:@"region_id"];
        }
        // Add data to form
        self.navigationItem.title = SCLocalizedString(@"Edit Address");
        [self.form setFormData:self.address.modelData];
    }
}
@end

@implementation SCHiddenAddressWorker
- (instancetype)init{
    self = [super init];
    if (self) {
        if ([GLOBALVAR.storeView.customer valueForKey:@"address_fields_config"]) {
            SimiModel *hiddenAddressModel = [[SimiModel alloc]initWithModelData:[GLOBALVAR.storeView.customer valueForKey:@"address_fields_config"]];
            if (hiddenAddressModel.count > 0) {
                self.available = YES;
                [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showNewAddress:) name:SIMI_SHOWNEWADDRESSSCREEN object:nil];
            }
        }
    }
    return self;
}

- (void)showNewAddress:(NSNotification*)noti{
    SCAppController *appController = noti.object;
    appController.isDiscontinue = YES;
    SCConfigureNewAddressViewController *newAddressViewController = [SCConfigureNewAddressViewController new];
    NSDictionary *params = noti.userInfo;
    UINavigationController *navi = [params valueForKey:KEYEVENT.APPCONTROLLER.navigation_controller];
    if ([params valueForKey:KEYEVENT.APPCONTROLLER.delegate]) {
        newAddressViewController.delegate = [params valueForKey:KEYEVENT.APPCONTROLLER.delegate];
    }
    if ([params valueForKey:KEYEVENT.NEWADDRESSVIEWCONTROLLER.is_editing]) {
        newAddressViewController.isEditing = [[params valueForKey:KEYEVENT.NEWADDRESSVIEWCONTROLLER.is_editing]boolValue];
    }
    if ([params valueForKey:KEYEVENT.NEWADDRESSVIEWCONTROLLER.address_model]) {
        newAddressViewController.address = [params valueForKey:KEYEVENT.NEWADDRESSVIEWCONTROLLER.address_model];
    }
    if ([params valueForKey:KEYEVENT.NEWADDRESSVIEWCONTROLLER.is_newcustomer]) {
        newAddressViewController.isNewCustomer = [[params valueForKey:KEYEVENT.NEWADDRESSVIEWCONTROLLER.is_newcustomer]boolValue];
    }
    if ([params valueForKey:KEYEVENT.NEWADDRESSVIEWCONTROLLER.open_newaddress_from]) {
        newAddressViewController.positionOpenNewAddress = [[params valueForKey:KEYEVENT.NEWADDRESSVIEWCONTROLLER.open_newaddress_from]integerValue];
    }
    if ([[params valueForKey:KEYEVENT.APPCONTROLLER.is_showpopover]boolValue]) {
        UINavigationController *newAddressNavi = [[UINavigationController alloc]initWithRootViewController:newAddressViewController];
        newAddressNavi.navigationBar.tintColor = THEME_NAVIGATION_ICON_COLOR;
        newAddressNavi.navigationBar.barTintColor = THEME_COLOR;
        
        if (SIMI_SYSTEM_IOS >= 8) {
            newAddressNavi.modalPresentationStyle = UIModalPresentationPopover;
            UIPopoverPresentationController *popover = newAddressNavi.popoverPresentationController;
            popover.sourceRect = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1);
            popover.sourceView = [UIApplication sharedApplication].delegate.window.rootViewController.view;;
            if ([params valueForKey:KEYEVENT.APPCONTROLLER.delegate]) {
                popover.delegate = [params valueForKey:KEYEVENT.APPCONTROLLER.delegate];
            }
            popover.permittedArrowDirections = 0;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:newAddressNavi animated:YES completion:nil];
            });
        }
    }else{
        [navi pushViewController:newAddressViewController animated:YES];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
