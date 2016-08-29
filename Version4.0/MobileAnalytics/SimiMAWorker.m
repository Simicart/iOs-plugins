//
//  SimiMAWorker.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 7/23/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiMAWorker.h"
#import <SimiCartBundle/SimiOrderModel.h>
#import <SimiCartBundle/SimiCartModel.h>
#import <SimiCartBundle/SimiCartModelCollection.h>
#import <SimiCartBundle/SimiShippingModel.h>
@implementation SimiMAWorker
- (instancetype)init
{
    self = [super init];
    if (self) {
        maModel = [[SimiMAModel alloc]init];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetGoogleAnalyticsID:) name:@"DidGetGoogleAnalyticsID" object:nil];
        [maModel getGoogleAnalyticsIDWithParams:nil];
    }
    return self;
}

- (void)didGetGoogleAnalyticsID:(NSNotification*)noti
{
    SimiResponder* responder = [noti.userInfo valueForKey:@"responder"];
    if ([[responder.status uppercaseString] isEqualToString:@"SUCCESS"])
    {
        stringGoogleAnalyticsID = [maModel valueForKey:@"ga_id"];
        tracker = [[GAI sharedInstance] trackerWithTrackingId:stringGoogleAnalyticsID];
#pragma mark Thong ke screen
#pragma mark
        
#pragma mark Home Screen
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetStartHomeScreen:) name:@"SCHomeViewControllerViewWillAppear" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetStartHomeScreen:) name:@"SCHomeViewControllerPadViewWillAppear" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetStartHomeScreen:) name:@"MatrixHomeViewControllerPadViewWillAppear" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetStartHomeScreen:) name:@"MatrixHomeViewControllerPadViewWillAppear" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetStartHomeScreen:) name:@"ZaraHomeViewControllerPadViewWillAppear" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetStartHomeScreen:) name:@"ZaraHomeViewControllerPadViewWillAppear" object:nil];
        
        
#pragma mark Product Detail Screen
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetStartProductScreen:) name:@"SCProductViewControllerPadViewWillAppear" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetStartProductScreen:) name:@"SCProductViewControllerViewWillAppear" object:nil];
        
#pragma mark Category Screen
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetStartCategoryScreen:) name:@"SCCategoryViewControllerPadViewWillAppear" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetStartCategoryScreen:) name:@"SCCategoryViewControllerViewWillAppear" object:nil];
        
#pragma mark Cart Screen
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetStartCartScreen:) name:@"SCCartViewControllerViewWillAppear" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetStartCartScreen:) name:@"SCCartViewControllerPadViewWillAppear" object:nil];
        
#pragma mark Review Order Screen
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetStartReviewOrderScreen:) name:@"SCOrderViewControllerViewWillAppear" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetStartReviewOrderScreen:) name:@"SCOrderViewControllerPadViewWillAppear" object:nil];
        
#pragma mark Order History Screen
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetStartOrderHistoryScreen:) name:@"SCOrderHistoryViewControllerViewDidLoad" object:nil];
        
#pragma mark Order History Screen Detail
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetStartOrderHistoryDetailScreen:) name:@"SCOrderDetailViewControllerViewWillAppear" object:nil];
        
#pragma mark
#pragma mark Checkout Success
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didPlaceOrderSuccess:) name:@"DidPlaceOrder-After" object:nil];
        
#pragma mark
#pragma mark Click Banner
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didClickBanner:) name:@"DidClickBanner" object:nil];
    }
}

- (void)didGetStartHomeScreen:(NSNotification*)noti
{
    [tracker set:kGAIScreenName value:@"Home Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didGetStartProductScreen:(NSNotification*)noti
{
    [tracker set:kGAIScreenName value:@"Product Detail"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didGetStartCategoryScreen:(NSNotification*)noti
{
    [tracker set:kGAIScreenName value:@"Category"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}
- (void)didGetStartCartScreen:(NSNotification*)noti
{
    [tracker set:kGAIScreenName value:@"Cart Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}
- (void)didGetStartReviewOrderScreen:(NSNotification*)noti
{
    [tracker set:kGAIScreenName value:@"Review Order Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}
- (void)didGetStartOrderHistoryScreen:(NSNotification*)noti
{
    [tracker set:kGAIScreenName value:@"Order History"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}
- (void)didGetStartOrderHistoryDetailScreen:(NSNotification*)noti
{
    [tracker set:kGAIScreenName value:@"Order History Detail"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didClickBanner:(NSNotification*)noti
{
    id banner = noti.object;
    [tracker set:kGAIEventAction value:@"Banner"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Banner"     // Event category (required)
                                                          action:@"Click"  // Event action (required)
                                                           label:[banner valueForKey:@"url"]          // Event label
                                                           value:nil] build]];    // Event value
}

- (void)didPlaceOrderSuccess:(NSNotification*)noti
{
    SimiOrderModel *order = noti.object;
    SimiCartModelCollection *cartCollection = [noti.userInfo valueForKey:@"cart"];
    SimiShippingModel *shippingModel = [noti.userInfo valueForKey:@"shipping"];
    NSString *stringTransactionWithId = [NSString stringWithFormat:@"%@",[order valueForKey:@"invoice_number"]];
    NSNumber *numberRevenue = [NSNumber numberWithFloat:[[[[order valueForKey:@"fee"]valueForKey:@"v2"]valueForKey:@"grand_total"] floatValue]];
    NSNumber *numberTax = [NSNumber numberWithFloat:[[[order valueForKey:@"fee"]valueForKey:@"tax"] floatValue]];
    NSNumber *numberShipping = [NSNumber numberWithFloat:[[shippingModel valueForKey:@"s_method_fee"] floatValue]];
    NSString *currencyCode = [[[[SimiGlobalVar sharedInstance]store]valueForKey:@"store_config"] valueForKey:@"currency_code"];
    [tracker send:[[GAIDictionaryBuilder createTransactionWithId:stringTransactionWithId             // (NSString) Transaction ID
                                                     affiliation:@"In-app Store"         // (NSString) Affiliation
                                                         revenue:numberRevenue                  // (NSNumber) Order revenue (including tax and shipping)
                                                             tax:numberTax                  // (NSNumber) Tax
                                                        shipping:numberShipping                      // (NSNumber) Shipping
                                                    currencyCode:currencyCode] build]];        // (NSString) Currency code
    
    for (int i = 0; i < cartCollection.count; i++) {
        SimiCartModel *model = [cartCollection objectAtIndex:i];
        NSString *strProductName = [model valueForKey:@"product_name"];
        NSString *strProductSKU = [model valueForKey:@"product_id"];
        NSNumber *numberPrice = [NSNumber numberWithFloat:[[model valueForKey:@"product_price"] floatValue]];
        NSNumber *numberQuanlity = [NSNumber numberWithFloat:[[model valueForKey:@"product_qty"] floatValue]];
        [tracker send:[[GAIDictionaryBuilder createItemWithTransactionId:stringTransactionWithId         // (NSString) Transaction ID
                                                                    name:strProductName // (NSString) Product Name
                                                                     sku:strProductSKU            // (NSString) Product SKU
                                                                category:@""            // (NSString) Product category
                                                                   price:numberPrice               // (NSNumber)  Product price
                                                                quantity:numberQuanlity                  // (NSInteger)  Product quantity
                                                            currencyCode:currencyCode] build]];    // (NSString) Currency code
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
