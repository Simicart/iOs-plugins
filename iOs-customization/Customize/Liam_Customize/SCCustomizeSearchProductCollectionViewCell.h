//
//  SCCustomizeSearchProductCollectionViewCell.h
//  SimiCartPluginFW
//
//  Created by Liam on 4/26/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SCProductCollectionViewCell.h>

@interface SCCustomizeSearchProductCollectionViewCell : SCProductCollectionViewCell
@property (strong, nonatomic) NSDictionary *productData;
- (void)updateProductDataForCell:(NSDictionary*)data;
@end
