//
//  SCAppWishlistViewController.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 11/10/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCAppWishlistViewController.h"
#import <SimiCartBundle/SCProductListViewController.h>
#import <SimiCartBundle/SimiResponder.h>
#import "SCAppWishlistModel.h"
#import <SimiCartBundle/SCProductViewController.h>
#import "SCAppWishlistCell.h"
#import "SimiGlobalVar+WishlistVar.h"

static NSInteger const WISHLIST_ADD_TO_CART_FALSE_ALERT_TAG = 2;

@interface SCAppWishlistViewController ()
{
}

@end

@implementation SCAppWishlistViewController
{
    UIView * backgroundCellView;    
}


@synthesize tableViewProductCollection, productCollection, currentProductCollection, categoryId, isDidClickRefine, sortType, wishlistItemCount, sharingMessage, sharingUrl, currentExpandingOption,needReloadWishlist, sectionHeaderHeight;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        wishlistItemCount = nil;
        sharingMessage = nil;
        sharingUrl = nil;
        globalAppWishlistViewController = self;
        currentExpandingOption = -1;
        sectionHeaderHeight = 40.0f;
        backgroundCellView = [[UIView alloc]init];
        [backgroundCellView setBackgroundColor:[UIColor clearColor]];
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [self setToSimiView];
    needReloadWishlist = NO;
    
    tableViewProductCollection = [self createTableView] ;
    tableViewProductCollection.dataSource = self;
    tableViewProductCollection.delegate = self;
    tableViewProductCollection.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    __weak SCAppWishlistViewController *tempSelf = self;
    if(SIMI_SYSTEM_IOS >= 9){
         self.tableViewProductCollection.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [tableViewProductCollection.infiniteScrollingView setBackgroundColor:THEME_COLOR];
    [tableViewProductCollection addInfiniteScrollingWithActionHandler:^{
        [tempSelf getProducts];
    }];
    
    
    [self.view addSubview:tableViewProductCollection];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:SCLocalizedString(@"Refine") style:UIBarButtonItemStyleBordered target:self action:@selector(refine)];
    sortType = ProductCollectionSortNone;
    
    self.listEmptyText = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 170)/2, SCREEN_HEIGHT/2, 170, 15)];
    [self.listEmptyText setTextColor:[UIColor grayColor]];
    [self.listEmptyText setText:SCLocalizedString(@"Your Wishlist is empty")];
    [self.view addSubview:self.listEmptyText];
    [self.listEmptyText setHidden:YES];
    
    [self getProducts];
    self.title = SCLocalizedString(@"My Wishlist");
    
    
    [super viewDidLoad];
}

- (SimiTableView *)createTableView
{
    SimiTableView * a =   [[SimiTableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    return a;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [tableViewProductCollection deselectRowAtIndexPath:[tableViewProductCollection indexPathForSelectedRow] animated:YES];
    if(needReloadWishlist){
        [self reloadWishlist];
    }
}

- (void) reloadWishlist
{
    productCollection = nil;
    currentProductCollection = nil;
    [self reloadInputViews];
    [self getProducts];
    needReloadWishlist = NO;
}

- (void)refine{
    isDidClickRefine = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    SCRefineViewController *nextController = [[SCRefineViewController alloc]init];
    //    [nextController setSelectedCategoryID:_categoryID];
    [nextController setSortType:sortType];
    nextController.delegate = self;
    [UIView beginAnimations:@"View Flip" context:nil];
    [UIView setAnimationDuration: 0.5];
    [self.navigationController pushViewController:nextController animated:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];
}

- (void)getProducts{
    if (productCollection == nil) {
        productCollection = [[SCAppWishlistModelCollection alloc] init];
    }
    NSInteger offset = productCollection.count;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetWishlistProducts:) name:@"DidGetWishlist" object:productCollection];
    //[productCollection getAllProductsWithOffset:offset limit:10 sortType:sortType otherParams:@{@"width": @"200", @"height": @"200"}];
    [productCollection getWishlistProducts:offset limit:10 sortType:sortType otherParams:@{@"width": @"200", @"height": @"200"}];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if(currentProductCollection == nil){
        currentProductCollection = [[SCAppWishlistModelCollection alloc] init];
    }
    currentProductCollection = [productCollection mutableCopy];
    
    [tableViewProductCollection.infiniteScrollingView startAnimating];
}

