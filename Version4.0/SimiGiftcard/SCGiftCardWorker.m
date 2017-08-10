//
//  SCGiftCardWorker.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/2/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCGiftCardWorker.h"
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SCLeftMenuViewController.h>
#import <SimiCartBundle/SCCartViewController.h>
#import <SimiCartBundle/SimiCheckbox.h>
#import "SCGiftCardProductsViewController.h"
#import "SimiGiftCardCreditModel.h"
#import "SimiGiftCodeModel.h"

#define CART_VIEW_GIFTCARD_CREDIT @"CART_VIEW_GIFTCARD_CREDIT"
#define CART_VIEW_GIFTCARD @"CART_VIEW_GIFTCARD"

@implementation SCGiftCardWorker{
    SimiTable * cells;
    SimiCheckbox *giftCardCreditCb, *giftCardCb;
    SimiTable *cartCells;
    UITableView *cartTableView;
    UIView *giftCardView, *giftCardCreditView;
    SimiTextField *giftCardTextField, *giftCardCreditTextField, *giftCardCodeTextField;
    UIPickerView *giftCardPicker;
    NSString *giftCodeSelected;
    SCCartViewController *cartVC;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leftmenuInitCellsAfter:) name:@"SCLeftMenu_InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leftmenuDidSelectRow:) name:@"SCLeftMenu_DidSelectRow" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cartViewInitCells:) name:@"InitCartCell-After" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cartViewCellForRow:) name:@"InitializedCartCell-Before" object:nil];
    }
    return self;
}

- (void)leftmenuInitCellsAfter:(NSNotification*)noti{
    cells = noti.object;
    SimiSection *section = [cells getSectionByIdentifier:LEFTMENU_SECTION_MAIN];
    SimiRow *row = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_GIFTCARD height:50 sortOrder:600];
    row.image = [UIImage imageNamed:@"ic_contact"];
    row.title = SCLocalizedString(@"GiftCard Products");
    row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [section addObject:row];
    [section sortItems];
}

- (void)leftmenuDidSelectRow:(NSNotification*)noti{
    SimiRow *row = [noti.userInfo valueForKey:@"simirow"];
    if ([row.identifier isEqualToString:LEFTMENU_ROW_GIFTCARD]) {
        SCGiftCardProductsViewController *giftCardProductViewController = [SCGiftCardProductsViewController new];
        [[SimiGlobalVar sharedInstance].currentlyNavigationController pushViewController:giftCardProductViewController animated:YES];
    }
}

- (void)cartViewInitCells:(NSNotification *)noti {
    NSDictionary *giftCardData = [SimiGlobalVar sharedInstance].cart.giftCardData;
    if([[giftCardData objectForKey:@"use_giftcard"] boolValue]) {
        cartCells = noti.object;
        SimiSection *totalSection = [cartCells getSectionByIdentifier:CART_TOTALS];
        [totalSection addRowWithIdentifier:CART_VIEW_GIFTCARD_CREDIT height:30 sortOrder:200];
        [totalSection addRowWithIdentifier:CART_VIEW_GIFTCARD height:30 sortOrder:210];
        [totalSection sortItems];
    }
}

