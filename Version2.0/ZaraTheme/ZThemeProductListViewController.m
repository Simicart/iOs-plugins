//
//  ZThemeProductListViewController.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 4/7/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeProductListViewController.h"
@class ZThemeProductListViewController;
@interface ZThemeProductListViewController ()

@end

@implementation ZThemeProductListViewController

@synthesize zCollectionView, zCollectionGetProductType;
@synthesize spot_ID, categoryId, categoryName, keySearchProduct;
@synthesize searchProduct, imageFogWhenSearch, viewToolBar;
@synthesize lblNumberProducts, btnFilter, btnSort, lblProducts;
@synthesize sortPopoverController;
@synthesize filterViewController, filterParam, isFiltering;

#pragma mark Main Method
- (void)viewDidLoadBefore
{
    [self setToSimiView];
    [self setNavigationBarOnViewDidLoadForZTheme];
    
    _isFirstLoad = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    UICollectionViewLayout* stackLayout = [[UICollectionViewLayout alloc] init];
    zCollectionView = [[ZThemeCollectionViewController alloc]initWithCollectionViewLayout:stackLayout];
    [zCollectionView.collectionView setFrame:self.view.bounds];
    zCollectionView.collectionGetProductType = zCollectionGetProductType;
    if (spot_ID) {
        zCollectionView.spot_ID = spot_ID;
    }
    if (categoryId) {
        zCollectionView.categoryId = categoryId;
    }
    if (keySearchProduct) {
        zCollectionView.searchProduct = keySearchProduct;
    }
    [self.view addSubview:zCollectionView.collectionView];
    self.zCollectionView.delegate = self;
    if (!self.isOpenSearchFromHome) {
        [self.zCollectionView getProducts];
    }
    
    imageFogWhenSearch = [[UIImageView alloc]initWithFrame:self.view.bounds];
    [imageFogWhenSearch  setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:0.7]];
    [self.view addSubview:imageFogWhenSearch];
    [imageFogWhenSearch setHidden:YES];
    [imageFogWhenSearch setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapImageFog)];
    [imageFogWhenSearch addGestureRecognizer:tapGesture];
    
    searchProduct = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 6, 320, 25)];
    searchProduct.simiObjectName = @"SearchBarOnList";
    searchProduct.delegate = self;
    searchProduct.placeholder = SCLocalizedString(@"Search");
    searchProduct.searchBarStyle = UISearchBarStyleMinimal;
    searchProduct.userInteractionEnabled = YES;
    searchProduct.translucent = YES;
    searchProduct.barTintColor = [UIColor clearColor];
    searchProduct.tintColor = [UIColor darkGrayColor];
    [searchProduct setBackgroundColor:[UIColor clearColor]];
    [searchProduct setText:self.keySearchProduct];
    
    searchProduct.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:searchProduct];
    
    if (self.isOpenSearchFromHome) {
        [searchProduct becomeFirstResponder];
    }
    
    [self viewToolBar];
    [self.view addSubview:viewToolBar];
    [self.viewToolBar setHidden:YES];
}
- (void)viewWillAppearAfter:(BOOL)animated
{
    [self setNavigationBarOnViewWillAppearForZTheme:YES isShowRightItems:YES];
    self.navigationItem.leftItemsSupplementBackButton = YES;
}


- (void)selectedProduct:(NSString *)productID_
{
    ZThemeProductViewController *zThemeProductViewController = [ZThemeProductViewController new];
    zThemeProductViewController.arrayProductsID = self.zCollectionView.arrayProductsID;
    zThemeProductViewController.firstProductID = productID_;
    [self.navigationController pushViewController:zThemeProductViewController animated:YES];
}

