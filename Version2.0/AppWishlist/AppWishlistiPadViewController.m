//
//  AppWishlistiPadViewController.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/9/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "AppWishlistiPadViewController.h"
#import "SCAppWishlistModelCollection.h"
#import "SCAppWishlistModel.h"
#import "SimiGlobalVar+WishlistVar.h"

@interface AppWishlistiPadViewController ()

@end


@implementation AppWishlistiPadViewController
{
    UIColor * colorBG;
    UIView * listEmptyText;
}

@synthesize appWishlistView, productDetailView, shareWishlistAnchor, header
;


- (void)viewDidLoad {
    [super viewDidLoad];

    colorBG =[UIColor colorWithRed:(240/255.0) green:(240/255.0) blue:(240/255.0) alpha:1.0];
    
    appWishlistView = nil;
    productDetailView = nil;
    listEmptyText = nil;
    
    appWishlistView = [[SCAppWishlistViewController_Pad alloc] init];
    productDetailView = [[SCProductViewController_Pad alloc] init];
    
    shareWishlistAnchor = [[UIView alloc]initWithFrame:CGRectMake(100, 110, 10, 10)];
    
    listEmptyText = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    UILabel * listEmptyTextLabel;
    listEmptyTextLabel = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 170)/2, SCREEN_HEIGHT/2, 170, 15)];
    [listEmptyTextLabel setTextColor:[UIColor grayColor]];
    [listEmptyTextLabel setText:SCLocalizedString(@"Your Wishlist is empty")];
    
    [listEmptyText addSubview:listEmptyTextLabel];
    
    [self.view addSubview:listEmptyText];
    [listEmptyText setHidden:YES];
    
    
    appWishlistView.view.frame = CGRectMake(1, 40, 320, SCREEN_HEIGHT-70);
    [appWishlistView.tableViewProductCollection setBackgroundColor:[UIColor whiteColor]];
    appWishlistView.sectionHeaderHeight = 0.0f;
    [appWishlistView.view setBackgroundColor:colorBG];
    appWishlistView.tableViewProductCollection.separatorColor = colorBG;
    
    
    //appWishlistView.tableViewProductCollection.style = UITableViewStylePlain ;
    
    productDetailView.view.frame = CGRectMake(322, 40, SCREEN_WIDTH - 320, SCREEN_HEIGHT-110);
    
    
    [self startLoadingData];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectMyWishlistCellAtIndexPath:) name:@"DidSelectMyWishlistCellAtIndexPath" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddWishlistProductToCart:) name:@"DidAddWishlistProductToCart" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogout:) name:@"DidLogout" object:nil];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    
}

- (void)didSelectMyWishlistCellAtIndexPath: (NSNotification *)noti
{
    NSString * productId = (NSString *)noti.object;
    productDetailView.productId = productId;
    [productDetailView getProduct];
    globalAppWishlistViewController.isDiscontinue = YES;
}

-(void)didLogout : (NSNotification *)noti
{
    [self.navigationController popViewControllerAnimated:YES];
    [self removeObserverForNotification:noti];
}

- (void)didAddWishlistProductToCart: (NSNotification *)noti
{

}

- (void)didGetWishlist: (NSNotification *)noti
{
    [self stopLoadingData];
        
    [self.view addSubview:appWishlistView.view];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    NSNumber * wishlistItemCount = (NSNumber *)[[responder.other objectAtIndex:0] objectForKey:@"wishlist_items_qty"];
    [self.view setBackgroundColor:colorBG];
    
    [self updateWishlistQty];
    
    if ([wishlistItemCount intValue] > 0){
        if (productDetailView.productId == nil) {
            SCAppWishlistModelCollection * a = (SCAppWishlistModelCollection *)noti.object;
            SCAppWishlistModel * firstItem = (SCAppWishlistModel *)[a objectAtIndex:0];
            productDetailView.productId = [firstItem objectForKey:@"product_id"];
            [productDetailView getProduct];
            
            [self.view addSubview:productDetailView.view];
        }
    }
    else {
        
    }
    
    [appWishlistView updateWishlistQty];
    [productDetailView.tableViewProduct setSeparatorColor:colorBG];
    [productDetailView.separatingLine setBackgroundColor:colorBG];
    [productDetailView.scrollViewProduct.layer setBorderColor:[colorBG CGColor]];
    [productDetailView.scrollViewProduct.layer setBorderWidth:1.0f];
    
    [self createHeader];
    
}

-(void)createHeader
{
    [self updateWishlistQty];
    if ([appWishlistView.wishlistItemCount intValue] == 0) {
        return;
    }
    [header removeFromSuperview];
    header = nil;
    header = [appWishlistView createHeader];
    header.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    [header setBackgroundColor:colorBG];
    [self.view addSubview:header];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc
{
   
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateWishlistQty
{
    if ([appWishlistView.wishlistItemCount intValue] >0) {
        [listEmptyText setHidden:YES];
        [appWishlistView.view setHidden:NO];
        [productDetailView.view setHidden:NO];
    }
    else {
        [header removeFromSuperview];
        [listEmptyText setHidden:NO];
        [appWishlistView.view setHidden:YES];
        [productDetailView.view setHidden:YES];
    }
}


@end
