//
//  CreditCardModelCollection.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 2/5/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "CreditCardModelCollection.h"

@implementation CreditCardModelCollection
- (void)getListCreditCards{
    notificationName = DidGetListCreditCards;
    self.resource = @"ewaycards";
    self.parseKey = @"ewaycards";
    self.method = MethodGet;
    [self request];
}
- (void)deleteCardWithId:(NSString *)tokenId{
    notificationName = DidDeleteCard;
    self.resource = [NSString stringWithFormat:@"ewaycards/%@",tokenId];
    self.parseKey = @"ewaycards";
    self.method = MethodDelete;
    [self request];
}
- (void)setCardDefaultWithId:(NSString *)tokenId{
    notificationName = DidSetCardDefault;
    self.parseKey = @"ewaycards";
    self.resource = @"ewaycards/carddefault";
    self.method = MethodPut;
    [self.body addEntriesFromDictionary:@{@"token_id":tokenId}];
    [self request];
}

@end
