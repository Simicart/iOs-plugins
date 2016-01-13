//
//  ZThemeProductListViewControllerPad.m
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 5/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeProductListViewControllerPad.h"
#import "ZThemeWorker.h"
#import "SimiViewController+ZTheme.h"
#import "ZThemeProductViewControllerPad.h"

@interface ZThemeProductListViewControllerPad ()

@end

@implementation ZThemeProductListViewControllerPad

@synthesize viewToolBar, btnSort, btnFilter, btnCategory, filterViewController, filterParam, isFiltering, scCollectionGetProductType;

#pragma mark Main Method
- (void)viewDidLoadBefore
{
    [self setToSimiView];
    [self viewToolBar];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    self.isFirstLoad = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self initCollectionView];
    [self addGestureRecognizer];
    [self.zCollectionView getProducts];
    [self.view addSubview:viewToolBar];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:@"DidGetAllProducts" object:self.productCollection];
}

- (void)initCollectionView
{
    UICollectionViewLayout* stackLayout = [[UICollectionViewLayout alloc] init];
    self.zCollectionView = nil;
    self.zCollectionView = [[ZThemeCollectionViewControllerPad alloc]initWithCollectionViewLayout:stackLayout];
    [self.zCollectionView.collectionView setFrame:CGRectMake(0, 60, 1024, 708)];
    self.zCollectionView.collectionGetProductType = self.zCollectionGetProductType;
    if (self.spot_ID) {
        self.zCollectionView.spot_ID = self.spot_ID;
    }
    if (self.categoryId) {
        self.zCollectionView.categoryId = self.categoryId;
    }
    if (self.keySearchProduct) {
        self.zCollectionView.searchProduct = self.keySearchProduct;
    }
    [self.view addSubview:self.zCollectionView.collectionView];
    self.zCollectionView.delegate = self;
}

- (void)viewWillAppearBefore:(BOOL)animated{
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.navigationItem.leftBarButtonItems = [[[ZThemeWorker sharedInstance] navigationBarPad] leftButtonItems];
    self.navigationItem.rightBarButtonItems = [[[ZThemeWorker sharedInstance] navigationBarPad] rightButtonItems];
}

