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

@interface SCEmailToFriendViewController (){
    SimiTextField *recipientNameTextField;
    SimiTextField *recipientEmailTextField;
    UITextView *customMessageTextView;
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
    float cellWidth = SCREEN_WIDTH;
    float valueWidth = cellWidth - titleWidth - padding*3;
    float textFieldHeight = 40;
    float textFieldWidth = cellWidth - padding*2;
    NSString *currencySymbol = @"";
    if ([giftCodeModel valueForKey:@"currency_symbol"] && ![[giftCodeModel valueForKey:@"currency_symbol"] isKindOfClass:[NSNull class]]) {
        currencySymbol = [giftCodeModel valueForKey:@"currency_symbol"];
    }
    
    SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, cellWidth - padding*2, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:20 andTextColor:THEME_CONTENT_COLOR text:@"Gift Card Code Information"];
    [self.view addSubview:titleLabel];
    height += 30;
    
    SimiLabel *giftCardCodeLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Gift Card Code"];
    [self.view addSubview:giftCardCodeLabel];
    
    SimiTextView *giftCardCodeTextView = [[SimiTextView alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, 170, 40) font:[UIFont systemFontOfSize:15 weight:UIFontWeightSemibold] borderWidth:1 borderColor:[UIColor lightGrayColor] paddingLeft:10];
    giftCardCodeTextView.layer.cornerRadius = 6;
    giftCardCodeTextView.editable = NO;
    giftCardCodeTextView.text = [giftCodeModel valueForKey:@"gift_code"];
    [self.view addSubview:giftCardCodeTextView];
    height += 40;
    
    SimiLabel *balanceLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Balance"];
    [self.view addSubview:balanceLabel];
    
    SimiLabel *balanceValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@""];
    [self.view addSubview:balanceValueLabel];
    height += labelHeight;
    
    SimiLabel *statusLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Status"];
    [self.view addSubview:statusLabel];
    
    SimiLabel *statusValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@""];
    [self.view addSubview:statusValueLabel];
    height += labelHeight;
    
    SimiLabel *addedLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Added Date"];
    [self.view addSubview:addedLabel];
    
    NSString *addedValue = [giftCodeModel valueForKey:@"added_date"];
    SimiLabel *addedValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:addedValue];
    [self.view addSubview:addedValueLabel];
    height += labelHeight;
    
    SimiLabel *expiredLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, titleWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:@"Expired Date"];
    [self.view addSubview:expiredLabel];
    
    NSString *expiredValue = [giftCodeModel valueForKey:@"expired_at"];
    SimiLabel *expiredValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:expiredValue];
    [self.view addSubview:expiredValueLabel];
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
        [self.view addSubview:commentLabel];
        
        NSString *commentValue = [giftCodeModel valueForKey:@"comment"];
        SimiLabel *commentValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(titleWidth+padding*2, height, valueWidth, labelHeight) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:THEME_CONTENT_COLOR text:commentValue];
        [commentValueLabel resizLabelToFit];
        [self.view addSubview:commentValueLabel];
        height += CGRectGetHeight(commentValueLabel.frame)+5;
    }
    
    SimiLabel *recipientNameLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, textFieldWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:16 andTextColor:THEME_CONTENT_COLOR text:[NSString stringWithFormat:@"%@*",SCLocalizedString(@"Recipient name")]];
    [self.view addSubview:recipientNameLabel];
    height += labelHeight;
    
    recipientNameTextField = [[SimiTextField alloc]initWithFrame:CGRectMake(padding, height, textFieldWidth, textFieldHeight) placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME size:16] textColor:THEME_CONTENT_COLOR borderWidth:1 borderColor:[UIColor lightGrayColor] cornerRadius:6 leftView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, textFieldHeight)] rightView:nil];
    recipientNameTextField.delegate = self;
    [self.view addSubview:recipientNameTextField];
    height += textFieldHeight;
    
    SimiLabel *recipientEmailLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, textFieldWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:16 andTextColor:THEME_CONTENT_COLOR text:[NSString stringWithFormat:@"%@*",SCLocalizedString(@"Recipient email address")]];
    [self.view addSubview:recipientEmailLabel];
    height += labelHeight;
    
    recipientEmailTextField = [[SimiTextField alloc]initWithFrame:CGRectMake(padding, height, textFieldWidth, textFieldHeight) placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME size:16] textColor:THEME_CONTENT_COLOR borderWidth:1 borderColor:[UIColor lightGrayColor] cornerRadius:6 leftView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, textFieldHeight)] rightView:nil];
    recipientEmailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    recipientEmailTextField.delegate = self;
    [self.view addSubview:recipientEmailTextField];
    height += textFieldHeight;
    
    SimiLabel *customMessageLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, textFieldWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:16 andTextColor:THEME_CONTENT_COLOR text:@"Custom message"];
    [self.view addSubview:customMessageLabel];
    height += labelHeight;
    
    customMessageTextView = [[UITextView alloc]initWithFrame:CGRectMake(padding, height, textFieldWidth, 100)];
    customMessageTextView.layer.borderWidth = 1;
    customMessageTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    customMessageTextView.layer.cornerRadius = 6;
    [self.view addSubview:customMessageTextView];
    height += 100;
    
    emailToFriendButton = [[SimiButton alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 44, CGRectGetWidth(self.view.frame), 44) title:@"SEND TO FRIEND" titleFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:16] cornerRadius:0 borderWidth:0 borderColor:[UIColor clearColor] shadowOffset:CGSizeMake(1, 1) shadowRadius:4 shadowOpacity:0.7f];
    [emailToFriendButton addTarget:self action:@selector(emailToFriend:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)emailToFriend:(UIButton*)sender{
    
}

@end
