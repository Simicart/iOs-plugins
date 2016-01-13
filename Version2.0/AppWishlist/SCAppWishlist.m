//
//  SCAppWishlist.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 11/10/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCAppWishlist.h"
#import <SimiCartBundle/UIButton+WebCache.h>
#import <SimiCartBundle/SCProductViewController.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SCLoginViewController.h>
#import "SCAppWishlistViewController.h"
#import "SimiGlobalVar+WishlistVar.h"
#import "SCAppWishlist4Theme01.h"
#import "SCAppWishlist4iPad.h"
#import <SimiCartBundle/UIImage+SimiCustom.h>
#import "UIView+Toast.h"
#import <SimiCartBundle/BBBadgeBarButtonItem.h>

#define PRODUCT_LABEL_IDENTIFIER @"SIMI_PRODUCT_LABEL"
#define THEME01_IMAGEVIEW_TAG 1000
#define THEME01_PRODUCT_ADDTOWISHLIST_BUTTON_TAG 1001



@implementation SCAppWishlist{
    SCAppWishlist4Theme01 * appWishlistThem01;
    SCAppWishlist4iPad * appWishlistiPad;
    UIImageView * roundBackground;
    UIPopoverController * wishlistPopOver;
    SCLoginViewController * loginVC;
    UIButton * rightButton;
    BBBadgeBarButtonItem * rightBadgeBarButton;
}



@synthesize product, imageView, wishlistProductCollection, addToWishlistButton;
@synthesize currentProductIdOnWishlist, wishlistItemsQty, moreViewController, myWishlistRow, productViewController, addorremoveprocessing, accountViewController, reloadAddToWishlistIcon, currentAddToWishlistButton, updateProductViewControllerWhileAppears, notAddedYetButtonImage, addedByNowButtonImage , addOrRemoveProcessingButtonImage;
;


- (id)init{
    wishlistPopOver = nil;
    moreViewController = nil;
    accountViewController = nil;
    productViewController = nil;
    product = nil;
    imageView = nil;
    wishlistProductCollection = nil;
    addToWishlistButton = nil;
    currentAddToWishlistButton = nil;
    
    currentProductIdOnWishlist = nil;
    myWishlistRow = nil;
    addToCartButtonBackgroundImage = nil;
    roundBackground = nil;
       
    
    [SCAppWishlistViewController singleton];
    
    //reloadAddToWishlistIcon = NO;
    updateProductViewControllerWhileAppears = NO;

    
    currentProductIdOnWishlist = @"0";
    wishlistItemsQty = 0;
    wishlistProductCollection =[[SCAppWishlistModelCollection alloc]init];
    addorremoveprocessing = NO;
    
    //moreViewController = [[SCMoreViewController alloc]init];
    [self initImages];
    self = [super init];
    
    if (self) {
        
        addToCartButtonBackgroundImage = [[UIImage imageNamed:@"pixel"]imageWithColor:THEME_COLOR];
        
        myWishlistRow = [[SimiRow alloc] initWithIdentifier:@"MYWISHLIST" height:40];
        NSString * wishlistTitle = SCLocalizedString(@"My Wishlist");
        myWishlistRow.title = wishlistTitle;
        myWishlistRow.image = [UIImage imageNamed:@"wishlisticon3"];
        myWishlistRow.simiObjectIdentifier = @"MYWISHLIST";
        myWishlistRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controllerViewDidLoad:) name:@"SimiViewController-ViewDidLoad" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTheArrays:) name:@"SCProductViewController-ViewWillAppear" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMoreViewController:) name:@"SCMoreViewController-ViewWillAppear" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addCellToMoreViewController:) name:@"SCMoreViewController_InitCellsAfter" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:@"DidLogin" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetWishlistProducts:) name:@"DidGetWishlist" object:nil];
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zThemeNavigationBarPadReturnRightButtonItems:) name:@"ZThemeNavigationBarPad_ReturnRightButtonItems" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zThemeNavigationBarReturnRightButtonItems:) name:@"ZThemeNavigationBar_ReturnRightButtonItems" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zThemeProductViewControllerPadDidGetProduct:) name:@"ZThemeProductViewControllerPad_DidGetProduct" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zThemeProductViewControllerPadDidChangeProduct:) name:@"ZThemeProductViewControllerPad_DidChangeProduct" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zThemeProductViewControllerPadDidGetProduct:) name:@"ZThemeProductViewController_DidGetProduct" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zThemeProductViewControllerPadDidChangeProduct:) name:@"ZThemeProductViewController_DidChangeProduct" object:nil];
        
        appWishlistThem01 = [SCAppWishlist4Theme01 new];
        appWishlistThem01.appwishlistCoreWorker = self;
        
        appWishlistiPad = [SCAppWishlist4iPad new];
        appWishlistiPad.appwishlistCoreWorker = self;
    }
    return self;
}


