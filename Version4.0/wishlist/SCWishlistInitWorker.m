//
//  SCWishlistInitWorker.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/25/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SCWishlistInitWorker.h"
#import <SimiCartBundle/SCProductMoreViewController.h>
#import <SimiCartBundle/SimiViewController.h>
#import <SimiCartBundle/SCLoginViewController.h>
#import <SimiCartBundle/SCAccountViewController.h>
#import <SimiCartBundle/SCLeftMenuViewController.h>
#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SCNavigationBarPhone.h>
#import <SimiCartBundle/SCProductSecondDesignViewController.h>
#import "SCWishlistModelCollection.h"
#import "SCWishlistModel.h"
#import "SCWishlistViewController.h"

#define BUTTON_SIZE 50
#define ACCOUNT_WISHLIST_ROW @"ACCOUNT_WISHLIST_ROW"
#define LEFTMENU_WISHLIST_ROW @"LEFTMENU_WISHLIST_ROW"

#define PRODUCT_IS_NOT_IN_WISHLIST @"PRODUCT_IS_NOT_IN_WISHLIST"

@implementation SCWishlistInitWorker{
    SimiViewController* currentlyViewController;
    UIButton* wishlistButton;
    NSMutableDictionary* product;
    SCWishlistModelCollection* wishlistModelCollection;
    SCWishlistModel* wishlistModel;
    SCWishlistViewController* wishlistViewController;
}
-(id) init{
    if(self == [super init]){
        //Product More View
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initViewMoreAction:) name:@"SCProductMoreViewController_InitViewMoreAction" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beforeTouchMoreAction:) name:@"SCProductMoreViewController-BeforeTouchMoreAction" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initViewMoreAction:) name:@"SCProductViewController_InitViewMoreAction" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beforeTouchMoreAction:) name:@"SCProductViewController_BeforeTouchMoreAction" object:nil];
        
        
        //My Account Screen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializedAccountCellAfter:) name:@"SCAccountViewController-InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectAccountCellAtIndexPath:) name:@"DidSelectAccountCellAtIndexPath" object:nil];
        
        //Left Menu
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listMenuInitCellsAfter:) name:Simi_SCLeftMenuViewControler_InitCells_End object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listMenuDidSelectRow:) name:Simi_SCLeftMenuViewControler_DidSelectCell object:nil];
        
        wishlistModelCollection = [SCWishlistModelCollection new];
        wishlistModel = [SCWishlistModel new];
    }
    return self;
}

#pragma mark Event Handlers
//Add wishlist button on product more view screen
- (void)initViewMoreAction:(NSNotification *)noti
{
    MoreActionView * actionView = noti.object;
    if(!wishlistButton){
        wishlistButton = [UIButton new];
        [wishlistButton setImageEdgeInsets:UIEdgeInsetsMake(9, 9, 9, 9)];
        [wishlistButton.layer setCornerRadius:25.0f];
        [wishlistButton.layer setShadowOffset:CGSizeMake(1, 1)];
        [wishlistButton.layer setShadowRadius:2];
        wishlistButton.layer.shadowOpacity = 0.5;
        [wishlistButton setBackgroundColor:[UIColor whiteColor]];
        [wishlistButton addTarget:self action:@selector(didTouchWishlistButton) forControlEvents:UIControlEventTouchUpInside];
    }
    actionView.numberIcon += 1;
    [actionView.arrayIcon addObject:wishlistButton];
}

//Update product and wishlist button
- (void)beforeTouchMoreAction:(NSNotification *)noti
{
    currentlyViewController = noti.object;
    if ([noti.object isKindOfClass:[SCProductMoreViewController class]]) {
        product = ((SCProductMoreViewController*)currentlyViewController).productModel;
    }else if ([noti.object isKindOfClass:[SCProductSecondDesignViewController class]])
    {
        product = ((SCProductSecondDesignViewController*)currentlyViewController).product;
    }
    
    [self updateWishlistIcon];
}

#pragma mark Update Wishlist Icon
-(void)updateWishlistIcon
{
    if (![product objectForKey:@"wishlist_item_id"] || [[product objectForKey:@"wishlist_item_id"] isEqualToString:PRODUCT_IS_NOT_IN_WISHLIST] )
        [wishlistButton setImage:[UIImage imageNamed:@"wishlist_empty_icon"] forState:UIControlStateNormal];
    else
        [wishlistButton setImage:[UIImage imageNamed:@"wishlist_color_icon"] forState:UIControlStateNormal];
}

#pragma mark Wishlist Button Touched

- (void)didTouchWishlistButton
{
    if (![[SimiGlobalVar sharedInstance] isLogin]) {
        [currentlyViewController.navigationController pushViewController:[SCLoginViewController new] animated:YES];
        return;
    }
    [wishlistButton setEnabled:NO];
    if (![product objectForKey:@"wishlist_item_id"] || [[product objectForKey:@"wishlist_item_id"] isEqualToString:PRODUCT_IS_NOT_IN_WISHLIST])
        [self addProductToWishlist];
    else
        [self removeProductFromWishlist];
}

