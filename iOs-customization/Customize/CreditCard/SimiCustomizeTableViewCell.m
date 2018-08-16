//
//  SimiCustomizeTableViewCell.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 1/17/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SimiCustomizeTableViewCell.h"

@implementation SimiCustomizeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.heightCell = 5;
        self.paddingY = 0;
        self.paddingX = 15;
        self.contentWidth = SCREEN_WIDTH - 2*self.paddingX;
        if(PADDEVICE){
            self.contentWidth = 2*SCREEN_WIDTH/3 - 2*_paddingX;
        }
    }
    return self;
}
- (SimiLabel *)addLabelWithFrame:(CGRect)frame text:(NSString *)text font:(UIFont *)font textColor:(UIColor *)color{
    SimiLabel *label = [[SimiLabel alloc] initWithFrame:frame andFontName:font.fontName andFontSize:font.pointSize andTextColor:color text:text];
    label.numberOfLines = 0;
    [label sizeToFit];
    self.heightCell += CGRectGetHeight(label.frame) + _paddingY;
    [self.contentView addSubview:label];
    return label;
}
- (SimiLabel *)addLabelWithFrame:(CGRect)frame text:(NSString *)text font:(UIFont *)font{
    return [self addLabelWithFrame:frame text:text font:font textColor:THEME_CONTENT_COLOR];
}
- (SimiLabel *)addLabelWithText:(NSString *)text font:(UIFont *)font{
    return [self addLabelWithText:text font:font textColor:THEME_CONTENT_COLOR];
}
- (SimiLabel *)addLabelWithText:(NSString *)text font:(UIFont *)font textColor:(UIColor *)color{
    return [self addLabelWithFrame:CGRectMake(_paddingX, self.heightCell, _contentWidth, 25) text:text font:font textColor:color];
}
- (SimiLabel *)addLabelWithText:(NSString *)text{
    return  [self addLabelWithText:text font:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
}
- (SimiLabel *)addLabelWithTitle:(NSString *)title value:(NSString *)value{
    SimiLabel *label = [[SimiLabel alloc] initWithFrame:CGRectMake(_paddingX, self.heightCell, _contentWidth, 25)];
    [label showHTMLTextWithTitle:title value:value fontSize:THEME_FONT_SIZE];
    self.heightCell += CGRectGetHeight(label.frame) + _paddingY;
    [self.contentView addSubview:label];
    return label;
}
- (SimiTextField *)addTextFieldWithFrame:(CGRect)frame text:(NSString *)text placeHolder:(NSString *)placeHolder font:(UIFont *)font textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor paddingLeft:(CGFloat)paddingLeft{
    SimiTextField *textField = [[SimiTextField alloc] initWithFrame:frame placeHolder:placeHolder font:font textColor:textColor backgroundColor:backgroundColor borderWidth:borderWidth borderColor:borderColor paddingLeft:paddingLeft];
    textField.text = SCLocalizedString(text);
    [self.contentView addSubview:textField];
    self.heightCell += CGRectGetHeight(frame) + self.paddingY;
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    toolbar.items = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEdittingTextField:)]];
    textField.inputAccessoryView = toolbar;
    return textField;
}
- (SimiTextField *)addTextFieldWithText:(NSString *)text placeHolder:(NSString *)placeHolder font:(UIFont *)font textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor paddingLeft:(CGFloat)paddingLeft{
    return [self addTextFieldWithFrame:CGRectMake(_paddingX, self.heightCell, _contentWidth, 40) text:text placeHolder:placeHolder font:font textColor:textColor backgroundColor:backgroundColor borderWidth:borderWidth borderColor:borderColor paddingLeft:5];
}

- (SimiTextField *)addTextFieldWithPlaceHolder:(NSString *)placeHolder{
    return [self addTextFieldWithPlaceHolder:placeHolder text:@""];
}
- (SimiTextField *)addTextFieldWithPlaceHolder:(NSString *)placeHolder text:(NSString *)text{
     return [self addTextFieldWithText:text placeHolder:placeHolder font:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE] textColor:THEME_CONTENT_COLOR backgroundColor:[UIColor whiteColor] borderWidth:1 borderColor:[UIColor lightGrayColor] paddingLeft:5];
}
- (SimiButton *)addButtonWithFrame:(CGRect)frame title:(NSString *)title{
    SimiButton *button = [[SimiButton alloc] initWithFrame:frame title:title titleFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE] cornerRadius:4 borderWidth:0 borderColor:[UIColor clearColor]];
    [self.contentView addSubview:button];
    self.heightCell += frame.size.height + self.paddingY;
    return button;
}

- (SimiButton *)addButtonWithTitle:(NSString *)title{
    return [self addButtonWithFrame:CGRectMake(_paddingX, self.heightCell, _contentWidth, 40) title:title];
}

- (SimiCheckbox *)addCheckbox:(SimiCheckbox *)checkbox{
    [self.contentView addSubview:checkbox];
    self.heightCell += checkbox.frame.size.height + self.paddingY;
    return checkbox;
}
- (SimiCheckbox *)addCheckboxWithTitle:(NSString *)title{
    return [self addCheckboxWithTitle:title font:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE - 1]];
}

- (SimiCheckbox *)addCheckboxWithTitle:(NSString *)title font:(UIFont *)font{
    SimiCheckbox *checkbox = [self addCheckbox:[[SimiCheckbox alloc] initWithFrame:CGRectMake(_paddingX, self.heightCell, _contentWidth, 25) title:SCLocalizedString(title) checkHeight:20]];
    checkbox.titleLabel.font = font;
    return checkbox;
}

- (SimiTextView *)addTextViewWithFrame:(CGRect)frame text:(NSString *)text{
    SimiTextView *textView = [[SimiTextView alloc] initWithFrame:frame font:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE] borderWidth:1 borderColor:[UIColor lightGrayColor] paddingLeft:5];
    textView.text = SCLocalizedString(text);
    [self.contentView addSubview:textView];
    self.heightCell += CGRectGetHeight(textView.frame) + self.paddingY;
    return textView;
}
- (SimiTextView *)addTextViewWithHeight:(CGFloat)height text:(NSString *)text{
    return [self addTextViewWithFrame:CGRectMake(_paddingX, self.heightCell, _contentWidth, height) text:text];
}
- (SimiTextView *)addTextViewWithText:(NSString *)text{
    return [self addTextViewWithHeight:100 text:text];
}

- (SimiTextField *)addFieldWithLabel:(NSString *)label{
    return [self addTextFieldWithPlaceHolder:label text:@""];
}

- (SimiTextField *)addFieldWithLabel:(NSString *)label text:(NSString *)text{
    [self addLabelWithText:label];
    return [self addTextFieldWithPlaceHolder:label text:text];
}
- (SimiTextField *)addFieldWithLabel:(NSString *)label placeHolder:(NSString *)placeHolder{
    return [self addFieldWithLabel:label text:@"" placeHolder:placeHolder];
}
- (SimiTextField *)addFieldWithLabel:(NSString *)label text:(NSString *)text placeHolder:(NSString *)placeHolder{
    [self addLabelWithText:label font:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE - 1]];
    return [self addTextFieldWithPlaceHolder:placeHolder text:text];
}

- (void)doneEdittingTextField:(UIToolbar *)toolbar{
    [self.delegate doneEditting];
}
@end
