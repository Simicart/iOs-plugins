//
//  CreditCardModelCollection.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 2/5/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

#define DidGetListCreditCards @"DidGetListCreditCards"
#define DidDeleteCard @"DidDeleteCard"
#define DidSetCardDefault @"DidSetCardDefault"

@interface CreditCardModelCollection : SimiModelCollection
- (void)getListCreditCards;
- (void)deleteCardWithId:(NSString *)tokenId;
- (void)setCardDefaultWithId:(NSString *)tokenId;
@end
