//
//  SimiGiftCardTimeZoneModelCollection.h
//  SimiCartPluginFW
//
//  Created by Liam on 8/11/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
static NSString *DidGetSimiTimeZone = @"DidGetSimiTimeZone";
@interface SimiGiftCardTimeZoneModelCollection : SimiModelCollection
- (void)getGiftCardTimeZoneWithParams:(NSDictionary *)params;
@end
