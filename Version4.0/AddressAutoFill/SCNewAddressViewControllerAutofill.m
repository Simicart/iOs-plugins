//
//  SCNewAddressViewController.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/19/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SCNewAddressViewControllerAutofill.h"
#import <SimiCartBundle/SimiGlobalVar.h>

@implementation SCNewAddressViewControllerAutofill

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidCreateAddressAutofill" object:nil];
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    SCNewAddressViewController *newAddressView = [noti.userInfo valueForKey:@"newAddressView"];
    SCNewAddressViewControllerAutofillObject *delegate = [SCNewAddressViewControllerAutofillObject new];
    delegate.anAddressView = newAddressView;
    newAddressView.tableViewAddress.dataSource = delegate;
    newAddressView.tableViewAddress.delegate = delegate;
    [newAddressView.tableViewAddress reloadData];
    newAddressView.simiObjectIdentifier = delegate;
}

@end

@implementation SCNewAddressViewControllerAutofillObject
@synthesize anAddressView, autofill;

- (id)init{
    self = [super init];
    if (self) {
        autofill = [[AddressAutofill alloc]init];
        autofill.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLocationPermisionRequest:) name:@"AskForLocationPermision" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AskForLocationPermision" object:nil];
}

-(void)didReceiveLocationPermisionRequest:(NSNotification*) noti
{
    [autofill locationPermision];
}

-(void)addressAutofill
{
    [anAddressView startLoadingData];
    [autofill start];
}

-(void)autofillUpdateAddressTable:(CLPlacemark*)place
{
    if (place != nil)
    {
        if (anAddressView.countries != nil && [place.addressDictionary valueForKey:@"CountryCode"]) {
            for (SimiAddressModel *country in anAddressView.countries) {
                if ([[country valueForKey:@"country_code"] isEqualToString:[place.addressDictionary valueForKey:@"CountryCode"]]) {
                    [anAddressView.form setValue:[country valueForKey:@"country_code"] forKey:@"country_code"];
                    [anAddressView.form setValue:[country valueForKey:@"country_name"] forKey:@"country_name"];
                    anAddressView.states = [country valueForKey:@"states"];
                    if (anAddressView.stateId == nil) {
                        // NOTHING
                    } else if ([anAddressView.states isKindOfClass:[NSNull class]] || anAddressView.states.count == 0) {
                        if ([anAddressView.form.fields indexOfObject:anAddressView.stateId] != NSNotFound) {
                            [anAddressView.form.fields removeObject:anAddressView.stateId];
                            [anAddressView.form.fields addObject:anAddressView.stateName];
                        }
                        if ([place.addressDictionary valueForKey:@"State"]) {
                            [anAddressView.form setValue:[place.addressDictionary valueForKey:@"State"] forKey:@"state_name"];
                        } else {
                            [anAddressView.form removeObjectForKey:@"state_name"];
                        }
                    } else {
                        if ([anAddressView.form.fields indexOfObject:anAddressView.stateName] != NSNotFound) {
                            [anAddressView.form.fields removeObject:anAddressView.stateName];
                            [anAddressView.form.fields addObject:anAddressView.stateId];
                        }
                        [anAddressView.stateId setDataSource:anAddressView.states];
                        if ([place.addressDictionary valueForKey:@"State"]) {
                            BOOL stateExisted = NO;
                            for (SimiAddressModel *state in anAddressView.states) {
                                if ([[state objectForKey:@"state_name"] isEqualToString:[place.addressDictionary valueForKey:@"State"]] || [[state objectForKey:@"state_code"] isEqualToString:[place.addressDictionary valueForKey:@"State"]]) {
                                    [anAddressView.form setValue:[state objectForKey:@"state_id"] forKey:@"state_id"];
                                    [anAddressView.form setValue:[state objectForKey:@"state_code"] forKey:@"state_code"];
                                    [anAddressView.form setValue:[state objectForKey:@"state_name"] forKey:@"state_name"];
                                    stateExisted = YES;
                                    break;
                                }
                            }
                            if (!stateExisted) {
                                [anAddressView.form setValue:[place.addressDictionary valueForKey:@"State"] forKey:@"state_name"];
                                [anAddressView.form removeObjectForKey:@"state_id"];
                            }
                        } else {
                            [anAddressView.form removeObjectForKey:@"state_id"];
                        }
                    }
                    [anAddressView.form sortFormFields];
                    break;
                }
            }
        }
        
        if ([place.addressDictionary valueForKey:@"City"]) {
            [anAddressView.form setValue:[place.addressDictionary valueForKey:@"City"] forKey:@"city"];
        }
        
        NSString *street = @"";
        if ([place.addressDictionary valueForKey:@"Street"]) {
            street = [place.addressDictionary valueForKey:@"Street"];
        }
        if ([place.addressDictionary valueForKey:@"SubLocality"]) {
            if(street.length > 0) {
                street = [street stringByAppendingString:@", "];
            }
            street = [street stringByAppendingString:[place.addressDictionary valueForKey:@"SubLocality"]];
        }
        if ([place.addressDictionary valueForKey:@"SubAdministrativeArea"]) {
            if(street.length > 0) {
                street = [street stringByAppendingString:@", "];
            }
            street = [street stringByAppendingString:[place.addressDictionary valueForKey:@"SubAdministrativeArea"]];
        }
        [anAddressView.form setValue:street forKey:@"street"];
        
        if (place.postalCode && place.postalCode.length > 0) {
            [anAddressView.form setValue:place.postalCode forKey:@"zip"];
        }
    }
    
    [anAddressView.tableViewAddress reloadData];
    [anAddressView stopLoadingData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //    return isNewCustomer ? 2 : 1;
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return [anAddressView.form tableView:tableView numberOfRowsInSection:0];
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return [anAddressView.form tableView:tableView titleForHeaderInSection:0];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section) {
        return [anAddressView.form tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *newAddressCellIdentifier = @"NewAddressCellAutofillIdentifier";
        static NSString *profileTextCellIdentifier = @"AddressTextCellAutofillIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:profileTextCellIdentifier];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newAddressCellIdentifier];
        cell.imageView.image = [UIImage imageNamed:@"addressautofill"];
        cell.textLabel.text = SCLocalizedString(@"Use Your Current Location");
        return cell;
    } else {
        return [anAddressView.form tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self addressAutofill];
    } else {
        [anAddressView.form tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark Scroll view delegate
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
//    [anAddressView.form scrollViewWillBeginDecelerating:scrollView];
}

@end
