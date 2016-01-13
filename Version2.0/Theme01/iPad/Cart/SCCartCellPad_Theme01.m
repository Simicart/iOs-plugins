//
//  SCCartCellPad_Theme01.h
//  SimiCart
//
//  Created by Tan on 5/16/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiFormatter.h>
#import <SimiCartBundle/UILabelDynamicSize.h>
#import "SCCartCellPad_Theme01.h"
#import "SimiThemeWorker.h"

@implementation SCCartCellPad_Theme01

@synthesize nameLabel, priceLabel, qtyTextField, productImageView, deleteButton, deleteImage, stockStatusLabel, cellWith;

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
        nameLabel = [[UILabel alloc]init];
        nameLabel.text = _name;
        nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
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
        if (priceLabel == nil) {
            priceLabel = [[UILabel alloc]init];
        }
        priceLabel.text = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[NSNumber numberWithFloat:[_price floatValue]]];
    }
}

- (void)setQty:(NSString *)qty
{
    if (![qtyTextField.text isEqualToString:qty]) {
        _qty = [qty copy];
        if (qtyTextField == nil) {
            qtyTextField = [[UITextField alloc]init];
        }
        qtyTextField.text = _qty;
        qtyTextField.keyboardType = UIKeyboardTypeNumberPad;
    }
}

- (void)setStockStatus:(BOOL)stockStatus
{
    _stockStatus = stockStatus;
    stockStatusLabel = [[UILabel alloc]init];
    if(_stockStatus){
        stockStatusLabel.text = SCLocalizedString(@"In Stock");
    }else{
        stockStatusLabel.text = SCLocalizedString(@"Out Stock");
    }
}
- (void)setImagePath:(NSString *)imagePath
{
    if (![imagePath isKindOfClass:[NSNull class]]) {
        if (![_imagePath isEqualToString:imagePath]) {
            _imagePath = [imagePath copy];
            productImageView = [[UIImageView alloc]init];
            [productImageView sd_setImageWithURL:[NSURL URLWithString:_imagePath]];
            [productImageView setContentMode:UIViewContentModeScaleAspectFit];
        }
    }
}

- (void)setTextFieldTag:(NSInteger)textFieldTag
{
    qtyTextField.tag = textFieldTag;
}

- (void)deleteButtonClicked:(id)sender
{
    [self.delegate removeProductFromCart:self.cartItemId];
}

