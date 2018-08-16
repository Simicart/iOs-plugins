//
//  SCCustomizeInitWorker.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 12/5/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//
//NSString *const kSimiKey                = @"DDy6k8e2Zk5S43TyR7FvZkJLu0x0AF";
//NSString *kBaseURL                      = @"https://www.astiraustralia.com.au/";
//
//NSString *const kCloudSimiKey                = @"jeiSkC1zF1TLTYPNxHUcdTwWF1Wd1wSlLbd5OfE";
//NSString *kCloudBaseURL                      = @"https://www.simicart.com/appdashboard/rest/";

#import <Foundation/Foundation.h>
#import "MyFavouriteWorker.h"
#import "ProductWorker.h"
#import "OrderWorker.h"
#import "CreditCardInitWorker.h"

@interface SCCustomizeInitWorker : NSObject
@property (strong, nonatomic) MyFavouriteWorker *favouriteWorker;
@property (strong, nonatomic) ProductWorker *productWorker;
@property (strong, nonatomic) OrderWorker *orderWorker;
@property (strong, nonatomic) CreditCardInitWorker *creditCardWorker;

@end
