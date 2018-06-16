//
//  SCProductReviewWorker.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 9/12/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCProductReviewController.h"
#import <SimiCartBundle/SCProductSecondDesignViewController.h>
static NSString *product_reviews_section = @"product_reviews_section";
static NSString *product_reviews_normal_row = @"product_reviews_normal_row";
static NSString *product_reviews_viewall_row = @"product_reviews_viewall_row";
static NSString *product_reviews_add_row = @"product_reviews_add_row";
static NSString *product_reviews_firstpeople_row = @"product_reviews_firstpeople_row";

@interface SCProductReviewWorker : NSObject

@end

@interface SCPProductDetailReviewWorker : NSObject
@property (strong, nonatomic) SimiTable *cells;
@property (strong, nonatomic) UITableView *contentTableView;
@property (strong, nonatomic) SimiProductModel *product;
- (void)createReviewSection;
@end
