//
//  BraintreeInitWorker.h
//  SimiCartPluginFW
//
//  Created by Axe on 12/8/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//
@import PassKit;
#import <Foundation/Foundation.h>
#import "BraintreeCore.h"
#import "BraintreeDropIn.h"
#import "BraintreeApplePay.h"

@interface BraintreeInitWorker : NSObject<PKPaymentAuthorizationViewControllerDelegate,BTViewControllerPresentingDelegate,BTAppSwitchDelegate, UIAlertViewDelegate>

@end
