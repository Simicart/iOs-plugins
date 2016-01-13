//
//  SCProductDetailViewController.h
//  SimiCart
//
//  Created by Tan on 5/6/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiProductModel.h>
#import "SimiTabViewController_Theme01.h"

@interface SCProductDetailViewController_Theme01 : SimiTabViewController_Theme01

@property (strong, nonatomic) SimiProductModel *product;
@property (strong, nonatomic) NSMutableArray *tabItems;

- (void)setData;
- (NSString *)convertToHTMLString:(NSArray *)arr;

@end