- (void)cartViewCellForRow:(NSNotification *)noti {
    cartTableView = [noti.userInfo objectForKey:@"tableView"];
    cartVC = noti.object;
    SimiRow *row = [noti.userInfo objectForKey:@"row"];
    NSDictionary *giftCardData = [SimiGlobalVar sharedInstance].cart.giftCardData;
    NSDictionary *customerData = [giftCardData objectForKey:@"customer"];
    if([row.identifier isEqualToString:CART_VIEW_GIFTCARD]) {
        UITableViewCell *cell = [cartTableView dequeueReusableCellWithIdentifier:CART_VIEW_GIFTCARD];
        if(!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CART_VIEW_GIFTCARD];
            giftCardCb = [[SimiCheckbox alloc] initWithTitle:[NSString stringWithFormat:@"%@",SCLocalizedString(@"Use Gift Card to check out")]];
            [giftCardCb addTarget:self action:@selector(giftCardCbChangedValue:) forControlEvents:UIControlEventValueChanged];
            giftCardCb.frame = CGRectMake(10, 0, cartTableView.frame.size.width - 20, 30);
            [cell.contentView addSubview:giftCardCb];
            giftCardView = [[UIView alloc] initWithFrame:CGRectMake(10, 30, cartTableView.frame.size.width - 20, 145)];
            SimiLabel *giftCardLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(0, 0, giftCardView.frame.size.width, 30)];
            giftCardLabel.text = @"Enter a Gift Card code";
            [giftCardView addSubview:giftCardLabel];
            giftCardCodeTextField = [[SimiTextField alloc] initWithFrame:CGRectMake(0, 30, giftCardView.frame.size.width, 40) placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE] textColor:THEME_CONTENT_COLOR];
            [giftCardView addSubview:giftCardCodeTextField];
            SimiLabel *giftCardExistingLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(0, 70, giftCardView.frame.size.width, 30)];
            giftCardExistingLabel.text = @"or select from your existing Gift Card code(s)";
            [giftCardView addSubview:giftCardExistingLabel];
            giftCardCreditTextField = [[SimiTextField alloc] initWithFrame:CGRectMake(0, 100, giftCardView.frame.size.width, 40) placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE] textColor:THEME_CONTENT_COLOR];
            [giftCardView addSubview:giftCardCreditTextField];
            giftCardPicker = [[UIPickerView alloc] init];
            giftCardPicker.delegate = self;
            giftCardPicker.dataSource = self;
            giftCardCreditTextField.inputView = giftCardPicker;
            UIToolbar *giftCardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
            giftCardToolbar.items = @[[[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelGiftCardSelection:)],[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],[[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"Select") style:UIBarButtonItemStyleDone target:self action:@selector(doneGiftCardSelection:)]];
            giftCardCreditTextField.inputAccessoryView = giftCardToolbar;
            SimiButton *applyGiftCardButton = [[SimiButton alloc] initWithFrame:CGRectMake(10, 145, cartTableView.frame.size.width - 20, 40) title:@"APPLY" titleFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
            [applyGiftCardButton addTarget:self action:@selector(applyGiftCard:) forControlEvents:UIControlEventTouchUpInside];
            [giftCardCreditView addSubview:applyGiftCardButton];
            giftCardCreditView.hidden = YES;
            [cell.contentView addSubview:giftCardCreditView];
            giftCardView.hidden = YES;
            [cell.contentView addSubview:giftCardView];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
        cell.layoutMargins = UIEdgeInsetsZero;
        cartVC.simiObjectIdentifier = cell;
        cartVC.isDiscontinue = YES;
    }else if([row.identifier isEqualToString:CART_VIEW_GIFTCARD_CREDIT]) {
        UITableViewCell *cell = [cartTableView dequeueReusableCellWithIdentifier:CART_VIEW_GIFTCARD_CREDIT];
        if(!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CART_VIEW_GIFTCARD_CREDIT];
            giftCardCreditCb = [[SimiCheckbox alloc] initWithTitle:[NSString stringWithFormat:@"%@(%@)",SCLocalizedString(@"Use Gift Card credit to check out"),[customerData objectForKey:@"balance"]]];
            [giftCardCreditCb addTarget:self action:@selector(giftCardCreditCbChangedValue:) forControlEvents:UIControlEventValueChanged];
            giftCardCreditCb.frame = CGRectMake(10, 0, cartTableView.frame.size.width - 20, 30);
            [cell.contentView addSubview:giftCardCreditCb];
            giftCardCreditView = [[UIView alloc] initWithFrame:CGRectMake(10, 30, cartTableView.frame.size.width - 20, 120)];
            SimiLabel *giftCardCreditLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(0, 0, giftCardCreditView.frame.size.width, 30)];
            giftCardCreditLabel.text = @"Enter Gift Card credit amount to pay for this order";
            [giftCardCreditView addSubview:giftCardCreditLabel];
            giftCardCreditTextField = [[SimiTextField alloc] initWithFrame:CGRectMake(0, 30, giftCardCreditView.frame.size.width, 40) placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE] textColor:THEME_CONTENT_COLOR];
            giftCardCreditTextField.keyboardType = UIKeyboardTypeNumberPad;
            [giftCardCreditView addSubview:giftCardCreditTextField];
            SimiButton *applyGiftCardCreditButton = [[SimiButton alloc] initWithFrame:CGRectMake(10, 75, cartTableView.frame.size.width - 20, 40) title:@"APPLY" titleFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
            [applyGiftCardCreditButton addTarget:self action:@selector(applyGiftCardCredit:) forControlEvents:UIControlEventTouchUpInside];
            [giftCardCreditView addSubview:applyGiftCardCreditButton];
            giftCardCreditView.hidden = YES;
            [cell.contentView addSubview:giftCardCreditView];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
        cell.layoutMargins = UIEdgeInsetsZero;
        cartVC.simiObjectIdentifier = cell;
        cartVC.isDiscontinue = YES;
    }
}

- (void)cancelGiftCardSelection: (id)sender {
    giftCardCreditTextField.text = @"";
    giftCodeSelected = @"";
    [giftCardCreditTextField endEditing:YES];
}

- (void)doneGiftCardSelection: (id)sender {
    [giftCardCreditTextField endEditing:YES];
}

