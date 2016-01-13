//
//  SCAppWishlist4iPad.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/5/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCAppWishlist4iPad.h"
#import "SCProductViewController_Pad.h"
#import <SimiCartBundle/SCLoginViewController.h>
#import <SimiCartBundle/SCAppDelegate.h>
#import "SimiNavigationBarWorker.h"
#import "SCLeftMenuView.h"
#import "SimiGlobalVar+WishlistVar.h"

@implementation SCAppWishlist4iPad
{
        NSMutableArray *cells;
}


@synthesize appwishlistCoreWorker, productViewControllerMap, appWishlistPadView
;


-(id)init
{
    self = [super init];
    if (self) {
        
        
        self.actived = NO;
        
        productViewControllerMap = [NSMutableArray arrayWithObjects: nil];
        
        ipadProductDetailsViews = [[NSMutableArray alloc]initWithObjects: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SCProductViewController_Pad_controllerViewWillAppear:) name:@"SCProductViewController_Pad-ViewWillAppear" object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SCLeftMenuAddingWishlistRow:) name:@"SCLeftMenu_DidGetLocationRowStoreLocator" object:nil];
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SCLeftMenuAddingWishlistRow:) name:@"SCLeftMenu_InitCellsAfter" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SCLeftMenuAddingWishlistRow:) name:@"SCLeftMenu_DidSelectRow" object:nil];
        
        
    }
    return self;
}

#pragma mark -
#pragma mark Events catcher

-(void)viewControllerDidLoad: (NSNotification *)noti
{
    NSString * viewClassName = NSStringFromClass([noti.object class]);
    if([viewClassName isEqualToString:@"SCProductViewController_Pad"])
    {
        self.actived = YES;
        
        UIImageView * tempImageView = [[UIImageView alloc]init];
        
        
        SCProductViewController_Pad * a = (SCProductViewController_Pad *)noti.object;
        [a.scrollView addSubview:tempImageView];
        appwishlistCoreWorker.imageView = tempImageView;
        
        appwishlistCoreWorker.productViewController = (SCProductViewController *)noti.object;
        appwishlistCoreWorker.product = appwishlistCoreWorker.productViewController.product;
        appwishlistCoreWorker.reloadAddToWishlistIcon = YES;
        

        
         UIButton * tempButton = [appwishlistCoreWorker addAddToWishlistButtonToProductView: appwishlistCoreWorker.imageView :appwishlistCoreWorker.product];
        
        NSMutableArray * tempArray = [NSMutableArray  arrayWithObjects:tempImageView, a , tempButton , nil];
        
        [productViewControllerMap addObject:tempArray];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidDrawProductImageView" object:nil];
        
    }
}

-(void)SCLeftMenuAddingWishlistRow: (NSNotification *)noti
{
    if ([noti.name isEqualToString:@"SCLeftMenu_InitCellsAfter"])
    {
        cells =  noti.object;
        SimiSection *section = (SimiSection *)[cells objectAtIndex:0];
        
        [section removeRowByIdentifier:MY_WISHLIST_ROW_IPAD];
        if([[SimiGlobalVar sharedInstance] isLogin])
        {
            SimiRow *row = [self createMyWishlistRow];
            [section addObject:row];
            
        }        
    }
    /*
    else if ([noti.name isEqualToString:@"SCLeftMenu_UpdateCellsForTableView_Pad"])
    {
        
        SCLeftMenuView * a = (SCLeftMenuView *)noti.object;
        cells =  a.cells;
        SimiSection *section = (SimiSection *)[cells objectAtIndex:0];

        if ([[SimiGlobalVar sharedInstance] isLogin]) {
            SimiRow *row = [self createMyWishlistRow];
            [section addObject:row];
        }
        else {
            [section removeRowByIdentifier:MY_WISHLIST_ROW_IPAD];
        }
        
        
    }
     */
    else if ([noti.name isEqualToString:@"SCLeftMenu_DidSelectRow"]) {
        SimiRow *row = [(SimiRow*)noti.userInfo valueForKey:@"simirow"];
        UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
        if ([row.identifier isEqualToString:MY_WISHLIST_ROW_IPAD]) {
            SimiNavigationBarWorker *navi = noti.object;
            if (appWishlistPadView == nil)
            {
                appWishlistPadView = [[AppWishlistiPadViewController alloc]init];
                globalAppWishlistiPadViewController = appWishlistPadView;
            }
            else
            {
                //[appWishlistPadView.appWishlistView getProducts];
            }
            [(UINavigationController *)currentVC popToRootViewControllerAnimated:NO];
            [(UINavigationController *)currentVC pushViewController:appWishlistPadView animated:YES];
            
            navi.isDiscontinue = YES;
             
        }
    }
}

