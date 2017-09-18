//
//  SCReviewDetailController.h
//  SimiCart
//
//  Created by Tan on 7/2/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiProductModel.h>
#import "SimiReviewModelCollection.h"


@interface SCProductReviewController : SimiViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *reviewTableView;
@property (strong, nonatomic) SimiReviewModelCollection *reviewCollection;
@property (strong, nonatomic) NSMutableArray *reviewCount;
@property (strong, nonatomic) NSMutableArray *cells;

@property (strong, nonatomic) SimiProductModel *product;

- (void)getReviews;
- (void)didGetReviewCollection:(NSNotification *)noti;

@end