- (void)giftCardCreditCbChangedValue: (SimiCheckbox *)checkbox {
    SimiSection *cartTotalSection = [cartCells getSectionByIdentifier:CART_TOTALS];
    SimiRow *giftCardCreditRow = [cartTotalSection getRowByIdentifier:CART_VIEW_GIFTCARD_CREDIT];
    if(checkbox.checkState == M13CheckboxStateChecked) {
        giftCardCreditRow.height = 150;
        giftCardCreditView.hidden = NO;
    }else {
        giftCardCreditRow.height = 30;
        giftCardCreditView.hidden = YES;
    }
    [cartTableView reloadData];
}

- (void)giftCardCbChangedValue: (SimiCheckbox *)checkbox {
    SimiSection *cartTotalSection = [cartCells getSectionByIdentifier:CART_TOTALS];
    SimiRow *giftCardRow = [cartTotalSection getRowByIdentifier:CART_VIEW_GIFTCARD];
    if(checkbox.checkState == M13CheckboxStateChecked) {
        giftCardRow.height = 220;
        giftCardView.hidden = NO;
    }else {
        giftCardRow.height = 30;
        giftCardView.hidden = YES;
    }
    [cartTableView reloadData];
}

- (void)applyGiftCard: (SimiButton *)button {
    NSMutableDictionary *params = [NSMutableDictionary new];
    if(giftCardCb.checkState == M13CheckboxStateChecked && (![giftCardCodeTextField.text isEqualToString:@""] || ![giftCodeSelected isEqualToString:@""])) {
        [params addEntriesFromDictionary:@{@"giftvoucher":@"1"}];
        if(![giftCardCodeTextField.text isEqualToString:@""]) {
            [params addEntriesFromDictionary:@{@"giftcode":giftCardCodeTextField.text}];
        }
        if(![giftCodeSelected isEqualToString:@""]) {
            [params addEntriesFromDictionary:@{@"existed_giftcode":giftCodeSelected}];
        }
    }else {
        [params addEntriesFromDictionary:@{@"giftvoucher":@"0"}];
    }
    SimiGiftCardCreditModel *giftCardModel = [SimiGiftCardCreditModel new];
    [giftCardModel useGiftCardCreditWithParams:params];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUseGiftCard:) name:DidUseGiftCard object:nil];
    [cartVC startLoadingData];
}

- (void)applyGiftCardCredit: (SimiButton *)button {
    NSMutableDictionary *params = [NSMutableDictionary new];
    if(giftCardCreditCb.checkState == M13CheckboxStateChecked && ![giftCardCreditTextField.text isEqualToString:@""]) {
        [params addEntriesFromDictionary:@{@"usecredit":@"1",@"credit_amount":giftCardTextField.text}];
    }else {
        [params addEntriesFromDictionary:@{@"usecredit":@"0"}];
    }
    SimiGiftCodeModel *giftCodeModel = [SimiGiftCodeModel new];
    [giftCodeModel useGiftCodeWithParams:params];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUseGiftCode:) name:DidUseGiftCode object:nil];
    [cartVC startLoadingData];
    
}

- (void)didUseGiftCard: (NSNotification *)noti {
    SimiResponder *responder = [noti.userInfo objectForKey:@"responder"];
    if([responder.status isEqualToString:@"SUCCESS"]) {
        SimiGiftCardCreditModel* giftCardCredit = noti.object;
    
    }else {
        [cartVC showToastMessage:responder.responseMessage];
    }
}

- (void)didUseGiftCode: (NSNotification *)noti {
    SimiResponder *responder = [noti.userInfo objectForKey:@"responder"];
    if([responder.status isEqualToString:@"SUCCESS"]) {
         SimiGiftCodeModel* giftCode = noti.object;
        
    }else {
        [cartVC showToastMessage:responder.responseMessage];
    }
}

#pragma mark UIPickerViewDelegate && UIPickerViewDataSource
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSArray* listCode = [[[SimiGlobalVar sharedInstance].cart.giftCardData objectForKey:@"customer"] objectForKey:@"list_code"];
    NSDictionary *code = [listCode objectAtIndex:row];
    giftCardCreditTextField.text = [code objectForKey:@"hidden_code"];
    giftCodeSelected = [code objectForKey:@"gift_code"];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray* listCode = [[[SimiGlobalVar sharedInstance].cart.giftCardData objectForKey:@"customer"] objectForKey:@"list_code"];
    return listCode.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSArray* listCode = [[[SimiGlobalVar sharedInstance].cart.giftCardData objectForKey:@"customer"] objectForKey:@"list_code"];
    NSDictionary *code = [listCode objectAtIndex:row];
    return [NSString stringWithFormat:@"%@(%@)",[code objectForKey:@"hidden_code"], [code objectForKey:@"balance"]];
}

@end
