//
//  SCCartTotalCellPad_Theme01.m
//  SimiCart
//
//  Created by Tân Hoàng on 8/8/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "SCCartTotalCellPad_Theme01.h"
#import "SimiGlobalVar+Theme01.h"
#import <SimiCartBundle/SimiFormatter.h>

@implementation SCCartTotalCellPad_Theme01

@synthesize heightCell, order, totalV2, subTotal, subTotalLabel, subTotalExcl, subTotalExclLabel, subTotalIncl, subTotalInclLabel, tax, taxLabel, discount, discountLabel, total, totalLabel, totalExcl, totalIncl, totalInclLabel, totalExclLabel, shipping, shippingLabel, shippingExcl, shippingExclLabel, shippingIncl, shippingInclLabel;
@synthesize subTotalValueLabel, subTotalExclValueLabel, subTotalInclValueLabel, totalValueLabel, totalExclValueLabel, totalInclValueLabel, discountValueLabel, taxValueLabel, shippingValueLabel, shippingExclValueLabel, shippingInclValueLabel, cellWith;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setOrder:(SimiOrderModel *)order_
{
    order = [order_ copy];
    
    if(![order valueForKey:@"total_v2"]){
        NSArray *fee= [order valueForKey:@"fee"];
        totalV2 = [fee valueForKey:@"v2"];
    }else{
        totalV2 = [order valueForKey:@"total_v2"];
    }
    self.subTotal = [totalV2 valueForKey:@"subtotal"];
    self.subTotalExcl = [totalV2 valueForKey:@"subtotal_excl_tax"];
    self.subTotalIncl = [totalV2 valueForKey:@"subtotal_incl_tax"];
    self.shipping = [totalV2 valueForKey:@"shipping_hand"];
    self.shippingExcl = [totalV2 valueForKey:@"shipping_hand_excl_tax"];
    self.shippingIncl = [totalV2 valueForKey:@"shipping_hand_incl_tax"];
    self.total = [totalV2 valueForKey:@"grand_total"];
    self.totalExcl = [totalV2 valueForKey:@"grand_total_excl_tax"];
    self.totalIncl = [totalV2 valueForKey:@"grand_total_incl_tax"];
    self.tax = [totalV2 valueForKey:@"tax"];
    self.discount = [totalV2 valueForKey:@"discount"];
    [self setInterfaceCell];
}

- (void)setData:(NSMutableArray*)cartPrices
{
    self.subTotal = [cartPrices valueForKey:@"subtotal"];
    self.subTotalExcl = [cartPrices valueForKey:@"subtotal_excl_tax"];
    self.subTotalIncl = [cartPrices valueForKey:@"subtotal_incl_tax"];
    self.shipping = [cartPrices valueForKey:@"shipping_hand"];
    self.shippingExcl = [cartPrices valueForKey:@"shipping_hand_excl_tax"];
    self.shippingIncl = [cartPrices valueForKey:@"shipping_hand_incl_tax"];
    self.total = [cartPrices valueForKey:@"grand_total"];
    self.totalExcl = [cartPrices valueForKey:@"grand_total_excl_tax"];
    self.totalIncl = [cartPrices valueForKey:@"grand_total_incl_tax"];
    self.tax = [cartPrices valueForKey:@"tax"];
    self.discount = [cartPrices valueForKey:@"discount"];
    [self setInterfaceCell];
}

#pragma mark Setters
- (void)setSubTotal:(NSString *)subTotal_
{
    subTotal = [subTotal_ copy];
    subTotalLabel = [[UILabel alloc]init];
    [subTotalLabel setTextAlignment:NSTextAlignmentRight];
    subTotalValueLabel = [[UILabel alloc]init];
    subTotalLabel.text = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[NSNumber numberWithFloat:[subTotal floatValue]]];
    subTotalLabel.text = [NSString stringWithFormat:@"%@:",  SCLocalizedString(@"Subtotal")];
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        subTotalLabel.text = [NSString stringWithFormat:@":%@",  SCLocalizedString(@"Subtotal")];
    }
    subTotalValueLabel.text = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[NSNumber numberWithFloat:[subTotal floatValue]]];
    subTotalLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    subTotalLabel.textColor = [UIColor blackColor];
    subTotalValueLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    subTotalValueLabel.textColor = THEME01_PRICE_COLOR;
}

