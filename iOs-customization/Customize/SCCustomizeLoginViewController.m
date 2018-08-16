//
//  SCCustomizeLoginViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 3/26/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCCustomizeLoginViewController.h"
#import <SimiCartBundle/SCAppController.h>

@interface SCCustomizeLoginViewController ()

@end

@implementation SCCustomizeLoginViewController

- (void)didLogin:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    if (responder.status == SUCCESS) {
        if ([noti.name isEqualToString:Simi_DidLogin]) {
            SimiCustomerModel *tempCustomer = noti.object;
            [self trackingWithProperties:@{@"action":@"login_success",@"customer_email":tempCustomer.email}];
            if (self.isPresented) {
                [self dismissViewControllerAnimated:YES completion:^{
                    if(self.isLoginInCheckout){
                        [[NSNotificationCenter defaultCenter] postNotificationName:SCCartViewController_ContinueCheckOutWithExistCustomer object:nil];
                    }else{
                        [GLOBALVAR.currentlyNavigationController popToRootViewControllerAnimated:NO];
                        [[SCAppController sharedInstance] openProductWithNavigationController:GLOBALVAR.currentlyNavigationController productId:self.product.entityId moreParams:nil];
                    }
                }];
            }else{
                if(self.isLoginInCheckout){
                    [[NSNotificationCenter defaultCenter] postNotificationName:SCCartViewController_ContinueCheckOutWithExistCustomer object:nil];
                }else{
                    [self.navigationController popToRootViewControllerAnimated:NO];
                    [[SCAppController sharedInstance] openProductWithNavigationController:GLOBALVAR.currentlyNavigationController productId:self.product.entityId moreParams:nil];
                }
            }
        }
    }else{
        self.textFieldPassword.text = @"";
        [self showAlertWithTitle:@"" message:responder.message];
    }
    [self stopLoadingData];
}

@end
