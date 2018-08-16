//
//  SCCustomizeRegisterViewController.m
//  SimiCartPluginFW
//
//  Created by Liam on 3/12/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCCustomizeRegisterViewController.h"

@interface SCCustomizeRegisterViewController ()

@end

@implementation SCCustomizeRegisterViewController
- (void)addFieldsToFormBlock{
    [self.form addField:@"Text"
            config:@{
                     @"name" : @"company_name",
                     @"title": SCLocalizedString(@"Company"),
                     @"required":@1
                     }];
    [self.form addField:@"Text"
                 config:@{
                          @"name" : @"abn",
                          @"title": SCLocalizedString(@"ABN"),
                          @"required":@1
                          }];
    [self.form addField:@"Phone"
                 config:@{
                          @"name" : @"telephone",
                          @"title": SCLocalizedString(@"Telephone"),
                          @"required":@1
                          }];
    [self.form addField:@"Phone"
                 config:@{
                          @"name" : @"mobile",
                          @"title": SCLocalizedString(@"Mobile"),
                          @"required":@1
                          }];
    [self.form addField:@"Name"
                 config:@{
                          @"name" : @"firstname",
                          @"title": SCLocalizedString(@"First Name"),
                          @"required":@1
                          }];
    [self.form addField:@"Name"
                 config:@{
                          @"name" : @"lastname",
                          @"title": SCLocalizedString(@"Last Name"),
                          @"required":@1
                          }];
    [self.form addField:@"Number"
                 config:@{
                          @"name" : @"number_of_physios",
                          @"title": SCLocalizedString(@"How many Therapists do you have?"),
                          @"required":@1
                          }];
    [self.form addField:@"Text"
                 config:@{
                          @"name" : @"street",
                          @"title": SCLocalizedString(@"Street Address"),
                          @"required":@1
                          }];
    [self.form addField:@"Text"
                 config:@{
                          @"name" : @"city",
                          @"title": SCLocalizedString(@"City"),
                          @"required":@1
                          }];
    self.stateName = (SimiFormText *)[self.form addField:@"Text"
                                                  config:@{
                                                           @"name": @"region",
                                                           @"title": SCLocalizedString(@"State"),
                                                           }];
    NSString *stateIDName = @"region_id";
    self.stateId = (SimiFormSelect *)[self.form addField:@"Select"
                                                  config:@{
                                                           @"name": stateIDName,
                                                           @"title": SCLocalizedString(@"State"),
                                                           @"option_type": SimiFormOptionNavigation,
                                                           @"nav_controller": self.navigationController,
                                                           @"value_field": @"state_id",
                                                           @"label_field": @"state_name",
                                                           @"index_titles": @1,
                                                           @"searchable": @1,
                                                           @"required": @1
                                                           }];
    [self.form addField:@"Text"
                 config:@{
                          @"name": @"postcode",
                          @"title": SCLocalizedString(@"Zip Code"),
                          @"required": @1
                          }];
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
                                                           @"required": @1
                                                           }];
    [self.form addField:@"Email"
                 config:@{
                          @"name": @"email",
                          @"title": SCLocalizedString(@"Email Address"),
                          @"required": @1
                          }];
    [self.form addField:@"Date"
                 config:@{
                          @"name": @"dob",
                          @"title": SCLocalizedString(@"Date of Birth"),
                          @"date_type": @"date",
                          @"date_format": @"yyyy-MM-dd",
                          @"required": @0
                          }];
    [self.form addField:@"Password"
            config:@{
                     @"name": @"password",
                     @"title": SCLocalizedString(@"Password"),
                     @"required": @1
                     }];
    [self.form addField:@"Password"
            config:@{
                     @"name": @"confirmation",
                     @"title": SCLocalizedString(@"Confirm Password"),
                     @"required": @1
                     }];
    [self.form addField:@"Text"
                 config:@{
                          @"name": @"customer_comment",
                          @"title": SCLocalizedString(@"Anything in particular you were looking at?"),
                          @"required": @0
                          }];
    [self.form addField:@"Checkbox"
                 config:@{
                          @"name": @"is_subscribed",
                          @"title": SCLocalizedString(@"Sign Up for Newsletter"),
                          @"required": @0
                          }];
}

