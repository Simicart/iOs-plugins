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
        self.lblMethodTitle.font = [UIFont fontWithName:SCP_FONT_REGULAR size:FONT_SIZE_MEDIUM];
        self.lblMethodContent.font = [UIFont fontWithName:SCP_FONT_LIGHT size:FONT_SIZE_SMALL];
        [self.btnEditCard setImage:[[UIImage imageNamed:@"scp_ic_address_edit"] imageWithColor:SCP_BUTTON_BACKGROUND_COLOR] forState:UIControlStateNormal];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}
- (void)setTitle:(NSString *)title andContent:(NSString *)content andIsSelected:(BOOL)isSelected titleWidth:(float)titleWidth contentWidth:(float)contentWidth;
{
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
    [self.optionImageView setFrame:CGRectMake(16, self.heightCell + 5, 15, 15)];
    self.optionImageView.image = optionImage;
    
    float lblMethodTitleWidth = titleWidth;
    [self.lblMethodTitle setFrame:CGRectMake(45, self.heightCell, lblMethodTitleWidth, 30)];
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
        [self.lblMethodContent setFrame:CGRectMake(45, self.heightCell, contentWidth, 20)];
        [self.lblMethodContent resizLabelToFit];
        self.heightCell += self.lblMethodContent.labelHeight;
    }
    self.heightCell += 15;
}

- (void)setPriceWithParams:(NSDictionary *)param{
    NSString *price = [param valueForKey:@"s_method_fee"]?[[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[param valueForKey:@"s_method_fee"]]]:@"";
    self.lblMethodTitle.text = [NSString stringWithFormat:@"%@ (%@)",methodTitle,price];
    
    
    if (self.isCreditCard) {
        float titleWidth = [SimiGlobalFunction widthOfText:self.lblMethodTitle.text font:self.lblMethodTitle.font];
        [self.btnEditCard setFrame:CGRectMake(self.lblMethodTitle.frame.origin.x + titleWidth, 0, 100, 40)];
        [self.contentView addSubview:self.btnEditCard];
    }
}

@end
