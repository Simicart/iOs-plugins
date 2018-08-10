//
//  SCAppEngageInitworker.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/8/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCAppEngageInitworker.h"
#import <CoreSpotlight/CoreSpotlight.h>
@import Firebase;
#import <SimiCartBundle/SCProductListViewController.h>
#import <SimiCartBundle/SCCategoryViewController.h>
#import "SimiCMSPageModel.h"
#import <SimiCartBundle/SCWebViewController.h>
#import "SCDeeplinkModel.h"
#import "SCBlueberryProductViewController.h"

@implementation SCAppEngageInitworker {
    SimiProductModel *productModel;
}
- (id)init{
    if(self == [super init]){
        if (![SimiGlobalVar sharedInstance].isFirebaseInited) {
            //Init Firebase configure
            [FIRApp configure];
            [SimiGlobalVar sharedInstance].isFirebaseInited = YES;
        }
        
        //Dynamic Links
        [FIROptions defaultOptions].deepLinkURLScheme = [[NSBundle mainBundle] bundleIdentifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationOpenURL:) name:@"ApplicationOpenURL" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(continueUserActivity:) name:@"ContinueUserActivity" object:nil];
        
//        Searchable iOS
        if(SIMI_SYSTEM_IOS >= 9){
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProduct:) name:@"DidGetProductWithID" object:nil];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInit:) name:@"DidInit" object:nil];
    }
    return self;
}

- (void)indexSearchableItems{
    if(productModel){
        NSMutableArray* searchableItems = [[NSMutableArray alloc] initWithCapacity:0];
        NSUserActivity* userActivity = [[NSUserActivity alloc] initWithActivityType:[NSString stringWithFormat:@"%@.%@",[[NSBundle mainBundle] bundleIdentifier],[productModel objectForKey:@"entity_id"]]];
        userActivity.title = [productModel objectForKey:@"name"];
        if ([productModel objectForKey:@"entity_id"]) {
            userActivity.userInfo = @{@"id":[productModel objectForKey:@"entity_id"]};
        }
        userActivity.eligibleForSearch = YES;
        CSSearchableItemAttributeSet* searchableItemAttributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:@"product"];
        NSArray* images = [productModel objectForKey:@"images"];
        if(images.count > 0)
            searchableItemAttributeSet.thumbnailData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[images objectAtIndex:0] objectForKey:@"url"]]];
        searchableItemAttributeSet.title = [productModel objectForKey:@"name"];
        searchableItemAttributeSet.contentDescription = [productModel objectForKey:@"short_description"];
        id item = [[CSSearchableItem alloc]initWithUniqueIdentifier:[productModel objectForKey:@"entity_id"] domainIdentifier:[NSString stringWithFormat:@"%@.searchAPIs.product",[[NSBundle mainBundle] bundleIdentifier]] attributeSet:searchableItemAttributeSet];
        [searchableItems addObject:item];
        userActivity.contentAttributeSet = searchableItemAttributeSet;
        [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:[NSArray arrayWithArray:searchableItems] completionHandler:^(NSError * _Nullable error) {
            if(error != nil){
                NSLog(@"IndexSearchableItem Error: %@",error.localizedDescription);
            }
        }];
    }
}

- (void)didGetProduct: (NSNotification*) noti{
    productModel = noti.object;
    [NSThread detachNewThreadSelector: @selector(indexSearchableItems) toTarget:self withObject:NULL];
}

- (void)didInit: (NSNotification *)noti {
    NSUserActivity* userActivity = [SimiGlobalVar sharedInstance].searchableUserActivity;
    if(userActivity) {
        if(userActivity && [userActivity.userInfo objectForKey:@"kCSSearchableItemActivityIdentifier"]){
            NSString* productID = [userActivity.userInfo objectForKey:@"kCSSearchableItemActivityIdentifier"];
            [[[SimiGlobalVar sharedInstance] currentlyNavigationController] popToRootViewControllerAnimated:NO];
//            [[SCAppController sharedInstance]openProductWithNavigationController:[[SimiGlobalVar sharedInstance] currentlyNavigationController] productId:productID moreParams:nil];
            [self openProductViewController:productID];
        }else {
            [self openAppWithUserActivity:userActivity];
        }
        userActivity = nil;
    }
}

