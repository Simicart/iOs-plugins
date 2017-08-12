//
//  SCGiftCardOnCartInitWorker.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/11/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCGiftCardOnCartWorker.h"
#import <SimiCartBundle/SCCartViewController.h>
#import <SimiCartBundle/SimiCheckbox.h>
#import "SimiCartModelCollection+GiftCard.h"

#define CART_VIEW_GIFTCART_CREDIT @"CART_VIEW_GIFTCART_CREDIT"
#define CART_VIEW_GIFTCODE @"CART_VIEW_GIFTCODE"

@implementation SCGiftCardOnCartWorker{
    SimiCheckbox *giftCardCreditCb, *giftCodeCb;
    SimiTable *cartCells;
    UITableView *cartTableView;
    SimiTextField *giftCodeTextField, *giftCardCreditTextField, *giftExistingCodeTextField;
    NSString *giftCodeSelected;
    SCCartViewController *cartVC;
//    UIView *giftCardCreditView, *giftCardView;
    BOOL useGiftCode, useGiftCardCredit;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cartViewInitCells:) name:@"InitCartCell-After" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cartViewCellForRow:) name:@"InitializedCartCell-Before" object:nil];
    }
    return self;
}

//Giftcard on Cart Page
- (void)cartViewInitCells:(NSNotification *)noti {
    NSDictionary *giftCardData = [SimiGlobalVar sharedInstance].cart.giftCardData;
    if([[giftCardData objectForKey:@"use_giftcard"] boolValue]) {
        cartCells = noti.object;
        SimiSection *totalSection = [cartCells getSectionByIdentifier:CART_TOTALS];
        NSDictionary *credit = [giftCardData objectForKey:@"credit"];
        NSDictionary *giftcode = [giftCardData objectForKey:@"giftcode"];
        if([[credit objectForKey:@"use_credit"] boolValue]) {
            [totalSection addRowWithIdentifier:CART_VIEW_GIFTCART_CREDIT height:150 sortOrder:2000];
            useGiftCardCredit = YES;
        }else {
            useGiftCardCredit = NO;
            [totalSection addRowWithIdentifier:CART_VIEW_GIFTCART_CREDIT height:30 sortOrder:2000];
        }
        if([[giftcode objectForKey:@"use_giftcode"] boolValue]) {
            [totalSection addRowWithIdentifier:CART_VIEW_GIFTCODE height:220 + 30*(giftcode.allValues.count - 1) sortOrder:2100];
            useGiftCode = YES;
        }else {
            [totalSection addRowWithIdentifier:CART_VIEW_GIFTCODE height:30 sortOrder:2100];
            useGiftCode = NO;
        }
        [totalSection sortItems];
    }
}