- (void)didGetWishlistProducts:(NSNotification *)noti{
    
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    
    if(([currentProductCollection isEqualToArray:productCollection]) && (wishlistItemCount==(NSNumber *)[[responder.other objectAtIndex:0] objectForKey:@"wishlist_items_qty"]))
    {
        [tableViewProductCollection.infiniteScrollingView stopAnimating];
        [self stopLoadingData];
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
            wishlistItemCount = (NSNumber *)[[responder.other objectAtIndex:0] objectForKey:@"wishlist_items_qty"];
        }
        else if (wishlistItemCount == nil) {
            wishlistItemCount = [NSNumber numberWithInt:0];
        }
        [self updateWishlistQty];
        return;
    }
    currentExpandingOption = -1;
    
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        

        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        wishlistItemCount = (NSNumber *)[[responder.other objectAtIndex:0] objectForKey:@"wishlist_items_qty"];
        sharingMessage = (NSString *)[[responder.other objectAtIndex:0] objectForKey:@"sharing_message"];
        sharingUrl = (NSString *)[[responder.other objectAtIndex:0] objectForKey:@"sharing_url"];
        
        [self updateWishlistQty];
        
    }
    else if ([(NSString *)[responder.message objectAtIndex:0] isEqualToString:@"No information"]) {
        [self reloadWishlist];
        return;
    }
    
    [tableViewProductCollection reloadData];
    [globalAppWishlistViewController reloadInputViews];
    
    [tableViewProductCollection.infiniteScrollingView stopAnimating];
    [self stopLoadingData];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    if([noti.name isEqualToString: @"DidAddWishlistProductToCart"])
    {
        
        if ([responder.status isEqualToString:@"SUCCESS"])
        {
            if (globalAppWishlistiPadViewController!=nil) {
                //[globalAppWishlistiPadViewController.appWishlistView reloadWishlist];
                globalAppWishlistiPadViewController.productDetailView.productId = nil;
                [globalAppWishlistiPadViewController.view makeToast:SCLocalizedString(@"Added to cart")
                            duration:2.0
                            position:[NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)]
                 ];
            }
            else {
                [self.view makeToast:SCLocalizedString(@"Added to cart")
                            duration:2.0
                            position:[NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT-80)]
                 ];
            }
            
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Error"
                                  message: SCLocalizedString(@"The Product has NOT been Added To Cart")
                                  delegate: self
                                  cancelButtonTitle: @"OK"
                                  otherButtonTitles: nil];
            alert.tag = WISHLIST_ADD_TO_CART_FALSE_ALERT_TAG;
            [alert show];

        }
        
        
        [globalCartViewController getCart];
    }
    
    [self removeObserverForNotification:noti];
}

- (void)didRemoveProductFromWishlist: (NSNotification *)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    
    if([[responder.status uppercaseString] isEqualToString:@"SUCCESS"])
    {
        [globalAppWishlistViewController.view makeToast:SCLocalizedString(@"Removed from Wishlist")
                                               duration:2.0
                                               position:[NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT-80)]
         ];
        
        
        //decrease the items count
        wishlistItemCount = [NSNumber numberWithInt:([wishlistItemCount intValue]-1)];
        [self updateWishlistQty];
        
        @try {
            [tableViewProductCollection reloadData];
           // [tableViewProductCollection deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:currentExpandingOption inSection:0], nil] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [tableViewProductCollection.infiniteScrollingView stopAnimating];

        }
        @catch (NSException *exception) {
            [self reloadWishlist];
        }       
        @finally {
            if (globalAppWishlistiPadViewController) {
                [globalAppWishlistiPadViewController stopLoadingData];
            }
            else if (globalAppWishlistViewController) {
                [globalAppWishlistViewController stopLoadingData];
            }
        }
        
    }
    else {
    
        [globalAppWishlistViewController.view makeToast:SCLocalizedString(@"Removed from Wishlist")
                                               duration:2.0
                                               position:[NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT-80)]
         ];
        
    }
    [self removeObserverForNotification:noti];
}


#pragma mark Table View Data Source
//Gin edit
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableViewProductCollection respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableViewProductCollection setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableViewProductCollection respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableViewProductCollection setLayoutMargins:UIEdgeInsetsZero];
    }
}
//end
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return productCollection.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == currentExpandingOption)
    {
        return 232;
    }
    return 152;
}
- (SCAppWishlistCell  *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //Init cell
    static NSString *appWishlistIdentifier = @"AppWishlistIdentifier";
    SCAppWishlistCell *cell = [tableView dequeueReusableCellWithIdentifier:appWishlistIdentifier];
    cell = [[[NSBundle mainBundle]loadNibNamed:@"SCAppWishlistCell" owner:self options:nil]objectAtIndex:0];
    NSInteger row = indexPath.row;
    //Set cell data
    SCAppWishlistModel *product = [productCollection objectAtIndex:row];
    [product setValue:[NSString stringWithFormat:@"%ld. %@", (long)row+1, [product valueForKey:@"product_name"]] forKey:@"cell_product_name"];
    cell.product = product;
    [cell setInterfaceCell];
    
    //Set cell style
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [cell setSelectedBackgroundView:nil];
    
    if(currentExpandingOption == indexPath.row )
        [cell showButtons];

    return cell;
}