- (void)setSubTotalIncl:(NSString *)subTotalIncl_
{
    subTotalIncl = [subTotalIncl_ copy];
    subTotalInclLabel = [[UILabel alloc]init];
    subTotalInclValueLabel = [[UILabel alloc]init];
    subTotalInclLabel.text = [NSString stringWithFormat:@"%@:", [[SCLocalizedString(@"Subtotal") stringByAppendingString:@" "]stringByAppendingString:SCLocalizedString(@"Incl. Tax")]];
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        subTotalInclLabel.text = [NSString stringWithFormat:@":%@", [[SCLocalizedString(@"Subtotal") stringByAppendingString:@" "]stringByAppendingString:SCLocalizedString(@"Incl. Tax")]];
    }
    subTotalInclValueLabel.text = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[NSNumber numberWithFloat:[subTotalIncl floatValue]]];
    subTotalInclLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    subTotalInclLabel.textColor = [UIColor blackColor];
    subTotalInclValueLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    subTotalInclValueLabel.textColor = THEME01_PRICE_COLOR;
}

- (void)setSubTotalExcl:(NSString *)subTotalExcl_
{
    subTotalExcl = [subTotalExcl_ copy];
    subTotalExclLabel = [[UILabel alloc]init];
    subTotalExclValueLabel = [[UILabel alloc]init];
    subTotalExclLabel.text = [NSString stringWithFormat:@"%@:", [[SCLocalizedString(@"Subtotal") stringByAppendingString:@" "]stringByAppendingString:SCLocalizedString(@"Excl. Tax")]];
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        subTotalExclLabel.text = [NSString stringWithFormat:@":%@", [[SCLocalizedString(@"Subtotal") stringByAppendingString:@" "]stringByAppendingString:SCLocalizedString(@"Excl. Tax")]];
    }
    subTotalExclValueLabel.text = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[NSNumber numberWithFloat:[subTotalExcl floatValue]]];
    subTotalExclLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    subTotalExclLabel.textColor = [UIColor blackColor];
    subTotalExclValueLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    subTotalExclValueLabel.textColor = THEME01_PRICE_COLOR;
}


- (void)setShipping:(NSString *)shipping_
{
    shipping = [shipping_ copy];
    shippingLabel = [[UILabel alloc]init];
    shippingValueLabel = [[UILabel alloc]init];
    shippingLabel.text = [NSString stringWithFormat:@"%@:", SCLocalizedString(@"Shipping & Handling")];
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        shippingLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Shipping & Handling")];
    }
    shippingValueLabel.text = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[NSNumber numberWithFloat:[shipping floatValue]]];
    shippingLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    shippingLabel.textColor = [UIColor blackColor];
    shippingValueLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    shippingValueLabel.textColor = THEME01_PRICE_COLOR;
}

- (void)setShippingIncl:(NSString *)shippingIncl_
{
    shippingIncl = [shippingIncl_ copy];
    shippingInclLabel = [[UILabel alloc]init];
    shippingInclValueLabel = [[UILabel alloc]init];
    shippingInclLabel.text = [NSString stringWithFormat:@"%@:", [[SCLocalizedString(@"Shipping") stringByAppendingString:@" "]stringByAppendingString:SCLocalizedString(@"Incl. Tax")]];
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        shippingInclLabel.text = [NSString stringWithFormat:@":%@", [[SCLocalizedString(@"Shipping") stringByAppendingString:@" "]stringByAppendingString:SCLocalizedString(@"Incl. Tax")]];
    }
    shippingInclValueLabel.text = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[NSNumber numberWithFloat:[shippingIncl floatValue]]];
    shippingInclLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    shippingInclLabel.textColor = [UIColor blackColor];
    shippingInclValueLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    shippingInclValueLabel.textColor = THEME01_PRICE_COLOR;
}

- (void)setShippingExcl:(NSString *)shippingExcl_
{
    shippingExcl = [shippingExcl_ copy];
    shippingExclLabel = [[UILabel alloc]init];
    shippingExclValueLabel = [[UILabel alloc]init];
    shippingExclLabel.text = [NSString stringWithFormat:@"%@:", [[SCLocalizedString(@"Shipping") stringByAppendingString:@" "]stringByAppendingString:SCLocalizedString(@"Excl. Tax")]];
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        shippingExclLabel.text = [NSString stringWithFormat:@":%@", [[SCLocalizedString(@"Shipping") stringByAppendingString:@" "]stringByAppendingString:SCLocalizedString(@"Excl. Tax")]];
    }
    shippingExclValueLabel.text = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[NSNumber numberWithFloat:[shippingExcl floatValue]]];
    shippingExclLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    shippingExclLabel.textColor = [UIColor blackColor];
    shippingExclValueLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    shippingExclValueLabel.textColor = THEME01_PRICE_COLOR;
}

- (void)setTotal:(NSString *)total_
{
    total = [total_ copy];
    totalLabel = [[UILabel alloc]init];
    totalValueLabel = [[UILabel alloc]init];
    totalLabel.text = [NSString stringWithFormat:@"%@:", SCLocalizedString(@"Grand Total")];
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        totalLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Grand Total")];
    }
    totalValueLabel.text = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[NSNumber numberWithFloat:[total floatValue]]];
    totalLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    totalLabel.textColor = [UIColor blackColor];
    totalValueLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    totalValueLabel.textColor = THEME01_PRICE_COLOR;
}