#pragma mark -
#pragma mark Receive Notification

- (void)didReceiveNotification:(NSNotification *)noti{
    
    if ([noti.name isEqualToString:@"DidDrawProductImageView"])
    {
        NSString* string = [NSString stringWithCString:class_getName([noti.object class]) encoding:NSASCIIStringEncoding];
        if([string isEqualToString:@"UIImageView"])
        {
        UIImageView * a = (UIImageView *) noti.object;
            [self addAddToWishlistButtonToProductView:a :[noti.userInfo valueForKey:@"product"]];
        }
    }
}

-(void)didRemoveProductFromWishlist: (NSNotification *)noti{
    
SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];

    if(([[responder.status uppercaseString] isEqualToString:@"SUCCESS"]) && (imageView != nil) && (product != nil))
    {
        //decrease the items count
        globalAppWishlistViewController.wishlistItemCount = [NSNumber numberWithInt:([globalAppWishlistViewController.wishlistItemCount intValue]-1)];
        [globalAppWishlistViewController updateWishlistQty];
        
        updateProductViewControllerWhileAppears = YES;
        
        addorremoveprocessing = NO;
        currentProductIdOnWishlist = @"0";
        
        [currentAddToWishlistButton setImage:notAddedYetButtonImage forState:UIControlStateNormal];
        
        [currentAddToWishlistButton removeTarget:self action:@selector(removeFromWishlist:)  forControlEvents:UIControlEventTouchUpInside];
        [currentAddToWishlistButton addTarget:self action:@selector(addToWishList:) forControlEvents:UIControlEventTouchUpInside];
        
        globalAppWishlistViewController.needReloadWishlist = YES;
              
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Warning" message: (NSString*)[responder.message objectAtIndex:0] delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
    
    
    [globalAppWishlistViewController reloadWishlist];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"DidRemoveProductFromWishlist" object:nil];
}

-(void)didAddProductToWishlist: (NSNotification *)noti{
     SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if(([[responder.status uppercaseString] isEqualToString:@"SUCCESS"]) && (imageView != nil) && (product != nil))
    {
        
        updateProductViewControllerWhileAppears = YES;
        
        addorremoveprocessing = NO;
        currentProductIdOnWishlist = [[responder.other objectAtIndex:0] objectForKey:@"wishlist_item_id"];
        [currentAddToWishlistButton setImage:addedByNowButtonImage forState:UIControlStateNormal];
        [currentAddToWishlistButton removeTarget:self action:@selector(addToWishList:)  forControlEvents:UIControlEventTouchUpInside];
        [currentAddToWishlistButton addTarget:self action:@selector(removeFromWishlist:) forControlEvents:UIControlEventTouchUpInside];
        
        wishlistItemsQty = (NSNumber *)[[responder.other objectAtIndex:0] objectForKey:@"wishlist_items_qty"] ;
        
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Warning" message: (NSString*)[responder.message objectAtIndex:0] delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        reloadAddToWishlistIcon = YES;
        [productViewController getProduct];
    }
    
    
    [globalAppWishlistViewController reloadWishlist];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"DidAddProductToWishlist" object:nil];
}

