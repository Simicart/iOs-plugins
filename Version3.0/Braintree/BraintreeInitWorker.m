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

@implementation BraintreeInitWorker
{
    SimiViewController *currentVC;
    NSString* clientToken;
    NSDictionary* paymentMethod;
    NSDictionary* shippingMethod;
}
-(instancetype) init{
    if(self == [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationDidFinishLaunching" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationOpenURL" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidSelectPaymentMethod" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidPlaceOrder-After" object:nil];
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
    }else if([noti.name isEqualToString:@"DidSelectPaymentMethod"]){
        
    }else if([noti.name isEqualToString:@"DidPlaceOrder-After"]){
        paymentMethod = [noti.userInfo objectForKey:@"payment"];
        shippingMethod = [noti.userInfo objectForKey:@"shipping"];
        if([[[[noti.userInfo valueForKey:@"data"] valueForKey:@"payment_method"] uppercaseString] isEqualToString:@"SIMIBRAINTREE"]){
            currentVC = [noti.userInfo valueForKey:@"controller"];
            BTPaymentViewController* btPaymentVC = [[BTPaymentViewController alloc] init];
            btPaymentVC.payment = paymentMethod;
            btPaymentVC.shippingMethod = shippingMethod;
            btPaymentVC.order = noti.object;
            [currentVC.navigationController pushViewController:btPaymentVC animated:YES];
        }
    }
}

@end