#pragma mark - viewToolBar
- (UIView*)viewToolBar
{
    CGRect frame = self.view.frame;
    
    frame.origin.y = 0;
    frame.size.height = 50;
    viewToolBar = [[ILTranslucentView alloc] initWithFrame:frame];
    viewToolBar.backgroundColor = [UIColor clearColor];
    viewToolBar.translucentTintColor = [UIColor clearColor];
    viewToolBar.alpha = 1;
    viewToolBar.translucentStyle = UIBarStyleDefault;
    viewToolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if (SIMI_SYSTEM_IOS < 7.0) {
        viewToolBar.backgroundColor = [UIColor whiteColor];
    }
    
    self.lblNumberProducts = [[UILabel alloc]initWithFrame:CGRectMake(425, 0, 40, 50)];
    [self.lblNumberProducts setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:22]];
    [self.lblNumberProducts setTextColor:[UIColor orangeColor]];
    [self.lblNumberProducts setText:@"0"];
    [self.lblNumberProducts setTextAlignment:NSTextAlignmentRight];
    
    
    UILabel *lblProduct = [[UILabel alloc]initWithFrame:CGRectMake(475, 0, 150, 50)];
    [lblProduct setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:22]];
    [lblProduct setText:SCLocalizedString(@"PRODUCTS")];
    
    UIImageView *imgSort = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 110, 14, 16, 22)];
    [imgSort setImage:[UIImage imageNamed:@"Ztheme_icon_sort_ipad"]];
    
    UILabel *lblSort = [[UILabel alloc]initWithFrame:CGRectMake(imgSort.frame.origin.x + imgSort.frame.size.width, 5, 90, 40)];
    [lblSort setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:22]];
    [lblSort setText:SCLocalizedString(@"Sort")];
    
    
    if (!btnSort) {
        btnSort=[UIButton buttonWithType:UIButtonTypeCustom ];
    }
    [btnSort setFrame:CGRectMake(imgSort.frame.origin.x, 5, 110, 40)];
    [btnSort addTarget:self action:@selector(btnSort:) forControlEvents:UIControlEventTouchUpInside];
    btnSort.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    if (viewToolBar) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, viewToolBar.frame.size.height-1, SCREEN_WIDTH, 1)];
        [v setBackgroundColor:[UIColor lightGrayColor]];
        v.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [viewToolBar addSubview:v];
        [viewToolBar addSubview:imgSort];
        [viewToolBar addSubview:lblSort];
        [viewToolBar addSubview:btnSort];
        [viewToolBar addSubview:lblProduct];
        [viewToolBar addSubview:self.lblNumberProducts];
    }
    int x = 10;
    int y = 5;
    
    if (_isCategory) {
        if (!btnCategory) {
            btnCategory=[UIButton buttonWithType:UIButtonTypeCustom ];
        }
        [btnCategory setFrame:CGRectMake(x, y, 150, 40)];
        x += 150;
        [btnCategory setImage:[UIImage imageNamed:@"Ztheme_btncategory"]forState:UIControlStateNormal];
        [btnCategory setImageEdgeInsets:UIEdgeInsetsMake(5, 25, 5, 108)];
        [btnCategory setTitle:SCLocalizedString(@"Category") forState:UIControlStateNormal];
        [btnCategory setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnCategory.titleLabel setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:22]];
        [btnCategory addTarget:self action:@selector(btnCategory:) forControlEvents:UIControlEventTouchUpInside];
        btnCategory.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [viewToolBar addSubview:btnCategory];
    }
     
    
    if (btnFilter == nil) {
        btnFilter = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    [btnFilter setFrame:CGRectMake(x, y, 100, CGRectGetHeight(viewToolBar.frame)- 2*y)];
    [btnFilter setBackgroundColor:[UIColor clearColor]];
    [btnFilter setImage:[UIImage imageNamed:@"Ztheme_filter"] forState:UIControlStateNormal];
    [btnFilter setTitle:SCLocalizedString(@"Filter") forState:UIControlStateNormal];
    [btnFilter.titleLabel setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:22]];
    [btnFilter setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnFilter addTarget:self action:@selector(filter) forControlEvents:UIControlEventTouchUpInside];
    [btnFilter setHidden:YES];
    [viewToolBar addSubview:btnFilter];
    return viewToolBar;
}


#pragma mark Action

- (void)selectedProduct:(NSString *)productID_
{
    ZThemeProductViewControllerPad *zThemeProductViewController = [ZThemeProductViewControllerPad new];
    zThemeProductViewController.arrayProductsID = self.zCollectionView.arrayProductsID;
    zThemeProductViewController.firstProductID = productID_;
    [self.navigationController pushViewController:zThemeProductViewController animated:YES];
}