-(void)updateTheArrays: (NSNotification *)noti
{
    SCProductViewController * tempProductViewController = (SCProductViewController *)noti.object;
   
    
    
    for( UITableViewCell *tempCell in [tempProductViewController.tableViewProduct visibleCells])
    {
        for (UIView *i in tempCell.subviews){
            if([i isKindOfClass:[UIButton class]]){
                UIButton *tempBtn = (UIButton *)i;
                if(tempBtn.tag == 1){
                    if(productViewController!=nil){
                        if(productViewController!=tempProductViewController)
                        {
                            currentAddToWishlistButton = tempBtn;
                            reloadAddToWishlistIcon = NO;
                            productViewController = tempProductViewController;
                            
                            if(!updateProductViewControllerWhileAppears) return;
                            
                            //[self addAddToWishlistButtonToProductView:imageView :product];
                            [tempProductViewController getProduct];
                            
                            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidDrawProductImageView" object:nil];
                        }
                    }
                }
            }
        }
    }
    
}


-(UIButton *)addAddToWishlistButtonToProductView:(UIImageView*)inputImageView :(SimiProductModel *) inputProduct{
    
   
    imageView = inputImageView;
    addorremoveprocessing = NO;
    product = inputProduct;
    bool alreadyOnWishlist = NO;
    
    if(([product objectForKey:@"wishlist_item_id"])&&(![((NSString *)[product objectForKey:@"wishlist_item_id"]) isEqualToString:@"0"]))
    {
        alreadyOnWishlist = YES;
        if(appWishlistiPad.actived)
        {
            [appWishlistiPad updateCurrentProductIdOnWishlist:imageView :[product objectForKey:@"wishlist_item_id"]];
        }
        else
            currentProductIdOnWishlist = [product objectForKey:@"wishlist_item_id"];
    }
    
    if(reloadAddToWishlistIcon)
    {
        
        [self createAddToWishlistButton:imageView];
        
        if (alreadyOnWishlist)
        {
            [addToWishlistButton setImage:addedByNowButtonImage forState:UIControlStateNormal];
            [addToWishlistButton addTarget:self action:@selector(removeFromWishlist:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            [addToWishlistButton setImage:notAddedYetButtonImage forState:UIControlStateNormal];
            [addToWishlistButton addTarget:self action:@selector(addToWishList:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        currentAddToWishlistButton = addToWishlistButton;
        addToWishlistButton.tag = 1;
        
        if(roundBackground !=nil)
        {
            [imageView.superview addSubview:roundBackground];
        }
        
        
        [imageView.superview addSubview:addToWishlistButton];
        [imageView.superview bringSubviewToFront:addToWishlistButton];
        reloadAddToWishlistIcon = NO;
    }
    else
    {
        if (alreadyOnWishlist)
        {
            [currentAddToWishlistButton setImage:addedByNowButtonImage forState:UIControlStateNormal];
            [currentAddToWishlistButton removeTarget:self action:@selector(addToWishList:)  forControlEvents:UIControlEventTouchUpInside];
            [currentAddToWishlistButton addTarget:self action:@selector(removeFromWishlist:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            [currentAddToWishlistButton removeTarget:self action:@selector(removeFromWishlist:)  forControlEvents:UIControlEventTouchUpInside];
            [currentAddToWishlistButton setImage:notAddedYetButtonImage forState:UIControlStateNormal];
            [currentAddToWishlistButton addTarget:self action:@selector(addToWishList:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        
        [imageView.superview bringSubviewToFront:currentAddToWishlistButton];
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"DidDrawProductImageView" object:nil];
    
    return currentAddToWishlistButton;
}

-(void) updateMoreViewController: (NSNotification *)noti{
    moreViewController = (SCMoreViewController *)noti.object;
}

-(void) addCellToMoreViewController:(NSNotification *)noti{

    //if(moreViewController==nil)
    //    moreViewController = (SCMoreViewController*)noti.object;
    if(moreViewController==nil)
        return;
    
    if( [moreViewController.cells count]==0) return;
    
    SimiSection * firstSection = (SimiSection *)[moreViewController.cells objectAtIndex:0];

    globalAppWishlistViewController.needReloadWishlist = YES;
    
    if ([[SimiGlobalVar sharedInstance] isLogin])
    {
        SimiSection * firstSection = (SimiSection *)[moreViewController.cells objectAtIndex:0];
        BOOL alreadyAdded = NO;
        for (SimiRow* row in firstSection.rows)
        {
            if(row == myWishlistRow)
                alreadyAdded = YES;
        }
        if (!alreadyAdded){
            [firstSection addRow:myWishlistRow];
            
            [[NSNotificationCenter defaultCenter]removeObserver:self name:@"SCMoreViewController_DidSelectCellAtIndexPath" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openWishlistView:) name: @"SCMoreViewController_DidSelectCellAtIndexPath" object:nil];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogout:) name:@"DidLogout" object:nil];
        
    }
    else
    {
        for (SimiRow* row in firstSection.rows)
        {
            if(row == myWishlistRow)
                [firstSection.rows removeObject:row];
        }

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:@"DidLogin" object:nil];
    }

    
    
}

- (void)controllerViewDidLoad:(NSNotification *)noti{
    /*
     for adding My Wishlist icon to MoreViewController
     
     *
     */
    
        NSString * viewClassName = NSStringFromClass([noti.object class]);
        if([viewClassName isEqualToString:@"SCProductViewController"])
        {
            productViewController = (SCProductViewController *)noti.object;
            product = productViewController.product;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidDrawProductImageView" object:nil];
            reloadAddToWishlistIcon = YES;
        }
        else if([viewClassName isEqualToString:@"SCCartViewController"])
        {
            globalCartViewController = noti.object;
        }    
        else if([viewClassName isEqualToString:@"SCMoreViewController"])
        {
            moreViewController = noti.object;
            if([[SimiGlobalVar sharedInstance] isLogin])
            {
                SimiSection * firstSection = (SimiSection *)[moreViewController.cells objectAtIndex:0];
                BOOL alreadyAdded = NO;
                for (SimiRow* row in firstSection.rows)
                {
                    if(row == myWishlistRow)
                    alreadyAdded = YES;
                }
                if (!alreadyAdded)
                {
                    [firstSection.rows addObject:myWishlistRow];
                    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"SCMoreViewController_DidSelectCellAtIndexPath" object:nil];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openWishlistView:) name: @"SCMoreViewController_DidSelectCellAtIndexPath" object:nil];
                }
            }
        }
        else if([viewClassName isEqualToString:@"SCAccountViewController"])
        {
            accountViewController = noti.object;
            SimiSection *section =  (SimiSection *)[accountViewController.accountCells objectAtIndex:0];
            //[section addRowWithIdentifier:MY_WISHLIST_ROW height:44 sortOrder:3];
            //[section addRowWithIdentifier:MY_WISHLIST_ROW height:44];
            SimiRow * newRow = [[SimiRow alloc]initWithIdentifier:MY_WISHLIST_ROW height:44];
            [section.rows insertObject:newRow atIndex:3];
            newRow = nil;
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addToMyAccountViewController:) name:@"InitializedAccountCell-After" object:nil];
            
            [[NSNotificationCenter defaultCenter]removeObserver:self name:@"DidSelectAccountCellAtIndexPath" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellDidSelectedOnAccountViewController:) name:@"DidSelectAccountCellAtIndexPath" object:nil];
            
        }
        else
        {
            [appWishlistiPad viewControllerDidLoad:noti];
            [appWishlistThem01 viewControllerDidLoad:noti];            
        }
}

- (void)didLogout:(NSNotification *)noti{
    if ([noti.name isEqualToString:@"DidLogout"]){

        
        [self removeObserverForNotification:noti];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:@"DidLogin" object:nil];
        
        [self removeObserverForNotification:noti];
        
        [[NSNotificationCenter defaultCenter]removeObserver:self name:@"DidSelectAccountCellAtIndexPath" object:nil];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:@"SCMoreViewController_DidSelectCellAtIndexPath" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:@"DidLogin" object:nil];

    }
    
}