#pragma mark Dynamic Links
//These methods are called when your app receives a link on iOS 8 and older, and when your app is opened for the first time after installation on any version of iOS
- (void)applicationOpenURL:(NSNotification*) noti{
    NSURL* url = [noti.userInfo objectForKey:@"url"];
    NSNumber* number = noti.object;
    FIRDynamicLink *dynamicLink = [[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];
    if (dynamicLink) {
        [self handleDynamicLink:dynamicLink.url.absoluteString];
        number = [NSNumber numberWithBool:YES];
    }else{
        number = [NSNumber numberWithBool:NO];
    }
}

//Handle links received as Universal Links when the app is already installed (on iOS 9 and newer)
- (void)continueUserActivity:(NSNotification*) noti{
    NSUserActivity* userActivity = [noti.userInfo objectForKey:@"userActivity"];
    NSNumber* handledNumber = [noti.userInfo objectForKey:@"handled"];
    if(userActivity) {
        if(userActivity && [userActivity.userInfo objectForKey:@"kCSSearchableItemActivityIdentifier"]){
            NSString* productID = [userActivity.userInfo objectForKey:@"kCSSearchableItemActivityIdentifier"];
            [[[SimiGlobalVar sharedInstance] currentlyNavigationController] popToRootViewControllerAnimated:NO];
//            [[SCAppController sharedInstance]openProductWithNavigationController:[[SimiGlobalVar sharedInstance] currentlyNavigationController] productId:productID moreParams:nil];
            [self openProductViewController:productID];
            handledNumber = [NSNumber numberWithBool:YES];
        }else {
            NSString *activityURL = userActivity.webpageURL.absoluteURL.absoluteString;
            if([activityURL containsString:@"app.goo.gl"]){
                BOOL handled = [[FIRDynamicLinks dynamicLinks] handleUniversalLink:userActivity.webpageURL
                                                                        completion:^(FIRDynamicLink * _Nullable dynamicLink,
                                                                                     NSError * _Nullable error) {
                                                                            if(!error) {
                                                                                [self handleDynamicLink:dynamicLink.url.absoluteString];
                                                                            }
                                                                        }];
                handledNumber = [NSNumber numberWithBool:handled];
            }else{
                [self handleDynamicLink:activityURL];
                handledNumber = [NSNumber numberWithBool:YES];
            }
        }
    }
}

- (void)openAppWithUserActivity: (NSUserActivity *)userActivity {
    NSString *activityURL = userActivity.webpageURL.absoluteURL.absoluteString;
    if([activityURL containsString:@"app.goo.gl"]){
        [[FIRDynamicLinks dynamicLinks] handleUniversalLink:userActivity.webpageURL
                                                 completion:^(FIRDynamicLink * _Nullable dynamicLink,
                                                              NSError * _Nullable error) {
                                                     if(!error) {
                                                         [self handleDynamicLink:dynamicLink.url.absoluteString];
                                                     }
                                                 }];
    }else{
        [self handleDynamicLink:activityURL];
    }
}

- (void)handleDynamicLink: (NSString *)deeplinkURL{
    if(deeplinkURL && ![deeplinkURL isEqualToString:@""]){
        NSArray *deeplinkPaths = [deeplinkURL componentsSeparatedByString:@"?"];
        if(deeplinkPaths.count > 1) {
            NSString *deepLinkPath = [[deeplinkURL componentsSeparatedByString:@"?"] objectAtIndex:1];
            NSDictionary *deepLinkValues = [self convertFromDeeplinkPath:deepLinkPath];
            if([deepLinkValues objectForKey:@"simi_product_id"]){
                NSString *productID = [deepLinkValues objectForKey:@"simi_product_id"];
                [[[SimiGlobalVar sharedInstance] currentlyNavigationController] popToRootViewControllerAnimated:NO];
//                [[SCAppController sharedInstance]openProductWithNavigationController:[[SimiGlobalVar sharedInstance] currentlyNavigationController]  productId:productID moreParams:nil];
                [self openProductViewController:productID];
            } else if([deepLinkValues objectForKey:@"simi_cate_id"] && [deepLinkValues objectForKey:@"simi_has_child"] && [deepLinkValues objectForKey:@"simi_cate_name"]) {
                NSString *categoryID = [deepLinkValues objectForKey:@"simi_cate_id"];
                BOOL hasChild = [[deepLinkValues objectForKey:@"simi_has_child"] boolValue];
                NSString *categoryName = [deepLinkValues objectForKey:@"simi_cate_name"];
                if(PHONEDEVICE) {
                    if(hasChild) {
                        SCCategoryViewController *nextController = [[SCCategoryViewController alloc]init];
                        nextController.openFrom = CategoryOpenFromParentCategory;
                        [nextController setCategoryId:categoryID];
                        [nextController setCategoryRealName:categoryName];
                        [[[SimiGlobalVar sharedInstance] currentlyNavigationController] popToRootViewControllerAnimated:NO];
                        [[[SimiGlobalVar sharedInstance] currentlyNavigationController] pushViewController:nextController animated:YES];
                    }else {
                        SCProductListViewController *nextController = [[SCProductListViewController alloc]init];;
                        [nextController setCategoryID: categoryID];
                        nextController.nameOfProductList = categoryName;
                        [[[SimiGlobalVar sharedInstance] currentlyNavigationController] popToRootViewControllerAnimated:NO];
                        [[[SimiGlobalVar sharedInstance] currentlyNavigationController] pushViewController:nextController animated:YES];
                    }
                }else {
                    
                }
            } else if([deepLinkValues objectForKey:@"simi_cms_id"]) {
                NSString *cmsID = [deepLinkValues objectForKey:@"simi_cms_id"];
                [[[SimiGlobalVar sharedInstance] currentlyNavigationController] popToRootViewControllerAnimated:NO];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCMSPage:) name:@"Simi_DidGetCMSPages" object:nil];
                [[SimiCMSPageModel new] getCMSPageWithID:cmsID];
                [((SimiViewController *)[[SimiGlobalVar sharedInstance] currentlyNavigationController].viewControllers.lastObject) startLoadingData];
            }else {
                [self getDeeplinkInformationWithURL:deeplinkURL];
            }
        }else {
            [self getDeeplinkInformationWithURL:deeplinkURL];
        }
    }
}

