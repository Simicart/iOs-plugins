//
//  SCPCartCell.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 6/4/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPCartCell.h"
#import "SCPGlobalVars.h"

@implementation SCPCartCell{
    UIView *qtyView;
    SimiLabel *priceLabel;
    float contentPadding;
}
@synthesize contentWidth, contentHeight, qtyViewHeight,qtyViewWidth,priceWidth,paddingX,paddingY;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier quoteItemModel:(SimiQuoteItemModel *)itemModel{
    self = [self initWithStyle:style reuseIdentifier:reuseIdentifier quoteItemModel:itemModel useOnOrderPage:NO];
    return self;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier quoteItemModel:(SimiQuoteItemModel*)itemModel useOnOrderPage:(BOOL)useOnOrderPage{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.useOnOrderPage = useOnOrderPage;
        self.item = itemModel;
        [[NSNotificationCenter defaultCenter] postNotificationName:SCCartCell_BeginInitialize object:self];
        if(self.isDiscontinue){
            self.isDiscontinue = NO;
            return self;
        }
        [self configureInterface];
        [self initContentView];
        [self initializedProductName];
        [self initializedDeleteButton];
        [self initializedOptions];
        [self initializedCartCellPrices];
        [self initializedCartQuantity];
        [self initializedProductImageView];
        [self updatePrices];
        [self updateQuantity];
        if(contentHeight < imageWidth)
            contentHeight = imageWidth;
        self.heightCell += contentHeight;
        CGRect frame = self.simiContentView.frame;
        frame.size.height = contentHeight;
        self.simiContentView.frame = frame;
        [[NSNotificationCenter defaultCenter] postNotificationName:SCCartCell_EndInitialize object:self];
        if(self.isDiscontinue){
            self.isDiscontinue = NO;
            return self;
        }
        [SimiGlobalFunction sortViewForRTL:self.simiContentView andWidth:contentWidth];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)configureInterface{
    cellWidth = SCREEN_WIDTH;
    paddingX = SCALEVALUE(15);
    contentPadding = SCALEVALUE(15);
    imageX = 0;
    imageWidth = SCALEVALUE(100);
    if(PADDEVICE){
        cellWidth = SCREEN_WIDTH*0.6f;
        if(self.useOnOrderPage){
            cellWidth = SCREEN_WIDTH*0.4f;
        }
        contentPadding = SCALEVALUE(20);
        paddingX = SCALEVALUE(15);
        imageWidth = SCALEVALUE(150);
    }
    contentWidth = cellWidth - 2*paddingX;
    deleteButtonWidth = 44;
    deleteButtonX = contentWidth - deleteButtonWidth;
    labelX = imageWidth + imageX + paddingX;
    labelWidth = contentWidth - labelX - paddingX;
    optionWidth = labelWidth;
    optionX = labelX;
    qtyViewHeight = 30;
    qtyViewWidth = SCALEVALUE(70);
    if(self.useOnOrderPage){
        qtyViewWidth = SCALEVALUE(95);
    }
    priceWidth = labelWidth - qtyViewWidth - SCALEVALUE(15);
    
    if(PADDEVICE){
        priceWidth = labelWidth - qtyViewWidth - SCALEVALUE(30);
    }
    
    self.heightCell = contentPadding;
    if(self.useOnOrderPage){
        self.heightCell = 0;
    }
    contentHeight = 0;
}

- (void)initContentView{
    self.simiContentView = [[UIView alloc] initWithFrame:CGRectMake(paddingX, self.heightCell, contentWidth, 0)];
    self.simiContentView.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.simiContentView];
}