- (void)btnSort:(id)sender
{
    UIButton* senderButton = (UIButton*)sender;
    if ( self.menuSort== nil) {
        //Create the ColorPickerViewController.
        self.menuSort = [[SCMenuSort alloc] initWithStyle:UITableViewStylePlain];
        self.menuSort.tableView.showsVerticalScrollIndicator = NO;
        //Set this VC as the delegate.
        self.menuSort.delegate = self;
    }
    if (_popController == nil) {
        //The color picker popover is not showing. Show it.
        _popController = [[UIPopoverController alloc] initWithContentViewController:self.menuSort];
        if(SIMI_SYSTEM_IOS >= 7.0)
            [_popController setBackgroundColor:[UIColor whiteColor]];
        [_popController setDelegate:self];
        [_popController presentPopoverFromRect:senderButton.bounds inView:senderButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        //The color picker popover is showing. Hide it.
        [_popController dismissPopoverAnimated:YES];
        _popController = nil;
    }
}


- (void)btnCategory:(id)sender
{
    UIButton* senderButton = (UIButton*)sender;
    if (_scMenuCategory == nil) {
        //Create the ColorPickerViewController.
        _scMenuCategory = [[SCMenuCategory alloc] initWithStyle:UITableViewStylePlain];
        //Set this VC as the delegate.
        _scMenuCategory.delegate = self;
        _scMenuCategory.categoryId = self.categoryId;
    }
    if (_scMenuCategory_v2 == nil) {
        _scMenuCategory_v2 = [[SCMenuCategory_v2 alloc]initWithStyle:UITableViewStylePlain];
        _scMenuCategory_v2.delegate = self;
        _scMenuCategory_v2.categoryId = self.categoryId;
    }
    
    if (_popController == nil) {
        //The color picker popover is not showing. Show it.
        NSString *strHaveAllProDuct = [NSString stringWithFormat:@"%@",[[[[SimiGlobalVar sharedInstance]store] valueForKey:@"store_config"]valueForKey:@"is_show_link_all_product"]];
        if ([strHaveAllProDuct isEqualToString:@"1"]) {
            _popController = [[UIPopoverController alloc] initWithContentViewController:_scMenuCategory];
        }else
        {
            _popController = [[UIPopoverController alloc] initWithContentViewController:_scMenuCategory_v2];
        }
        
        if (SIMI_SYSTEM_IOS >= 7.0)
            [_popController setBackgroundColor:[UIColor whiteColor]];
        _popController.delegate = self;
        [_popController presentPopoverFromRect:senderButton.bounds inView:senderButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        //The color picker popover is showing. Hide it.
        [_popController dismissPopoverAnimated:YES];
        _popController = nil;
    }
}


- (void)numberProductChange:(int)numberProduct
{
    [self.lblNumberProducts setText:[NSString stringWithFormat:@"%d",numberProduct]];
}

#pragma mark Menu Categroy Delegate
- (void)selectedIDMenu:(NSString *)categoryId
{
    filterParam = @{};
    self.categoryId = categoryId;
    self.zCollectionView.categoryId = categoryId;
    self.zCollectionView.productCollection = nil;
    [self.zCollectionView getProducts];
}

-(void)selectedIDMenu:(NSString*)categoryId categoryName:(NSString*)categoryName
{
    filterParam = @{};
    self.categoryId = categoryId;
    self.zCollectionView.categoryId = categoryId;
    self.zCollectionView.productCollection = nil;
    [self.zCollectionView getProducts];
}




#pragma mark Filter & SCCollectionView Delegate
- (void)startGetProductModelCollection
{
    btnSort.enabled = NO;
    btnFilter.enabled = NO;
    btnCategory.enabled = NO;
    btnSort.alpha = 0.5;
    [btnSort setBackgroundColor:[UIColor whiteColor]];
    btnFilter.alpha = 0.5;
    btnCategory.alpha = 0.5;
}
- (void)didGetProductModelCollection:(NSDictionary*)layerNavigation
{
    btnSort.enabled = YES;
    btnSort.alpha = 1.0;
    [btnSort setBackgroundColor:[UIColor clearColor]];
    btnCategory.enabled = YES;
    btnCategory.alpha = 1.0;;
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
    [_popControllerFilter dismissPopoverAnimated:YES];
    [self.zCollectionView setFilterParam:param];
    [self.zCollectionView.productCollection removeAllObjects];
    [self.zCollectionView.collectionView reloadData];
    [self.zCollectionView getProducts];
}

- (void)filter
{
    if (_popControllerFilter == nil) {
        _popControllerFilter = [[UIPopoverController alloc]initWithContentViewController:filterViewController];
        _popControllerFilter.delegate = self;
        [_popControllerFilter setBackgroundColor:[UIColor whiteColor]];
        if (SIMI_SYSTEM_IOS > 7.0){
            [_popControllerFilter setBackgroundColor:[UIColor clearColor]];
        }
    }
    [_popControllerFilter presentPopoverFromRect:btnFilter.bounds inView:btnFilter permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

@end
