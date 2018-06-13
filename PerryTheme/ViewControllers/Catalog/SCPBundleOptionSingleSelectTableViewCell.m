//
//  SCPBundleOptionSingleSelectTableViewCell.m
//  SimiCartPluginFW
//
//  Created by Liam on 6/12/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPBundleOptionSingleSelectTableViewCell.h"

@implementation SCPBundleOptionSingleSelectTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier optionRow:(SCProductOptionRow *)optionRow productModel:(SimiProductModel *)productModel{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.optionValueModel = optionRow.optionValueModel;
        self.productModel = productModel;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (self) {
            [self setBackgroundColor:[UIColor clearColor]];
            float padding = SCP_GLOBALVARS.padding;
            float widthCell = SCREEN_WIDTH - padding *2;
            if (PADDEVICE) {
                widthCell = SCREEN_WIDTH *2/3 - padding *2;
            }
            self.simiContentView = [[UIView alloc]initWithFrame:CGRectMake(padding, 0, widthCell, optionRow.height)];
            [self.simiContentView setBackgroundColor:[UIColor whiteColor]];
            [self.contentView addSubview:self.simiContentView];
            
            self.nameLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, 10, widthCell - padding*2 - 100, 24) andFontName:SCP_FONT_REGULAR andFontSize:FONT_SIZE_MEDIUM andTextColor:COLOR_WITH_HEX(@"#272727")];
            [self.simiContentView addSubview:self.nameLabel];
            
            self.selectImageView = [[UIImageView alloc]initWithFrame:CGRectMake(widthCell - padding - 15, 15, 15, 15)];
            [self.simiContentView addSubview:self.selectImageView];
            
            NSString *optionPrice = @"";
            SimiBundleOptionValueModel *bundleValueModel = (SimiBundleOptionValueModel *)self.optionValueModel;
            NSDictionary *bundleOptions = nil;
            if ([[self.productModel.appOptions valueForKey:@"bundle_options"] isKindOfClass:[NSDictionary class]]) {
                bundleOptions = [[self.productModel.modelData objectForKey:@"app_options"] objectForKey:@"bundle_options"];
            }
            if (bundleOptions != nil) {
                if([[bundleOptions valueForKey:@"showIncludeTax"]boolValue]){
                    if (bundleValueModel.priceInclTax > 0 || (bundleValueModel.priceInclTax == 0 && [GLOBALVAR isShowZeroPrice])) {
                        optionPrice = [[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%f",bundleValueModel.priceInclTax]];
                    }
                }else if ([[bundleOptions valueForKey:@"showBothPrices"]boolValue]){
                    if (bundleValueModel.priceInclTax > 0 || (bundleValueModel.priceInclTax && [GLOBALVAR isShowZeroPrice])){
                        optionPrice = [[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%f",bundleValueModel.priceInclTax]];
                    }
                }else{
                    if (bundleValueModel.priceExclTax > 0 || (bundleValueModel.priceExclTax == 0 && [GLOBALVAR isShowZeroPrice])) {
                        optionPrice = [[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%f",bundleValueModel.priceExclTax]];
                    }
                }
            }
            if (![optionPrice isEqualToString:@""]) {
                optionPrice= [NSString stringWithFormat:@"  %@",optionPrice];
            }
            NSString *titleString = [NSString stringWithFormat:@"%@%@",self.self.optionValueModel.title,optionPrice];
            UIColor *optionNameColor = COLOR_WITH_HEX(@"#272727");
            UIColor *priceColor = COLOR_WITH_HEX(@"#F69435");
            NSMutableAttributedString *titleAttributeString = [[NSMutableAttributedString alloc]initWithString:titleString];
            [titleAttributeString addAttributes:@{NSFontAttributeName:[UIFont fontWithName:SCP_FONT_LIGHT size:FONT_SIZE_MEDIUM],NSForegroundColorAttributeName:optionNameColor} range:[titleString rangeOfString:self.optionValueModel.title]];
            if (![optionPrice isEqualToString:@""]) {
                [titleAttributeString addAttributes:@{NSFontAttributeName:[UIFont fontWithName:SCP_FONT_REGULAR size:FONT_SIZE_MEDIUM],NSForegroundColorAttributeName:priceColor} range:[titleString rangeOfString:optionPrice]];
            }
            [self.nameLabel setAttributedText:titleAttributeString];
        }
    }
    return self;
}
@end