- (void)initializedProductImageView{
    productImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, 0, imageWidth, imageWidth)];
    productImageView.backgroundColor = COLOR_WITH_HEX(@"#f7f7f7");
    if ([self.item.modelData valueForKey:@"image"]) {
        [productImageView sd_setImageWithURL:[NSURL URLWithString:[self.item.modelData valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"logo"]];
        [productImageView setContentMode:UIViewContentModeScaleAspectFill];
        productImageView.clipsToBounds = YES;
    }
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(productImageClick)];
    singleTap.numberOfTapsRequired = 1;
    [productImageView setUserInteractionEnabled:YES];
    [productImageView addGestureRecognizer:singleTap];
    [self.simiContentView addSubview:productImageView];
}

- (void)initializedDeleteButton{
    deleteButton = [UIButton new];
    [deleteButton setImage:[UIImage imageNamed:@"scp_ic_close"] forState:UIControlStateNormal];
    [deleteButton setImageEdgeInsets:UIEdgeInsetsMake(10, 20, 20, 10)];
    [deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    if (!self.useOnOrderPage) {
        [deleteButton setFrame:CGRectMake(deleteButtonX, 0, deleteButtonWidth, deleteButtonWidth)];
        [self.simiContentView addSubview:deleteButton];
    }
}

- (void)initializedProductName{
    if(self.useOnOrderPage)
        contentHeight += contentPadding;
    else
        contentHeight += 2*contentPadding;
    nameLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(labelX, contentHeight, labelWidth, 20) andFontName:SCP_FONT_SEMIBOLD andFontSize:FONT_SIZE_LARGE andTextColor:[UIColor blackColor] text:self.item.name];
    [self.simiContentView addSubview:nameLabel];
    contentHeight += CGRectGetHeight(nameLabel.frame) + contentPadding - 5;
}

- (void)initializedOptions{
    if (self.item.option) {
        options = [[NSMutableArray alloc]initWithArray:self.item.option];
    }
    if (optionsLabel == nil && options.count > 0) {
        optionsLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(labelX, contentHeight, labelWidth, 0)];
    }
    if (optionsLabel) {
        NSString *optionHTML = @"";
        for (int i = 0; i < options.count; i++) {
            NSDictionary *option = [options objectAtIndex:i];
            NSString *unitOptionHTML = [NSString stringWithFormat:@"<span style='font-family:%@;font-size:%f'>%@</span>: <span style='font-family:%@;font-size:%f'>%@</span>",SCP_FONT_REGULAR,FONT_SIZE_MEDIUM,[option valueForKeyPath:@"option_title"],SCP_FONT_LIGHT,FONT_SIZE_MEDIUM,[option valueForKeyPath:@"option_value"]];
            if (GLOBALVAR.isReverseLanguage) {
                unitOptionHTML = [NSString stringWithFormat:@"<span style='font-family:%@;font-size:%f'>%@</span>: <span style='font-family:%@;font-size:%f'>%@</span>",SCP_FONT_LIGHT,FONT_SIZE_MEDIUM,[option valueForKeyPath:@"option_value"],SCP_FONT_REGULAR,FONT_SIZE_MEDIUM,[option valueForKeyPath:@"option_title"]];
            }
            if (i > 0) {
                optionHTML = [NSString stringWithFormat:@"%@&emsp;%@",optionHTML,unitOptionHTML];
            }else
                optionHTML = [NSString stringWithFormat:@"%@", unitOptionHTML];
        }
        optionsLabel.attributedText =
        [[NSAttributedString alloc]  initWithData: [optionHTML dataUsingEncoding:NSUnicodeStringEncoding]
                                          options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                               documentAttributes: nil
                                            error: nil];
        optionsLabel.textColor = [UIColor blackColor];
        [self.simiContentView addSubview:optionsLabel];
        optionsLabel.numberOfLines = 0;
        [optionsLabel sizeToFit];
        contentHeight += CGRectGetHeight(optionsLabel.frame) + contentPadding;
    }
}