- (void)didLogin:(NSNotification *)noti{
    if ([noti.name isEqualToString:@"DidLogin"]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogout:) name:@"DidLogout" object:nil];
    }
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([[responder.status uppercaseString] isEqualToString:@"SUCCESS"]) {
        if (wishlistPopOver!=nil) {
            [wishlistPopOver dismissPopoverAnimated:YES];
            wishlistPopOver = nil;
        }
        wishlistItemsQty = (NSNumber *)[(SimiModel *)noti.object objectForKey:@"wishlist_items_qty"];
        if (rightBadgeBarButton !=nil)
            rightBadgeBarButton.badgeValue = [wishlistItemsQty stringValue];
    }
    [self removeObserverForNotification:noti];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogout:) name:@"DidLogout" object:nil];
}


- (void)didCancelLogin: (NSNotification *)noti
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"DidLogin" object:nil];
    [self removeObserverForNotification:noti];
}

-(void) openWishlistView:(NSNotification *)noti{
    NSIndexPath * indexPath = [noti.userInfo objectForKey:@"indexPath"];
    SimiSection *section = [moreViewController.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if ([row.identifier isEqualToString:@"MYWISHLIST"]) {
        if ([(NSString *)row.simiObjectIdentifier isEqualToString:@"MYWISHLIST"]) {
            SCAppWishlistViewController *wishlistController = [SCAppWishlistViewController singleton];
            [moreViewController.navigationController pushViewController:wishlistController animated:YES];
            moreViewController.isDiscontinue = YES;
        }
    }
}

-(void) didGetWishlistProducts: (NSNotification *)noti {
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    rightBadgeBarButton.badgeValue = [(NSNumber *)[[responder.other objectAtIndex:0] objectForKey:@"wishlist_items_qty"] stringValue] ;
    
}

-(void) zThemeNavigationBarReturnRightButtonItems: (NSNotification *)noti {
    NSMutableArray * rightButtonItems = (NSMutableArray *)noti.object;

    if (rightButton == nil) {
        rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        [rightButton setImage:[UIImage imageNamed:@"ztheme_ic_wishlist.png"] forState:UIControlStateNormal];
        [rightButton addTarget:appWishlistThem01 action:@selector(pushWishlistViewController) forControlEvents:UIControlEventTouchUpInside];
        rightButton.alpha = 1;
        UIBarButtonItem * rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        if (rightBadgeBarButton == nil) {
            rightBadgeBarButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:rightButton];
            rightBadgeBarButton.shouldHideBadgeAtZero = YES;
            rightBadgeBarButton.badgeValue = [wishlistItemsQty stringValue];
            rightBadgeBarButton.badgeMinSize = 3;
            rightBadgeBarButton.badgePadding = 3;
            rightBadgeBarButton.badgeOriginX = rightButton.frame.size.width - 10;
            rightBadgeBarButton.badgeOriginY = rightButton.frame.origin.y - 3;
            rightBadgeBarButton.badgeFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
            [rightBadgeBarButton setTintColor:THEME_COLOR];
            rightBadgeBarButton.badgeBGColor = [UIColor whiteColor];
            rightBadgeBarButton.badgeTextColor = THEME_COLOR;
        }
        
        rightBarButtonItem.simiObjectName = @"zThemeWishlistRightBadgeBarButton";
        for (NSObject * buttonItem in rightButtonItems) {
            if ([buttonItem.simiObjectName isEqualToString:@"zThemeWishlistRightBadgeBarButton"]) {
                [rightButtonItems removeObject:buttonItem];
            }
        }
        [rightButtonItems addObject:rightBarButtonItem];
    }
}