- (void)cartViewCellForRow:(NSNotification *)noti {
    cartTableView = [noti.userInfo objectForKey:@"tableView"];
    cartVC = noti.object;
    SimiRow *row = [noti.userInfo objectForKey:@"row"];
    NSDictionary *giftCardData = [SimiGlobalVar sharedInstance].cart.giftCardData;
    NSDictionary *customerData = [giftCardData objectForKey:@"customer"];
    float padding = 10;
    float viewWidth = cartTableView.frame.size.width - 2* padding;
    if([row.identifier isEqualToString:CART_VIEW_GIFTCODE]) {
        //        UITableViewCell *cell = [cartTableView dequeueReusableCellWithIdentifier:CART_VIEW_GIFTCODE];
        //        if(!cell) {
        float cellY = 0;
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CART_VIEW_GIFTCODE];
        NSDictionary *giftCode = [giftCardData objectForKey:@"giftcode"];
        if(!giftCodeCb) {
            giftCodeCb = [[SimiCheckbox alloc] initWithTitle:[NSString stringWithFormat:@"%@",SCLocalizedString(@"Use Gift Card to check out")]];
            [giftCodeCb addTarget:self action:@selector(giftCodeCbChangedValue:) forControlEvents:UIControlEventValueChanged];
        }
        if(useGiftCode) {
            giftCodeCb.checkState = M13CheckboxStateChecked;
        }else {
            giftCodeCb.checkState = M13CheckboxStateUnchecked;
        }
        [cell.contentView addSubview:giftCodeCb];
        giftCodeCb.frame = CGRectMake(padding, cellY, viewWidth, 30);
        if(useGiftCode) {
            cellY += giftCodeCb.frame.size.height;
            for(NSObject *giftCodeValue in giftCode.allValues) {
                if([giftCodeValue isKindOfClass:[NSDictionary class]]) {
                    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(padding, cellY - 5, 40, 40)];
                    [editButton setImage:[UIImage imageNamed:@"ic_address_edit"] forState:UIControlStateNormal];
                    editButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
                    editButton.simiObjectIdentifier = giftCodeValue;
                    [editButton addTarget:self action:@selector(giftCodeSelectedEditing:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.contentView addSubview:editButton];
                    SimiLabel *giftCodeLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(padding + 40, cellY, viewWidth - 80, 30)];
                    giftCodeLabel.text = [NSString stringWithFormat:@"%@ (%@)",[((NSDictionary *)giftCodeValue) objectForKey:@"hidden_code"],[((NSDictionary *)giftCodeValue) objectForKey:@"amount"]];
                    [cell.contentView addSubview:giftCodeLabel];
                    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(padding + viewWidth - 40, cellY - 5, 40, 40)];
                    [deleteButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
                    deleteButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
                    deleteButton.simiObjectIdentifier = giftCodeValue;
                    [deleteButton addTarget:self action:@selector(giftCodeSelectedDelete:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.contentView addSubview:deleteButton];
                    cellY += 30;
                }
            }
            SimiLabel *giftCardLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(padding, cellY, viewWidth, 30)];
            giftCardLabel.text = @"Enter a Gift Card code";
            [cell.contentView addSubview:giftCardLabel];
            cellY += giftCardLabel.frame.size.height;
            if(!giftCodeTextField) {
                giftCodeTextField = [[SimiTextField alloc] init];
            }
            [cell.contentView addSubview:giftCodeTextField];
            giftCodeTextField.frame = CGRectMake(padding, cellY, viewWidth, 40);
            cellY += 40;
            SimiLabel *giftCardExistingLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(padding, cellY, viewWidth, 30)];
            giftCardExistingLabel.text = @"or select from your existing Gift Card code(s)";
            [cell.contentView addSubview:giftCardExistingLabel];
            cellY += 30;
            if(!giftExistingCodeTextField) {
                giftExistingCodeTextField = [[SimiTextField alloc] init];
                UIPickerView *giftCardPicker = [[UIPickerView alloc] init];
                giftCardPicker.delegate = self;
                giftCardPicker.dataSource = self;
                giftExistingCodeTextField.inputView = giftCardPicker;
                UIToolbar *giftCardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 140, SCREEN_WIDTH, 40)];
                giftCardToolbar.items = @[[[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelGiftCardSelection:)],[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],[[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"Select") style:UIBarButtonItemStyleDone target:self action:@selector(doneGiftCardSelection:)]];
                giftExistingCodeTextField.inputAccessoryView = giftCardToolbar;
            }
            [cell.contentView addSubview:giftExistingCodeTextField];
            giftExistingCodeTextField.frame = CGRectMake(padding, cellY, viewWidth, 40);
            cellY += 40;
            SimiButton *applyGiftCodeButton = [[SimiButton alloc] initWithFrame:CGRectMake(padding, cellY + 5, 100, 40) title:@"APPLY" titleFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
            [applyGiftCodeButton addTarget:self action:@selector(applyGiftCode:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:applyGiftCodeButton];
        }
        //        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
        cell.layoutMargins = UIEdgeInsetsZero;
        cartVC.simiObjectIdentifier = cell;
        cartVC.isDiscontinue = YES;
        
    }else if([row.identifier isEqualToString:CART_VIEW_GIFTCART_CREDIT]) {
//        UITableViewCell *cell = [cartTableView dequeueReusableCellWithIdentifier:CART_VIEW_GIFTCODE_CREDIT];
//        if(!cell) {
       UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CART_VIEW_GIFTCART_CREDIT];
        NSDictionary *credit = [giftCardData objectForKey:@"credit"];
        if(!giftCardCreditCb) {
            giftCardCreditCb = [[SimiCheckbox alloc] initWithTitle:[NSString stringWithFormat:@"%@(%@)",SCLocalizedString(@"Use Gift Card credit to check out"),[customerData objectForKey:@"balance"]]];
            [giftCardCreditCb addTarget:self action:@selector(giftCardCreditCbChangedValue:) forControlEvents:UIControlEventValueChanged];
            giftCardCreditCb.frame = CGRectMake(padding, 0, viewWidth, 30);
        }
        if(useGiftCardCredit) {
            giftCardCreditCb.checkState = M13CheckboxStateChecked;
        }else {
            giftCardCreditCb.checkState = M13CheckboxStateUnchecked;
        }
        giftCardCreditCb.titleLabel.text = [NSString stringWithFormat:@"%@(%@)",SCLocalizedString(@"Use Gift Card credit to check out"),[customerData objectForKey:@"balance"]];
        [cell.contentView addSubview:giftCardCreditCb];
        if(useGiftCardCredit) {
            SimiLabel *giftCardCreditLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(padding, 30, viewWidth, 30)];
            giftCardCreditLabel.text = @"Enter Gift Card credit amount to pay for this order";
            [cell.contentView addSubview:giftCardCreditLabel];
            if(!giftCardCreditTextField) {
                giftCardCreditTextField = [[SimiTextField alloc] initWithFrame:CGRectMake(padding, 60, viewWidth, 40) placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE] textColor:THEME_CONTENT_COLOR];
                giftCardCreditTextField.keyboardType = UIKeyboardTypeDecimalPad;
            }
            if([[credit objectForKey:@"use_credit"] boolValue]) {
                giftCardCreditTextField.text = [NSString stringWithFormat:@"%@", [credit objectForKey:@"use_credit_amount"]];
            }else {
                giftCardCreditTextField.text = @"";
            }
            [cell.contentView addSubview:giftCardCreditTextField];
            SimiButton *applyGiftCardCreditButton = [[SimiButton alloc] initWithFrame:CGRectMake(padding, 105, 100, 40) title:@"APPLY" titleFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
            [applyGiftCardCreditButton addTarget:self action:@selector(applyGiftCardCredit:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:applyGiftCardCreditButton];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
        cell.layoutMargins = UIEdgeInsetsZero;
//        }
        cartVC.simiObjectIdentifier = cell;
        cartVC.isDiscontinue = YES;
    }
}

