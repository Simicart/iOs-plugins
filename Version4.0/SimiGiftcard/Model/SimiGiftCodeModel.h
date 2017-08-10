//
//  SimiGiftCodeModel.h
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#define DidUseGiftCode @"DidUseGiftCode"

@interface SimiGiftCodeModel : SimiModel
- (void)useGiftCodeWithParams: (NSDictionary *)params;
@end