-(void) zThemeNavigationBarPadReturnRightButtonItems:(NSNotification *)noti {
    NSMutableArray * rightButtonItems = (NSMutableArray *)noti.object;
    if ([rightButtonItems count] == 2)
        return;

    if (rightButton == nil) {
        rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [rightButton setImage:[UIImage imageNamed:@"ztheme_ic_wishlist.png"] forState:UIControlStateNormal];
        [rightButton addTarget:appWishlistThem01 action:@selector(pushWishlistViewController) forControlEvents:UIControlEventTouchUpInside];
        rightButton.alpha = 1;
    }
    UIBarButtonItem * rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    if (rightBadgeBarButton == nil) {
        rightBadgeBarButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:rightButton];
        rightBadgeBarButton.shouldHideBadgeAtZero = YES;
        rightBadgeBarButton.badgeValue = [wishlistItemsQty stringValue];
        rightBadgeBarButton.badgeMinSize = 4;
        rightBadgeBarButton.badgePadding = 4;
        rightBadgeBarButton.badgeOriginX = rightButton.frame.size.width - 15;
        rightBadgeBarButton.badgeOriginY = rightButton.frame.origin.y;
        rightBadgeBarButton.badgeFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        [rightBadgeBarButton setTintColor:THEME_COLOR];
        rightBadgeBarButton.badgeBGColor = [UIColor whiteColor];
        rightBadgeBarButton.badgeTextColor = THEME_COLOR;
    }
    
    UIBarButtonItem *itemSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    itemSpace.width = 10;
    [rightButtonItems insertObject:rightBarButtonItem atIndex:2];
    [rightButtonItems insertObject:itemSpace atIndex:3];
}

