//
//  SCPProductsViewController.h
//  SimiCartPluginFW
//
//  Created by Liam on 4/27/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SCProductListViewController.h>
#import "SCPProductCollectionView.h"

@interface SCPProductsViewController : SCProductListViewController
@property (strong, nonatomic) SCPProductCollectionView *gridModeCollectionView;
@property (strong, nonatomic) SCPProductCollectionView *listModeCollectionView;
@end
