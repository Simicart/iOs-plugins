//
//  SCReviewDetailController.h
//  SimiCart
//
//  Created by Tan on 7/2/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "SimiProductModel.h"
#import "SimiReviewModelCollection.h"

@protocol SCProductReviewControllerDelegate<NSObject>
@optional
- (void)didSelectReviewDetail:(UIViewController*)viewController;
@end

@interface SCProductReviewController : SimiViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *reviewTableView;
@property (strong, nonatomic) SimiReviewModelCollection *reviewCollection;
@property (strong, nonatomic) NSMutableArray *reviewCount;
@property (strong, nonatomic) NSMutableArray *cells;
@property (weak, nonatomic) id<SCProductReviewControllerDelegate> delegate;

@property (strong, nonatomic) SimiProductModel *product;

- (void)getReviews;
- (void)didGetReviewCollection:(NSNotification *)noti;

@end
