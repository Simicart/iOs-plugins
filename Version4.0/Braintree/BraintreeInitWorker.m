//
//  BraintreeInitWorker.m
//  SimiCartPluginFW
//
//  Created by Axe on 12/8/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import "BraintreeInitWorker.h"
#import "BTPaymentViewController.h"
#import <SimiCartBundle/SimiOrderModel.h>

#define DidSelectPaymentMethod @"DidSelectPaymentMethod"
#define DidPlaceOrderAfter @"DidPlaceOrder-After"
#define DidPlaceOrderBefore @"SCOrderViewController-BeforePlaceOrder"
#define BRAINTREE_PAYMENT_METHOD @"simibraintree"

@implementation BraintreeInitWorker
{
    SimiViewController *currentVC;
    NSString* clientToken;
    SimiOrderModel* originalOrder;
}
-(instancetype) init{
    if(self == [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationDidFinishLaunching" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationOpenURL" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidSelectPaymentMethod object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidPlaceOrderAfter object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidPlaceOrderBefore object:nil];
        [BTAppSwitch setReturnURLScheme:[NSString stringWithFormat:@"%@.payments",[NSBundle mainBundle].bundleIdentifier]];
    }
    return self;
}

-(void) didReceiveNotification:(NSNotification *)noti{
    if([noti.name isEqualToString:@"ApplicationDidFinishLaunching"]){
    }else if([noti.name isEqualToString:@"ApplicationOpenURL"]){
        NSURL *url = [noti.userInfo valueForKey:@"url"];
        NSString* sourceApplication = [noti.userInfo valueForKey:@"source_application"];
        NSNumber* number = noti.object;
        if ([url.scheme localizedCaseInsensitiveCompare:[NSString stringWithFormat:@"%@.payments",[NSBundle mainBundle].bundleIdentifier]] == NSOrderedSame) {
            number = [NSNumber numberWithBool:[BTAppSwitch handleOpenURL:url sourceApplication:sourceApplication]];
        }
    }else if([noti.name isEqualToString:DidSelectPaymentMethod]){
        
    }else if([noti.name isEqualToString:DidPlaceOrderAfter]){
        NSDictionary* payment = [noti.userInfo objectForKey:@"payment"];
        NSDictionary* shipping = [noti.userInfo objectForKey:@"shipping"];
        if([[[[noti.userInfo valueForKey:@"data"] valueForKey:@"payment_method"] lowercaseString] isEqualToString:BRAINTREE_PAYMENT_METHOD]){
            currentVC = [noti.userInfo valueForKey:@"controller"];
            BTPaymentViewController* btPaymentVC = [[BTPaymentViewController alloc] init];
            btPaymentVC.payment = payment;
            btPaymentVC.shipping = shipping;
            SimiOrderModel* orderModel = [[SimiOrderModel alloc] init];
            [orderModel addEntriesFromDictionary:originalOrder];
            [orderModel addEntriesFromDictionary:noti.object];
            btPaymentVC.order = orderModel;
            if(PHONEDEVICE)
                [currentVC.navigationController pushViewController:btPaymentVC animated:YES];
            else if(PADDEVICE){
                UINavigationController* navi = [[UINavigationController alloc] initWithRootViewController:btPaymentVC];
                navi.modalPresentationStyle = UIModalPresentationPopover;
                navi.modalInPopover = YES;
                UIPopoverPresentationController* popoverVC = navi.popoverPresentationController;
                popoverVC.sourceView = currentVC.view;
                popoverVC.sourceRect = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1);
                [popoverVC setPermittedArrowDirections:0];
                [currentVC presentViewController:navi animated:YES completion:nil];
            }
        }
    }else if([noti.name isEqualToString:DidPlaceOrderBefore]){
        originalOrder = [[SimiOrderModel alloc] initWithDictionary:[noti.userInfo objectForKey:@"order"]];
    }
}

@end
