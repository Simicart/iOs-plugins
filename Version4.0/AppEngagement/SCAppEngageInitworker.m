//
//  SCAppEngageInitworker.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/8/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCAppEngageInitworker.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import <FirebaseCore/FirebaseCore.h>
#import <FirebaseDynamicLinks/FirebaseDynamicLinks.h>
#import <SimiCartBundle/SCProductListViewController.h>
#import <SimiCartBundle/SCCategoryViewController.h>
#import <SimiCartBundle/SimiCMSModel.h>
#import "SCDeeplinkModel.h"

typedef enum : NSUInteger {
    OpenAppFromDynamicLink,
    OpenAppFromUniversalLink,
    OpenAppFromSearchableIOS,
} OpenAppType;

@implementation SCAppEngageInitworker {
    NSArray *productList;
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
        
        //Searchable iOS
        if(SIMI_SYSTEM_IOS >= 9){
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:@"DidGetProductCollection" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openSearchableItem:) name:@"DidInit" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openSearchableItem:) name:@"ContinueUserActivity" object:nil];
        }
    }
    return self;
}

- (void)indexSearchableItems{
    if(productList && productList.count > 0){
        NSMutableArray* searchableItems = [[NSMutableArray alloc] initWithCapacity:0];
        for(NSDictionary* product in productList){
            NSUserActivity* userActivity = [[NSUserActivity alloc] initWithActivityType:[NSString stringWithFormat:@"%@.%@",[[NSBundle mainBundle] bundleIdentifier],[product objectForKey:@"entity_id"]]];
            userActivity.title = [product objectForKey:@"name"];
            userActivity.userInfo = @{@"id":[product objectForKey:@"entity_id"]};
            userActivity.eligibleForSearch = YES;
            CSSearchableItemAttributeSet* searchableItemAttributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:@"product"];
            NSArray* images = [product objectForKey:@"images"];
            if(images.count > 0)
                searchableItemAttributeSet.thumbnailData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[images objectAtIndex:0] objectForKey:@"url"]]];
            searchableItemAttributeSet.title = [product objectForKey:@"name"];
            searchableItemAttributeSet.contentDescription = [product objectForKey:@"short_description"];
            id item = [[CSSearchableItem alloc]initWithUniqueIdentifier:[product objectForKey:@"entity_id"] domainIdentifier:[NSString stringWithFormat:@"%@.searchAPIs.product",[[NSBundle mainBundle] bundleIdentifier]] attributeSet:searchableItemAttributeSet];
            [searchableItems addObject:item];
            userActivity.contentAttributeSet = searchableItemAttributeSet;
            [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:[NSArray arrayWithArray:searchableItems] completionHandler:^(NSError * _Nullable error) {
                if(error != nil){
                    NSLog(@"IndexSearchableItem Error: %@",error.localizedDescription);
                }
            }];
        }
    }
}

- (void)didGetProducts: (NSNotification*) noti{
    if([noti.object isKindOfClass:[NSArray class]]){
        productList = noti.object;
        [NSThread detachNewThreadSelector: @selector(indexSearchableItems) toTarget:self withObject:NULL];
    }
}
- (void)openSearchableItem:(NSNotification*) noti{
    NSUserActivity* searchableUserActivity = [SimiGlobalVar sharedInstance].searchableUserActivity;
    if(searchableUserActivity) {
        if(searchableUserActivity && [searchableUserActivity.userInfo objectForKey:@"kCSSearchableItemActivityIdentifier"]){
            NSString* productID = [searchableUserActivity.userInfo objectForKey:@"kCSSearchableItemActivityIdentifier"];
            [[[SimiGlobalVar sharedInstance] currentlyNavigationController] popToRootViewControllerAnimated:NO];
            [SimiGlobalVar pushProductDetailWithNavigationController:[[SimiGlobalVar sharedInstance] currentlyNavigationController] andProductID:productID andProductIDs:nil];
        }else {
            [self openAppWithUserActivity:searchableUserActivity];
        }
        searchableUserActivity = nil;
    }
}

