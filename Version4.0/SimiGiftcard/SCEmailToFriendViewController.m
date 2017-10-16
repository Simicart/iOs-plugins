//
//  SCEmailToFriendViewController.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/16/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCEmailToFriendViewController.h"
#import "SimiTextView.h"
#import "SimiTextField.h"
#import "SimiGiftCardCreditModel.h"

@interface SCEmailToFriendViewController ()<UITextFieldDelegate, UIScrollViewDelegate>{
    UIScrollView *contentScrollView;
    SimiTextField *recipientNameTextField;
    SimiTextField *recipientEmailTextField;
    UITextView *customMessageTextView;
    SimiGiftCardCreditModel *giftCardCreditModel;
}

@end

@implementation SCEmailToFriendViewController
@synthesize giftCodeModel;

- (void)viewDidLoadBefore{
    self.navigationItem.title = SCLocalizedString(@"EMAIL GIFT CARD TO FRIEND");
}

- (void)viewWillAppearBefore:(BOOL)animated{
    
}

- (void)viewDidAppearBefore:(BOOL)animated{
    float labelHeight = 25;
    float height = 5;
    float padding = 10;
    float titleWidth = 120;
    float cellWidth = CGRectGetWidth(self.view.bounds);
    float valueWidth = cellWidth - titleWidth - padding*3;
    float textFieldHeight = 40;
    float textFieldWidth = cellWidth - padding*2;
    NSString *currencySymbol = @"";
    if (contentScrollView == nil) {
        contentScrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
        contentScrollView.delegate = self;
        [self.view addSubview:contentScrollView];
        if ([giftCodeModel valueForKey:@"currency_symbol"] && ![[giftCodeModel valueForKey:@"currency_symbol"] isKindOfClass:[NSNull class]]) {
            currencySymbol = [giftCodeModel valueForKey:@"currency_symbol"];
        }
        
        SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, cellWidth - padding*2, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:20 andTextColor:THEME_CONTENT_COLOR text:@"Gift Card Code Information"];
        [contentScrollView addSubview:titleLabel];
        height += 30;
        
        SimiLabel *giftCardCodeLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Gift Card Code"];
        [contentScrollView addSubview:giftCardCodeLabel];
        
        SimiTextView *giftCardCodeTextView = [[SimiTextView alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, 170, 40) font:[UIFont systemFontOfSize:15 weight:UIFontWeightSemibold] borderWidth:1 borderColor:[UIColor lightGrayColor] paddingLeft:10];
        giftCardCodeTextView.layer.cornerRadius = 6;
        giftCardCodeTextView.editable = NO;
        giftCardCodeTextView.text = [giftCodeModel valueForKey:@"gift_code"];
        [contentScrollView addSubview:giftCardCodeTextView];
        height += 40;
        
        SimiLabel *balanceLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Balance"];
        [contentScrollView addSubview:balanceLabel];
        
        SimiLabel *balanceValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@""];
        [contentScrollView addSubview:balanceValueLabel];
        height += labelHeight;
        
        SimiLabel *statusLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Status"];
        [contentScrollView addSubview:statusLabel];
        
        SimiLabel *statusValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@""];
        [contentScrollView addSubview:statusValueLabel];
        height += labelHeight;
        
        SimiLabel *addedLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Added Date"];
        [contentScrollView addSubview:addedLabel];
        
        NSString *addedValue = [giftCodeModel valueForKey:@"added_date"];
        SimiLabel *addedValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:addedValue];
        [contentScrollView addSubview:addedValueLabel];
        height += labelHeight;
        
        SimiLabel *expiredLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Expired Date"];
        [contentScrollView addSubview:expiredLabel];
        
        NSString *expiredValue = [giftCodeModel valueForKey:@"expired_at"];
        SimiLabel *expiredValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:expiredValue];
        [contentScrollView addSubview:expiredValueLabel];
        height += labelHeight;
        
        NSString *statusValue = [giftCodeModel valueForKey:@"status"];
        switch ([statusValue integerValue]) {
            case 1:
                statusValue = @"Pending";
                break;
            case 2:
                statusValue = @"Active";
                break;
            case 3:
                statusValue = @"Disabled";
                break;
            case 4:
                statusValue = @"Used";
                break;
            case 5:
                statusValue = @"Expried";
                break;
            case 6:
                statusValue = @"Deleted";
                break;
            default:
                break;
        }
        [statusValueLabel setText:statusValue];
        NSString *balanceValue = [[SimiFormatter sharedInstance]priceWithPrice:[giftCodeModel valueForKey:@"balance"] andCurrency:currencySymbol];
        [balanceValueLabel setText:balanceValue];
        
        if ([giftCodeModel valueForKey:@"comment"]) {
            SimiLabel *commentLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Comment"];
            [contentScrollView addSubview:commentLabel];
            
            NSString *commentValue = [giftCodeModel valueForKey:@"comment"];
            SimiLabel *commentValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:commentValue];
            [commentValueLabel resizLabelToFit];
            [contentScrollView addSubview:commentValueLabel];
            height += CGRectGetHeight(commentValueLabel.frame)+5;
        }
        
        SimiLabel *recipientNameLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, textFieldWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:16 andTextColor:THEME_CONTENT_COLOR text:[NSString stringWithFormat:@"%@*",SCLocalizedString(@"Recipient name")]];
        [contentScrollView addSubview:recipientNameLabel];
        height += labelHeight;
        
        recipientNameTextField = [[SimiTextField alloc]initWithFrame:CGRectMake(padding, height, textFieldWidth, textFieldHeight) placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME size:16] textColor:THEME_CONTENT_COLOR borderWidth:1 borderColor:[UIColor lightGrayColor] cornerRadius:6 leftView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, textFieldHeight)] rightView:nil];
        recipientNameTextField.text = [giftCodeModel valueForKey:@"recipient_name"];
        recipientNameTextField.delegate = self;
        [contentScrollView addSubview:recipientNameTextField];
        height += textFieldHeight;
        
        SimiLabel *recipientEmailLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, textFieldWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:16 andTextColor:THEME_CONTENT_COLOR text:[NSString stringWithFormat:@"%@*",SCLocalizedString(@"Recipient email address")]];
        [contentScrollView addSubview:recipientEmailLabel];
        height += labelHeight;
        
        recipientEmailTextField = [[SimiTextField alloc]initWithFrame:CGRectMake(padding, height, textFieldWidth, textFieldHeight) placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME size:16] textColor:THEME_CONTENT_COLOR borderWidth:1 borderColor:[UIColor lightGrayColor] cornerRadius:6 leftView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, textFieldHeight)] rightView:nil];
        recipientEmailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        recipientEmailTextField.text = [giftCodeModel valueForKey:@"recipient_email"];
        recipientEmailTextField.delegate = self;
        [contentScrollView addSubview:recipientEmailTextField];
        height += textFieldHeight;
        
        SimiLabel *customMessageLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, textFieldWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:16 andTextColor:THEME_CONTENT_COLOR text:@"Custom message"];
        [contentScrollView addSubview:customMessageLabel];
        height += labelHeight;
        
        customMessageTextView = [[UITextView alloc]initWithFrame:CGRectMake(padding, height, textFieldWidth, 100)];
        customMessageTextView.layer.borderWidth = 1;
        customMessageTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        customMessageTextView.layer.cornerRadius = 6;
        customMessageTextView.text = [giftCodeModel valueForKey:@"message"];
        [customMessageTextView setFont:[UIFont fontWithName:THEME_FONT_NAME size:13]];
        [contentScrollView addSubview:customMessageTextView];
        height += 100;
        [contentScrollView setContentSize:CGSizeMake(cellWidth, height)];
        [contentScrollView setContentInset:UIEdgeInsetsMake(0, 0, 60, 0)];
        
        emailToFriendButton = [[SimiButton alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 44, CGRectGetWidth(self.view.frame), 44) title:@"SEND TO FRIEND" titleFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:16] cornerRadius:0 borderWidth:0 borderColor:[UIColor clearColor] shadowOffset:CGSizeMake(1, 1) shadowRadius:4 shadowOpacity:0.7f];
        [emailToFriendButton addTarget:self action:@selector(emailToFriend:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:emailToFriendButton];
    }
}

