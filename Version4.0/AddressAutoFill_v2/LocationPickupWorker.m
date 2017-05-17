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

@implementation LocationPickupWorker{
    SCNewAddressViewController *newAddressViewController;
    SimiAddressAutofillModel *addressModel;
    UITableViewController *_resultsController;
    GMSAutocompleteTableDataSource *_tableDataSource;
    SimiFormText* streetForm;
}
- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidCreateAddressAutofill" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SimiFormMapAPI_DidGetAddress" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(formFieldDataChanged:) name:SimiFormFieldDataChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newAddressViewDidLoadBefore:) name:@"SCNewAddressViewController-ViewDidLoadBefore" object:nil];
    }
    [GMSPlacesClient provideAPIKey:@"AIzaSyAB9r0kEvYZF-4LFKD4myDXNSSWwkw2bBA"];
    [GMSServices provideAPIKey:@"AIzaSyAB9r0kEvYZF-4LFKD4myDXNSSWwkw2bBA"];
    // Setup the results view controller.
    _tableDataSource = [[GMSAutocompleteTableDataSource alloc] init];
    _tableDataSource.delegate = self;
    _resultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    _resultsController.view.alpha = 1;
    _resultsController.view.backgroundColor = [UIColor whiteColor];
    _resultsController.tableView.delegate = _tableDataSource;
    _resultsController.tableView.dataSource = _tableDataSource;
    return self;
}

-(void) newAddressViewDidLoadBefore:(NSNotification*) noti{
    newAddressViewController = noti.object;
    streetForm = (SimiFormText*)[newAddressViewController.form getFieldByName:@"street"];
    streetForm.inputText.delegate = self;
    [streetForm.inputText addTarget:self
                             action:@selector(textFieldDidChange:)
                   forControlEvents:UIControlEventEditingChanged];
}

- (void)getAddressWithParams:(NSDictionary*)params
{
    if (addressModel == nil) {
        addressModel = [SimiAddressAutofillModel new];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetAddress:) name:@"DidGetAddress" object:addressModel];
    [addressModel getAddressWithParams:params];
    [newAddressViewController startLoadingData];
}

- (void)didGetAddress:(NSNotification*)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        if ([addressModel valueForKey:@"country_id"]) {
            [newAddressViewController.country updateFormData:[NSString stringWithFormat:@"%@",[addressModel valueForKey:@"country_id"]]];
        }
        if ([addressModel valueForKey:@"country_name"]) {
            [newAddressViewController.form setValue:[addressModel valueForKey:@"country_name"] forKey:@"country_name"];
        }
        if ([addressModel valueForKey:@"region"]) {
            [newAddressViewController.form setValue:[addressModel valueForKey:@"region"] forKey:@"region"];
        }
        if ([addressModel valueForKey:@"region_id"]) {
            NSString *regionID = [addressModel valueForKey:@"region_id"];
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
        if ([addressModel valueForKey:@"city"]) {
            [newAddressViewController.form setValue:[addressModel valueForKey:@"city"] forKey:@"city"];
        }
        if ([addressModel valueForKey:@"street"]) {
            [newAddressViewController.form setValue:[addressModel valueForKey:@"street"] forKey:@"street"];
        }
        if ([addressModel valueForKey:@"postcode"]) {
            [newAddressViewController.form setValue:[addressModel valueForKey:@"postcode"] forKey:@"postcode"];
        }else{
            [newAddressViewController.form setValue:@"" forKey:@"postcode"];
        }
        [newAddressViewController.form sortFormFields];
        [newAddressViewController.tableViewAddress reloadData];
    }
    [self removeObserverForNotification:noti];
    [newAddressViewController stopLoadingData];
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"DidCreateAddressAutofill"]) {
        newAddressViewController = [noti.userInfo valueForKey:@"newAddressView"];
        SimiFormAbstract* mapForm = [newAddressViewController.form getFieldByName:@"latlng"];
        if(!mapForm){
            mapForm = [newAddressViewController.form addField:@"MapAPI" config:@{@"name": @"latlng",
                                                                                 @"title": SCLocalizedString(@"Country"),
                                                                                 @"sort_order":@10000,
                                                                                 @"height":[NSNumber numberWithFloat:[SimiGlobalVar scaleValue:250]]}];
        }
    }else if([noti.name isEqualToString:@"SimiFormMapAPI_DidGetAddress"])
    {
        NSDictionary *params = noti.object;
        [self getAddressWithParams:params];
    }
}

-(void) formFieldDataChanged:(NSNotification*) noti{
    if([((SimiFormAbstract*)noti.object).simiObjectName isEqualToString:@"street"]){
//        [newAddressViewController addChildViewController:_resultsController];
//        [streetForm.superview addSubview:_resultsController.view];
//        CGRect frame = _resultsController.view.frame;
//        frame.origin.y = 50;
//        _resultsController.view.frame = frame;
//        [streetForm.superview layoutIfNeeded];
//        
//        // Reload the data.
//        [_resultsController.tableView reloadData];
//        [_resultsController didMoveToParentViewController:newAddressViewController];
    }
}


#pragma mark - GMSAutocompleteTableDataSourceDelegate
- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource didAutocompleteWithPlace:(GMSPlace *)place {
    [streetForm.inputText resignFirstResponder];
//    [self autocompleteDidSelectPlace:place];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[place description]];
    if (place.attributions) {
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]];
        [text appendAttributedString:place.attributions];
    }
    NSDictionary *params = @{@"longitude":[NSString stringWithFormat:@"%f",place.coordinate.longitude], @"latitude":[NSString stringWithFormat:@"%f",place.coordinate.latitude]};
    [self getAddressWithParams:params];
}

- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource
didFailAutocompleteWithError:(NSError *)error {
    [streetForm.inputText resignFirstResponder];
//    [self autocompleteDidFail:error];
    streetForm.inputText.text = @"";
}

- (void)didRequestAutocompletePredictionsForTableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [_resultsController.tableView reloadData];
}

- (void)didUpdateAutocompletePredictionsForTableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_resultsController.tableView reloadData];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    // Add the results controller.
//    _resultsController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [newAddressViewController addChildViewController:_resultsController];
    [newAddressViewController.view addSubview:_resultsController.view];
    [newAddressViewController.tableViewAddress setContentOffset:CGPointMake(0, 250)];
    CGRect frame = _resultsController.view.frame;
    frame.origin.y = 100;
    _resultsController.view.frame = frame;
//    [streetForm.superview layoutIfNeeded];
    
    // Reload the data.
    [_resultsController.tableView reloadData];
    [_resultsController didMoveToParentViewController:newAddressViewController];
    
//    _resultsController.view.alpha = 0.0f;
    // Animate in the results.
//    [UIView animateWithDuration:0.5
//                     animations:^{
//                         _resultsController.view.alpha = 1.0f;
//                     }
//                     completion:^(BOOL finished) {
//                     }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [_resultsController willMoveToParentViewController:nil];
    [_resultsController.view removeFromSuperview];
    [_resultsController removeFromParentViewController];
//    [UIView animateWithDuration:0.5
//                     animations:^{
//                         _resultsController.view.alpha = 0.0f;
//                     }
//                     completion:^(BOOL finished) {
//                     }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [textField resignFirstResponder];
    textField.text = @"";
    return NO;
}

#pragma mark - Private Methods

- (void)textFieldDidChange:(UITextField *)textField {
    [_tableDataSource sourceTextHasChanged:textField.text];
}

@end
