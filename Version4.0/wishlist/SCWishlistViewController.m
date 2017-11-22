//
//  SCWishlistViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/25/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SCWishlistViewController.h"
#import <SimiCartBundle/UIScrollView+SVInfiniteScrolling.h>

#define COLLECTIONVIEWCELLHEIGHT 150
#define WISHLISTCOLLECTIONVIEWCELL @"WISHLISTCOLLECTIONVIEWCELL"

@interface SCWishlistViewController ()

@end

@implementation SCWishlistViewController{
    UICollectionView* wishlistCollectionView;
    SCWishlistModelCollection* wishlistModelCollection;
    UIView* wishlistShareView;
    UILabel* emptyLabel;
}

- (void)viewDidLoadBefore {
    [super viewDidLoadBefore];
    self.eventTrackingName = @"wishlist_action";
    float paddingX = 5;
    float paddingY = 5;
    //Add notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetWishlistItems:) name:DidGetWishlistItems object:nil];
    //Init Model and request get wishlist items
    wishlistModelCollection = [SCWishlistModelCollection new];
    
    //Wishlist Share View
    float wishlistShareViewHeight = 40;
    wishlistShareView = [[UIView alloc] initWithFrame:CGRectMake(0, paddingY, SCREEN_WIDTH, wishlistShareViewHeight)];
    wishlistShareView.backgroundColor = COLOR_WITH_HEX(@"#e8e8e8");
    UILabel* wishlistShareLabel = [[UILabel alloc] init];
    wishlistShareLabel.text = SCLocalizedString(@"Share Wishlist");
    wishlistShareLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE - 2];
    [wishlistShareView addSubview:wishlistShareLabel];
    UIImageView* wishlistShareImageView = [[UIImageView alloc] init];
    wishlistShareImageView.image = [UIImage imageNamed:@"wishlist_share_icon"];
    [wishlistShareView addSubview:wishlistShareImageView];
    CGSize fittingShareLabelSize = [wishlistShareLabel.text sizeWithAttributes:@{NSFontAttributeName : wishlistShareLabel.font}];
    CGRect frame = wishlistShareView.frame;
    frame.size.width = fittingShareLabelSize.width + wishlistShareViewHeight + paddingX;
    frame.origin.x = SCREEN_WIDTH - frame.size.width - paddingX;
    wishlistShareView.frame = frame;
    wishlistShareLabel.frame = CGRectMake(frame.size.width - fittingShareLabelSize.width - paddingX, 0, fittingShareLabelSize.width, wishlistShareViewHeight);
    wishlistShareImageView.frame = CGRectMake(wishlistShareViewHeight/3, wishlistShareViewHeight/3, wishlistShareViewHeight/3, wishlistShareViewHeight/3);
    [wishlistShareView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wishlistShareViewTapped:)]];
    [self.view addSubview:wishlistShareView];
    
    //Add wishlist collection view
    UICollectionViewFlowLayout* collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    if(PHONEDEVICE)
        collectionViewLayout.itemSize = CGSizeMake(SCREEN_WIDTH, COLLECTIONVIEWCELLHEIGHT);
    else if(PADDEVICE)
        collectionViewLayout.itemSize = CGSizeMake(SCREEN_WIDTH/2 - paddingX, COLLECTIONVIEWCELLHEIGHT);
    wishlistCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, wishlistShareViewHeight + paddingY, self.view.bounds.size.width, self.view.bounds.size.height - wishlistShareViewHeight - paddingY * 2 - 64) collectionViewLayout:collectionViewLayout];
    wishlistCollectionView.backgroundColor = [UIColor whiteColor];
    wishlistCollectionView.delegate = self;
    wishlistCollectionView.dataSource = self;
    [self.view addSubview:wishlistCollectionView];
    //Handle after scroll to bottom collection view
    __block __weak id weakSelf = self;
    [wishlistCollectionView addInfiniteScrollingWithActionHandler:^{
        [weakSelf getWishlistItems];
    }];
    emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, paddingY, SCREEN_WIDTH, 30)];
    emptyLabel.text = SCLocalizedString(@"Your wishlist is empty");
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
    [self.view addSubview:emptyLabel];
    [SimiGlobalFunction sortViewForRTL:self.view andWidth:SCREEN_WIDTH];
}

- (void)viewWillAppearBefore:(BOOL)animated{
    [super viewWillAppearBefore:animated];
    //Hide all view before load wishlist items
    emptyLabel.hidden = YES;
    wishlistShareView.hidden = YES;
    wishlistCollectionView.hidden = YES;
    [self getWishlistItemsFromBegin];
}

- (void)handleWishlistItemsCount{
    if(wishlistModelCollection.count > 0){
        wishlistCollectionView.hidden = NO;
        wishlistShareView.hidden = NO;
        emptyLabel.hidden = YES;
    }else{
        wishlistCollectionView.hidden = YES;
        wishlistShareView.hidden = YES;
        emptyLabel.hidden = NO;
    }
}