-(void)zThemeProductViewControllerPadDidGetProduct : (NSNotification *)noti
{
    productViewController = (SCProductViewController *)noti.object;
    product = productViewController.product;
    [self zThemeAddAddToWishlistButton];
}

-(void)zThemeProductViewControllerPadDidChangeProduct: (NSNotification *)noti
{
    if (productViewController.product == nil) {
        if (addToWishlistButton !=nil)
            [addToWishlistButton removeFromSuperview];
        addToWishlistButton = nil;
    }
    else {
        [self zThemeAddAddToWishlistButton];
    }
}

-(void)zThemeAddAddToWishlistButton {
    UIImageView *tempView;
    for (UIView * subView in productViewController.view.subviews) {
        if ([(NSString *)subView.simiObjectIdentifier isEqualToString:@"tempViewWishlistZTheme"]) {
            tempView = (UIImageView *)subView;
        }
    }
    if (tempView == nil) {
        tempView = [[UIImageView alloc]initWithFrame:CGRectMake(200, 200, 400, 400)];
        tempView.simiObjectIdentifier = @"tempViewWishlistZTheme";
        [productViewController.view addSubview:tempView];
    }
    reloadAddToWishlistIcon = YES;
    if (addToWishlistButton !=nil) {
        [addToWishlistButton removeFromSuperview];
        addToWishlistButton = nil;
    }
    [self addAddToWishlistButtonToProductView:tempView :productViewController.product];
}

#pragma  mark -
#pragma  mark wishlist add/remove button event


-(IBAction) removeFromWishlist:(id)sender
{
    BOOL runRemovingFunction = NO;
    if (appWishlistiPad.actived &&(!addorremoveprocessing)) {
        runRemovingFunction = [appWishlistiPad clickedRemoveFromWishlist:sender];
    }
    else {
        if ((![currentProductIdOnWishlist isEqualToString: @"0"]) && (!addorremoveprocessing)) {
            currentAddToWishlistButton = (UIButton *)sender;
            addorremoveprocessing = YES;
            runRemovingFunction = YES;
            [wishlistProductCollection removeProductFromWishlist:currentProductIdOnWishlist otherParams:nil];
            [currentAddToWishlistButton setImage:addOrRemoveProcessingButtonImage forState:UIControlStateNormal];
        }
    }
    if(runRemovingFunction)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveProductFromWishlist:) name:@"DidRemoveProductFromWishlist" object:nil];
    }
}