- (void)initializedCartQuantity{
    qtyView = [[UIView alloc] initWithFrame:CGRectMake(labelX, contentHeight, qtyViewWidth, qtyViewHeight)];
    [self.simiContentView addSubview:qtyView];
    contentHeight += CGRectGetHeight(qtyView.frame) + contentPadding;
    if(self.useOnOrderPage){
        SimiLabel *qtyLabel = [[SimiLabel alloc] initWithFrame:qtyView.bounds];
        NSString *qtyHTML = [NSString stringWithFormat:@"<span style='font-family:%@;font-size:%f'>%@</span>:&nbsp;<span style='font-family:%@;font-size:%f'>%@</span>",SCP_FONT_REGULAR,FONT_SIZE_MEDIUM,SCLocalizedString(@"Quantity"),SCP_FONT_LIGHT,FONT_SIZE_MEDIUM,[NSString stringWithFormat:@"%ld",(long)self.item.qty]];
        qtyLabel.attributedText =
        [[NSAttributedString alloc]  initWithData: [qtyHTML dataUsingEncoding:NSUnicodeStringEncoding]
                                          options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                               documentAttributes: nil
                                            error: nil];
        qtyLabel.textColor = [UIColor blackColor];
        [qtyLabel adjustFontSizeToFitText];
        [qtyView addSubview:qtyLabel];
    }else{
        float qtyBoxWidth = SCALEVALUE(30);
        float qtyBoxHeight = SCALEVALUE(25);
        float qtyButtonWidth = (qtyViewWidth - qtyBoxWidth)/2;
        if(self.item.maxQty > 10000)
            self.item.maxQty = 10000;
        qtyButton = [[UIButton alloc]initWithFrame:CGRectMake((qtyViewWidth - qtyBoxWidth)/2 , (qtyViewHeight - qtyBoxHeight)/2, qtyBoxWidth, qtyBoxHeight)];
        [qtyButton titleLabel].font = [UIFont fontWithName:SCP_FONT_SEMIBOLD size:FONT_SIZE_MEDIUM];
        qtyButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [qtyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [[qtyButton layer] setBorderColor:COLOR_WITH_HEX(@"#ff7d00").CGColor];
        [[qtyButton layer] setBorderWidth:1];
        [[qtyButton layer] setCornerRadius:qtyBoxWidth/3];
        [qtyButton addTarget:self action:@selector(qtyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [qtyView addSubview:qtyButton];
        UIButton *minusButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, qtyButtonWidth, qtyViewHeight)];
        [minusButton addTarget:self action:@selector(minusQty:) forControlEvents:UIControlEventTouchUpInside];
        [minusButton setTitle:@"-" forState:UIControlStateNormal];
        minusButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [minusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [minusButton titleLabel].font = [UIFont fontWithName:SCP_FONT_REGULAR size:30];
        UIButton *plusButton = [[UIButton alloc] initWithFrame:CGRectMake(qtyViewWidth - qtyButtonWidth, 0, qtyButtonWidth, qtyViewHeight)];
        [plusButton addTarget:self action:@selector(plusQty:) forControlEvents:UIControlEventTouchUpInside];
        [plusButton setTitle:@"+" forState:UIControlStateNormal];
        plusButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [plusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [plusButton titleLabel].font = [UIFont fontWithName:SCP_FONT_REGULAR size:30];
        [qtyView addSubview:qtyButton];
        [qtyView addSubview:minusButton];
        [qtyView addSubview:plusButton];
    }
}
- (void)minusQty:(id)sender{
    if(self.item.qty - self.item.qtyIncrement >= self.item.minQty){
        qty = self.item.qty - self.item.qtyIncrement;
        [self.delegate editItemQtyWithItem:self.item andQty:[NSString stringWithFormat:@"%d",qty]];
        [qtyButton setTitle:[NSString stringWithFormat:@"%ld",(long)qty] forState:UIControlStateNormal];
    }
}
- (void)plusQty:(id)sender{
    if(self.item.qty + self.item.qtyIncrement < self.item.maxQty){
        qty = self.item.qty + self.item.qtyIncrement;
        [self.delegate editItemQtyWithItem:self.item andQty:[NSString stringWithFormat:@"%d",qty]];
        [qtyButton setTitle:[NSString stringWithFormat:@"%ld",(long)qty] forState:UIControlStateNormal];
    }
}
- (void)initializedCartCellPrices{
    priceLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(labelX + labelWidth - priceWidth, contentHeight, priceWidth, qtyViewHeight) andFontName:SCP_FONT_SEMIBOLD andFontSize:FONT_SIZE_HEADER andTextColor:COLOR_WITH_HEX(@"#ff7d00")];
    [self.simiContentView addSubview:priceLabel];
}

- (void)updatePrices{
    NSDictionary *taxConfig = GLOBALVAR.storeView.tax;
    NSString *cartPriceConfig = [NSString stringWithFormat:@"%@",[taxConfig valueForKey:@"tax_cart_display_price"]];
    if ([cartPriceConfig isEqualToString:@"3"]) {
        priceLabel.text = [[SimiFormatter sharedInstance] priceWithPrice:self.item.rowTotalInclTax andCurrency:self.currencySymbol];
    }else if ([cartPriceConfig isEqualToString:@"2"]){
        priceLabel.text = [[SimiFormatter sharedInstance] priceWithPrice:self.item.rowTotalInclTax andCurrency:self.currencySymbol];
    }else if ([cartPriceConfig isEqualToString:@"1"]){
        priceLabel.text = [[SimiFormatter sharedInstance] priceWithPrice:self.item.rowTotal andCurrency:self.currencySymbol];
    }
    [priceLabel adjustFontSizeToFitText];
}

- (void)updateCellWithQuoteItem:(SimiQuoteItemModel*)quoteItem{
    self.item = quoteItem;
    [self updatePrices];
    [self updateQuantity];
}

- (void)deleteButtonClicked:(id)sender {
    [self.delegate removeProductFromCartWithItem:self.item];
}

- (void)qtyButtonClicked:(UIButton*)sender{
    qtyArray = [[NSMutableArray alloc] init];
    float qtyIncrement = 1;
    if (self.item.qtyIncrement > 0) {
        qtyIncrement = self.item.qtyIncrement;
    }
    for (int i = self.item.minQty; i <= self.item.maxQty; i+= qtyIncrement) {
        [qtyArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    int qty = [[qtyButton titleForState:UIControlStateNormal] intValue];
    if(qty > [[qtyArray objectAtIndex:qtyArray.count - 1] intValue])
        qty = [[qtyArray objectAtIndex:qtyArray.count - 1] intValue];
    NSInteger selectedIndex = 0;
    for (int i = 0; i < qtyArray.count; i++) {
        NSString *value = [qtyArray objectAtIndex:i];
        if ([value integerValue] == qty) {
            selectedIndex = i;
            break;
        }
    }
    ActionSheetStringPicker* qtyPicker = [[ActionSheetStringPicker alloc]initWithTitle:@"" rows:qtyArray initialSelection:selectedIndex target:self successAction:@selector(didSelectValue:element:) cancelAction:@selector(cancelActionSheet:) origin:sender];
    [qtyPicker showActionSheetPicker];
}

- (void)cancelEditQty:(id)sender{
    [qtyTextField setText:[NSString stringWithFormat:@"%ld",(long)qty]];
    qtyTitleLabel.text = qtyTextField.text;
    [qtyTextField endEditing:YES];
}
- (void)didSelectValue:(NSNumber *)selectedIndex element:(id)element{
    if(![[qtyButton titleForState:UIControlStateNormal] isEqual: [qtyArray objectAtIndex: [selectedIndex intValue]]]){
        [self.delegate editItemQtyWithItem:self.item andQty:[qtyArray objectAtIndex: [selectedIndex intValue]]];
    }
}


- (void)productImageClick{
    [self.delegate selectProductWithItem:self.item];
}

@end
