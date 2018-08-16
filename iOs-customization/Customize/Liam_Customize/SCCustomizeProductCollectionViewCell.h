//
//  SCCustomizeProductCollectionViewCell.h
//  SimiCartPluginFW
//
//  Created by Liam on 3/5/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SCProductCollectionViewCell.h>

@interface SCCustomizeProductCollectionViewCell : SCProductCollectionViewCell
@property (strong, nonatomic) SimiButton *callForPriceButton;
@property BOOL isShowNameOneLine;
@end
