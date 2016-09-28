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


// actually like the parrent but without the post data to server
- (void)saveAddressPaypalRewrite{
    if (self.isNewCustomer) {
        NSString *password = [self.form objectForKey:@"customer_password"];
        NSString *confirm  = [self.form objectForKey:@"confirm_password"];
        if (![password isEqualToString:confirm]) {
            [self showAlertWithTitle:@"Error" message:@"Password and Confirm password don't match."];
            return;
        }
    }
    // Valid Form
    if (![self.form isDataValid]) {
        [self showAlertWithTitle:@"Warning" message:@"Please select all (*) fields"];
        return;
    }
    [self.address removeAllObjects];
    [self.address addData:self.form];
    if ([self.form objectForKey:@"name"]) {
        [self.address setValue:[[self.form objectForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"name"];
    }
    [self.address saveToLocal];
    [self.delegate didSaveAddress:self.address];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
