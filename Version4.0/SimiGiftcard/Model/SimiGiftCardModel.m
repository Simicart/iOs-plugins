//
//  SimiGiftCardModel.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiGiftCardModel.h"
#import "SimiGiftCardAPI.h"

@implementation SimiGiftCardModel
- (void)getGiftCardWithID:(NSString*)giftcardID params:(NSDictionary*)params{
    currentNotificationName = DidGetGiftCardDetail;
    keyResponse = @"simigiftcard";
    [self preDoRequest];
    NSMutableDictionary *currentParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [currentParams setValue:giftcardID forKey:@"entity_id"];
    [[SimiGiftCardAPI new] getGiftCardProductWithParams:currentParams target:self selector:@selector(didFinishRequest:responder:)];
}

- (float)heightPriceOnGrid{
    float heightContent = 0;
    float heightLabel = 20;
#pragma mark Bundle
    if ([[self valueForKey:@"app_prices"] isKindOfClass:[NSDictionary class]]) {
        self.appPrice = [self valueForKey:@"app_prices"];
    }else
        self.appPrice  = [NSDictionary new];
    /**
     Have Minimal Price
     */
    if([[self.appPrice valueForKey:@"minimal_price"]intValue] == 1) {
        /**
         Show exclude tax Price
         */
        if([[self.appPrice valueForKey:@"show_ex_in_price"]intValue] == 1) {
            if ([self.appPrice valueForKey:@"price_label"]) {
                heightContent += heightLabel;
            }
            
            if ([self.appPrice valueForKey:@"price_excluding_tax"]) {
                heightContent += heightLabel;
            }
            
            if ([[self.appPrice valueForKey:@"show_weee_price"]intValue] == 1 && [self.appPrice valueForKey:@"weee"]) {
                heightContent += heightLabel;
            }
            
            if ([self.appPrice valueForKey:@"price_including_tax"]) {
                heightContent += heightLabel;
            }
        }else
        /**
         Don't show exclude Price
         */
        {
            if ([self.appPrice valueForKey:@"price_label"] && [self.appPrice valueForKey:@"price"]) {
                heightContent += heightLabel;
            }
            
            if ([[self.appPrice valueForKey:@"show_weee_price"]intValue] == 1 && [self.appPrice valueForKey:@"weee"]) {
                heightContent += heightLabel;
            }
            
            if ([self.appPrice valueForKey:@"price_in"] && ![[self.appPrice valueForKey:@"price_in"] isEqualToString:@""]) {
                heightContent += heightLabel;
            }
        }
    }else
    /**
     Don't Have Minimal Price
     */
    {
        /**
         Show From To Tax Price
         */
        if ([[self.appPrice valueForKey:@"show_from_to_tax_price"]intValue] == 1) {
            /**
             Show Exclude in Price
             */
            if ([[self.appPrice valueForKey:@"show_ex_in_price"]intValue] == 1) {
                if ([self.appPrice valueForKey:@"product_from_label"]) {
                    heightContent += heightLabel;
                }
                
                if ([self.appPrice valueForKey:@"from_price_excluding_tax"]) {
                    heightContent += heightLabel;
                }
                
                if ([self.appPrice valueForKey:@"from_price_including_tax"]) {
                    heightContent += heightLabel;
                }
                
                if ([[self.appPrice valueForKey:@"show_weee_price"]intValue] == 1 && [self.appPrice valueForKey:@"weee"]) {
                    heightContent += heightLabel;
                }
                
                if ([self.appPrice valueForKey:@"product_to_label"]) {
                    heightContent += heightLabel;
                }
                if ([self.appPrice valueForKey:@"to_price_excluding_tax"]) {
                    heightContent += heightLabel;
                }
                if ([self.appPrice valueForKey:@"to_price_including_tax"]) {
                    heightContent += heightLabel;
                }
            }
            else
            /**
             Don't Show Exclude in Price
             */
            {
                if ([self.appPrice valueForKey:@"product_from_label"] && [self.appPrice valueForKey:@"from_price"]) {
                    heightContent += heightLabel;
                }
                
                if ([self.appPrice valueForKey:@"product_to_label"] && [self.appPrice valueForKey:@"to_price"]) {
                    heightContent += heightLabel;
                }
                
                if ([[self.appPrice valueForKey:@"show_weee_price"]intValue] == 1 && [self.appPrice valueForKey:@"weee"]) {
                    heightContent += heightLabel;
                }
            }
        }else
        /**
         Don't Show From To Tax Price
         */
        {
            /**
             Show Exclud In Price
             */
            if ([[self.appPrice valueForKey:@"show_ex_in_price"]intValue] == 1) {
                if ([self.appPrice valueForKey:@"product_from_label"] && [self.appPrice valueForKey:@"from_price"]) {
                    heightContent += heightLabel;
                }
                
                if ([[self.appPrice valueForKey:@"show_weee_price"]intValue] == 1 && [self.appPrice valueForKey:@"weee"]) {
                    heightContent += heightLabel;
                }
                
                if ([self.appPrice valueForKey:@"product_to_label"] && [self.appPrice valueForKey:@"to_price"]) {
                    heightContent += heightLabel;
                }
            }else
            /**
             Don't Show Exclude In Price
             */
            {
                if ([self.appPrice valueForKey:@"price"]) {
                    heightContent += heightLabel;
                }
                
                if ([[self.appPrice valueForKey:@"show_weee_price"]intValue] == 1 && [self.appPrice valueForKey:@"weee"]) {
                    heightContent += heightLabel;
                }
            }
        }
    }
    /**
     Configure Price
     */
    if ([[self.appPrice valueForKey:@"configure"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *configureDict = [self.appPrice valueForKey:@"configure"];
        if ([configureDict valueForKey:@"price_label"]) {
            heightContent += heightLabel;
        }
        
        if ([[configureDict valueForKey:@"show_ex_in_price"]intValue] == 1) {
            if ([configureDict valueForKey:@"price_excluding_tax"]) {
                heightContent += heightLabel;
            }
            
            if ([[configureDict valueForKey:@"show_weee_price"]intValue] == 1 && [configureDict valueForKey:@"weee"]) {
                heightContent += heightLabel;
            }
            if ([configureDict valueForKey:@"price_including_tax"]) {
                heightContent += heightLabel;
            }
        }else
        {
            if ([self.appPrice valueForKey:@"price"]) {
                heightContent += heightLabel;
            }
            
            if ([[self.appPrice valueForKey:@"show_weee_price"]intValue] == 1 && [self.appPrice valueForKey:@"weee"]) {
                heightContent += heightLabel;
            }
        }
    }
    return heightContent + 10;
}
@end
