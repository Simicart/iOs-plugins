//
//  SimiGiftCardModelCollection.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiGiftCardModelCollection.h"
#import "SimiGiftCardAPI.h"

@implementation SimiGiftCardModelCollection
- (void)getGiftCardProductCollectionWithParams:(NSDictionary *)params{
    notificationName = DidGetGiftCardProductCollection;
    self.parseKey = @"simigiftcards";
    actionType = CollectionActionTypeInsert;
    [self preDoRequest];
    [[SimiGiftCardAPI new] getGiftCardProductCollectionWithParams:params target:self selector:@selector(didGetResponseFromNetwork:)];
}
@end
