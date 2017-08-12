//
//  SCGiftCardCollectionViewCell.h
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SimiGiftCardModel.h"
#import "SCGiftCardPriceView.h"

@interface SCGiftCardCollectionViewCell : UICollectionViewCell{
    UIImageView *productImageView;
    SimiLabel *nameLabel;
    NSDictionary *priceDict;
    BOOL stockStatus;
    UIImageView *stockStatusImageView;
    SimiLabel *stockStatusLabel;
    SCGiftCardPriceView *giftPriceView;
}
@property (strong, nonatomic) SimiGiftCardModel *productModel;
@end
