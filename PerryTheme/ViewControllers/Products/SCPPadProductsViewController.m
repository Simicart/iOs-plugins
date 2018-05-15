//
//  SCPPadProductsViewController.m
//  SimiCartPluginFW
//
//  Created by Liam on 5/14/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPPadProductsViewController.h"
#import "SCPPadProductCollectionView.h"

@interface SCPPadProductsViewController ()

@end

@implementation SCPPadProductsViewController
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
@end