#pragma mark Set Interface
- (void)setInterfaceCell
{
    _heightCell = 25;
    float labelNameX = 280;
    float labelOptionX = 280;
    float labelValueX = 390;
    float imageX = 30;
    float deleteX = cellWith - 40;
    float editTextX = 515;
    
    float widthLabel = cellWith - 320;
    float widthOption = 100;
    float widthValue = 200;
    int heightLabel = 25;
    
    //  Liam Update RTL
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        deleteX = 30;
        imageX = 370;
        labelNameX = 50;
        editTextX = 30;
        labelOptionX = 250;
        labelValueX = 50;
    }
    //  End RTL

    [productImageView setFrame:CGRectMake(imageX, _heightCell + 5, 220, 220)];
    [self addSubview:productImageView];
    
    _productBackgroundImage = [[UIImageView alloc]initWithFrame:productImageView.frame];
    [_productBackgroundImage setImage:[UIImage imageNamed:@""]];
    [_productBackgroundImage.layer setBorderWidth:1.0];
    [_productBackgroundImage.layer setBorderColor:[UIColor colorWithRed:202.0/255 green:202.0/255 blue:202.0/255 alpha:0.5].CGColor];
    [_productBackgroundImage setImage:[UIImage imageNamed:@"theme1_cartbackgroundimageproduct"]];
    [self addSubview:_productBackgroundImage];
    
    CGRect frame = productImageView.frame;
    frame.origin.x += 195;
    frame.origin.y += 195;
    frame.size.height = 20;
    frame.size.width = 20;
    _showProductDetailImage = [[UIImageView alloc]initWithFrame:frame];
    [_showProductDetailImage setImage:[UIImage imageNamed:@"theme1_itemshowproductdetail"]];
    [self addSubview:_showProductDetailImage];
    
    _btnShowProductDetailImage = [[UIButton alloc]initWithFrame:productImageView.frame];
    [_btnShowProductDetailImage addTarget:self action:@selector(didSelectProduct:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnShowProductDetailImage];
    
    
    deleteImage = [[UIImageView alloc]init];
    
    UIImage *imgDelete = [UIImage imageNamed:@"theme01_delete"];
    deleteImage.image = imgDelete;
    [deleteImage setFrame:CGRectMake(deleteX, _heightCell - 15, 13, 13)];
    deleteButton = [[UIButton alloc]init];
    frame = deleteImage.frame;
    frame.origin.x -= 15;
    frame.origin.y -= 15;
    frame.size.width += 30;
    frame.size.height += 30;
    deleteButton.frame = frame;
    [deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:deleteImage];
    [self addSubview:deleteButton];
    
    [nameLabel setFrame:CGRectMake(labelNameX, _heightCell + 5, widthLabel, heightLabel)];
    [nameLabel resizLabelToFit];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE];
    [self addSubview:nameLabel];
    frame = nameLabel.frame;
    nameLabel.numberOfLines = 1;
    if(frame.size.height > 30){
        frame.size.height = 50;
        nameLabel.numberOfLines = 2;
        frame.origin.x = frame.origin.x - 1;
        nameLabel.frame = frame;
    }
    frame.origin.y = frame.origin.y - 8;
    nameLabel.frame = frame;
    _heightCell += heightLabel * nameLabel.numberOfLines + 3;
    
    [priceLabel setFrame:CGRectMake(labelNameX, _heightCell, widthLabel, heightLabel)];
    priceLabel.textColor = THEME01_PRICE_COLOR;
    priceLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_LIGHT] size:20];
    [self addSubview:priceLabel];
    _heightCell += heightLabel * 2;
    int i = 0;
    for (NSDictionary *option in [_item valueForKeyPath:@"options"]) {
        if(i < 2){
            UILabel *optionNameLabel =  [[UILabel alloc]initWithFrame:CGRectMake(labelOptionX, _heightCell, widthOption, 20)];
            optionNameLabel.text = [NSString stringWithFormat:@"%@:", [option valueForKeyPath:@"option_title"]];
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                [optionNameLabel setText:[NSString stringWithFormat:@":%@", [option valueForKeyPath:@"option_title"]]];
            }
            optionNameLabel.textColor = [UIColor blackColor];
            optionNameLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE];
            [self addSubview:optionNameLabel];
            
            
            UILabel *optionValueLabel =  [[UILabel alloc]init];
            optionValueLabel.text = [[NSString stringWithFormat:@"%@", [option valueForKeyPath:@"option_value"]] stringByDecodingHTMLEntities];
            [optionValueLabel setFrame:CGRectMake(labelValueX , _heightCell, widthValue, 20)];
            optionValueLabel.textColor = [UIColor blackColor];
            optionValueLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE];
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
    qtyLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE];
    [self addSubview:qtyLabel];

    [qtyTextField setFrame:CGRectMake(editTextX, _heightCell - 1, 75, heightLabel)];
    qtyTextField.textColor = [UIColor blackColor];
    qtyTextField.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE];
    [qtyTextField setTextAlignment:NSTextAlignmentCenter];
    //Set Strike Through for Regular Price
    UIView *throughLine = [[UIView alloc] init];
    throughLine.backgroundColor = [UIColor lightGrayColor];
    frame = qtyTextField.frame;
    frame.origin.y += frame.size.height;
    frame.size.height = 1;
    throughLine.frame = frame;
    [self addSubview:throughLine];
    [self addSubview:qtyTextField];
    _heightCell += heightLabel;
    UIImage *imgEdit = [UIImage imageNamed:@"theme01_edit_qty"];
    UIImageView *editImage = [[UIImageView alloc]init];
    editImage.image = imgEdit;
    frame.origin.x += 68;
    frame.origin.y -= 8;
    frame.size.height = 9;
    frame.size.width = 9;
    editImage.frame = frame;
    [self addSubview:editImage];
    
    [stockStatusLabel setFrame:CGRectMake(labelNameX, _heightCell, widthLabel, heightLabel)];
    stockStatusLabel.textColor = [UIColor redColor];
    stockStatusLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE];
    [self addSubview:stockStatusLabel];
    //  Liam Update RTL
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel*)view;
                [label setTextAlignment:NSTextAlignmentRight];
            }
        }
    }
    //  End RTL
    
}

- (void) setCellWith:(int)cellWith_
{
    cellWith = cellWith_;
}

- (int) getCellWith
{
    return cellWith;
}

- (void)didSelectProduct:(id)sender
{
    [self.delegate showProductDetail:[_item valueForKey:@"product_id"]];
}

@end
