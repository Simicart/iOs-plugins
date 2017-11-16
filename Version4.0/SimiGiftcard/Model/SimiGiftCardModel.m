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
    notificationName = DidGetGiftCardDetail;
    self.parseKey = @"simigiftcard";
    [self preDoRequest];
    NSMutableDictionary *currentParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [currentParams setValue:giftcardID forKey:@"entity_id"];
    [[SimiGiftCardAPI new] getGiftCardProductWithParams:currentParams target:self selector:@selector(didGetResponseFromNetwork:)];
}

- (void)uploadImageWithParams:(NSDictionary *)params{
    notificationName = DidUploadImage;
    self.parseKey = @"images";
    [self preDoRequest];
    [[SimiGiftCardAPI new] uploadImageWithParams:params target:self selector:@selector(didGetResponseFromNetwork:)];
}

- (float)heightPriceOnGrid{
    float heightContent = 0;
    float heightLabel = 20;
#pragma mark Bundle
    if([[self.appPrices valueForKey:@"minimal_price"]intValue] == 1) {
        /**
         Show exclude tax Price
         */
        if([[self.appPrices valueForKey:@"show_ex_in_price"]intValue] == 1) {
            if ([self.appPrices valueForKey:@"price_label"]) {
                heightContent += heightLabel;
            }
            
            if ([self.appPrices valueForKey:@"price_excluding_tax"]) {
                heightContent += heightLabel;
            }
            
            if ([[self.appPrices valueForKey:@"show_weee_price"]intValue] == 1 && [self.appPrices valueForKey:@"weee"]) {
                heightContent += heightLabel;
            }
            
            if ([self.appPrices valueForKey:@"price_including_tax"]) {
                heightContent += heightLabel;
            }
        }else
        /**
         Don't show exclude Price
         */
        {
            if ([self.appPrices valueForKey:@"price_label"] && [self.appPrices valueForKey:@"price"]) {
                heightContent += heightLabel;
            }
            
            if ([[self.appPrices valueForKey:@"show_weee_price"]intValue] == 1 && [self.appPrices valueForKey:@"weee"]) {
                heightContent += heightLabel;
            }
            
            if ([self.appPrices valueForKey:@"price_in"] && ![[self.appPrices valueForKey:@"price_in"] isEqualToString:@""]) {
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
        if ([[self.appPrices valueForKey:@"show_from_to_tax_price"]intValue] == 1) {
            /**
             Show Exclude in Price
             */
            if ([[self.appPrices valueForKey:@"show_ex_in_price"]intValue] == 1) {
                if ([self.appPrices valueForKey:@"product_from_label"]) {
                    heightContent += heightLabel;
                }
                
                if ([self.appPrices valueForKey:@"from_price_excluding_tax"]) {
                    heightContent += heightLabel;
                }
                
                if ([self.appPrices valueForKey:@"from_price_including_tax"]) {
                    heightContent += heightLabel;
                }
                
                if ([[self.appPrices valueForKey:@"show_weee_price"]intValue] == 1 && [self.appPrices valueForKey:@"weee"]) {
                    heightContent += heightLabel;
                }
                
                if ([self.appPrices valueForKey:@"product_to_label"]) {
                    heightContent += heightLabel;
                }
                if ([self.appPrices valueForKey:@"to_price_excluding_tax"]) {
                    heightContent += heightLabel;
                }
                if ([self.appPrices valueForKey:@"to_price_including_tax"]) {
                    heightContent += heightLabel;
                }
            }
            else
            /**
             Don't Show Exclude in Price
             */
            {
                if ([self.appPrices valueForKey:@"product_from_label"] && [self.appPrices valueForKey:@"from_price"]) {
                    heightContent += heightLabel;
                }
                
                if ([self.appPrices valueForKey:@"product_to_label"] && [self.appPrices valueForKey:@"to_price"]) {
                    heightContent += heightLabel;
                }
                
                if ([[self.appPrices valueForKey:@"show_weee_price"]intValue] == 1 && [self.appPrices valueForKey:@"weee"]) {
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
            if ([[self.appPrices valueForKey:@"show_ex_in_price"]intValue] == 1) {
                if ([self.appPrices valueForKey:@"product_from_label"] && [self.appPrices valueForKey:@"from_price"]) {
                    heightContent += heightLabel;
                }
                
                if ([[self.appPrices valueForKey:@"show_weee_price"]intValue] == 1 && [self.appPrices valueForKey:@"weee"]) {
                    heightContent += heightLabel;
                }
                
                if ([self.appPrices valueForKey:@"product_to_label"] && [self.appPrices valueForKey:@"to_price"]) {
                    heightContent += heightLabel;
                }
            }else
            /**
             Don't Show Exclude In Price
             */
            {
                if ([self.appPrices valueForKey:@"price"]) {
                    heightContent += heightLabel;
                }
                
                if ([[self.appPrices valueForKey:@"show_weee_price"]intValue] == 1 && [self.appPrices valueForKey:@"weee"]) {
                    heightContent += heightLabel;
                }
            }
        }
    }
    /**
     Configure Price
     */
    if ([[self.appPrices valueForKey:@"configure"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *configureDict = [self.appPrices valueForKey:@"configure"];
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
            if ([self.appPrices valueForKey:@"price"]) {
                heightContent += heightLabel;
            }
            
            if ([[self.appPrices valueForKey:@"show_weee_price"]intValue] == 1 && [self.appPrices valueForKey:@"weee"]) {
                heightContent += heightLabel;
            }
        }
    }
    return heightContent + 10;
}
@end
