//
//  SimiTagCollectionCell.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 7/12/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//
#import <SimiCartBundle/SimiModel.h>
#import "SimiTagModelCollection.h"
@interface SimiTagCollectionCell : UICollectionViewCell
@property (nonatomic, strong)  UIImageView *imgTag;
@property (nonatomic, strong)  UILabel *lblTagName;
@property (nonatomic) BOOL hasData;
@property (nonatomic, strong) SimiTagModel *simiTagModel;
- (void)setData;
@end
