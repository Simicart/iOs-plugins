//
//  SCCustomizeInitWorker.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 12/5/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCCustomizeInitWorker.h"
#import "SCCustomizeCategoryViewController.h"
#import "SCCustomizeProductCollectionViewCell.h"
#import "SCCustomizeRegisterViewController.h"
#import "SCCustomizeHomeViewController.h"
#import "SCCustomizeHomeViewControllerPad.h"
#import "SCCustomizeProductListViewController.h"
#import "SCCustomizeNavigationBarPad.h"
#import "SCCustomizeThankyouPageViewController.h"

@implementation SCCustomizeInitWorker
{
    UITabBarController *rootController;
}
- (id)init{
    if(self == [super init]){
        _favouriteWorker = [MyFavouriteWorker new];
        _productWorker = [ProductWorker new];
        self.orderWorker = [OrderWorker new];
        self.creditCardWorker = [CreditCardInitWorker new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProduct:) name:Simi_DidGetProductModel object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProductCollection:) name:Simi_DidGetProductCollection object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetSpotProductCollection:) name:Simi_DidGetSpotProductCollection object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCategoryScreen:) name:SIMI_SHOWCATEGORY object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginRegisterProductCollectionViewCell:) name:SCProductCollectionView_RegisterCollectionViewCell object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCollectionItemSize:) name:SCProductCollectionView_UpdateSizeForItem object:nil];
        //Cursor color
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidFinishLauching:) name:ApplicationDidFinishLaunching object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCreateAccount:) name:SIMI_SHOWREGISTERSCREEN object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(initRootController:) name:Simi_InitializedRootController object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openThankyouPage:) name:SIMI_SHOWTHANKYOUPAGE object:nil];
        if (PHONEDEVICE) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showProductListScreen:) name:SIMI_SHOWPRODUCTLIST object:nil];
        }
    }
    return self;
}
- (void)appDidFinishLauching:(NSNotification *)noti{
    [[UITextField appearance] setTintColor:COLOR_WITH_HEX(@"#e42a31")];
    [[UITextView appearance] setTintColor:COLOR_WITH_HEX(@"#e42a31")];
}

- (void)didGetProductCollection:(NSNotification *)noti{
    SimiProductModelCollection *products  = noti.object;
    if(!GLOBALVAR.isLogin){
        if(products.count){
            for(SimiProductModel *product in products.collectionData){
                product.appPrices = nil;
            }
        }
    }else{
        if(products.count){
            for(SimiProductModel *product in products.collectionData){
                if([[product objectForKey:@"final_price"] floatValue] == 0 && product.productType != ProductTypeGrouped){
                    product.appPrices = nil;
                }
            }
        }
    }
}
- (void)didGetSpotProductCollection:(NSNotification *)noti{
    SimiProductModelCollection *products  = noti.object;
    if(!GLOBALVAR.isLogin){
        if(products.count){
            for(SimiProductModel *product in products.collectionData){
                product.appPrices = nil;
            }
        }
    }else{
        if(products.count){
            for(SimiProductModel *product in products.collectionData){
                if([[product objectForKey:@"final_price"] floatValue] == 0&& product.productType != ProductTypeGrouped){
                    product.appPrices = nil;
                }
            }
        }
    }
}
- (void)didGetProduct:(NSNotification *)noti{
    SimiProductModel *product = noti.object;
    if(!GLOBALVAR.isLogin){
        if(product){
            product.appPrices = nil;
        }
    }else{
        if([[product objectForKey:@"final_price"] floatValue] == 0 && product.productType != ProductTypeGrouped){
            product.appPrices = nil;
        }
    }
}
- (void)openThankyouPage:(NSNotification *)noti{
    SimiOrderModel *orderModel = [noti.userInfo objectForKey:KEYEVENT.THANKYOUPAGEVIEWCONTROLLER.order_model];
    UINavigationController *navi = [noti.userInfo objectForKey:KEYEVENT.APPCONTROLLER.navigation_controller];
    SCCustomizeThankyouPageViewController *thankVC = [[SCCustomizeThankyouPageViewController alloc] init];
    thankVC.order = orderModel;
    if (PHONEDEVICE) {
        [navi pushViewController:thankVC animated:YES];
    }else{
        UINavigationController *thankyouNavi = [[UINavigationController alloc]initWithRootViewController:thankVC];
        thankyouNavi.modalPresentationStyle = UIModalPresentationPopover;
        UIPopoverPresentationController *popover = thankyouNavi.popoverPresentationController;
        popover.sourceRect = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1);
        popover.sourceView = navi.view;
        popover.permittedArrowDirections = 0;
        [navi presentViewController:thankyouNavi animated:YES completion:nil];
    }
    SCAppController *appController = noti.object;
    appController.isDiscontinue = YES;
}
- (void)showCategoryScreen:(NSNotification*)noti{
    SCAppController *appController = noti.object;
    appController.isDiscontinue = YES;
    SCCustomizeCategoryViewController *categoryViewController = [SCCustomizeCategoryViewController new];
    categoryViewController.categoryId = [noti.userInfo valueForKey:KEYEVENT.CATEGORYVIEWCONTROLLER.category_id];
    categoryViewController.categoryRealName = [noti.userInfo valueForKey:KEYEVENT.CATEGORYVIEWCONTROLLER.category_name];
    UINavigationController *navigationController = [noti.userInfo valueForKey:KEYEVENT.APPCONTROLLER.navigation_controller];
    [navigationController pushViewController:categoryViewController animated:YES];
}

