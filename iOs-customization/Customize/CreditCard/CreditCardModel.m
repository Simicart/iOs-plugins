//
//  CreditCardModel.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 2/5/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "CreditCardModel.h"

@implementation CreditCardModel
- (void)editCardWithParams:(NSDictionary *)params{
    notificationName = DidEditCreditCard;
    self.parseKey = @"ewaycard";
    self.resource = @"ewaycards";
    self.method = MethodPost;
    [self.body addEntriesFromDictionary:params];
    [self request];
}
@end