- (void)getDeeplinkInformationWithURL: (NSString *)deeplinkURL {
    SCDeeplinkModel *deeplink = [SCDeeplinkModel new];
    [deeplink getDeeplinkInformation:deeplinkURL];
    [((SimiViewController *)([SimiGlobalVar sharedInstance].currentlyNavigationController.viewControllers.lastObject)) startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetDeeplinkInformation:) name:DidGetDeeplinkInformation object:nil];
}

- (void)didGetDeeplinkInformation: (NSNotification *)noti {
    [self removeObserverForNotification:noti];
    [((SimiViewController *)([SimiGlobalVar sharedInstance].currentlyNavigationController.viewControllers.lastObject)) stopLoadingData];
    SimiResponder *responder = [noti.userInfo objectForKey:@"responder"];
    if([responder.status isEqualToString:@"SUCCESS"]) {
        SCDeeplinkModel *deeplink = noti.object;
        if([[deeplink objectForKey:@"type"] isEqualToString:@"1"]) {
            NSString *categoryName = [deeplink objectForKey:@"name"];
            NSString *categoryID = [deeplink objectForKey:@"id"];
            BOOL hasChild = [[deeplink objectForKey:@"has_child"] boolValue];
            if(PHONEDEVICE) {
                if(hasChild) {
                    SCCategoryViewController *nextController = [[SCCategoryViewController alloc]init];
                    nextController.openFrom = CategoryOpenFromParentCategory;
                    [nextController setCategoryId:categoryID];
                    [nextController setCategoryRealName:categoryName];
                    [[[SimiGlobalVar sharedInstance] currentlyNavigationController] popToRootViewControllerAnimated:NO];
                    [[[SimiGlobalVar sharedInstance] currentlyNavigationController] pushViewController:nextController animated:YES];
                }else {
                    SCProductListViewController *nextController = [[SCProductListViewController alloc]init];;
                    [nextController setCategoryID: categoryID];
                    nextController.nameOfProductList = categoryName;
                    [[[SimiGlobalVar sharedInstance] currentlyNavigationController] popToRootViewControllerAnimated:NO];
                    [[[SimiGlobalVar sharedInstance] currentlyNavigationController] pushViewController:nextController animated:YES];
                }
            }else {
                
            }
        }else if([[deeplink objectForKey:@"type"] isEqualToString:@"2"]) {
            NSString *productID = [deeplink objectForKey:@"id"];
            [[[SimiGlobalVar sharedInstance] currentlyNavigationController] popToRootViewControllerAnimated:NO];
//            [[SCAppController sharedInstance]openProductWithNavigationController:[[SimiGlobalVar sharedInstance] currentlyNavigationController] productId:productID moreParams:nil];
            [self openProductViewController:productID];
        }else if([[deeplink objectForKey:@"type"] isEqualToString:@"3"]) {
            NSString *cmsID = [deeplink objectForKey:@"id"];
            [[[SimiGlobalVar sharedInstance] currentlyNavigationController] popToRootViewControllerAnimated:NO];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCMSPage:) name:@"Simi_DidGetCMSPages" object:nil];
            [[SimiCMSPageModel new] getCMSPageWithID:cmsID];
            [((SimiViewController *)[[SimiGlobalVar sharedInstance] currentlyNavigationController].viewControllers.lastObject) startLoadingData];
        }else if([[deeplink objectForKey:@"type"] isEqualToString:@"4"]) {
            [[[SimiGlobalVar sharedInstance] currentlyNavigationController] popToRootViewControllerAnimated:NO];
        }
    }else {
        
    }
}