-(IBAction) addToWishList:(id)sender
{
    BOOL runAddingFunction = NO;
    
    if(productViewController==nil) return;
    if(!addorremoveprocessing)
    {
        currentAddToWishlistButton = (UIButton *)sender;
        if (appWishlistiPad.actived && (currentAddToWishlistButton.superview.tag != THEME01_IMAGEVIEW_TAG)) {
            runAddingFunction = [appWishlistiPad clickedAddToWishlist:sender];
        }
        else {
            currentAddToWishlistButton = (UIButton *)sender;
            if([[SimiGlobalVar sharedInstance] isLogin])
            {
                if((![productViewController isCheckedAllRequiredOptions])&&(productViewController.optionDict.count != 0))
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Required options are not selected.") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
                    [alertView show];
                }
                else
                {
                    product = productViewController.product;
                    addorremoveprocessing = YES;
                    [currentAddToWishlistButton setImage:addOrRemoveProcessingButtonImage forState:UIControlStateNormal];
                    UIImageView *thumnailView = [[UIImageView alloc]initWithFrame:CGRectMake(160, 0, 60, 90)];
                    thumnailView.image = imageView.image;
                    [thumnailView setContentMode:UIViewContentModeScaleAspectFit];
                    [imageView.superview addSubview:thumnailView];
                    [imageView.superview bringSubviewToFront:thumnailView];
                    
                    [UIView animateWithDuration:0.6
                                          delay:0
                                        options:UIViewAnimationOptionAllowAnimatedContent
                                     animations:^{
                                         CGRect frame = imageView.superview.frame;
                                         thumnailView.frame = CGRectMake(3*frame.size.width/4-15, frame.size.height, 60, 90);
                                         thumnailView.transform = CGAffineTransformMakeRotation(140);
                                     }
                                     completion:^(BOOL finished){
                                         [thumnailView removeFromSuperview];
                                     }];
                    //[imageView.superview startLoadingData];
                    
                    
                    NSMutableArray *selectedOptions = [[NSMutableArray alloc] init];
                    for (NSDictionary *option in [product valueForKeyPath:@"options"]) {
                        if ([[option valueForKeyPath:@"is_selected"] boolValue]) {
                            [selectedOptions addObject:option];
                        }
                    }
                    
                    
                    
                    SimiProductModel *cartItem = [[SimiProductModel alloc] init];
                    [cartItem setValue:[product valueForKeyPath:@"product_id"] forKey:@"product_id"];
                    [cartItem setValue:[product valueForKeyPath:@"product_name"] forKey:@"product_name"];
                    [cartItem setValue:[product valueForKeyPath:@"product_price"] forKey:@"product_price"];
                    [cartItem setValue:[product valueForKeyPath:@"product_image"] forKey:@"product_image"];
                    [cartItem setValue:[product valueForKeyPath:@"product_qty"] forKey:@"product_qty"];
                    [cartItem setValue:selectedOptions forKey:@"options"];
                    
                    runAddingFunction = YES;
                    
                    [wishlistProductCollection addProductToWishlist:cartItem otherParams:nil];
                    
                }
            }
            else{
                //haven't logged in
                loginVC = [[SCLoginViewController alloc]init];
                loginVC.navigationItem.title = [SCLocalizedString(@"Sign In") uppercaseString];

                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    UINavigationController *navi;
                    navi = [[UINavigationController alloc]initWithRootViewController:loginVC];

                    if(wishlistPopOver == nil){
                        wishlistPopOver = [[UIPopoverController alloc]initWithContentViewController:navi];
                    }
                    [wishlistPopOver presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:productViewController.view permittedArrowDirections:0 animated:YES];
                    wishlistPopOver.delegate = self;
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:@"DidLogin" object:nil];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCancelLogin:) name:@"SCLoginViewController-DidCancel" object:nil];
                }
                else
                    [productViewController.navigationController pushViewController:loginVC animated:YES];
                loginVC = nil;
            }
        }
    }else
    {
        
    }
    if(runAddingFunction)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddProductToWishlist:) name:@"DidAddProductToWishlist" object:nil];
    }
}


#pragma mark -
#pragma mark init Functions

-(void)initImages
{
    if ([SimiGlobalVar sharedInstance].themeUsing == ThemeShowZTheme) {
        addedByNowButtonImage =  [UIImage imageNamed:@"ztheme_ic_wishlist_product_2"];
        notAddedYetButtonImage = [UIImage imageNamed:@"ztheme_ic_wishlist_product_1"];
        addOrRemoveProcessingButtonImage = [self.class imageWithName:@"ztheme_ic_wishlist_product_2" withColor:[UIColor lightGrayColor]];
        return;
    }
    
    addedByNowButtonImage = [self.class imageWithName:@"wishlisticon2" withColor:[UIColor redColor]];
    notAddedYetButtonImage = [self.class imageWithName:@"wishlisticon1" withColor:[UIColor redColor]];
    addOrRemoveProcessingButtonImage = [self.class imageWithName:@"wishlisticon2" withColor:[self.class lighterColorForColor:[UIColor redColor]]];
}


