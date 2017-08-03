//
//  SCGiftCardCollectionViewCell.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCGiftCardCollectionViewCell.h"

@implementation SCGiftCardCollectionViewCell
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        float imageSize = CGRectGetWidth(frame);
        productImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, imageSize, imageSize)];
        productImageView.contentMode = UIViewContentModeScaleAspectFit;
        [productImageView.layer setBorderWidth:1];
        [productImageView.layer setBorderColor:THEME_IMAGE_BORDER_COLOR.CGColor];
        [self.contentView addSubview:productImageView];
        
        nameLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(0, imageSize, imageSize, 20) andFontSize:15];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:nameLabel];
        
        float sizeImageStock = 80;
        stockStatusLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(imageSize - sizeImageStock - 10, imageSize - 35, sizeImageStock * 1.4, 14) andFontName:THEME_FONT_NAME_REGULAR andFontSize:8 andTextColor:THEME_OUT_STOCK_TEXT_COLOR text:[SCLocalizedString(@"Out of stock") uppercaseString]];
        [stockStatusLabel setBackgroundColor:[UIColor clearColor]];
        stockStatusImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageSize - sizeImageStock, imageSize - sizeImageStock, sizeImageStock, sizeImageStock)];
        [stockStatusImageView setImage:[UIImage imageNamed:@"stockstatus_background"]];
        [stockStatusImageView addSubview:stockStatusLabel];
        [productImageView addSubview:stockStatusImageView];
    }
    return self;
}

- (void)setProductModel:(SimiGiftCardModel *)productModel{
    if (_productModel == nil) {
        _productModel = productModel;
        stockStatus = [[self.productModel valueForKey:@"is_salable"] boolValue];
        if (!stockStatus) {
            [stockStatusImageView setHidden:YES];
        }
        if ([[self.productModel valueForKey:@"images"] isKindOfClass:[NSArray class]]) {
            NSArray *images = [self.productModel valueForKey:@"images"];
            if (images.count > 0) {
                NSDictionary *image = [images objectAtIndex:0];
                [productImageView sd_setImageWithURL:[NSURL URLWithString:[image valueForKey:@"url"]]placeholderImage:[UIImage imageNamed:@"logo"]];
            }
        }
        if ([self.productModel valueForKey:@"name"]) {
            [nameLabel setText:[NSString stringWithFormat:@"%@",[self.productModel valueForKeyPath:@"name"]]];
        }
    }
}
@end
