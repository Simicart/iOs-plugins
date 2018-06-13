//
//  SCPOptionSingleSelectTableViewCell.m
//  SimiCartPluginFW
//
//  Created by Liam on 6/12/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPOptionSingleSelectTableViewCell.h"

@implementation SCPOptionSingleSelectTableViewCell{
    NSMutableAttributedString *titleAttributeString;
    NSMutableAttributedString *disableTitleAttributeString;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier optionRow:(SCProductOptionRow *)optionRow productModel:(SimiProductModel *)productModel{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
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
        
        self.selectImageView = [[UIImageView alloc]initWithFrame:CGRectMake(padding + 80, 15, 15, 15)];
        [self.simiContentView addSubview:self.selectImageView];
        
        self.nameLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding + 100, 10, widthCell - padding*2 - 100, 24) andFontName:SCP_FONT_REGULAR andFontSize:FONT_SIZE_MEDIUM andTextColor:COLOR_WITH_HEX(@"#272727")];
        [self.simiContentView addSubview:self.nameLabel];
        
        NSString *optionPrice = @"";
        if ([self.optionValueModel isKindOfClass:[SimiConfigurableOptionValueModel class]]) {
            SimiConfigurableOptionValueModel *configurableValueModel = (SimiConfigurableOptionValueModel *)self.optionValueModel;
            if (configurableValueModel.price > 0 || (configurableValueModel.price == 0 && [GLOBALVAR isShowZeroPrice])) {
                optionPrice = [[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%f",configurableValueModel.price]];
            }
        }else{
            SimiCustomOptionValueModel *customValueModel = (SimiCustomOptionValueModel*)self.optionValueModel;
            if (self.productModel.appPrices) {
                if ([[self.productModel.appPrices valueForKey:@"show_ex_in_price"]boolValue]){
                    optionPrice = [[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%f",customValueModel.price_including_tax]];
                }else{
                    optionPrice = [[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%f",customValueModel.price]];
                }
            }
        }
        if (![optionPrice isEqualToString:@""]) {
            optionPrice= [NSString stringWithFormat:@" + %@",optionPrice];
        }
        NSString *titleString = [NSString stringWithFormat:@"%@%@",self.self.optionValueModel.title,optionPrice];
        UIColor *optionNameColor = COLOR_WITH_HEX(@"#272727");
        UIColor *priceColor = COLOR_WITH_HEX(@"#F69435");
        titleAttributeString = [[NSMutableAttributedString alloc]initWithString:titleString];
        [titleAttributeString addAttributes:@{NSFontAttributeName:[UIFont fontWithName:SCP_FONT_LIGHT size:FONT_SIZE_MEDIUM],NSForegroundColorAttributeName:optionNameColor} range:[titleString rangeOfString:self.optionValueModel.title]];
        disableTitleAttributeString = [[NSMutableAttributedString alloc]initWithString:titleString attributes:@{NSStrikethroughStyleAttributeName:[NSNumber numberWithInt:NSUnderlineStyleSingle]}];
        [disableTitleAttributeString addAttributes:@{NSFontAttributeName:[UIFont fontWithName:SCP_FONT_LIGHT size:FONT_SIZE_MEDIUM],NSForegroundColorAttributeName:optionNameColor} range:[titleString rangeOfString:self.optionValueModel.title]];
        if (![optionPrice isEqualToString:@""]) {
            [titleAttributeString addAttributes:@{NSFontAttributeName:[UIFont fontWithName:SCP_FONT_REGULAR size:FONT_SIZE_MEDIUM],NSForegroundColorAttributeName:priceColor} range:[titleString rangeOfString:optionPrice]];
            [disableTitleAttributeString addAttributes:@{NSFontAttributeName:[UIFont fontWithName:SCP_FONT_REGULAR size:FONT_SIZE_MEDIUM],NSForegroundColorAttributeName:priceColor} range:[titleString rangeOfString:optionPrice]];
        }
        [self.nameLabel setAttributedText:titleAttributeString];
    }
    return self;
}

- (void)updateCellWithRow:(SCProductOptionRow *)optionRow{
    self.optionValueModel = optionRow.optionValueModel;
    if (self.optionValueModel.isSelected) {
        [self.selectImageView setImage:[UIImage imageNamed:@"scp_ic_option_selected"]];
    }else{
        [self.selectImageView setImage:[UIImage imageNamed:@"scp_ic_option_unselect"]];
    }
    if ([self.optionValueModel isKindOfClass:[SimiConfigurableOptionValueModel class]]) {
        if (self.optionValueModel.hightLight) {
            [self.nameLabel setAttributedText:titleAttributeString];
        }else{
            [self.nameLabel setAttributedText:disableTitleAttributeString];
        }
    }
}
@end
