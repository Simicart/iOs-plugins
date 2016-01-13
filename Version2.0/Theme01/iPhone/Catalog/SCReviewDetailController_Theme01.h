//
//  SCReviewDetailController.h
//  SimiCart
//
//  Created by Tan on 7/2/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiProductModel.h>
#import <SimiCartBundle/SimiReviewModelCollection.h>
#import <SimiCartBundle/SCReviewDetailController.h>

#import "SCTheme01_APIKey.h"
#import "SimiGlobalVar+Theme01.h"
#import "SimiViewController+Theme01.h"

@interface SCReviewDetailController_Theme01 : SCReviewDetailController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) float productRate;
@property (nonatomic) int heightCell;
@end
