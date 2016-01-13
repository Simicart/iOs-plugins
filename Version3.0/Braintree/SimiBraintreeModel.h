//
//  SimiBraintreeModel.h
//  SimiCartPluginFW
//
//  Created by Axe on 12/30/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimiCartBundle/SimiOrderModel.h>

extern NSString *const kBraintreeUpdatePayment;

@interface SimiBraintreeModel : SimiModel
-(void) sendNonceToServer:(NSString* )nonce andOrder:(SimiOrderModel*) order;
@end
