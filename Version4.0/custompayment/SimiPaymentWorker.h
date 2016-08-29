//
//  SimiAvenueWorker.h
//  SimiCartPluginFW
//
//  Created by biga on 11/6/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomPaymentModelCollection.h"
#import "SimiPaymentWebView.h"

@interface SimiPaymentWorker : SimiViewController<UIWebViewDelegate,UIAlertViewDelegate>
@property (strong, nonatomic) CustomPaymentModelCollection* customPayment;

@end
