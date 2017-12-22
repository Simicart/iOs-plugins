//
//  SimiGiftCardModelCollection.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiGiftCardModelCollection.h"

@implementation SimiGiftCardModelCollection
- (void)getGiftCardProductCollectionWithParams:(NSDictionary *)params{
    notificationName = DidGetGiftCardProductCollection;
    self.parseKey = @"simigiftcards";
    actionType = CollectionActionTypeInsert;
    self.resource = @"simigiftcards";
    if (params.count > 0) {
        [self.params addEntriesFromDictionary:params];
    }
    self.method = MethodGet;
    [self preDoRequest];
    [self request];
}
@end
