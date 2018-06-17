//
//  SCPPadProductsViewController.m
//  SimiCartPluginFW
//
//  Created by Liam on 5/14/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPPadProductsViewController.h"
#import "SCPPadProductCollectionView.h"
#import "SCPPadProductViewController.h"

@interface SCPPadProductsViewController ()

@end

@implementation SCPPadProductsViewController
- (void)viewDidLoadBefore{
    [self configureLogo];
    if ([self openCategoryCmsPage]) {
        return;
    }
    self.sortIndex = -1;
    [self createViewToolBar];
    
    if (productModelCollection == nil) {
        productModelCollection = [SimiProductModelCollection new];
    }
    [self addProductCollectionView];
    if (productModelCollection.count == 0) {
        [self getProducts];
    }
    [self.view addSubview:viewToolBar];
    [self addNoProductLabel];
}

- (void)createViewToolBar{
    if (viewToolBar == nil) {
        CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
        float buttonWidth = 65;
        float buttonHeight = frame.size.height;
        float iconSize = 25;
        viewToolBar = [[UIView alloc]initWithFrame:frame];
        [viewToolBar setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
        
        sortButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - buttonWidth, 0, buttonWidth, buttonHeight)];
        [sortButton setImageEdgeInsets:UIEdgeInsetsMake((buttonHeight - iconSize)/2, (buttonWidth - iconSize)/2, (buttonHeight - iconSize)/2, (buttonWidth - iconSize)/2)];
        [sortButton setImage:[UIImage imageNamed:@"scp_ic_sort"] forState:UIControlStateNormal];
        [sortButton addTarget:self action:@selector(sortAction:)forControlEvents:UIControlEventTouchUpInside];
        [sortButton setHidden:YES];
        [viewToolBar addSubview:sortButton];
        
        filterButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
        [filterButton setImageEdgeInsets:UIEdgeInsetsMake((buttonHeight - iconSize)/2, (buttonWidth - iconSize)/2, (buttonHeight - iconSize)/2, (buttonWidth - iconSize)/2)];
        [filterButton setImage:[UIImage imageNamed:@"scp_ic_filter"] forState:UIControlStateNormal];
        [filterButton addTarget:self action:@selector(filterAction:)forControlEvents:UIControlEventTouchUpInside];
        [filterButton setHidden:YES];
        [viewToolBar addSubview:filterButton];
        viewToolBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    }
}

- (void)addProductCollectionView{
    self.gridModeCollectionView = [[SCPPadProductCollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:[UICollectionViewFlowLayout new]];
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

#pragma mark Action
- (void)sortAction:(id)sender{
    UIButton* senderButton = (UIButton*)sender;
    SCPSortViewController *refineViewController = [[SCPSortViewController alloc]init];
    refineViewController.delegate = self;
    refineViewController.sortArray = self.sortArray;
    refineViewController.selectedIndex = self.sortIndex;
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:refineViewController];
    navigationController.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popover = navigationController.popoverPresentationController;
    popover.sourceRect = senderButton.bounds;
    popover.sourceView = senderButton;
    popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentViewController:navigationController animated:YES completion:nil];
    });
}

- (void)filterAction:(UIButton*)sender{
    SCPFilterViewController *filterViewController = [SCPFilterViewController new];
    filterViewController.delegate = self;
    filterViewController.modalPresentationStyle = UIModalPresentationPopover;
    filterViewController.filterContent = self.layersDict;
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:filterViewController];
    navigationController.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popover = navigationController.popoverPresentationController;
    popover.sourceRect = sender.bounds;
    popover.sourceView = sender;
    popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentViewController:navigationController animated:YES completion:nil];
    });
}

- (void)selectedProduct:(SimiProductModel *)productModel{
    SCPPadProductViewController *productVC = [SCPPadProductViewController new];
    productVC.product = productModel;
    productVC.productId = productModel.entityId;
    [self.navigationController pushViewController:productVC animated:nil];
}
@end