- (void)setTotalIncl:(NSString *)totalIncl_
{
    totalIncl = [totalIncl_ copy];
    totalInclLabel = [[UILabel alloc]init];
    totalInclValueLabel = [[UILabel alloc]init];
    totalInclLabel.text = [NSString stringWithFormat:@"%@:", [[SCLocalizedString(@"Grand Total") stringByAppendingString:@" "]stringByAppendingString:SCLocalizedString(@"Incl. Tax")]];
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        totalInclLabel.text = [NSString stringWithFormat:@":%@", [[SCLocalizedString(@"Grand Total") stringByAppendingString:@" "]stringByAppendingString:SCLocalizedString(@"Incl. Tax")]];
    }
    totalInclValueLabel.text = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[NSNumber numberWithFloat:[totalIncl floatValue]]];
    totalInclLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    totalInclLabel.textColor = [UIColor blackColor];
    totalInclValueLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    totalInclValueLabel.textColor = THEME01_PRICE_COLOR;
}

- (void)setTotalExcl:(NSString *)totalExcl_
{
    totalExcl = [totalExcl_ copy];
    totalExclLabel = [[UILabel alloc]init];
    totalExclValueLabel = [[UILabel alloc]init];
    totalExclLabel.text = [NSString stringWithFormat:@"%@:", [[SCLocalizedString(@"Grand Total") stringByAppendingString:@" "]stringByAppendingString:SCLocalizedString(@"Excl. Tax")]];
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        totalExclLabel.text = [NSString stringWithFormat:@":%@", [[SCLocalizedString(@"Grand Total") stringByAppendingString:@" "]stringByAppendingString:SCLocalizedString(@"Excl. Tax")]];
    }
    totalExclValueLabel.text = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[NSNumber numberWithFloat:[totalExcl floatValue]]];
    totalExclLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    totalExclLabel.textColor = [UIColor blackColor];
    totalExclValueLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    totalExclValueLabel.textColor = THEME01_PRICE_COLOR;
}

- (void)setTax:(NSString *)tax_
{
    tax = [tax_ copy];
    taxLabel = [[UILabel alloc]init];
    taxValueLabel = [[UILabel alloc]init];
    taxLabel.text = [NSString stringWithFormat:@"%@:", SCLocalizedString(@"Tax")];
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        taxLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Tax")];
    }
    taxValueLabel.text = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[NSNumber numberWithFloat:[tax floatValue]]];
    taxLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    taxLabel.textColor = [UIColor blackColor];
    taxValueLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    taxValueLabel.textColor = THEME01_PRICE_COLOR;
}

- (void)setDiscount:(NSString *)discount_
{
    discount = [discount_ copy];
    discountLabel = [[UILabel alloc]init];
    discountValueLabel = [[UILabel alloc]init];
    discountLabel.text = [NSString stringWithFormat:@"%@:", SCLocalizedString(@"Discount")];
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        discountLabel.text = [NSString stringWithFormat:@":%@", SCLocalizedString(@"Discount")];
    }
    discountValueLabel.text = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[NSNumber numberWithFloat:[discount floatValue]]];
    discountLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    discountLabel.textColor = [UIColor blackColor];
    discountValueLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    discountValueLabel.textColor = THEME01_PRICE_COLOR;
    //    [self setInterfaceCell];
    //        [self reArrangeLabels];
}