-(void)didReceiveNotification: (NSNotification *)noti
{
    NSString* string = [NSString stringWithCString:class_getName([noti.object class]) encoding:NSASCIIStringEncoding];
    if([string isEqualToString:@"UIImageView"])
    {
        SimiProductModel * tempProduct = [noti.userInfo objectForKey:@"product"];
        if(tempProduct!=nil)
        {
       
            for (NSMutableArray * a in productViewControllerMap)
            {
                SCProductViewController_Pad * tempProductViewController = [a objectAtIndex:1];
                if(tempProductViewController.product == tempProduct)
                {
                    appwishlistCoreWorker.currentAddToWishlistButton = [a objectAtIndex:2];
                    appwishlistCoreWorker.product = tempProduct;
                    appwishlistCoreWorker.imageView = [a objectAtIndex:0];
                    appwishlistCoreWorker.productViewController = (SCProductViewController *)tempProductViewController;
                    appwishlistCoreWorker.reloadAddToWishlistIcon = NO;
                    
                    [appwishlistCoreWorker addAddToWishlistButtonToProductView: appwishlistCoreWorker.imageView :appwishlistCoreWorker.product];
                }
            }
        }
    }

}

-(void)SCProductViewController_Pad_controllerViewWillAppear: (NSNotification *)noti
{
    if ([ NSStringFromClass([noti.object class]) isEqualToString:@"SCProductViewController_Pad"]) {
        BOOL existed = NO;
        for (SCProductViewController_Pad * a in ipadProductDetailsViews) {
            if (a == noti.object) {
                existed = YES;
                break;
            }
        }
        if (!existed) {
            [ipadProductDetailsViews addObject:(SCProductViewController_Pad *)noti.object];
        }
    }
}


-(BOOL)clickedRemoveFromWishlist:(UIButton *)button
{
    BOOL runRemovingFunction = NO;
    
    for (NSMutableArray * a in productViewControllerMap)
    {
        if([a objectAtIndex:2] == button)
        {
            SCProductViewController_Pad * tempProductViewController = [a objectAtIndex:1];
            appwishlistCoreWorker.currentAddToWishlistButton = button;
            appwishlistCoreWorker.product = tempProductViewController.product;
            appwishlistCoreWorker.imageView = [a objectAtIndex:0];
            appwishlistCoreWorker.productViewController = (SCProductViewController *)tempProductViewController;
            appwishlistCoreWorker.reloadAddToWishlistIcon = NO;
            
            appwishlistCoreWorker.addorremoveprocessing = YES;
            runRemovingFunction = YES;
            
            [appwishlistCoreWorker.wishlistProductCollection removeProductFromWishlist:appwishlistCoreWorker.currentProductIdOnWishlist otherParams:nil];
    
            [appwishlistCoreWorker.currentAddToWishlistButton setImage:appwishlistCoreWorker.addOrRemoveProcessingButtonImage forState:UIControlStateNormal];
        }
    }
    return runRemovingFunction;
    
}


