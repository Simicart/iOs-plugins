//
//  SCProductListTableViewCell+Customize.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 2/8/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCProductListTableViewCell+Customize.h"

@implementation SCProductListTableViewCell (Customize)
- (void)createPriceView{
    float buttonWidth = 0;
    if (GLOBALVAR.useAddToCartOnProductList) {
        NSString *buttonTitle = @"";
        if(GLOBALVAR.isLogin){
            buttonTitle = @"Add To Cart";
            if([[self.product objectForKey:@"final_price"] floatValue] == 0 && self.product.productType != ProductTypeGrouped){
                buttonTitle = @"Call For Price";
            }
        }else{
            buttonTitle = @"Please login to checkout";
        }
        UIFont *titleFont = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:15];
        buttonWidth = [buttonTitle sizeWithAttributes:@{NSFontAttributeName:titleFont}].width + 30;
        self.addToCartButton = [[SimiButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - padding - buttonWidth, self.heightCell , buttonWidth, 40)];
        [self.addToCartButton addTarget:self action:@selector(addToCart:) forControlEvents:UIControlEventTouchUpInside];
        [self.addToCartButton setTitle:buttonTitle forState:UIControlStateNormal];
        self.addToCartButton.layer.cornerRadius = 4;
        [self.addToCartButton.titleLabel setFont:titleFont];
        [self.contentView addSubview:self.addToCartButton];
    }
    if(GLOBALVAR.isLogin && ([[self.product objectForKey:@"final_price"] floatValue] != 0 || self.product.productType == ProductTypeGrouped)){
        if (self.product.appPrices) {
            self.priceView = [[SCPriceView alloc]initWithFrame:CGRectMake(padding, self.heightCell, imageWidth -  buttonWidth, heightLabel)];
            [self.priceView setProductModel:self.product andWidthView:CGRectGetWidth(self.priceView.frame)];
            [self.contentView addSubview:self.priceView];
        }
    }
    self.heightCell += CGRectGetHeight(self.priceView.frame) + 40;
}
- (void)addToCart:(UIButton *)button{
    if(!GLOBALVAR.isLogin){
        return;
    }
    if([[self.product objectForKey:@"final_price"] floatValue] == 0 && self.product.productType != ProductTypeGrouped){
        NSURL *url = [NSURL URLWithString:@"tel:1300680638"];
        if([[UIApplication sharedApplication] canOpenURL:url]){
            [[UIApplication sharedApplication] openURL:url];
        }
        return;
    }
    [super addToCart:button];
}
- (void)createStockLabel{
    
}
@end
