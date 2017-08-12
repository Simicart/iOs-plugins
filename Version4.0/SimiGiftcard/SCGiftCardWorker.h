//
//  SCGiftCardWorker.h
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCGiftCardOnCartWorker.h"
#import "SCGiftCardOnOrderWorker.h"

static NSString *LEFTMENU_ROW_GIFTCARD = @"LEFTMENU_ROW_GIFTCARD";
@interface SCGiftCardWorker : NSObject
@property (strong, nonatomic) SCGiftCardOnCartWorker *giftCardOnCartWorker;
@property (strong, nonatomic) SCGiftCardOnOrderWorker *giftCardOnOrderWorker;
@end