#pragma mark Dynamic Links
- (void)applicationOpenURL:(NSNotification*) noti{
    NSURL* url = [noti.userInfo objectForKey:@"url"];
    NSNumber* number = noti.object;
    FIRDynamicLink *dynamicLink = [[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];
    if (dynamicLink) {
        [self handleDynamicLink:dynamicLink.url.absoluteString type:OpenAppFromDynamicLink];
        number = [NSNumber numberWithBool:YES];
    }else{
        number = [NSNumber numberWithBool:NO];
    }
}

- (void)continueUserActivity:(NSNotification*) noti{
    NSUserActivity* userActivity = [noti.userInfo objectForKey:@"userActivity"];
    NSNumber* handledNumber = [noti.userInfo objectForKey:@"handled"];
    NSString *activityURL = userActivity.webpageURL.absoluteURL.absoluteString;
    if([activityURL containsString:@"app.goo.gl"]){
        BOOL handled = [[FIRDynamicLinks dynamicLinks] handleUniversalLink:userActivity.webpageURL
                                                                completion:^(FIRDynamicLink * _Nullable dynamicLink,
                                                                             NSError * _Nullable error) {
                                                                    if(!error) {
                                                                        [self handleDynamicLink:dynamicLink.url.absoluteString type:OpenAppFromDynamicLink];
                                                                    }
                                                                }];
        handledNumber = [NSNumber numberWithBool:handled];
    }else{
        [self handleDynamicLink:activityURL type:OpenAppFromUniversalLink];
    }
}

- (void)openAppWithUserActivity: (NSUserActivity *)userActivity {
    NSString *activityURL = userActivity.webpageURL.absoluteURL.absoluteString;
    if([activityURL containsString:@"app.goo.gl"]){
        [[FIRDynamicLinks dynamicLinks] handleUniversalLink:userActivity.webpageURL
                                                 completion:^(FIRDynamicLink * _Nullable dynamicLink,
                                                              NSError * _Nullable error) {
                                                     if(!error) {
                                                         [self handleDynamicLink:dynamicLink.url.absoluteString type:OpenAppFromDynamicLink];
                                                     }
                                                 }];
    }else{
        [self handleDynamicLink:activityURL type:OpenAppFromUniversalLink];
    }
}

- (void)handleDynamicLink: (NSString *)deeplinkLinkURL type: (OpenAppType)searchableType {
    if(searchableType == OpenAppFromDynamicLink) {
        NSString *deepLinkPath = [[deeplinkLinkURL componentsSeparatedByString:@"?"] objectAtIndex:1];
        NSDictionary *deepLinkValues = [self convertFromDeeplinkPath:deepLinkPath];
        if([deepLinkValues objectForKey:@"simi_product_id"]){
            NSString *productID = [deepLinkValues objectForKey:@"simi_product_id"];
            [[[SimiGlobalVar sharedInstance] currentlyNavigationController] popToRootViewControllerAnimated:NO];
            [SimiGlobalVar pushProductDetailWithNavigationController:[[SimiGlobalVar sharedInstance] currentlyNavigationController] andProductID:productID andProductIDs:@[productID]];
        } else if([deepLinkValues objectForKey:@"simi_cate_name"] && [deepLinkValues objectForKey:@"simi_has_child"] && [deepLinkValues objectForKey:@"simi_cate_name"]) {
            NSString *categoryID = [deepLinkValues objectForKey:@"simi_cate_name"];
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
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCMSPage:) name:DidGetCMSPage object:nil];
            [[SimiCMSModel new] getCMSPageWithID:cmsID];
            [((SimiViewController *)[[SimiGlobalVar sharedInstance] currentlyNavigationController].viewControllers.lastObject) startLoadingData];
        }else {
            
        }
    }else if(searchableType == OpenAppFromUniversalLink){
        SCDeeplinkModel *deeplink = [SCDeeplinkModel new];
        [deeplink getDeeplinkInformation:deeplinkLinkURL];
        [((SimiViewController *)([SimiGlobalVar sharedInstance].currentlyNavigationController.viewControllers.lastObject)) startLoadingData];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetDeeplinkInformation:) name:DidGetDeeplinkInformation object:nil];
    }
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
            [SimiGlobalVar pushProductDetailWithNavigationController:[[SimiGlobalVar sharedInstance] currentlyNavigationController] andProductID:productID andProductIDs:@[productID]];
        }else if([[deeplink objectForKey:@"type"] isEqualToString:@"3"]) {
            NSString *cmsID = [deeplink objectForKey:@"id"];
            [[[SimiGlobalVar sharedInstance] currentlyNavigationController] popToRootViewControllerAnimated:NO];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCMSPage:) name:DidGetCMSPage object:nil];
            [[SimiCMSModel new] getCMSPageWithID:cmsID];
            [((SimiViewController *)[[SimiGlobalVar sharedInstance] currentlyNavigationController].viewControllers.lastObject) startLoadingData];
        }else if([[deeplink objectForKey:@"type"] isEqualToString:@"4"]) {
            [[[SimiGlobalVar sharedInstance] currentlyNavigationController] popToRootViewControllerAnimated:NO];
        }
    }else {
        
    }
}

- (void)didGetCMSPage: (NSNotification *)noti {
    SimiCMSModel *cmsModel = noti.object;
    [((SimiViewController *)[[SimiGlobalVar sharedInstance] currentlyNavigationController].viewControllers.lastObject) stopLoadingData];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DidGetCMSPage object:nil];
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

@end