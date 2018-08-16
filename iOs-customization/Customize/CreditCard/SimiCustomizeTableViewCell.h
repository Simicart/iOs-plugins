//
//  SimiCustomizeTableViewCell.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 1/17/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiTextField.h>
#import <SimiCartBundle/SimiCheckbox.h>
#import <SimiCartBundle/SimiTextView.h>

@protocol SimiCustomizeTableViewCellDelegate
- (void)doneEditting;
@end

@interface SimiCustomizeTableViewCell : SimiTableViewCell

@property (nonatomic) float paddingX, paddingY, contentWidth;
@property (weak, nonatomic) id<SimiCustomizeTableViewCellDelegate>delegate;

- (SimiLabel *)addLabelWithFrame:(CGRect)frame text:(NSString *)text font:(UIFont *)font textColor:(UIColor *)color;
- (SimiLabel *)addLabelWithFrame:(CGRect)frame text:(NSString *)text font:(UIFont *)font;
- (SimiLabel *)addLabelWithText:(NSString *)text font:(UIFont *)font;
- (SimiLabel *)addLabelWithText:(NSString *)text font:(UIFont *)font textColor:(UIColor *)color;
- (SimiLabel *)addLabelWithText:(NSString *)text;
- (SimiLabel *)addLabelWithTitle:(NSString *)title value:(NSString *)value;

- (SimiTextField *)addTextFieldWithFrame:(CGRect)frame text:(NSString *)text placeHolder:(NSString *)placeHolder font:(UIFont *)font textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor paddingLeft:(CGFloat)paddingLeft;
- (SimiTextField *)addTextFieldWithText:(NSString *)text placeHolder:(NSString *)placeHolder font:(UIFont *)font textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor paddingLeft:(CGFloat)paddingLeft;
- (SimiTextField *)addTextFieldWithPlaceHolder:(NSString *)placeHolder;
- (SimiTextField *)addTextFieldWithPlaceHolder:(NSString *)placeHolder text:(NSString *)text;
- (SimiButton *)addButtonWithFrame:(CGRect)frame title:(NSString *)title;
- (SimiButton *)addButtonWithTitle:(NSString *)title;

- (SimiCheckbox *)addCheckbox:(SimiCheckbox *)checkbox;
- (SimiCheckbox *)addCheckboxWithTitle:(NSString *)title;
- (SimiCheckbox *)addCheckboxWithTitle:(NSString *)title font:(UIFont *)font;
- (SimiTextView *)addTextViewWithFrame:(CGRect)frame text:(NSString *)text;
- (SimiTextView *)addTextViewWithHeight:(CGFloat)height text:(NSString *)text;
- (SimiTextView *)addTextViewWithText:(NSString *)text;

- (SimiTextField *)addFieldWithLabel:(NSString *)label;
- (SimiTextField *)addFieldWithLabel:(NSString *)label text:(NSString *)text;
- (SimiTextField *)addFieldWithLabel:(NSString *)label placeHolder:(NSString *)placeHolder;
- (SimiTextField *)addFieldWithLabel:(NSString *)label text:(NSString *)text placeHolder:(NSString *)placeHolder;
@end