- (void)getWishlistItemsFromBegin{
    [wishlistModelCollection removeAllObjects];
    [wishlistCollectionView setContentOffset:CGPointZero animated:NO];
    [wishlistModelCollection getWishlistItemsWithParams:@{@"offset":[NSString stringWithFormat:@"%ld",(long) wishlistModelCollection.count],@"limit":@"10"}];
    [self startLoadingData];
}

- (void)getWishlistItems{
    [wishlistModelCollection getWishlistItemsWithParams:@{@"offset":[NSString stringWithFormat:@"%ld",(long) wishlistModelCollection.count],@"limit":@"10"}];
}

- (void)didGetWishlistItems: (NSNotification*) noti{
    [self stopLoadingData];
    SimiResponder* responder = [noti.userInfo objectForKey:responderKey];
    [wishlistCollectionView.infiniteScrollingView stopAnimating];
    if(responder.status == SUCCESS){
        [wishlistCollectionView reloadData];
        [self handleWishlistItemsCount];
    }else{
        [self showAlertWithTitle:@"" message:responder.message completionHandler:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)wishlistShareViewTapped: (id) sender{
    UIView* view = ((UITapGestureRecognizer* )sender).view;
    [self shareWishlistWithText:wishlistModelCollection.sharingMessage url:wishlistModelCollection.sharingURL inView:view];
}

#pragma mark UICollectionViewDelegate && UICollectionViewDataSource
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (UICollectionViewCell* )collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString* identifier = [NSString stringWithFormat:@"%@%ld",WISHLISTCOLLECTIONVIEWCELL,(long) indexPath.row];
    [collectionView registerClass:[SCWishlistCollectionViewCell class] forCellWithReuseIdentifier:identifier];
    SCWishlistCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.wishlistItem = [wishlistModelCollection objectAtIndex:indexPath.row];
    cell.delegate = self;
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return wishlistModelCollection.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

#pragma mark SCWishlistCollectionViewCellDelegate
- (void)deleteWishlistItem:(SCWishlistModel *)wishlistItem{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:SCLocalizedString(@"Confirmation") message:[NSString stringWithFormat:@"%@?",SCLocalizedString(@"Are you sure you want to remove this product from wishlist")] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:SCLocalizedString(@"Yes") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDeleteWishlistItem:) name:DidRemoveWishlistItem object:nil];
        [wishlistModelCollection removeItemWithWishlistItemID:wishlistItem.wishlistItemId];
        [self startLoadingData];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:SCLocalizedString(@"No") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
     [self presentViewController:alert animated:YES completion:nil];
}

- (void)tapToWishlistItem:(SCWishlistModel *)wishlistItem{
    [[SCAppController sharedInstance] openProductWithNavigationController:self.navigationController productId:wishlistItem.productId moreParams:@{}];
    
}

- (void)addToCartWithWishlistItem:(SCWishlistModel *)wishlistItem{
    
    if(wishlistItem.selectedAllRequiredOptions){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddProductFromWishlistToCart:) name:DidAddProductFromWishlistToCart object:nil];
        [wishlistModelCollection addProductToCartWithWishlistID:wishlistItem.wishlistItemId];
        [self startLoadingData];
    }else{
        [[SCAppController sharedInstance]openProductWithNavigationController:self.navigationController productId:wishlistItem.productId moreParams:nil];
    }
}


- (void)shareWishlistItem:(SCWishlistModel *)wishlistItem inView:(UIView *)view{
    [self shareWishlistWithText:wishlistItem.productSharingMessage url:wishlistItem.productSharingUrl  inView:view];
   
}

- (void)shareWishlistWithText: (NSString*) text url:(NSString*) url inView:(UIView*) view{
    NSURL *shareUrl = [NSURL URLWithString:url];
    NSArray *activityItems = [NSArray arrayWithObjects:text, shareUrl, nil];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        [self presentViewController:activityViewController animated:YES completion:nil];
    else {
        UIPopoverController *popOver = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
        [popOver presentPopoverFromRect:CGRectMake(0, 0, 40, 40) inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

//Notifications Catched
- (void)didAddProductFromWishlistToCart: (NSNotification* ) noti{
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    if(responder.status == SUCCESS){
        [self showToastMessage:@"Added to cart and removed from wishlist"];
    }else{
        [self showAlertWithTitle:@"" message:responder.message];
    }
    if(PHONEDEVICE)
        [[[[SCAppController sharedInstance] navigationBarPhone] cartController] getCart];
    // get wishlist again
    [self getWishlistItemsFromBegin];
}
- (void)didDeleteWishlistItem: (NSNotification*) noti{
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    if(responder.status == SUCCESS){
        [self showToastMessage:@"Removed from wishlist"];
    }else{
        [self showAlertWithTitle:@"" message:responder.message];
    }
    [wishlistCollectionView reloadData];
    [self handleWishlistItemsCount];
}

@end