- (void)emailToFriend:(UIButton*)sender{
    if ([recipientNameTextField.text isEqualToString:@""] || [recipientEmailTextField.text isEqualToString:@""]) {
        [self showToastMessage:@"Please enter all required fields" duration:1.5];
        return;
    }
    if (![SimiGlobalFunction validateEmail:recipientEmailTextField.text]) {
        [self showToastMessage:@"Email is not valid" duration:1.5];
        return;
    }
    giftCardCreditModel = [SimiGiftCardCreditModel new];
    NSDictionary *params = @{@"voucher_id":[giftCodeModel valueForKey:@"giftvoucher_id"],@"recipient_name":recipientNameTextField.text,@"recipient_email":recipientEmailTextField.text,@"message":customMessageTextView.text};
    [giftCardCreditModel sendEmailToFriendWithParams:params];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didSendEmailToFriend:) name:DidSendGiftCodeToFriend object:giftCardCreditModel];
    [self startLoadingData];
}

- (void)didSendEmailToFriend:(NSNotification*)noti{
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    if (responder.status == SUCCESS) {
        [self showToastMessage:[giftCardCreditModel valueForKey:@"success"] duration:1.5];
    }else
        [self showToastMessage:responder.message duration:1.5];
        
}

#pragma mark Text Field Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (customMessageTextView.isFirstResponder && PHONEDEVICE) {
        [customMessageTextView resignFirstResponder];
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)noti{
    float keyboardHeight = [[[noti userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    contentScrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
}

- (void)keyboardWillHide:(NSNotification *)noti{
    contentScrollView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
}

@end
