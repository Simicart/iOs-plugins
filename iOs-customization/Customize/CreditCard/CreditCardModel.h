//
//  CreditCardModel.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 2/5/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

#define DidEditCreditCard @"DidEditCreditCard"

@interface CreditCardModel : SimiModel

- (void)editCardWithParams:(NSDictionary *)params;
@end
