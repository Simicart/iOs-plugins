//
//  SCWishlistModelCollection.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 11/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import "SCPaypalExpressAPI.h"
static NSString *const SCPaypalExpress_DidStartPaypalExpress = @"SCPaypalExpress_DidStartPaypalExpress";
static NSString *const SCPaypalExpress_DidGetPaypalAddressInformation = @"SCPaypalExpress_DidGetPaypalAddressInformation";
static NSString *const SCPaypalExpress_PaypalExpressDidPlaceOrder = @"SCPaypalExpress_PaypalExpressDidPlaceOrder";
static NSString *const SCPaypalExpress_DidUpdatePaypalCheckoutAddress = @"SCPaypalExpress_DidUpdatePaypalCheckoutAddress";
static NSString *const SCPaypalExpress_DidGetPaypalCheckoutShippingMethods = @"SCPaypalExpress_DidGetPaypalCheckoutShippingMethods";
static NSString *const SCPaypalExpress_DidCompleteCheckOutWithPaypalExpress = @"SCPaypalExpress_DidCompleteCheckOutWithPaypalExpress";

@interface SCPaypalExpressModel: SimiModel


/*
 Notification name: DidStartPaypalExpress
 */
- (void)startPaypalExpress;

/*
 Notification name: DidGetPaypalAdressInformation
 */
- (void)reviewAddress;


/*
 Notification name: PaypalExpressDidPlaceOrder
 */
- (void)placeOrderWithParam:(NSDictionary *)params;

/*
 Notification name: DidUpdatePaypalCheckoutAddress
 */
- (void)updateAddressWithParam:(NSDictionary *)params;


/*
 Notification name: DidGetPaypalCheckoutShippingMethods
 */
- (void)getShippingMethods;
@end