- (void)cancelGiftCardSelection: (id)sender {
    giftExistingCodeTextField.text = @"";
    giftCodeSelected = @"";
    [giftExistingCodeTextField endEditing:YES];
}

- (void)doneGiftCardSelection: (id)sender {
    [giftExistingCodeTextField endEditing:YES];
}

- (void)giftCardCreditCbChangedValue: (SimiCheckbox *)checkbox {
    SimiSection *cartTotalSection = [cartCells getSectionByIdentifier:CART_TOTALS];
    SimiRow *giftCardCreditRow = [cartTotalSection getRowByIdentifier:CART_VIEW_GIFTCART_CREDIT];
    if(checkbox.checkState == M13CheckboxStateChecked) {
        giftCardCreditRow.height = 150;
        useGiftCardCredit = YES;
    }else {
        giftCardCreditRow.height = 30;
        useGiftCardCredit = NO;
        [self changeUsingGiftCardCredit:NO];
    }
    [cartTableView reloadData];
}

- (void)giftCodeCbChangedValue: (SimiCheckbox *)checkbox {
    SimiSection *cartTotalSection = [cartCells getSectionByIdentifier:CART_TOTALS];
    SimiRow *giftCardRow = [cartTotalSection getRowByIdentifier:CART_VIEW_GIFTCODE];
    if(checkbox.checkState == M13CheckboxStateChecked) {
        NSDictionary *giftCardData = [SimiGlobalVar sharedInstance].cart.giftCardData;
        NSDictionary *giftCode = [giftCardData objectForKey:@"giftcode"];
        giftCardRow.height = 220 + 30*(giftCode.allValues.count - 1);
        useGiftCode = YES;
        if(giftCode.allValues.count > 1){
            [self changeUsingGiftCode:YES];
        }
        giftCardRow.height = 220;
        useGiftCode = YES;
    }else {
        giftCardRow.height = 30;
        useGiftCode = NO;
        [self changeUsingGiftCode:NO];
    }
    [cartTableView reloadData];
}

