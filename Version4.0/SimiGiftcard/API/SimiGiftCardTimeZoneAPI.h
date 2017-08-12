//
//  SimiGiftCardTimeZoneAPI.h
//  SimiCartPluginFW
//
//  Created by Liam on 8/11/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

@interface SimiGiftCardTimeZoneAPI : SimiAPI
- (void)getGiftCardTimeZoneWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
@end