- (void)beginRegisterProductCollectionViewCell:(NSNotification*)noti{
    SCProductCollectionView *productCollectionView = noti.object;
    productCollectionView.isDiscontinue = YES;
    [productCollectionView registerClass:[SCCustomizeProductCollectionViewCell class] forCellWithReuseIdentifier:[noti.userInfo valueForKey:KEYEVENT.PRODUCTCOLLECTIONVIEW.identifier]];
}

- (void)updateCollectionItemSize:(NSNotification*)noti{
    SCProductCollectionView *collectionView = noti.object;
    NSValue *sizeValue = [noti.userInfo valueForKey:KEYEVENT.PRODUCTCOLLECTIONVIEW.item_size];
    CGSize size = sizeValue.CGSizeValue;
    NSIndexPath *indexPath = [noti.userInfo valueForKey:KEYEVENT.PRODUCTCOLLECTIONVIEW.indexpath];
    SCCustomizeProductCollectionViewCell *cell = (SCCustomizeProductCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    float heightNameLabel = CGRectGetHeight(cell.lblNameProduct.frame);
    if (heightNameLabel < 20) {
        heightNameLabel = 20;
    }
    size.height += heightNameLabel - 20;
    collectionView.itemSize = size;
    collectionView.isDiscontinue = YES;
}

- (void)showCreateAccount:(NSNotification*)noti{
    SCAppController *appController = noti.object;
    appController.isDiscontinue = YES;
    NSDictionary *params = noti.userInfo;
    UINavigationController *navi = [params valueForKey:KEYEVENT.APPCONTROLLER.navigation_controller];
    SCCustomizeRegisterViewController *registerViewController = [SCCustomizeRegisterViewController new];
    if ([params valueForKey:KEYEVENT.APPCONTROLLER.delegate]) {
        registerViewController.delegate = [params valueForKey:KEYEVENT.APPCONTROLLER.delegate];
    }
    if ([[params valueForKey:KEYEVENT.APPCONTROLLER.is_showpopover]boolValue]) {
        UINavigationController *profileNavi = [[UINavigationController alloc]initWithRootViewController:registerViewController];
        profileNavi.modalPresentationStyle = UIModalPresentationPopover;
        UIPopoverPresentationController *popover = profileNavi.popoverPresentationController;
        popover.sourceRect = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1);
        popover.sourceView = [UIApplication sharedApplication].delegate.window.rootViewController.view;
        popover.permittedArrowDirections = 0;
        [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:profileNavi animated:YES completion:nil];
    }else{
        [navi pushViewController:registerViewController animated:YES];
    }
}

- (void)initRootController:(NSNotification*)noti{
    rootController = [noti.userInfo valueForKey:KEYEVENT.INITWORKER.rootController];
    if (PHONEDEVICE) {
        SCCustomizeHomeViewController *homeViewController = [SCCustomizeHomeViewController new];
        UINavigationController *homeNavigationController = [[UINavigationController alloc]initWithRootViewController:homeViewController];
        rootController.viewControllers = @[homeNavigationController];
        [SCAppController sharedInstance].navigationBarPhone = [SCNavigationBarPhone new];
    }else{
        SCCustomizeHomeViewControllerPad *homeViewController = [SCCustomizeHomeViewControllerPad new];
        UINavigationController *homeNavigationController = [[UINavigationController alloc]initWithRootViewController:homeViewController];
        rootController.viewControllers = @[homeNavigationController];
        [SCAppController sharedInstance].navigationBarPad = [SCCustomizeNavigationBarPad new];
    }
    rootController.tabBar.hidden = YES;
    NSObject *initWorker = noti.object;
    initWorker.isDiscontinue = YES;
}

- (void)showProductListScreen:(NSNotification*)noti{
    SCAppController *appController = noti.object;
    appController.isDiscontinue = YES;
    NSDictionary *params = noti.userInfo;
    UINavigationController *navi = [params valueForKey:KEYEVENT.APPCONTROLLER.navigation_controller];
    SCCustomizeProductListViewController *productListViewController = [[SCCustomizeProductListViewController alloc]init];
    ProductListGetProductType productsType = [[params valueForKey:KEYEVENT.PRODUCTLISTVIEWCONTROLLER.getproduct_from]integerValue];
    NSString *productsId = [params valueForKey:KEYEVENT.PRODUCTLISTVIEWCONTROLLER.products_id];
    switch (productsType) {
        case ProductListGetProductTypeFromCategory:{
            productListViewController.categoryID = productsId;
        }
            break;
        case ProductListGetProductTypeFromSpot:{
            productListViewController.spotID = productsId;
        }
            break;
        case ProductListGetProductTypeFromSearch:{
            productListViewController.categoryID = productsId;
            productListViewController.keySearchProduct = [params valueForKey:KEYEVENT.PRODUCTLISTVIEWCONTROLLER.search_text];
            if ([params valueForKey:KEYEVENT.PRODUCTLISTVIEWCONTROLLER.search_option]) {
                productListViewController.isSearchOnAllProducts = [[params valueForKey:KEYEVENT.PRODUCTLISTVIEWCONTROLLER.search_option]boolValue];
            }
        }
            break;
        case ProductListGetProductTypeFromRelateProduct:{
            return;
        }
            break;
        default:
            break;
    }
    productListViewController.nameOfProductList = [params valueForKey:KEYEVENT.PRODUCTLISTVIEWCONTROLLER.products_name];;
    productListViewController.productListGetProductType = productsType;
    [navi pushViewController:productListViewController animated:YES];
}
@end