- (void)didClickButtonRegister{
    NSString *tfPass = [self.form objectForKey:@"password"];
    NSString *tfConfirm = [self.form objectForKey:@"confirmation"];
    if (![tfPass isEqualToString:tfConfirm]) {
        [self showAlertWithTitle:@"" message:@"Password and Confirm password don't match"];
        return;
    }
    
    NSString *tfEmail = [self.form objectForKey:@"email"];
    if(![SimiGlobalFunction validateEmail:tfEmail]){
        [self showAlertWithTitle:@"" message:@"Check your email and try again"];
        return;
    }
    // Valid Form
    if (![self.form isDataValid]){
        [self showAlertWithTitle:@"" message:@"Please select all (*) fields"];
        return;
    }
    //Set data to customer model
    if (self.customer == nil) {
        self.customer = [[SimiCustomerModel alloc] init];
    }
    [self.customer removeAllObjects];
    [self.customer addData:self.form];
    [self.customer setValue:@"1" forKey:@"create_address"];
    // POST data to server
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRegisterCustomer:) name:Simi_DidRegister object:self.customer];
    [self startLoadingData];
    [self trackingWithProperties:@{@"action":@"clicked_register_button", @"customer_email":tfEmail}];
    [self.customer doRegister];
}

- (void)viewDidLoadAfter{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(formDataChanged:) name:SimiFormDataChangedNotification object:self.form];
    [self.form.fields removeObject:self.stateName];
    [self.form.fields removeObject:self.stateId];
    [self setCountryData];
    [super viewDidLoadAfter];
}

- (void)setCountryData{
    self.countries = GLOBALVAR.storeView.allowedCountries;
    [self.country setDataSource:self.countries];
    for (int i = 0; i < self.countries.count; i++) {
        NSDictionary *country = [self.countries objectAtIndex:i];
        if ([[country valueForKey:@"country_code"] isEqualToString:[GLOBALVAR.storeView.base valueForKey:@"country_code"]]) {
            [self.country addSelected:country];
            if ([[country valueForKey:@"states"] isKindOfClass:[NSArray class]]) {
                self.states = [country valueForKey:@"states"];
            }
            break;
        }
    }
    if(self.stateId && self.stateName){
        if ([self.states isKindOfClass:[NSNull class]] || self.states.count == 0) {
            // Show State Name
            [self.form.fields removeObject:self.stateId];
            [self.form.fields addObject:self.stateName];
        } else {
            // Show State ID
            [self.form.fields removeObject:self.stateName];
            [self.form.fields addObject:self.stateId];
            // Make select fist state
            [self.stateId setDataSource:self.states];
            [self.stateId addSelected:[self.states objectAtIndex:0]];
        }
    }
    [self.form sortFormFields];
    [self.contentTableView reloadData];
}

#pragma mark - self.form Data Change
- (void)formDataChanged:(NSNotification *)note{
    NSString *stateIDName = @"region_id";
    SimiFormAbstract *field = [[note userInfo] objectForKey:@"field"];
    if ([field isEqual:self.country]) {
        // Update State Field
        for (SimiAddressModel *country in self.countries) {
            if ([[country valueForKey:@"country_code"] isEqualToString:[self.form valueForKey:@"country_id"]]) {
                [self.form setValue:[country valueForKey:@"country_name"] forKey:@"country_name"];
                self.states = [country valueForKey:@"states"];
                if (self.stateId == nil) {
                    // NOTHING
                } else if ([self.states isKindOfClass:[NSNull class]] || self.states.count == 0) {
                    if ([self.form.fields indexOfObject:self.stateId] != NSNotFound) {
                        [self.form.fields removeObject:self.stateId];
                        [self.form.fields addObject:self.stateName];
                        [self.form removeObjectForKey:@"region_code"];
                        [self.form removeObjectForKey:@"region"];
                        [self.form removeObjectForKey:@"region_id"];
                    }
                } else {
                    if ([self.form.fields indexOfObject:self.stateName] != NSNotFound) {
                        [self.form.fields removeObject:self.stateName];
                        [self.form.fields addObject:self.stateId];
                    }
                    [self.stateId setDataSource:self.states];
                    [self.stateId addSelected:[self.states objectAtIndex:0]];
                    self.stateId.optionsViewController = nil;
                }
                [self.form sortFormFields];
                break;
            }
        }
        [self.contentTableView reloadData];
    } else if ([field.simiObjectName isEqualToString:@"dob"]) {
        NSArray *dob = [[self.form objectForKey:@"dob"] componentsSeparatedByString:@"-"];
        if ([dob count] > 2) {
            [self.form setValue:[dob objectAtIndex:0] forKey:@"year"];
            [self.form setValue:[dob objectAtIndex:1] forKey:@"month"];
            [self.form setValue:[dob objectAtIndex:2] forKey:@"day"];
        }
    } else if ([field.simiObjectName isEqualToString:stateIDName]) {
        for (NSDictionary *state in self.states) {
            if ([[state objectForKey:@"state_id"] isEqualToString:[self.form objectForKey:stateIDName]]) {
                [self.form setValue:[state objectForKey:@"state_id"] forKey:stateIDName];
                [self.form setValue:[state objectForKey:@"state_name"] forKey:@"region"];
                [self.form setValue:[state objectForKey:@"state_code"] forKey:@"region_code"];
                break;
            }
        }
    }
}
@end
