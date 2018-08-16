//
//  SCCustomizeProductCollectionViewCell.m
//  SimiCartPluginFW
//
//  Created by Liam on 3/5/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCCustomizeProductCollectionViewCell.h"

@implementation SCCustomizeProductCollectionViewCell
- (void)setProductModelForCell:(SimiProductModel *)productModel{
    if (![self.productModel isEqual:productModel]) {
        [super setProductModelForCell:productModel];
        [self.imageStockStatus setHidden:YES];
        [self.lblStockStatus setHidden:YES];
        if(!_isShowNameOneLine){
            self.lblNameProduct.numberOfLines = 3;
            [self.lblNameProduct sizeToFit];
        }
        float height = CGRectGetHeight(self.lblNameProduct.frame) + 5;;
        CGRect frame = self.priceView.frame;
        frame.origin.y = imageSize + height;
        if(GLOBALVAR.isLogin){
            if([[self.productModel objectForKey:@"final_price"] floatValue] == 0 && self.productModel.productType != ProductTypeGrouped){
                self.priceView.hidden = YES;
                if(!_callForPriceButton){
                    frame.size.height = 40;
                    frame.origin.y = CGRectGetHeight(self.contentView.frame) - 40;
                    self.callForPriceButton = [[SimiButton alloc] initWithFrame:frame title:@"Call For Price"];
                    float widthOfText = [SCLocalizedString(@"Call For Price") sizeWithAttributes:@{NSFontAttributeName:self.callForPriceButton.titleLabel.font}].width;
                    UIFont *font = self.callForPriceButton.titleLabel.font;
                    if(widthOfText > self.callForPriceButton.frame.size.width - 20){
                        float fontSize = self.callForPriceButton.titleLabel.font.pointSize;
                        fontSize -= 1;
                        self.callForPriceButton.titleLabel.font = [UIFont fontWithName:font.fontName size:fontSize];
                    }
                    self.callForPriceButton.layer.cornerRadius = 4.0f;
                    [self.contentView addSubview:self.callForPriceButton];
                    [self.callForPriceButton addTarget:self action:@selector(callForPrice:) forControlEvents:UIControlEventTouchUpInside];
                }
                _callForPriceButton.hidden = NO;
            }else{
                [self.priceView setFrame:frame];
                _callForPriceButton.hidden = YES;
                self.priceView.hidden = NO;
            }
        }
    }
}
- (void)callForPrice:(UIButton *)button{
    NSURL *url = [NSURL URLWithString:@"tel:1300680638"];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
    }
}
@end
