//
//  SimiIpayViewController.h
//  SimiCartPluginFW
//
//  Created by KingRetina on 2/8/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SimiCartBundle/SimiViewController.h>
#import "Ipay.h"
#import "IpayPayment.h"
#import "SimiOrderModel+Ipay.h"

@interface SimiIpayViewController : SimiViewController<PaymentResultDelegate>{
    NSURL *url;
    UIBarButtonItem *backItem;
}


@property (strong, nonatomic) Ipay *paymentsdk;
@property (strong, nonatomic) SimiModel *payment;
@property (strong, nonatomic) SimiOrderModel *order;

@end
