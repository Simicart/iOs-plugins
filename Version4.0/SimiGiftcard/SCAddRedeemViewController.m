//
//  SCAddRedeemViewController.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/12/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCAddRedeemViewController.h"

@interface SCAddRedeemViewController ()<UITextFieldDelegate>

@end

@implementation SCAddRedeemViewController

- (void)viewDidLoadBefore{
    self.navigationItem.title = SCLocalizedString(@"GIFT CARD");
    giftCardCreditModel = [SimiGiftCardCreditModel new];
}

- (void)viewWillAppearBefore:(BOOL)animated{
    if (PHONEDEVICE) {
        [super viewWillAppearBefore:animated];
    }
}

- (void)viewDidAppearBefore:(BOOL)animated{
    if (giftCodeTextField == nil) {
        float height = 10;
        float padding = 15;
        float viewWidth = CGRectGetWidth(self.view.bounds);
        float buttonWidth = (viewWidth - padding*3)/2;
        SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, height, viewWidth - 2*padding, 25) andFontName:THEME_FONT_NAME_REGULAR andFontSize:20 andTextColor:THEME_CONTENT_COLOR text:@"Add/Redeem a Gift Card"];
        [self.view addSubview:titleLabel];
        height += 25;
        
        giftCodeTextField = [[SimiTextField alloc]initWithFrame:CGRectMake(padding, height, viewWidth - 2*padding, 40) placeHolder:@"Enter Gift Card Code" font:[UIFont fontWithName:THEME_FONT_NAME size:16] textColor:THEME_CONTENT_COLOR borderWidth:1 borderColor:[UIColor lightGrayColor] cornerRadius:6 leftView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 40)] rightView:nil];
        giftCodeTextField.delegate = self;
        giftCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [giftCodeTextField addTarget:self action:@selector(textChange) forControlEvents:UIControlEventEditingChanged];
        [self.view addSubview:giftCodeTextField];
        height += 60;
        
        redeemGiftCardButton = [[SimiButton alloc]initWithFrame:CGRectMake(padding, height, buttonWidth, 40) title:@"REDEEM GIFT CARD" titleFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:14] cornerRadius:6 borderWidth:0 borderColor:nil];
        [redeemGiftCardButton addTarget:self action:@selector(redeemGiftCode:) forControlEvents:UIControlEventTouchUpInside];
        redeemGiftCardButton.enabled = NO;
        redeemGiftCardButton.alpha = 0.5;
        [self.view addSubview:redeemGiftCardButton];
        
        addToListButton = [[SimiButton alloc]initWithFrame:CGRectMake(padding*2 + buttonWidth, height, buttonWidth, 40) title:@"ADD TO MY LIST" titleFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:14] cornerRadius:6 borderWidth:0 borderColor:nil];
        [addToListButton addTarget:self action:@selector(addGiftCodeToList:) forControlEvents:UIControlEventTouchUpInside];
        addToListButton.enabled = NO;
        addToListButton.alpha = 0.5;
        [self.view addSubview:addToListButton];
    }
}

- (void)redeemGiftCode:(UIButton*)sender{
    [giftCardCreditModel redeemGiftCodeWithParams:@{@"giftcode":giftCodeTextField.text}];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didCompletedAddOrRedeemGiftCode:) name:DidRedeemGiftCode object:giftCardCreditModel];
    [self startLoadingData];
}

- (void)addGiftCodeToList:(UIButton*)sender{
    [giftCardCreditModel addGiftCodeWithParams:@{@"giftcode":giftCodeTextField.text}];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didCompletedAddOrRedeemGiftCode:) name:DidAddGiftCodeToList object:giftCardCreditModel];
    [self startLoadingData];
}

- (void)didCompletedAddOrRedeemGiftCode:(NSNotification*)noti{
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        [self showToastMessage:[giftCardCreditModel valueForKey:@"success"] duration:1.5];
    }else
        [self showToastMessage:responder.responseMessage duration:1.5];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)textChange{
    if ([giftCodeTextField.text isEqualToString:@""]) {
        redeemGiftCardButton.enabled = NO;
        redeemGiftCardButton.alpha = 0.5;
        addToListButton.enabled = NO;
        addToListButton.alpha = 0.5;
    }else{
        redeemGiftCardButton.enabled = YES;
        redeemGiftCardButton.alpha = 1;
        addToListButton.enabled = YES;
        addToListButton.alpha = 1;
    }
}

@end