- (void)setInterfaceCell
{
    heightCell = 20;
    int origionTitleX = cellWith - 330;
    int origionValueX = cellWith - 190;
    int widthTitle = 195;
    int widthValue = 165;
    int heightLabel = 22;
    int heightLabelWithDistance = 25;
    //  Liam Update RTL
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        origionTitleX = cellWith - 210;
        origionValueX = cellWith - 350;
        widthValue = 130;
    }
    //  End RTL
    if(subTotal){
        [subTotalLabel setFrame:CGRectMake(origionTitleX, heightCell, widthTitle, heightLabel)];
        [subTotalValueLabel setFrame:CGRectMake(origionValueX, heightCell, widthValue, heightLabel)];
        //subTotalLabel.textAlignment = NSTextAlignmentRight;
        subTotalValueLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:subTotalLabel];
        [self addSubview:subTotalValueLabel];
        heightCell += heightLabelWithDistance;
    }
    if(subTotalExcl){
        [subTotalExclLabel setFrame:CGRectMake(origionTitleX, heightCell, widthTitle, heightLabel)];
        [subTotalExclValueLabel setFrame:CGRectMake(origionValueX, heightCell, widthValue, heightLabel)];
        subTotalExclLabel.textAlignment = NSTextAlignmentRight;
        subTotalExclValueLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:subTotalExclLabel];
        [self addSubview:subTotalExclValueLabel];
        heightCell += heightLabelWithDistance;
    }
    if(subTotalIncl){
        [subTotalInclLabel setFrame:CGRectMake(origionTitleX, heightCell, widthTitle, heightLabel)];
        [subTotalInclValueLabel setFrame:CGRectMake(origionValueX, heightCell, widthValue, heightLabel)];
        subTotalInclLabel.textAlignment = NSTextAlignmentRight;
        subTotalInclValueLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:subTotalInclLabel];
        [self addSubview:subTotalInclValueLabel];
        heightCell += heightLabelWithDistance;
    }
    if(discount){
        [discountLabel setFrame:CGRectMake(origionTitleX, heightCell, widthTitle, heightLabel)];
        [discountValueLabel setFrame:CGRectMake(origionValueX, heightCell, widthValue, heightLabel)];
        discountLabel.textAlignment = NSTextAlignmentRight;
        discountValueLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:discountLabel];
        [self addSubview:discountValueLabel];
        heightCell += heightLabelWithDistance;
    }
    if(shipping){
        [shippingLabel setFrame:CGRectMake(origionTitleX, heightCell, widthTitle, heightLabel)];
        [shippingValueLabel setFrame:CGRectMake(origionValueX, heightCell, widthValue, heightLabel)];
        shippingLabel.textAlignment = NSTextAlignmentRight;
        shippingValueLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:shippingLabel];
        [self addSubview:shippingValueLabel];
        heightCell += heightLabelWithDistance;
    }
    if(shippingExcl){
        [shippingExclLabel setFrame:CGRectMake(origionTitleX, heightCell, widthTitle, heightLabel)];
        [shippingExclValueLabel setFrame:CGRectMake(origionValueX, heightCell, widthValue, heightLabel)];
        shippingExclLabel.textAlignment = NSTextAlignmentRight;
        shippingExclValueLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:shippingExclLabel];
        [self addSubview:shippingExclValueLabel];
        heightCell += heightLabelWithDistance;
    }
    if(shippingIncl){
        [shippingInclLabel setFrame:CGRectMake(origionTitleX, heightCell, widthTitle, heightLabel)];
        [shippingInclValueLabel setFrame:CGRectMake(origionValueX, heightCell, widthValue, heightLabel)];
        shippingInclLabel.textAlignment = NSTextAlignmentRight;
        shippingInclValueLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:shippingInclLabel];
        [self addSubview:shippingInclValueLabel];
        heightCell += heightLabelWithDistance;
    }
    if(totalExcl){
        [totalExclLabel setFrame:CGRectMake(origionTitleX, heightCell, widthTitle, heightLabel)];
        [totalExclValueLabel setFrame:CGRectMake(origionValueX, heightCell, widthValue, heightLabel)];
        totalExclLabel.textAlignment = NSTextAlignmentRight;
        totalExclValueLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:totalExclLabel];
        [self addSubview:totalExclValueLabel];
        heightCell += heightLabelWithDistance;
    }
    if(tax){
        [taxLabel setFrame:CGRectMake(origionTitleX, heightCell, widthTitle, heightLabel)];
        [taxValueLabel setFrame:CGRectMake(origionValueX, heightCell, widthValue, heightLabel)];
        taxLabel.textAlignment = NSTextAlignmentRight;
        taxValueLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:taxLabel];
        [self addSubview:taxValueLabel];
        heightCell += heightLabelWithDistance;
    }
    if(total){
        [totalLabel setFrame:CGRectMake(origionTitleX, heightCell, widthTitle, heightLabel)];
        [totalValueLabel setFrame:CGRectMake(origionValueX, heightCell, widthValue, heightLabel)];
        totalLabel.textAlignment = NSTextAlignmentRight;
        totalValueLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:totalLabel];
        [self addSubview:totalValueLabel];
        heightCell += heightLabelWithDistance;
    }
    if(totalIncl){
        [totalInclLabel setFrame:CGRectMake(origionTitleX, heightCell, widthTitle, heightLabel)];
        [totalInclValueLabel setFrame:CGRectMake(origionValueX, heightCell, widthValue, heightLabel)];
        totalInclLabel.textAlignment = NSTextAlignmentRight;
        totalInclValueLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:totalInclLabel];
        [self addSubview:totalInclValueLabel];
        heightCell += heightLabelWithDistance;
    }
}


- (void) setCellWith:(int)cellWith_
{
    cellWith = cellWith_;
}

- (int) getCellWith
{
    return cellWith;
}

@end
