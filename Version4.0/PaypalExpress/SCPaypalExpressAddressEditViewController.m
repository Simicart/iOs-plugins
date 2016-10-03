//
//  SCPaypalExpressAddressEditViewController.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/22/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SCPaypalExpressAddressEditViewController.h"

@interface SCPaypalExpressAddressEditViewController ()

@end

@implementation SCPaypalExpressAddressEditViewController
- (void)saveAddress{
    if (self.isNewCustomer) {
        NSString *password = [self.form objectForKey:@"customer_password"];
        NSString *confirm  = [self.form objectForKey:@"confirm_password"];
        
        if ([password length] < 6) {
            [self showAlertWithTitle:@"" message:@"Please enter 6 or more characters."];
            return;
        }
        if (![password isEqualToString:confirm]) {
            [self showAlertWithTitle:@"" message:@"Password and Confirm password don't match."];
            return;
        }
    }
    // Valid Form
    if (![self.form isDataValid]) {
        [self showAlertWithTitle:@"" message:@"Please select all (*) fields"];
        return;
    }
    [self.address removeAllObjects];
    [self.address addData:self.form];
    if(SIMI_SYSTEM_IOS >=8.0)
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self.navigationController popViewControllerAnimated:NO];
    [self.delegate didSaveAddress:self.address];
}

@end
