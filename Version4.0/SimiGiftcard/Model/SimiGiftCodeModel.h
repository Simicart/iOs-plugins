//
//  SimiGiftCodeModel.h
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

static NSString *DidGetGiftCodeDetail = @"DidGetGiftCodeDetail";

@interface SimiGiftCodeModel : SimiModel
- (void)getGiftCodeDetailWithParams:(NSDictionary *)params;
@end