#pragma mark -
#pragma mark Image With Color


+(UIImage *)imageWithName:(NSString *)name withColor:(UIColor *)color {
    
    UIImage *img = [UIImage imageNamed:name];
    
    UIGraphicsBeginImageContext(img.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [color setFill];
    
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return coloredImg;
}




+ (UIColor *)lighterColorForColor:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MIN(r + 0.2, 1.0)
                               green:MIN(g + 0.2, 1.0)
                                blue:MIN(b + 0.2, 1.0)
                               alpha:a];
    return nil;
}


#pragma mark create AddToWishlistButton

-(void)createAddToWishlistButton: (UIImageView *)rootImageView
{
    addToWishlistButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addToWishlistButton.frame = CGRectMake(10.0, 5.0, 50.0, 50.0);
    [addToWishlistButton setImageEdgeInsets:UIEdgeInsetsMake(15.0, 15.0, 15.0, 15.0)];
    if(appWishlistThem01.actived)
    {
        addToWishlistButton.frame = CGRectMake(15.0, 80.0, 50.0, 50.0);
    }
    
    if ([SimiGlobalVar sharedInstance].themeUsing == ThemeShowZTheme) {
        addToWishlistButton.frame = CGRectMake(0.0, 40.0, 65.0, 65.0);
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        roundBackground = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"round_wishlist_background"]];
        [roundBackground setAlpha:0.75f];
        if (rootImageView.tag == THEME01_IMAGEVIEW_TAG) {
            rootImageView.superview.tag = THEME01_IMAGEVIEW_TAG;
            roundBackground.frame = CGRectMake(50.0, 175.0, 30.0, 30.0);
            addToWishlistButton.frame = CGRectMake(45.0, 170.0, 40.0, 40.0);
            [addToWishlistButton setImageEdgeInsets:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)];
        }
        else {
            roundBackground.frame = CGRectMake(30.0, 75.0, 30.0, 30.0);
            addToWishlistButton.frame = CGRectMake(25.0, 70.0, 40.0, 40.0);
            [addToWishlistButton setImageEdgeInsets:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)];
        }
        if ([SimiGlobalVar sharedInstance].themeUsing == ThemeShowZTheme) {
            roundBackground.frame = CGRectMake(0, 0, 0, 0);
            addToWishlistButton.frame = CGRectMake(25.0, 70.0, 65.0, 65.0);
        }
    }
}

#pragma mark add to MyAccount viewController

-(void)addToMyAccountViewController: (NSNotification*)noti
{
    if([[SimiGlobalVar sharedInstance] isLogin])
    {
        NSIndexPath *indexPath = [noti.userInfo objectForKey:@"indexPath"];
        SimiRow *row = [(SimiSection *)[accountViewController.accountCells objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        UITableViewCell *cell = (UITableViewCell *)noti.object;
        if ([row.identifier isEqualToString:MY_WISHLIST_ROW]) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = SCLocalizedString(@"My Wishlist");
        }
    }
    
}

-(void)cellDidSelectedOnAccountViewController: (NSNotification *)noti
{
    SimiRow *row = (SimiRow *)noti.object;
    if ([row.identifier isEqualToString:MY_WISHLIST_ROW]) {
       
        SCAppWishlistViewController *wishlistController = [SCAppWishlistViewController singleton];
        [accountViewController.navigationController pushViewController:wishlistController animated:YES];
        accountViewController.isDiscontinue = YES;        

    }

}


#pragma mark dealloc


- (void)dealloc
{

    
    [[NSNotificationCenter defaultCenter]removeObserver:accountViewController name:@"DidLogout" object:nil];

    [[NSNotificationCenter defaultCenter]removeObserver:self];
    appWishlistiPad = nil;
    appWishlistThem01 = nil;
    
}



@end