#pragma mark Search Bar Delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    searchProduct.barTintColor = [UIColor colorWithWhite:1 alpha:1];
    searchProduct.translucent = YES;
    searchProduct.text = self.keySearchProduct;
    [imageFogWhenSearch setHidden:NO];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    searchProduct.backgroundColor = [UIColor clearColor];
    [imageFogWhenSearch setHidden:YES];
    [self.searchProduct resignFirstResponder];
    self.keySearchProduct = searchProduct.text;
    searchProduct.text = @"";
    if (self.zCollectionGetProductType != ZThemeCollectioViewGetProductTypeFromSearch) {
        ZThemeProductListViewController *searchProductListViewController = [[ZThemeProductListViewController alloc]init];
        searchProductListViewController.zCollectionGetProductType = ZThemeCollectioViewGetProductTypeFromSearch;
        searchProductListViewController.keySearchProduct = self.keySearchProduct;
        searchProductListViewController.sortType = self.sortType;
        searchProductListViewController.sortSelected = self.sortSelected;
        searchProductListViewController.spot_ID = self.spot_ID;
        searchProductListViewController.categoryId = self.categoryId;
        [self.navigationController pushViewController:searchProductListViewController animated:YES];
    }else
    {
        self.zCollectionView.productCollection = nil;
        [self.zCollectionView.collectionView reloadData];
        self.zCollectionView.searchProduct = self.keySearchProduct;
        self.zCollectionView.filterParam = self.filterParam;
        self.zCollectionView.sortType = self.sortType;
        [self.zCollectionView getProducts];
    }
}
#pragma mark Tap Image Fog
- (void)didTapImageFog
{
    if (self.isOpenSearchFromHome && self.zCollectionView.productCollection.count == 0) {
        [self.searchProduct resignFirstResponder];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    self.keySearchProduct = searchProduct.text;
    searchProduct.backgroundColor = [UIColor clearColor];
    searchProduct.text = @"";
    [imageFogWhenSearch setHidden:YES];
    [self.searchProduct resignFirstResponder];
}

#pragma mark View Tool Bar
- (UIView*)viewToolBar
{
    if (viewToolBar == nil) {
        CGRect frame = self.view.frame;
        frame.size.height = 40;
        frame.origin.y = CGRectGetHeight(self.view.frame) - 104;
        viewToolBar = [[ILTranslucentView alloc] initWithFrame:frame];
        viewToolBar.translucentTintColor = [UIColor whiteColor];
        viewToolBar.translucentAlpha = 0.5;
        viewToolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        if (SIMI_SYSTEM_IOS < 7.0) {
            viewToolBar.backgroundColor = [UIColor whiteColor];
        }
        
        lblNumberProducts = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2-55, 9, 50, 22)];
        [lblNumberProducts setBackgroundColor:[UIColor clearColor]];
        [lblNumberProducts setText:@""];
        [lblNumberProducts setTextColor:THEME_COLOR];
        [lblNumberProducts setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:15]];
        [viewToolBar addSubview:lblNumberProducts];
        
        if (btnFilter == nil) {
            btnFilter = [UIButton buttonWithType:UIButtonTypeCustom];
        }
        [btnFilter setFrame:CGRectMake(0, 0, 70, viewToolBar.frame.size.height)];
        [btnFilter setBackgroundColor:[UIColor clearColor]];
        [btnFilter setImage:[UIImage imageNamed:@"Ztheme_filter"] forState:UIControlStateNormal];
        [btnFilter setTitle:SCLocalizedString(@"Filter") forState:UIControlStateNormal];
        [btnFilter.titleLabel setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:16]];
        [btnFilter setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnFilter addTarget:self action:@selector(filter) forControlEvents:UIControlEventTouchUpInside];
        [btnFilter setHidden:YES];
        [viewToolBar addSubview:btnFilter];
    }
    return viewToolBar;
}

#pragma mark Collection Delegate
- (void)numberProductChange:(int)numberProduct
{
    lblNumberProducts.text = [NSString stringWithFormat:@"%d",numberProduct];
    if (self.zCollectionView.isShowOnlyImage) {
        if (numberProduct < 17) {
            [self.viewToolBar setHidden:NO];
        }
    }else
    {
        if (numberProduct < 4) {
            [self.viewToolBar setHidden:NO];
        }
    }
    if (_isFirstLoad) {
        CGFloat priceWidth = [lblNumberProducts.text sizeWithFont:lblNumberProducts.font].width;
        CGRect frame = lblNumberProducts.frame;
        frame.origin.x = frame.origin.x + priceWidth + 5;
        frame.size.width = 150;
        frame.origin.y = frame.origin.y + 1;
        lblProducts = [[UILabel alloc]initWithFrame:frame];
        [lblProducts setText:SCLocalizedString(@"PRODUCTS")];
        [lblProducts setTextColor: [UIColor darkGrayColor]];
        [lblProducts setFont:[UIFont fontWithName:THEME_FONT_NAME size:15]];
        [lblProducts setBackgroundColor:[UIColor clearColor]];
        [viewToolBar addSubview:lblProducts];
        
        UIImageView *imgSort = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 65, 11, 10, 18)];
        [imgSort setImage:[UIImage imageNamed:@"Ztheme_icon_sort"]];
        
        UILabel *lblSort = [[UILabel alloc]initWithFrame:CGRectMake(imgSort.frame.origin.x + imgSort.frame.size.width+4, -2, 60, 40)];
        [lblSort setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:16]];
        [lblSort setText:SCLocalizedString(@"Sort")];
        if (!btnSort) {
            btnSort=[UIButton buttonWithType:UIButtonTypeCustom ];
            [btnSort setBackgroundColor:[UIColor clearColor]];
        }
        [btnSort setFrame:CGRectMake(imgSort.frame.origin.x, 0, 70, 40)];
        [btnSort addTarget:self action:@selector(btnSort:) forControlEvents:UIControlEventTouchUpInside];
        btnSort.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [viewToolBar addSubview:imgSort];
        [viewToolBar addSubview:lblSort];
        [viewToolBar addSubview:btnSort];
        _isFirstLoad = NO;
    }
}

