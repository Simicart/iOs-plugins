//
//  SimiGiftCodeAPI.h
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiAPI.h>

@interface SimiGiftCodeAPI : SimiAPI
- (void)getGiftCodeDetailWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
@end