- (void)applyGiftCode: (SimiButton *)button {
    NSMutableDictionary *params = [NSMutableDictionary new];
    if(![giftCodeTextField.text isEqualToString:@""] || ![giftCodeSelected isEqualToString:@""]) {
        [params addEntriesFromDictionary:@{@"giftvoucher":@"1"}];
        if(![giftCodeTextField.text isEqualToString:@""]) {
            [params addEntriesFromDictionary:@{@"giftcode":giftCodeTextField.text}];
            giftCodeTextField.text = @"";
        }
        if(![giftCodeSelected isEqualToString:@""]) {
            [params addEntriesFromDictionary:@{@"existed_giftcode":giftCodeSelected}];
            giftExistingCodeTextField.text = @"";
        }
    }else {
        [params addEntriesFromDictionary:@{@"giftvoucher":@"0"}];
    }
    [[SimiGlobalVar sharedInstance].cart useGiftCodeWithParams:params];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUseGiftCode:) name:DidUseGiftCodeOnCart object:nil];
    [cartVC startLoadingData];
}

- (void)applyGiftCardCredit: (SimiButton *)button {
    NSMutableDictionary *params = [NSMutableDictionary new];
    if([giftCardCreditTextField.text floatValue] > 0) {
        [params addEntriesFromDictionary:@{@"usecredit":@"1",@"credit_amount":giftCardCreditTextField.text}];
    }else {
        [params addEntriesFromDictionary:@{@"usecredit":@"0"}];
    }
    [[SimiGlobalVar sharedInstance].cart useGiftCardCreditWithParams:params];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUseGiftCardCredit:) name:DidUseGiftCardCreditOnCart object:nil];
    [cartVC startLoadingData];
    
}

- (void)updateGiftCodeWithParams: (NSDictionary *)params {
    [[SimiGlobalVar sharedInstance].cart updateGiftCodeWithParams:params];
    [cartVC startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateGiftCode:) name:DidUpdateGiftCodeOnCart object:nil];
}

- (void)didUseGiftCardCredit: (NSNotification *)noti {
    [self removeObserverForNotification:noti];
    [cartVC stopLoadingData];
    SimiResponder *responder = [noti.userInfo objectForKey:@"responder"];
    NSDictionary *giftCardData = [SimiGlobalVar sharedInstance].cart.giftCardData;
    if([responder.status isEqualToString:@"SUCCESS"]) {
        [self showGiftCardMessageOnCart];
        NSDictionary *credit = [giftCardData objectForKey:@"credit"];
        SimiSection *cartTotalSection = [cartCells getSectionByIdentifier:CART_TOTALS];
        SimiRow *giftCardCreditRow = [cartTotalSection getRowByIdentifier:CART_VIEW_GIFTCART_CREDIT];
        if([[credit objectForKey:@"use_credit"] boolValue]) {
            giftCardCreditCb.checkState = M13CheckboxStateChecked;
            giftCardCreditRow.height = 150;
            giftCardCreditTextField.text = [NSString stringWithFormat:@"%@",[credit objectForKey:@"use_credit_amount"]];
        }else {
            giftCardCreditCb.checkState = M13CheckboxStateUnchecked;
            giftCardCreditRow.height = 30;
            giftCardCreditTextField.text = @"";
        }
        [cartVC changeCartData:noti];
    }else {
        [cartVC showAlertWithTitle:@"" message:responder.responseMessage];
    }
}

