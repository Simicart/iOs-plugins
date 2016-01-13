//
//  ZThemeCartCell.m
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 5/28/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiFormatter.h>
#import <SimiCartBundle/UILabelDynamicSize.h>

#import "ZThemeCartCell.h"
#import "ZThemeWorker.h"

@implementation ZThemeCartCell

@synthesize nameLabel, priceLabel, qtyTextField, productImageView, deleteButton, deleteImage, stockStatusLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    //     Configure the view for the selected state
}

- (void)setName:(NSString *)name
{
    if (![_name isEqualToString:name]) {
        _name = [name copy];
        self.nameLabel = [[UILabel alloc]init];
        self.nameLabel.text = _name;
        self.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
}

- (void)setItem:(SimiCartModel *)item
{
    if (![_item isEqual:item]) {
        _item = [item copy];
    }
}

- (void)setPrice:(NSString *)price
{
    if (![_price isEqual:price]) {
        _price = [price copy];
        if (self.priceLabel == nil) {
            self.priceLabel = [[UILabel alloc]init];
        }
        self.priceLabel.text = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[NSNumber numberWithFloat:[_price floatValue]]];
    }
}

- (void)setQty:(NSString *)qty
{
    if (![self.qtyTextField.text isEqualToString:qty]) {
        _qty = [qty copy];
        if (self.qtyTextField == nil) {
            self.qtyTextField = [[UITextField alloc]init];
        }
        self.qtyTextField.text = _qty;
        self.qtyTextField.keyboardType = UIKeyboardTypeNumberPad;
    }
}

- (void)setStockStatus:(BOOL)stockStatus
{
    _stockStatus = stockStatus;
    self.stockStatusLabel = [[UILabel alloc]init];
    if(_stockStatus){
        self.stockStatusLabel.text = SCLocalizedString(@"In Stock");
    }else{
        self.stockStatusLabel.text = SCLocalizedString(@"Out Stock");
    }
}
- (void)setImagePath:(NSString *)imagePath
{
    if (![imagePath isKindOfClass:[NSNull class]]) {
        if (![_imagePath isEqualToString:imagePath]) {
            _imagePath = [imagePath copy];
            self.productImageView = [[UIImageView alloc]init];
            [self.productImageView sd_setImageWithURL:[NSURL URLWithString:_imagePath]];
            [self.productImageView setContentMode:UIViewContentModeScaleAspectFit];
        }
    }
}

- (void)setTextFieldTag:(NSInteger)textFieldTag
{
    self.qtyTextField.tag = textFieldTag;
}

- (void)deleteButtonClicked:(id)sender
{
    [self.delegate removeProductFromCart:self.cartItemId];
}

