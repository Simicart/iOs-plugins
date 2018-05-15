//
//  SCPProductsViewController.m
//  SimiCartPluginFW
//
//  Created by Liam on 4/27/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPProductsViewController.h"
#import "SCPProductCollectionView.h"
#import "SCPProductViewController.h"

@interface SCPProductsViewController ()

@end

@implementation SCPProductsViewController
- (void)viewDidLoadBefore{
    if ([self openCategoryCmsPage]) {
        return;
    }
    self.sortIndex = -1;
    [self createViewToolBar];
    
    if (productModelCollection == nil) {
        productModelCollection = [SimiProductModelCollection new];
    }
    [self addProductCollectionView];
    [self addProductTableView];
    if (productModelCollection.count == 0) {
        [self getProducts];
    }
    [self.view addSubview:viewToolBar];
    [self addNoProductLabel];
    if ([[[GLOBALVAR.storeView.catalog valueForKey:@"frontend"] valueForKey:@"view_products_default"]boolValue]) {
        [self.listModeCollectionView setHidden:YES];
        [self.listModeCollectionView setAlpha:0];
    }else{
        [self.gridModeCollectionView setAlpha:0];
        [self.gridModeCollectionView setHidden:YES];
    }
}

- (void)createViewToolBar{
    if (viewToolBar == nil) {
        CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
        float buttonWidth = 65;
        float buttonHeight = frame.size.height;
        float iconSize = 25;
        viewToolBar = [[UIView alloc]initWithFrame:frame];
        [viewToolBar setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
        
        changeLayoutButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
        [changeLayoutButton setImageEdgeInsets:UIEdgeInsetsMake((buttonHeight - iconSize)/2, (buttonWidth - iconSize)/2, (buttonHeight - iconSize)/2, (buttonWidth - iconSize)/2)];
        if ([[[GLOBALVAR.storeView.catalog valueForKey:@"frontend"] valueForKey:@"view_products_default"] boolValue]) {
            [changeLayoutButton setImage:[UIImage imageNamed:@"scp_ic_list"] forState:UIControlStateNormal];
            isProductShowGrid = YES;
        }else
            [changeLayoutButton setImage:[UIImage imageNamed:@"scp_ic_grib"] forState:UIControlStateNormal];
        [changeLayoutButton addTarget:self action:@selector(changeLayoutListView) forControlEvents:UIControlEventTouchUpInside];
        if(SIMI_SYSTEM_IOS >= 8)
            [viewToolBar addSubview:changeLayoutButton];
        
        sortButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - buttonWidth, 0, buttonWidth, buttonHeight)];
        [sortButton setImageEdgeInsets:UIEdgeInsetsMake((buttonHeight - iconSize)/2, (buttonWidth - iconSize)/2, (buttonHeight - iconSize)/2, (buttonWidth - iconSize)/2)];
        [sortButton setImage:[UIImage imageNamed:@"scp_ic_sort"] forState:UIControlStateNormal];
        [sortButton addTarget:self action:@selector(sortAction:)forControlEvents:UIControlEventTouchUpInside];
        [sortButton setHidden:YES];
        [viewToolBar addSubview:sortButton];
        
        filterButton = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - buttonWidth)/2, 0, buttonWidth, buttonHeight)];
        [filterButton setImageEdgeInsets:UIEdgeInsetsMake((buttonHeight - iconSize)/2, (buttonWidth - iconSize)/2, (buttonHeight - iconSize)/2, (buttonWidth - iconSize)/2)];
        [filterButton setImage:[UIImage imageNamed:@"scp_ic_filter"] forState:UIControlStateNormal];
        [filterButton addTarget:self action:@selector(filterAction:)forControlEvents:UIControlEventTouchUpInside];
        [filterButton setHidden:YES];
        [viewToolBar addSubview:filterButton];
        viewToolBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    }
}