- (void)didUseGiftCode: (NSNotification *)noti {
    [self removeObserverForNotification:noti];
    [cartVC stopLoadingData];
    SimiResponder *responder = [noti.userInfo objectForKey:@"responder"];
    if([responder.status isEqualToString:@"SUCCESS"]) {
        [self showGiftCardMessageOnCart];
        NSDictionary *giftCardData = [SimiGlobalVar sharedInstance].cart.giftCardData;
        NSDictionary *giftCode = [giftCardData objectForKey:@"giftcode"];
        SimiSection *cartTotalSection = [cartCells getSectionByIdentifier:CART_TOTALS];
        SimiRow *giftCardRow = [cartTotalSection getRowByIdentifier:CART_VIEW_GIFTCODE];
        if([[giftCode objectForKey:@"use_giftcode"] boolValue]) {
            giftCardRow.height = 220 + 30*(giftCode.allValues.count - 1);
            giftCodeCb.checkState = M13CheckboxStateChecked;
        }else {
            giftCardRow.height = 30;
            giftCodeCb.checkState = M13CheckboxStateUnchecked;
        }
        [cartVC changeCartData:noti];
    }else {
        [cartVC showAlertWithTitle:@"" message:responder.responseMessage];
    }
}

- (void)changeUsingGiftCode: (BOOL)usingGiftCode {
    [[SimiGlobalVar sharedInstance].cart useGiftCodeWithParams:@{@"giftvoucher":usingGiftCode?@"1":@"0"}];
    [cartVC startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeUsingGiftCode:) name:DidUseGiftCodeOnCart object:nil];
}

- (void)changeUsingGiftCardCredit: (BOOL)usingGiftCardCredit {
    [[SimiGlobalVar sharedInstance].cart useGiftCardCreditWithParams:@{@"usecredit":usingGiftCardCredit ?@"1":@"0"}];
    [cartVC startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeUsingGiftCardCredit:) name:DidUseGiftCardCreditOnCart object:nil];
}

- (void)didUpdateGiftCode: (NSNotification *)noti {
    [self removeObserverForNotification:noti];
    [cartVC stopLoadingData];
    SimiResponder *responder = [noti.userInfo objectForKey:@"responder"];
    if([responder.status isEqualToString:@"SUCCESS"]) {
        [self showGiftCardMessageOnCart];
        NSDictionary *giftCardData = [SimiGlobalVar sharedInstance].cart.giftCardData;
        NSDictionary *giftCode = [giftCardData objectForKey:@"giftcode"];
        SimiSection *cartTotalSection = [cartCells getSectionByIdentifier:CART_TOTALS];
        SimiRow *giftCardRow = [cartTotalSection getRowByIdentifier:CART_VIEW_GIFTCODE];
        if([[giftCode objectForKey:@"use_giftcode"] boolValue]) {
            giftCardRow.height = 220 + 30*(giftCode.allValues.count - 1);
            giftCodeCb.checkState = M13CheckboxStateChecked;
        }else {
            giftCardRow.height = 30;
            giftCodeCb.checkState = M13CheckboxStateUnchecked;
        }
        [cartVC changeCartData:noti];
    }else {
        [cartVC showAlertWithTitle:@"" message:responder.responseMessage];
    }
}

- (void)didChangeUsingGiftCode: (NSNotification *)noti {
    [self removeObserverForNotification:noti];
    [cartVC stopLoadingData];
    SimiResponder *responder = [noti.userInfo objectForKey:@"responder"];
    if([responder.status isEqualToString:@"SUCCESS"]) {
        [self showGiftCardMessageOnCart];
        [cartVC changeCartData:noti];
    }else {
        [cartVC showAlertWithTitle:@"" message:responder.responseMessage];
    }
}

- (void)didChangeUsingGiftCardCredit: (NSNotification *)noti {
    [self removeObserverForNotification:noti];
    [cartVC stopLoadingData];
    SimiResponder *responder = [noti.userInfo objectForKey:@"responder"];
    if([responder.status isEqualToString:@"SUCCESS"]) {
        [self showGiftCardMessageOnCart];
        [cartVC changeCartData:noti];
    }else {
        [cartVC showAlertWithTitle:@"" message:responder.responseMessage];
    }
}

