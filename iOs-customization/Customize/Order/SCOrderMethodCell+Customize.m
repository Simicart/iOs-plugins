//
//  SCOrderMethodCell+Customize.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 2/6/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCOrderMethodCell+Customize.h"

@implementation SCOrderMethodCell (Customize)
-(void)setTitle:(NSString *)title andContent:(NSString *)content andIsSelected:(BOOL)isSelected titleWidth:(float)titleWidth contentWidth:(float)contentWidth;
{
    self.heightCell = 5;
    float lblMethodTitleWidth = titleWidth;
    [self.lblMethodTitle setFrame:CGRectMake(45, self.heightCell, lblMethodTitleWidth, 30)];
    self.lblMethodTitle.text = title;
    [self.lblMethodTitle resizLabelToFit];
    
    NSError *err = nil;
    if(!self.isCreditCard){
        if ([SimiGlobalFunction validateHtmlString:content]) {
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]
                                                          initWithData: [content dataUsingEncoding:NSUnicodeStringEncoding]
                                                          options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                          documentAttributes: nil
                                                          error: &err];
            [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:THEME_FONT_NAME size:12] range:NSMakeRange(0, attributeString.length)];
            self.lblMethodContent.attributedText = attributeString;
        }else{
            self.lblMethodContent.text = content;
            [self.lblMethodContent setFont:[UIFont fontWithName:THEME_FONT_NAME size:12]];
        }
    }
    self.heightCell += CGRectGetHeight(self.lblMethodTitle.frame);
    CGRect contentFrame = CGRectMake(45, CGRectGetHeight(self.lblMethodTitle.frame), contentWidth, 20);
    [self.lblMethodContent setFrame:contentFrame];
    [self.lblMethodContent resizLabelToFit];
    contentFrame = self.lblMethodContent.frame;
    self.heightCell += CGRectGetHeight(self.lblMethodContent.frame) + 5;
    NSString *optionImageName = @"";
    if (isSelected) {
        optionImageName = @"ic_selected";
    }
    else{
        optionImageName = @"ic_unselected";
    }
    UIImage *optionImage = [UIImage imageNamed:optionImageName];
    [self.optionImageView setFrame:CGRectMake(16, 12, 15, 15)];
    self.optionImageView.image = optionImage;
    if ([GLOBALVAR isReverseLanguage]) {
        [self.optionImageView setFrame:CGRectMake(SCREEN_WIDTH -SCALEVALUE(30), 12, 15, 15)];
        
        [self.lblMethodContent setTextAlignment:NSTextAlignmentRight];
        contentFrame.origin.x = self.optionImageView.frame.origin.x -SCALEVALUE(10) - contentFrame.size.width;
        [self.lblMethodContent setFrame:contentFrame];
        
        [self.lblMethodTitle setTextAlignment:NSTextAlignmentRight];
        [self.lblMethodTitle setFrame:CGRectMake(self.optionImageView.frame.origin.x -SCALEVALUE(10)  - lblMethodTitleWidth, 5, lblMethodTitleWidth, 30)];
        
        if (PADDEVICE) {
            [self.optionImageView setFrame:CGRectMake(SCALEVALUE(512) -SCALEVALUE(30), 12, 15, 15)];
            
            [self.lblMethodContent setTextAlignment:NSTextAlignmentRight];
            contentFrame.origin.x = self.optionImageView.frame.origin.x -SCALEVALUE(10) - contentFrame.size.width;
            [self.lblMethodContent setFrame:contentFrame];
            
            [self.lblMethodTitle setTextAlignment:NSTextAlignmentRight];
            [self.lblMethodTitle setFrame:CGRectMake(self.optionImageView.frame.origin.x-SCALEVALUE(10)  - lblMethodTitleWidth, 5, lblMethodTitleWidth, 30)];
        }
    }
}

@end
