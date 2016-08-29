//
//  SCWishlistModel.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/26/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SCWishlistModel.h"

#define kAddProductToWishlistURL @"simiconnector/rest/v2/wishlistitems"

@implementation SCWishlistModel
-(void) addProductWithParams:(NSDictionary *)params{
    currentNotificationName = DidAddProductToWishList;
    keyResponse = @"wishlistitem";
    NSMutableDictionary *currentParams = [[NSMutableDictionary alloc]initWithDictionary:params];
    if (![SimiGlobalVar sharedInstance].isLogin) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *quoteID = @"";
        if ([userDefaults objectForKey:@"simi_quote_id"]) {
            quoteID = [userDefaults objectForKey:@"simi_quote_id"];
            if (![quoteID isEqualToString:@""] && quoteID != nil) {
                [currentParams setValue:quoteID forKey:@"quote_id"];
            }
        }
    }
    NSString* url = [NSString stringWithFormat:@"%@%@",kBaseURL,kAddProductToWishlistURL];
    [[SimiAPI new] requestWithMethod:@"POST" URL:url params:currentParams target:self selector:@selector(didFinishRequest:responder:) header:nil];
}
@end
