//
//  SCWishlistViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/25/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SCWishlistViewController.h"

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

- (void)viewDidLoad {
    [super viewDidLoad];
    float paddingX = 5;
    float paddingY = 5;
    //Add notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddProductFromWishlistToCart:) name:DidAddProductFromWishlistToCart object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDeleteWishlistItem:) name:DidRemoveWishlistItem object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetWishlistItems:) name:DidGetWishlistItems object:nil];
    //Init Model and request get wishlist items
    wishlistModelCollection = [SCWishlistModelCollection new];
    
    //Wishlist Share View
    float wishlistShareViewHeight = 40;
    wishlistShareView = [[UIView alloc] initWithFrame:CGRectMake(0, paddingY, SCREEN_WIDTH, wishlistShareViewHeight)];
    wishlistShareView.backgroundColor = COLOR_WITH_HEX(@"#e8e8e8");
    UILabel* wishlistShareLabel = [[UILabel alloc] init];
    wishlistShareLabel.text = SCLocalizedString(@"Share Wishlist");
    wishlistShareLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
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
    wishlistShareImageView.frame = CGRectMake(wishlistShareViewHeight/4, wishlistShareViewHeight/4, wishlistShareViewHeight/2, wishlistShareViewHeight/2);
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
    [wishlistCollectionView registerClass:[SCWishlistCollectionViewCell class] forCellWithReuseIdentifier:WISHLISTCOLLECTIONVIEWCELL];
    emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, paddingY, SCREEN_WIDTH, 30)];
    emptyLabel.text = SCLocalizedString(@"Your wishlist is empty");
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
    [self.view addSubview:emptyLabel];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //Hide all view before load wishlist items
    emptyLabel.hidden = YES;
    wishlistShareView.hidden = YES;
    wishlistCollectionView.hidden = YES;
    [wishlistModelCollection getWishlistItems];
    [self startLoadingData];
}

-(void) didGetWishlistItems: (NSNotification*) noti{
    [self stopLoadingData];
    SimiResponder* responder = [noti.userInfo objectForKey:@"responder"];
    
    if([responder.status isEqualToString:@"SUCCESS"]){
        [wishlistCollectionView reloadData];
        if(wishlistModelCollection.count > 0){
            wishlistCollectionView.hidden = NO;
            wishlistShareView.hidden = NO;
            emptyLabel.hidden = YES;
        }else{
            wishlistCollectionView.hidden = YES;
            wishlistShareView.hidden = YES;
            emptyLabel.hidden = NO;
        }
    }else{
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) wishlistShareViewTapped: (id) sender{
    UIView* view = ((UITapGestureRecognizer* )sender).view;
    [self shareWishlistWithText:wishlistModelCollection.sharingMessage url:wishlistModelCollection.sharingURL inView:view];
}

#pragma mark UICollectionViewDelegate && UICollectionViewDataSource
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(UICollectionViewCell* ) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SCWishlistCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:WISHLISTCOLLECTIONVIEWCELL forIndexPath:indexPath];
    cell.wishlistItem = [wishlistModelCollection objectAtIndex:indexPath.row];
    cell.delegate = self;
    return cell;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return wishlistModelCollection.count;
}

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

#pragma mark SCWishlistCollectionViewCellDelegate
-(void) deleteWishlistItem:(NSDictionary *)wishlistItem{
    [wishlistModelCollection removeItemWithWishlistItemID:[wishlistItem objectForKey:@"wishlist_item_id"]];
    [self startLoadingData];
}

-(void) tapToWishlistItem:(NSDictionary *)wishlistItem{
    SCProductViewController* productVC;
    if(PHONEDEVICE){
        productVC = [SCProductViewController new];
    }else{
        productVC = [SCProductViewControllerPad new];
    }
    productVC.productId = [wishlistItem objectForKey:@"product_id"];
    productVC.arrayProductsID = [NSMutableArray arrayWithArray:@[productVC.productId]];
    productVC.firstProductID = productVC.productId;
    [self.navigationController pushViewController:productVC animated:YES];
}

-(void) addToCartWithWishlistItem:(NSDictionary *)wishlistItem{
    
    if([[wishlistItem objectForKey:@"selected_all_required_options"] boolValue]){
        [wishlistModelCollection addProductToCartWithWishlistID:[wishlistItem objectForKey:@"wishlist_item_id"]];
        [self startLoadingData];
    }else{
        SCProductViewController* productVC;
        if(PHONEDEVICE){
            productVC = [SCProductViewController new];
        }else{
            productVC = [SCProductViewControllerPad new];
        }
        productVC.productId = [wishlistItem objectForKey:@"product_id"];
        productVC.arrayProductsID = [NSMutableArray arrayWithArray:@[productVC.productId]];
        productVC.firstProductID = productVC.productId;
        [self.navigationController pushViewController:productVC animated:YES];
    }
}

-(void) shareWishlistItem:(NSDictionary *)wishlistItem inView:(UIView *)view{
    [self shareWishlistWithText:[wishlistItem objectForKey:@"product_sharing_message"] url:[wishlistItem objectForKey:@"product_sharing_url"] inView:view];
   
}

-(void) shareWishlistWithText: (NSString*) text url:(NSString*) url inView:(UIView*) view{
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
-(void) didAddProductFromWishlistToCart: (NSNotification* ) noti{
    [self stopLoadingData];
    if(PHONEDEVICE)
        [[[[SCThemeWorker sharedInstance] navigationBarPhone] cartViewController] getCart];
    else if(PADDEVICE)
        [[[[SCThemeWorker sharedInstance] navigationBarPad] cartViewControllerPad] getCart];
    // get wishlist again
    [wishlistModelCollection getWishlistItems];
    [self startLoadingData];
}
-(void) didDeleteWishlistItem: (NSNotification*) noti{
    [self stopLoadingData];
    [wishlistCollectionView reloadData];
}

@end
