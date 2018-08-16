//
//  SCCusSearchModel.h
//  SimiCartPluginFW
//
//  Created by Liam on 4/25/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiModel.h>

@interface SCCusSearchModel : SimiModel
@property (strong, nonatomic) NSString *searchKey;
@property (nonatomic) int totalItems;
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSArray *pages;
@property (strong, nonatomic) NSArray *items;
- (void)starSearchanise;
@end