- (void)addProductTableView{
    self.listModeCollectionView = [[SCPProductCollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:[UICollectionViewFlowLayout new]];
    float bottomMenuHeight = CGRectGetHeight(self.tabBarController.tabBar.frame);
    [self.listModeCollectionView setContentInset:UIEdgeInsetsMake(SCP_GLOBALVARS.lineSpacing + 44, SCP_GLOBALVARS.padding, SCP_GLOBALVARS.lineSpacing + bottomMenuHeight, SCP_GLOBALVARS.padding)];
    self.listModeCollectionView.productModelCollection = productModelCollection;
    self.listModeCollectionView.gridMode = NO;
    self.listModeCollectionView.actionDelegate = self;
    __weak SCPProductsViewController *tempSelf = self;
    [self.listModeCollectionView addInfiniteScrollingWithActionHandler:^{
        [tempSelf getProducts];
    }];
    [self.view addSubview:self.listModeCollectionView];
}

- (void)addProductCollectionView{
    self.gridModeCollectionView = [[SCPProductCollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:[UICollectionViewFlowLayout new]];
    [self.gridModeCollectionView setContentInset:UIEdgeInsetsMake(SCP_GLOBALVARS.lineSpacing + 44, SCP_GLOBALVARS.padding, SCP_GLOBALVARS.lineSpacing + CGRectGetHeight(self.tabBarController.tabBar.frame), SCP_GLOBALVARS.padding)];
    self.gridModeCollectionView.productModelCollection = productModelCollection;
    self.gridModeCollectionView.gridMode = YES;
    self.gridModeCollectionView.actionDelegate = self;
    __weak SCPProductsViewController *tempSelf = self;
    [self.gridModeCollectionView addInfiniteScrollingWithActionHandler:^{
        [tempSelf getProducts];
    }];
    [self.view addSubview:self.gridModeCollectionView];
}

- (void)reloadData{
    [self.gridModeCollectionView reloadData];
    [self.listModeCollectionView reloadData];
}

- (void)setHideViewToolBar:(BOOL)isHide{
    
}

- (void)changeLayoutListView
{
    [changeLayoutButton setEnabled:NO];
    isProductShowGrid = !isProductShowGrid;
    if (isProductShowGrid) {
        [self.gridModeCollectionView reloadData];
        [UIView animateWithDuration:0.5 animations:^{
            [self.listModeCollectionView setAlpha:0];
        } completion:^(BOOL finished) {
            [self.listModeCollectionView setHidden:YES];
            [self.gridModeCollectionView setHidden:NO];
            [UIView animateWithDuration:0.5 animations:^{
                [self.gridModeCollectionView setAlpha:1];
            } completion:^(BOOL finished) {
                [changeLayoutButton setEnabled:YES];
            }];
        }];
        [changeLayoutButton setImage:[UIImage imageNamed:@"scp_ic_list"] forState:UIControlStateNormal];
        NSArray *invisibleCells = [self.listModeCollectionView indexPathsForVisibleItems];
        if (invisibleCells.count > 2) {
            [self.gridModeCollectionView scrollToItemAtIndexPath:[invisibleCells objectAtIndex:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        }
    }else
    {
        [self.listModeCollectionView reloadData];
        [UIView animateWithDuration:0.5 animations:^{
            [self.gridModeCollectionView setAlpha:0];
        } completion:^(BOOL finished) {
            [self.gridModeCollectionView setHidden:YES];
            [self.listModeCollectionView setHidden:NO];
            [UIView animateWithDuration:0.5 animations:^{
                [self.listModeCollectionView setAlpha:1];
            } completion:^(BOOL finished) {
                [changeLayoutButton setEnabled:YES];
            }];
        }];
        [changeLayoutButton setImage:[UIImage imageNamed:@"scp_ic_grib"] forState:UIControlStateNormal];
        NSArray *invisibleCells = [self.gridModeCollectionView indexPathsForVisibleItems];
        if (invisibleCells.count > 0) {
            [self.listModeCollectionView scrollToItemAtIndexPath:[invisibleCells objectAtIndex:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        }
    }
    
    NSMutableDictionary *properties = [[NSMutableDictionary alloc]initWithDictionary:trackingProperties];
    [properties setValue:@"changed_product_list_style" forKey:@"action"];
    if (isProductShowGrid) {
        [properties setValue:@"grid" forKey:@"product_list_style"];
    }else
        [properties setValue:@"list" forKey:@"product_list_style"];
    [[NSNotificationCenter defaultCenter]postNotificationName:TRACKINGEVENT object:@"products_action" userInfo:properties];
}

- (void)getProducts{
    if (productModelCollection.total > 0 && productModelCollection.count >= productModelCollection.total) {
        [self.gridModeCollectionView.infiniteScrollingView stopAnimating];
        [self.listModeCollectionView.infiniteScrollingView stopAnimating];
        return;
    }
    [super getProducts];
    [self.gridModeCollectionView.infiniteScrollingView startAnimating];
    [self.listModeCollectionView.infiniteScrollingView startAnimating];
}

- (void)didGetProducts:(NSNotification *)noti{
    [self.gridModeCollectionView.infiniteScrollingView stopAnimating];
    [self.listModeCollectionView.infiniteScrollingView stopAnimating];
    [super didGetProducts:noti];
}

- (void)selectedProduct:(SimiProductModel *)productModel{
    SCPProductViewController *productVC = [SCPProductViewController new];
    productVC.product = productModel;
    productVC.productId = productModel.entityId;
    [self.navigationController pushViewController:productVC animated:nil];
}
@end
