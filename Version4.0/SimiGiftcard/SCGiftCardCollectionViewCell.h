//
//  SCGiftCardCollectionViewCell.h
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiGiftCardModel.h"

@interface SCGiftCardCollectionViewCell : UICollectionViewCell{
    UIImageView *productImageView;
    SimiLabel *nameLabel;
    NSDictionary *priceDict;
    BOOL stockStatus;
    UIImageView *stockStatusImageView;
    SimiLabel *stockStatusLabel;
}
@property (strong, nonatomic) SimiGiftCardModel *productModel;
@end