- (void)setHideViewToolBar:(BOOL)isHide
{
    [viewToolBar setHidden:isHide];
}

#pragma mark Sort Action
- (void)btnSort:(id)sender
{
    if (_menuSort == nil) {
        _menuSort = [[SCMenuSort alloc] initWithStyle:UITableViewStylePlain];
        _menuSort.tableView.showsVerticalScrollIndicator = NO;
        _menuSort.delegate = self;
    }
    if (sortPopoverController == nil)
    {
        UIView *btn = (UIView *)sender;
        sortPopoverController = [[WYPopoverController alloc] initWithContentViewController:_menuSort];
        sortPopoverController.delegate = self;
        sortPopoverController.passthroughViews = @[btn];
        sortPopoverController.popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
        sortPopoverController.wantsDefaultContentAppearance = NO;
        [sortPopoverController setPopoverContentSize:CGSizeMake(300, 275)];
        [sortPopoverController presentPopoverFromRect:btn.bounds
                                               inView:btn
                             permittedArrowDirections:WYPopoverArrowDirectionDown
                                             animated:YES
                                              options:WYPopoverAnimationOptionFadeWithScale];
    }
    else
    {
        [self close:nil];
    }
}

- (void)close:(id)sender
{
    [sortPopoverController dismissPopoverAnimated:YES completion:^{
        [self sortPopupControllerDidDismissPopover:sortPopoverController];
    }];
}

#pragma mark Sort Delegate
-(void)selectedMenuSort:(ProductCollectionSortType)sortType_
{
    self.zCollectionView.sortType = sortType_;
    self.zCollectionView.productCollection = nil;
    [self.zCollectionView.collectionView reloadData];
    [self.zCollectionView getProducts];
    [self close:nil];
}

#pragma mark - WYPopoverControllerDelegate
- (void)popoverControllerDidPresentPopover:(WYPopoverController *)controller
{
    
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    [self sortPopupControllerDidDismissPopover:sortPopoverController];
    return YES;
}

- (void)sortPopupControllerDidDismissPopover:(WYPopoverController *)controller
{
    if (controller == sortPopoverController)
    {
        sortPopoverController.delegate = nil;
        sortPopoverController = nil;
    }
}

- (BOOL)popoverControllerShouldIgnoreKeyboardBounds:(WYPopoverController *)popoverController
{
    return YES;
}

- (void)popoverController:(WYPopoverController *)popoverController willTranslatePopoverWithYOffset:(float *)value
{
    // keyboard is shown and the popover will be moved up by 163 pixels for example ( *value = 163 )
    *value = 0; // set value to 0 if you want to avoid the popover to be moved
}

#pragma mark Filter
- (void)startGetProductModelCollection
{
    btnSort.enabled = NO;
    btnFilter.enabled = NO;
    btnSort.alpha = 0.5;
    [btnSort setBackgroundColor:[UIColor whiteColor]];
    btnFilter.alpha = 0.5;
}
- (void)didGetProductModelCollection:(NSDictionary*)layerNavigation
{
    btnSort.enabled = YES;
    btnSort.alpha = 1.0;
    [btnSort setBackgroundColor:[UIColor clearColor]];
    if (filterViewController == nil) {
        filterViewController = [SCFilterViewController new];
        filterViewController.delegate = self;
    }
    filterViewController.filterContent = layerNavigation;
    if ([(NSMutableArray*)[filterViewController.filterContent valueForKey:@"layer_state"] count] > 0 || [(NSMutableArray*)[filterViewController.filterContent valueForKey:@"layer_filter"] count] > 0) {
        btnFilter.enabled = YES;
        btnFilter.alpha = 1.0;
        [btnFilter setHidden:NO];
    }
}
- (void)filterWithParam:(NSMutableDictionary *)param
{
    [zCollectionView setFilterParam:param];
    [zCollectionView.productCollection removeAllObjects];
    [zCollectionView.collectionView reloadData];
    [zCollectionView getProducts];
}

- (void)filter
{
    if (filterViewController == nil) {
        filterViewController = [SCFilterViewController new];
    }
    self.filterViewController.delegate = self;
    [UIView beginAnimations:@"View Flip" context:nil];
    [UIView setAnimationDuration: 0.5];
    [self.navigationController pushViewController:filterViewController animated:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];
}
@end