- (void)didGetCMSPage: (NSNotification *)noti {
    SimiCMSPageModel *cmsModel = noti.object;
    [((SimiViewController *)[[SimiGlobalVar sharedInstance] currentlyNavigationController].viewControllers.lastObject) stopLoadingData];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Simi_DidGetCMSPages" object:nil];
    SCWebViewController *webViewController = [[SCWebViewController alloc] init];
    webViewController.title = [cmsModel objectForKey:@"cms_title"];
    webViewController.content = [cmsModel valueForKey:@"cms_content"];
    [[[SimiGlobalVar sharedInstance] currentlyNavigationController] popToRootViewControllerAnimated:NO];
    [[[SimiGlobalVar sharedInstance] currentlyNavigationController] pushViewController:webViewController animated:YES];
}

- (NSDictionary *)convertFromDeeplinkPath:(NSString *)deeplinkPath {
    NSArray *deepLinkItems = [deeplinkPath componentsSeparatedByString:@"&"];
    NSMutableDictionary *deeplinkValues = [NSMutableDictionary new];
    for(NSString *deepLinkItem in deepLinkItems) {
        NSArray *deepLinkItemValue = [deepLinkItem componentsSeparatedByString:@"="];
        [deeplinkValues setValue:[deepLinkItemValue objectAtIndex:1] forKey:[deepLinkItemValue objectAtIndex:0]];
    }
    return deeplinkValues;
}
- (void)openProductViewController:(NSString *)productID{
    SCBlueberryProductViewController *productViewController = [SCBlueberryProductViewController new];
    productViewController.productId = productID;
    [[[SimiGlobalVar sharedInstance]currentlyNavigationController] pushViewController:productViewController animated:YES];
    
}
@end
