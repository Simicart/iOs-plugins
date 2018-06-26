//
//  SCPOrderMethodCell.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 6/13/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPOrderMethodCell.h"
#import "SCPGlobalVars.h"

@implementation SCPOrderMethodCell{
    NSString *methodTitle;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.simiContentView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        self.simiContentView.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.simiContentView];
        
        self.lblMethodTitle = [[SimiLabel alloc]initWithFontName:SCP_FONT_REGULAR andFontSize:FONT_SIZE_MEDIUM];
        self.lblMethodTitle.numberOfLines = 0;
        [self.simiContentView addSubview:self.lblMethodTitle];
        
        self.lblMethodContent = [[SimiLabel alloc] initWithFontName:SCP_FONT_LIGHT andFontSize:FONT_SIZE_SMALL];
        [self.simiContentView addSubview:self.lblMethodContent];
        
        self.optionImageView = [UIImageView new];
        [self.simiContentView addSubview:self.optionImageView];
        
        
        self.btnEditCard = [UIButton new];
        [self.btnEditCard setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
       [self.btnEditCard setImage:[[UIImage imageNamed:@"scp_ic_address_edit"] imageWithColor:SCP_BUTTON_BACKGROUND_COLOR] forState:UIControlStateNormal];
        [self.btnEditCard setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 20, 10)];
        [self.btnEditCard addTarget:self action:@selector(editCreditCard:) forControlEvents:UIControlEventTouchUpInside];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setTitle:(NSString *)title andContent:(NSString *)content andIsSelected:(BOOL)isSelected width:(CGFloat)width;
{
    float simiContentPaddingX = SCALEVALUE(15);
    float simiContentWidth = width - 2*simiContentPaddingX;
    float optionImageX = SCALEVALUE(31);
    float optionImageSize = 15;
    float titlePaddingX = 10;
    float titleX = optionImageX + optionImageSize + titlePaddingX;
    float contentX = titleX;
    float lblMethodTitleWidth = simiContentWidth - contentX;
    float contentWidth = simiContentWidth - titleX;
    methodTitle = title;
    self.heightCell = 0;
    
    NSString *optionImageName = @"";
    if (isSelected) {
        optionImageName = @"ic_selected";
    }
    else{
        optionImageName = @"ic_unselected";
    }
    UIImage *optionImage = [UIImage imageNamed:optionImageName];
    [self.optionImageView setFrame:CGRectMake(optionImageX, self.heightCell + 5, optionImageSize, 15)];
    self.optionImageView.image = optionImage;
    
    [self.lblMethodTitle setFrame:CGRectMake(titleX, self.heightCell, lblMethodTitleWidth, 30)];
    self.lblMethodTitle.text = title;
    [self.lblMethodTitle resizLabelToFit];
    self.heightCell += self.lblMethodTitle.labelHeight;
    
    if(content && ![content isEqualToString:@""]){
        if ([SimiGlobalFunction validateHtmlString:content]) {
            NSError *err = nil;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]
                                                          initWithData: [content dataUsingEncoding:NSUnicodeStringEncoding]
                                                          options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                          documentAttributes: nil
                                                          error: &err];
            [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:SCP_FONT_LIGHT size:FONT_SIZE_SMALL] range:NSMakeRange(0, attributeString.length)];
            self.lblMethodContent.attributedText = attributeString;
        }else{
            self.lblMethodContent.text = content;
            [self.lblMethodContent setFont:[UIFont fontWithName:SCP_FONT_LIGHT size:FONT_SIZE_SMALL]];
        }
        [self.lblMethodContent setFrame:CGRectMake(contentX, self.heightCell, contentWidth, 20)];
        [self.lblMethodContent resizLabelToFit];
        self.heightCell += self.lblMethodContent.labelHeight;
    }
    self.heightCell += 15;
    if (self.isCreditCard) {
        float titleWidth = [SimiGlobalFunction widthOfText:self.lblMethodTitle.text font:self.lblMethodTitle.font];
        [self.btnEditCard setFrame:CGRectMake(self.lblMethodTitle.frame.origin.x + titleWidth, 0, 44, 44)];
        if(titleWidth > lblMethodTitleWidth){
            [self.btnEditCard setFrame:CGRectMake(CGRectGetWidth(self.simiContentView.frame) - 44, 0, 44, 44)];
        }
        [self.simiContentView addSubview:self.btnEditCard];
    }
    self.simiContentView.frame = CGRectMake(simiContentPaddingX, 0, simiContentWidth, self.heightCell);
}

- (void)setPriceWithParams:(NSDictionary *)param{
    NSString *price = [param valueForKey:@"s_method_fee"]?[[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[param valueForKey:@"s_method_fee"]]]:@"";
    self.lblMethodTitle.text = [NSString stringWithFormat:@"%@ (%@)",methodTitle,price];
}

@end