#pragma mark Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedRow = (int)indexPath.row;
    [self viewProductDetail:indexPath];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self createHeader];
}

- (UIView *)createHeader
{
    if([wishlistItemCount isEqualToNumber:[NSNumber numberWithInt:0]])
        return nil;
    
    CGRect frame = CGRectMake(23, 50, SCREEN_WIDTH, 40);
    
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width-130, 0, 140, 40)];
    
    //addButton.titleLabel.text = @"Share Wishlist";
    //[addButton setBackgroundColor:[UIColor grayColor]];
    
    [addButton setTitle:SCLocalizedString(@"Share Wishlist") forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    addButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
    
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    //[background setBackgroundColor:[UIColor whiteColor]];
    //[background setAlpha:1.0f];
    
    
    
    [headerView addSubview:background];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 40)];
    
    if((wishlistItemCount != nil)&&[wishlistItemCount intValue] >1)
    {
        NSString *itemText = SCLocalizedString(@"Items");
        title.text = [NSString stringWithFormat:@"%d %@", [wishlistItemCount intValue],itemText];
    }
    else
    {
        if(wishlistItemCount == nil)
            title.text = @"";
        else
        {
            NSString *itemText = SCLocalizedString(@"Item");
            title.text = [NSString stringWithFormat:@"%d %@", [wishlistItemCount intValue],itemText];
        }
    }
    
    [title setTextColor:[UIColor colorWithRed:(127/255.0) green:(127/255.0) blue:(127/255.0) alpha:1.0f]];
    title.font = [UIFont systemFontOfSize:13.0];
    [headerView addSubview:title];
    if(sharingMessage)
    {
        
        UIImageView *imgview = [[UIImageView alloc]
                                initWithFrame:CGRectMake(frame.size.width-130, 5, 30, 30)];
        [imgview setImage:[UIImage imageNamed:@"wishlist_icon_share.png"]];
        [imgview setContentMode:UIViewContentModeScaleAspectFit];
        
        [addButton addTarget:self action:@selector(shareWishlist) forControlEvents:UIControlEventTouchUpInside];
        
        [headerView addSubview:imgview];
        [headerView addSubview:addButton];
    }
    return headerView;

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return sectionHeaderHeight;
}

-(void) viewProductDetail: (NSIndexPath *)indexPath{
    
    SCAppWishlistModel *product = [productCollection objectAtIndex:indexPath.row];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectMyWishlistCellAtIndexPath" object:[product objectForKey:@"product_id"]  userInfo:@{@"app_wishlist_view_controller": self}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    SCProductViewController *productController = [[SCProductViewController alloc] init];
    [productController setProductId:[product valueForKey:@"product_id"]];
    [self.navigationController pushViewController:productController animated:YES];
}


- (void) shareWishlist {
    
    NSString *shareString = sharingMessage;
    //UIImage *shareImage = [UIImage imageNamed:@"captech-logo.jpg"];
    NSURL *shareUrl = [NSURL URLWithString:sharingUrl];
    shareString = [shareString stringByReplacingOccurrencesOfString:[shareUrl absoluteString] withString:@""];
    NSArray *activityItems = [NSArray arrayWithObjects:shareString, shareUrl, nil];
    //NSArray *activityItems = [NSArray arrayWithObjects:shareString, nil];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    
    [self presentViewController:activityViewController animated:YES completion:nil];
    
    
    /*
    UIActionSheet * sharingActionSheet = [[UIActionSheet alloc] initWithTitle:SCLocalizedString(@"Select Sharing option:")  delegate:self cancelButtonTitle:SCLocalizedString( @"Cancel") destructiveButtonTitle:nil otherButtonTitles:
          SCLocalizedString(@"Share on Facebook"),
          SCLocalizedString(@"Share on Twitter"),
          SCLocalizedString(@"Share via E-mail"),
          SCLocalizedString(@"Share via Message"),
          nil];
    [sharingActionSheet showInView:self.view];

     */
    
}

- (void) updateWishlistQty
{
    if ([wishlistItemCount isEqualToNumber:[NSNumber numberWithInt:0]]) {
        [self.listEmptyText setHidden:NO];
    }
    else {
        [self.listEmptyText setHidden:YES];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case WISHLIST_ADD_TO_CART_FALSE_ALERT_TAG:
        {
            switch (buttonIndex) {
                case 0:
                {
                    [self reloadWishlist];
                }
                break;
                default:break;
            }
            break;
        }
        default:
            NSLog(@"");
            
    }	
}



@end