-(BOOL)clickedAddToWishlist: (UIButton*)button
{
    BOOL runAddingfunction = NO;
    for (NSMutableArray * a in productViewControllerMap)
    {
        if( [a objectAtIndex:2] == button){
            SCProductViewController_Pad * tempProductViewController = [a objectAtIndex:1];
            appwishlistCoreWorker.currentAddToWishlistButton = button;
            appwishlistCoreWorker.product = tempProductViewController.product;
            appwishlistCoreWorker.imageView = [a objectAtIndex:0];
            appwishlistCoreWorker.productViewController = (SCProductViewController *)tempProductViewController;
            appwishlistCoreWorker.reloadAddToWishlistIcon = NO;
            
            if((![appwishlistCoreWorker.productViewController isCheckedAllRequiredOptions])&& (appwishlistCoreWorker.productViewController.optionDict.count != 0))
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Required options are not selected.") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
                [alertView show];
                break;
            }
            
            if([[SimiGlobalVar sharedInstance] isLogin])
            {
                {
                    appwishlistCoreWorker.addorremoveprocessing = YES;
                    [appwishlistCoreWorker.currentAddToWishlistButton setImage:appwishlistCoreWorker.addOrRemoveProcessingButtonImage forState:UIControlStateNormal];
                    
                    
                    NSMutableArray *selectedOptions = [[NSMutableArray alloc] init];
                    for (NSDictionary *option in [appwishlistCoreWorker.product valueForKeyPath:@"options"]) {
                        if ([[option valueForKeyPath:@"is_selected"] boolValue]) {
                            [selectedOptions addObject:option];
                        }
                    }
                    
                    
                    
                    SimiProductModel *cartItem = [[SimiProductModel alloc] init];
                    [cartItem setValue:[appwishlistCoreWorker.product valueForKeyPath:@"product_id"] forKey:@"product_id"];
                    [cartItem setValue:[appwishlistCoreWorker.product valueForKeyPath:@"product_name"] forKey:@"product_name"];
                    [cartItem setValue:[appwishlistCoreWorker.product valueForKeyPath:@"product_price"] forKey:@"product_price"];
                    [cartItem setValue:[appwishlistCoreWorker.product valueForKeyPath:@"product_image"] forKey:@"product_image"];
                    [cartItem setValue:[appwishlistCoreWorker.product valueForKeyPath:@"product_qty"] forKey:@"product_qty"];
                    [cartItem setValue:selectedOptions forKey:@"options"];
                    
                    runAddingfunction = YES;
                    
                    [appwishlistCoreWorker.wishlistProductCollection addProductToWishlist:cartItem otherParams:nil];
                }
            }
            else{
                //haven't logged in
                SCLoginViewController *nextController = [[SCLoginViewController alloc]init];
                nextController.navigationItem.title = @"title";
                UINavigationController * tempNavigation = appwishlistCoreWorker.productViewController.navigationController;
                if(tempNavigation != nil)
                {
                    [appwishlistCoreWorker.productViewController.navigationController pushViewController:nextController animated:YES];
                }
                else
                {
                    UIPopoverController * popController = nil;
                    popController = [[UIPopoverController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:nextController]];
                    nextController.isInPopover = YES;
                    nextController.popover = popController;
                    [popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:appwishlistCoreWorker.productViewController.view.superview permittedArrowDirections:0 animated:YES];
                }
                nextController = nil;
            }

            break;
            
            
        }
    }
    return runAddingfunction;
   
}


#pragma mark my wishlist row

- (SimiRow *)createMyWishlistRow
{
    SimiRow *row = [[SimiRow alloc]initWithIdentifier:MY_WISHLIST_ROW_IPAD height:40];
    row.title = SCLocalizedString(@"My Wishlist");
    row.image = [UIImage imageNamed:@"wishlisticon3"];
    row.accessoryType = UITableViewCellAccessoryNone;
    return row;
}


#pragma mark update another view

-(void)updateCurrentProductIdOnWishlist: (UIImageView *)image :(NSString *)id
{
    for (NSMutableArray * a in productViewControllerMap) {
        if (image == [a objectAtIndex:0]) {
            SCProductViewController_Pad * tempProductViewController = [a objectAtIndex:1];            
            if (tempProductViewController.isViewLoaded && tempProductViewController.view.window)
                appwishlistCoreWorker.currentProductIdOnWishlist = id;
            break;
        }
    }
}

#pragma mark dealloc


- (void)dealloc
{
    ipadProductDetailsViews = nil;
       
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