#pragma mark Set Interface
- (void)setInterfaceCell
{
    _heightCell = 5;
    float imageX = 10;
    float labelNameX = 100;
    float labelOptionX = 100;
    float labelValueX = 160;
    float deleteImageX = 300;
    float textFieldX = 255;
    
    float widthOption = 60;
    float widthValue = 120;
    float widthName = 190;
    
    float heightLabel = 20;
    
    if([[SimiGlobalVar sharedInstance]isReverseLanguage])
    {
        imageX = 230;
        labelNameX = 30;
        labelOptionX = 160;
        labelValueX = 20;
        deleteImageX = 10;
        textFieldX = 10;
    }
    
    [self.productImageView setFrame:CGRectMake(imageX, _heightCell + 5, 80, 90)];
    [self addSubview:self.productImageView];
    
    
    self.deleteImage = [[UIImageView alloc]init];
    
    UIImage *imgDelete = [UIImage imageNamed:@"Ztheme_delete"];
    self.deleteImage.image = imgDelete;
    [self.deleteImage setFrame:CGRectMake(deleteImageX, _heightCell + 5, 10, 10)];
    self.deleteButton = [[UIButton alloc]init];
    CGRect frame = self.deleteImage.frame;
    frame.origin.x -= 10;
    frame.origin.y -= 10;
    frame.size.width += 20;
    frame.size.height += 20;
    self.deleteButton.frame = frame;
    [self.deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.deleteImage];
    [self addSubview:self.deleteButton];
    
    [self.nameLabel setFrame:CGRectMake(labelNameX, _heightCell, widthName, heightLabel)];
    [self.nameLabel resizLabelToFit];
    self.nameLabel.textColor = [UIColor blackColor];
    self.nameLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", ZTHEME_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
    [self addSubview:self.nameLabel];
    frame = self.nameLabel.frame;
    self.nameLabel.numberOfLines = 1;
    if(frame.size.height > 30){
        frame.size.height = 40;
        self.nameLabel.numberOfLines = 2;
        frame.origin.x = frame.origin.x - 1;
        self.nameLabel.frame = frame;
    }
    _heightCell += heightLabel * self.nameLabel.numberOfLines;
    
    [self.priceLabel setFrame:CGRectMake(labelNameX, _heightCell, widthName, heightLabel)];
    self.priceLabel.textColor = ZTHEME_PRICE_COLOR;
    self.priceLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", ZTHEME_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
    [self addSubview:self.priceLabel];
    _heightCell += heightLabel;
    int i = 0;
    for (NSDictionary *option in [_item valueForKeyPath:@"options"]) {
        if(i < 2){
            UILabel *optionNameLabel =  [[UILabel alloc]initWithFrame:CGRectMake(labelOptionX, _heightCell, widthOption, 20)];
            optionNameLabel.text = [NSString stringWithFormat:@"%@:", [option valueForKeyPath:@"option_title"]];
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                optionNameLabel.text = [NSString stringWithFormat:@":%@", [option valueForKeyPath:@"option_title"]];
            }
            optionNameLabel.textColor = [UIColor blackColor];
            optionNameLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", ZTHEME_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
            [self addSubview:optionNameLabel];
            
            UILabel *optionValueLabel =  [[UILabel alloc]init];
            
            optionValueLabel.text = [[NSString stringWithFormat:@"%@", [option valueForKeyPath:@"option_value"]] stringByDecodingHTMLEntities];
            [optionValueLabel setFrame:CGRectMake(labelValueX, _heightCell, widthValue , 20)];
            optionValueLabel.textColor = [UIColor blackColor];
            optionValueLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", ZTHEME_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
            [self addSubview:optionValueLabel];
            _heightCell += heightLabel;
        }
        i++;
    }
    
    UILabel *qtyLabel =  [[UILabel alloc]initWithFrame:CGRectMake(labelOptionX, _heightCell, widthOption, 20)];
    qtyLabel.text = [NSString stringWithFormat:@"%@:", SCLocalizedString(@"Quantity")];
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        qtyLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Quantity")];
    }
    qtyLabel.textColor = [UIColor blackColor];
    qtyLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", ZTHEME_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
    [self addSubview:qtyLabel];
    
    [self.qtyTextField setFrame:CGRectMake(textFieldX, _heightCell - 1, 55, heightLabel)];
    self.qtyTextField.textColor = [UIColor blackColor];
    self.qtyTextField.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", ZTHEME_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
    [self.qtyTextField setTextAlignment:NSTextAlignmentCenter];
    //Set Strike Through for Regular Price
    UIView *throughLine = [[UIView alloc] init];
    throughLine.backgroundColor = [UIColor lightGrayColor];
    frame = self.qtyTextField.frame;
    frame.origin.y += frame.size.height;
    frame.size.height = 1;
    throughLine.frame = frame;
    [self addSubview:throughLine];
    [self addSubview:self.qtyTextField];
    _heightCell += heightLabel;
    UIImage *imgEdit = [UIImage imageNamed:@"Ztheme_edit_qty"];
    UIImageView *editImage = [[UIImageView alloc]init];
    editImage.image = imgEdit;
    frame.origin.x += 48;
    frame.origin.y -= 7;
    frame.size.height = 7;
    frame.size.width = 7;
    editImage.frame = frame;
    [self addSubview:editImage];
    
    [self.stockStatusLabel setFrame:CGRectMake(labelNameX, _heightCell, widthName, heightLabel)];
    self.stockStatusLabel.textColor = [UIColor redColor];
    self.stockStatusLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", ZTHEME_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
    [self addSubview:self.stockStatusLabel];
    
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel*)view;
                [label setTextAlignment:NSTextAlignmentRight];
            }
        }
    }
}

@end