- (void)giftCodeSelectedDelete: (UIButton *)sender {
    NSDictionary *giftCodeValue = (NSDictionary *)sender.simiObjectIdentifier;
    [[SimiGlobalVar sharedInstance].cart removeGiftCodeWithParams:@{@"giftcode":[giftCodeValue objectForKey:@"gift_code"]}];
    [cartVC startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveGiftCode:) name:DidRemoveGiftCodeOnCart object:nil];
}

- (void)didRemoveGiftCode: (NSNotification *)noti {
    [self removeObserverForNotification:noti];
    [cartVC stopLoadingData];
    SimiResponder *responder = [noti.userInfo objectForKey:@"responder"];
    if([responder.status isEqualToString:@"SUCCESS"]) {
        [self showGiftCardMessageOnCart];
        NSDictionary *giftCardData = [SimiGlobalVar sharedInstance].cart.giftCardData;
        NSDictionary *giftCode = [giftCardData objectForKey:@"giftcode"];
        SimiSection *cartTotalSection = [cartCells getSectionByIdentifier:CART_TOTALS];
        SimiRow *giftCardRow = [cartTotalSection getRowByIdentifier:CART_VIEW_GIFTCODE];
        if([[giftCode objectForKey:@"use_giftcode"] boolValue]) {
            giftCardRow.height = 220 + 30*(giftCode.allValues.count - 1);
            giftCodeCb.checkState = M13CheckboxStateChecked;
        }else {
            giftCardRow.height = 30;
            giftCodeCb.checkState = M13CheckboxStateUnchecked;
        }
        [cartVC changeCartData:noti];
    }else {
        [cartVC showAlertWithTitle:@"" message:responder.responseMessage];
    }
}

- (void)giftCodeSelectedEditing: (UIButton *)sender {
    NSDictionary *giftCodeValue = (NSDictionary *)sender.simiObjectIdentifier;
    float amount = [[giftCodeValue objectForKey:@"amount"] floatValue];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:SCLocalizedString(@"Edit amount") message:SCLocalizedString(@"Edit amount") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = SCLocalizedString(@"Amount");
        textField.text = [giftCodeValue objectForKey:@"amount"];
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:SCLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancelAction];
    UIAlertAction *editAction = [UIAlertAction actionWithTitle:SCLocalizedString(@"Change") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *amountTextField = alertController.textFields.firstObject;
        float changedAmount = [amountTextField.text floatValue];
        if(changedAmount > amount) {
            [cartVC showAlertWithTitle:@"" message:@"The new amount is exceeded the available amount"];
        }else {
            [self updateGiftCodeWithParams:@{@"giftcode":[giftCodeValue objectForKey:@"gift_code"],@"amount":amountTextField.text}];
            
        }
    }];
    [alertController addAction:editAction];
    [cartVC presentViewController:alertController animated:YES completion:nil];
}

#pragma mark UIPickerViewDelegate && UIPickerViewDataSource
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSArray* listCode = [[[SimiGlobalVar sharedInstance].cart.giftCardData objectForKey:@"customer"] objectForKey:@"list_code"];
    if(listCode.count > 0) {
        NSDictionary *code = [listCode objectAtIndex:row];
        giftExistingCodeTextField.text = [code objectForKey:@"hidden_code"];
        giftCodeSelected = [code objectForKey:@"gift_code"];
    }
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

- (void)showGiftCardMessageOnCart {
    NSDictionary *creditCardData = [SimiGlobalVar sharedInstance].cart.giftCardData;
    NSDictionary *message = [creditCardData objectForKey:@"message"];
    if([message isKindOfClass:[NSDictionary class]]) {
        NSString *success = [message objectForKey:@"success"];
        if([message objectForKey:@"notice"]) {
            NSString *notice = [message objectForKey:@"notice"];
            [cartVC showAlertWithTitle:success message:notice];
        }else {
            [cartVC showAlertWithTitle:@"" message:success];
        }
    }
}
@end
