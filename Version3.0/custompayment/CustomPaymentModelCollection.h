//
//  CustomPaymentModelCollection.h
//  SimiCartPluginFW
//
//  Created by Axe on 10/19/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import "CustomPaymentAPI.h"

@interface CustomPaymentModelCollection : SimiModelCollection
-(void) getCustomPaymentsWithParams:(NSDictionary*) params;
@end
