//
//  SCGridViewController_Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/12/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCGridViewController_Theme01.h"
#import "SimiViewController+Theme01.h"
@implementation SCGridViewController_Theme01
@synthesize viewToolBar, scCollectionView, lblNumberProducts, lblProducts;
//  Liam ADD 150326
@synthesize btnSort, btnFilter, filterViewController, filterParam, isFiltering;
@synthesize categoryName;
//  End
@synthesize categoryId = _categoryId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoadBefore
{
    [self setToSimiView];
    [self viewToolBar];
    _isFirstLoad = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewLayout* stackLayout = [[UICollectionViewLayout alloc] init];
    scCollectionView = [[SCCollectionViewController_Theme01 alloc]initWithCollectionViewLayout:stackLayout];
    [scCollectionView.collectionView setFrame:CGRectMake(0, viewToolBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - viewToolBar.frame.size.height)];
    scCollectionView.scCollectionGetProductType = _scCollectionGetProductType;
    if (_spotKey) {
        scCollectionView.spotKey = _spotKey;
    }
    if (_categoryId) {
        scCollectionView.categoryId = _categoryId;
    }
    if (keySearchProduct) {
        scCollectionView.searchProduct = keySearchProduct;
    }
    [self.view addSubview:scCollectionView.collectionView];
    [self.view addSubview: viewToolBar];
    self.scCollectionView.delegate = self;
    [self.scCollectionView getProducts];
    [self setNavigationBarOnViewDidLoadForTheme01];
}

- (void)viewWillAppearAfter:(BOOL)animated
{
    [self setNavigationBarOnViewWillAppearForTheme01];
    if (_scCollectionGetProductType == SCCollectionGetProductTypeFromSearch) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SCSearchViewController-ViewWillAppear" object:nil];
    }
}

- (void)viewWillDisappearAfter:(BOOL)animated
{
    [self deleteBackItemForTheme01];
}

#pragma mark - viewToolBar
- (UIView*)viewToolBar
{
    CGRect frame = self.view.frame;
    frame.size.height = 40;
    viewToolBar = [[ILTranslucentView alloc] initWithFrame:frame];
    viewToolBar.backgroundColor = [UIColor whiteColor];
    viewToolBar.translucentTintColor = [UIColor clearColor];
    viewToolBar.alpha = 1;
    viewToolBar.translucentStyle = UIBarStyleDefault;
    viewToolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if (SIMI_SYSTEM_IOS < 7.0) {
        viewToolBar.backgroundColor = [UIColor whiteColor];
    }
    lblNumberProducts = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2-55, 9, 50, 22)];
    [lblNumberProducts setText:@""];
    [lblNumberProducts setTextColor:THEME_COLOR];
    [lblNumberProducts setFont:[UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:15]];
    [lblProducts removeFromSuperview];
    if (viewToolBar) {
        [viewToolBar addSubview:lblNumberProducts];
    }
    //  Liam ADD 150326
    if (btnFilter == nil) {
        btnFilter = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    [btnFilter setFrame:CGRectMake(0, 0, 70, viewToolBar.frame.size.height)];
    [btnFilter setBackgroundColor:[UIColor clearColor]];
    [btnFilter setImage:[UIImage imageNamed:@"theme01_filter"] forState:UIControlStateNormal];
    [btnFilter setTitle:SCLocalizedString(@"Filter") forState:UIControlStateNormal];
    [btnFilter.titleLabel setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:16]];
    [btnFilter setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnFilter addTarget:self action:@selector(filter) forControlEvents:UIControlEventTouchUpInside];
    [btnFilter setHidden:YES];
    [viewToolBar addSubview:btnFilter];
    //  End
    return viewToolBar;
}

#pragma mark SCMenuSort Theme01 Delegate
-(void)selectedMenuSort:(ProductCollectionSortType)idArray rowSelect: (int)rowSelected
{
    scCollectionView.sortType = idArray;
    [scCollectionView.productCollection removeAllObjects];
    [scCollectionView.collectionView reloadData];
    [scCollectionView getProducts];
    _sortSelected = rowSelected;
    [self close:nil];
}

#pragma mark - searchProduct
-(void)searchProductWithKey:(NSString *)key{
    if (scCollectionView) {
        if ([key isEqualToString:keySearchProduct]) {
            return;
        }
        keySearchProduct = key;
        scCollectionView.searchProduct = key;
        [scCollectionView.productCollection removeAllObjects];
        [scCollectionView.collectionView reloadData];
        [scCollectionView getProducts];
    }else{
        keySearchProduct = key;
    }
}

- (void)close:(id)sender
{
    [sortPopoverController dismissPopoverAnimated:YES completion:^{
        [self sortPopupControllerDidDismissPopover:sortPopoverController];
    }];
}

- (void)btnSort:(id)sender
{
    if (sortPopoverController == nil)
    {
        UIView *btn = (UIView *)sender;
        _menuSort = [[SCMenuSort_Theme01 alloc] initWithStyle:UITableViewStylePlain];
        _menuSort.tableView.showsVerticalScrollIndicator = NO;
        _menuSort.delegate = self;
        _menuSort.rowSelect = _sortSelected;
        
        sortPopoverController = [[WYPopoverController alloc] initWithContentViewController:_menuSort];
        sortPopoverController.delegate = self;
        sortPopoverController.passthroughViews = @[btn];
        sortPopoverController.popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
        sortPopoverController.wantsDefaultContentAppearance = NO;
        [sortPopoverController presentPopoverFromRect:btn.bounds
                                                   inView:btn
                                 permittedArrowDirections:WYPopoverArrowDirectionAny
                                                 animated:YES
                                                  options:WYPopoverAnimationOptionFadeWithScale];
    }
    else
    {
        [self close:nil];
    }
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

#pragma mark SCCollectionView Delegate
- (void) selectedProduct:(NSString *)productId
{
    SCProductViewController_Theme01 *productController = [[SCProductViewController_Theme01 alloc] init];
    [productController setProductId:productId];
    [self.navigationController pushViewController:productController animated:YES];
}

- (void)numberProductChange:(int)numberProduct
{
    lblNumberProducts.text = [NSString stringWithFormat:@"%d",numberProduct];
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
        [viewToolBar addSubview:lblProducts];
        
        UIImageView *imgSort = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 65, 11, 10, 18)];
        [imgSort setImage:[UIImage imageNamed:@"theme01_icon_sort"]];
        
        UILabel *lblSort = [[UILabel alloc]initWithFrame:CGRectMake(imgSort.frame.origin.x + imgSort.frame.size.width+4, -2, 60, 40)];
        [lblSort setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:16]];
        [lblSort setText:SCLocalizedString(@"Sort")];
        if (!btnSort) {
            btnSort=[UIButton buttonWithType:UIButtonTypeCustom ];
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

//  Liam ADD 150326
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
    [scCollectionView setFilterParam:param];
    [scCollectionView.productCollection removeAllObjects];
    [scCollectionView.collectionView reloadData];
    [scCollectionView getProducts];
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
//  End

@end