#pragma mark Add to Wishlist
- (void)addProductToWishlist
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddProductToWishlist:) name:DidAddProductToWishList object:nil];
    if ([currentlyViewController isKindOfClass:[SCProductMoreViewController class]]) {
        [wishlistModel addProductWithParams:((SCProductMoreViewController*)currentlyViewController).cartItem];
    }else if ([currentlyViewController isKindOfClass:[SCProductSecondDesignViewController class]])
    {
        [wishlistModel addProductWithParams:((SCProductSecondDesignViewController*)currentlyViewController).cartItem];
    }
    [currentlyViewController startLoadingData];
}

- (void)didAddProductToWishlist:(NSNotification *)noti
{
    [wishlistButton setEnabled:YES];
    [currentlyViewController stopLoadingData];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        NSString* wishlistItemID = [wishlistModel objectForKey:@"wishlist_item_id"];
        if(wishlistItemID)
            [product setObject:wishlistItemID forKey:@"wishlist_item_id"];
        [self updateWishlistIcon];
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:responder.responseMessage  delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    [self removeObserverForNotification:noti];
}

#pragma mark Remove From Wishlist
-(void)removeProductFromWishlist
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveProductFromWishlist:) name:DidRemoveWishlistItem object:nil];
    [wishlistModelCollection removeItemWithWishlistItemID:[product objectForKey:@"wishlist_item_id"]];
}

- (void)didRemoveProductFromWishlist:(NSNotification *)noti
{
    [wishlistButton setEnabled:YES];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        [product setObject:PRODUCT_IS_NOT_IN_WISHLIST forKey:@"wishlist_item_id"];
        [self updateWishlistIcon];
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:responder.responseMessage  delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    [self removeObserverForNotification:noti];
}

#pragma mark Add to My Account Screen
-(void)initializedAccountCellAfter:(NSNotification *)noti
{
    SimiTable* cells = [[SimiTable alloc] initWithArray:noti.object];
    SimiSection* section = [cells getSectionByIdentifier:ACCOUNT_MAIN_SECTION];
    SimiRow *wishlistRow = [[SimiRow alloc]initWithIdentifier:ACCOUNT_WISHLIST_ROW height:45 sortOrder:310];
    wishlistRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    wishlistRow.title = SCLocalizedString(@"My Wishlist");
    wishlistRow.image = [UIImage imageNamed:@"wishlist_account_icon"];
    [section addRow:wishlistRow];
}

-(void)didSelectAccountCellAtIndexPath:(NSNotification *)noti
{
    if ([[(SimiRow *)noti.object identifier] isEqualToString:ACCOUNT_WISHLIST_ROW]) {
        SCAccountViewController *accountVC = [noti.userInfo objectForKey:@"self"];
        if (PADDEVICE) {
            [accountVC dismissViewControllerAnimated:YES completion:nil];
        }
        if (wishlistViewController == nil) {
            wishlistViewController = [SCWishlistViewController new];
        }
        UINavigationController *currentVC = kNavigationController;
        UIViewController *viewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
        for (UIViewController *viewControllerTemp in viewController.navigationController.viewControllers) {
            if (viewControllerTemp == wishlistViewController) {
                [viewControllerTemp.navigationController popToViewController:viewControllerTemp animated:YES];
                return;
            }
        }
        [currentVC pushViewController:wishlistViewController animated:YES];
        accountVC.isDiscontinue = YES;
    }
}

#pragma mark Add to Left Menu
-(void)listMenuInitCellsAfter:(NSNotification *)noti{
    if([SimiGlobalVar sharedInstance].isLogin){
        SimiTable * cells = [[SimiTable alloc] initWithArray:noti.object];
        SimiSection* section = [cells getSectionByIdentifier:LEFTMENU_SECTION_MAIN];
        SimiRow *wishlistRow = [[SimiRow alloc]initWithIdentifier:LEFTMENU_WISHLIST_ROW height:45 sortOrder:310];
        wishlistRow.title = SCLocalizedString(@"My Wishlist");
        wishlistRow.image = [UIImage imageNamed:@"wishlist_leftmenu_icon"];
        [section addRow:wishlistRow];
    }
}

-(void)listMenuDidSelectRow:(NSNotification *)noti{
    NSIndexPath *indexPath = [noti.userInfo valueForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.indexpath];
    SimiTable *cells = noti.object;
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if ([row.identifier isEqualToString: LEFTMENU_WISHLIST_ROW]) {
        if (wishlistViewController == nil) {
            wishlistViewController = [SCWishlistViewController new];
        }
        UINavigationController *currentVC = kNavigationController;
        UIViewController *viewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
        for (UIViewController *viewControllerTemp in viewController.navigationController.viewControllers) {
            if (viewControllerTemp == wishlistViewController) {
                [viewControllerTemp.navigationController popToViewController:viewControllerTemp animated:YES];
                return;
            }
        }
        [currentVC pushViewController:wishlistViewController animated:YES];
        [(SCNavigationBarPhone*)noti.object setIsDiscontinue:YES];
    }
}
#pragma mark dealloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
