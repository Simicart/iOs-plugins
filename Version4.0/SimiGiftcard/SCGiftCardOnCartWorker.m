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
#import <SimiCartBundle/SimiTextField.h>
#import "SimiQuoteItemModelCollection+GiftCard.h"

#define CART_VIEW_GIFTCART_CREDIT @"CART_VIEW_GIFTCART_CREDIT"
#define CART_VIEW_GIFTCODE @"CART_VIEW_GIFTCODE"
#define CART_VIEW_GIFTCARD_TITLE @"CART_VIEW_GIFTCARD_TITLE"

@implementation SCGiftCardOnCartWorker{
    SimiCheckbox *giftCardCreditCb, *giftCodeCb;
    SimiTable *cartCells;
    UITableView *cartTableView;
    SimiTextField *giftCodeTextField, *giftCardCreditTextField, *existingCodeTextField;
    NSString *giftCodeSelected;
    SCCartViewController *cartViewController;
    BOOL didGetGiftCodeConfig,didGetCreditConfig;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cartViewInitCells:) name:[NSString stringWithFormat:@"%@%@",SCCartViewController_RootEventName,SimiTableViewController_SubKey_InitCells_End] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cartViewCellForRow:) name:[NSString stringWithFormat:@"%@%@",SCCartViewController_RootEventName,SimiTableViewController_SubKey_InitializedCell_End] object:nil];
        if(PHONEDEVICE){
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cartViewWillAppear:) name:@"SCCartViewControllerViewWillAppear" object:nil];
        }else{
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cartViewWillAppear:) name:@"SCCartViewControllerPadViewWillAppear" object:nil];
        }
    }
    return self;
}

- (void)cartViewWillAppear:(NSNotification *)noti{
    didGetCreditConfig = NO;
    didGetGiftCodeConfig = NO;
}

//Giftcard on Cart Page
- (void)cartViewInitCells:(NSNotification *)noti {
    NSDictionary *giftCardData = [[SimiGlobalVar sharedInstance].cart.data valueForKey:@"gift_card"];
    if(giftCardData){
        cartCells = noti.object;
        SimiSection *totalSection = [cartCells getSectionByIdentifier:CART_TOTALS];
        SimiRow *totalRow = [totalSection getRowByIdentifier:CART_TOTALS_ROW];
        float sortOrder = totalRow.sortOrder - 1;
        NSDictionary *credit = [giftCardData objectForKey:@"credit"];
        NSDictionary *giftcode = [giftCardData objectForKey:@"giftcode"];
        NSDictionary *customer = [giftCardData objectForKey:@"customer"];
        if([[giftCardData objectForKey:@"use_giftcard"] boolValue]) {
            SimiRow *titleRow = [[SimiRow alloc] initWithIdentifier:CART_VIEW_GIFTCARD_TITLE height:44 sortOrder:sortOrder];
            [totalSection addObject:titleRow];
            if([customer objectForKey:@"balance"]){
                if([[credit objectForKey:@"use_credit"] boolValue]) {
                    [totalSection addRowWithIdentifier:CART_VIEW_GIFTCART_CREDIT height:150 sortOrder:sortOrder];
                }else {
                    [totalSection addRowWithIdentifier:CART_VIEW_GIFTCART_CREDIT height:30 sortOrder:sortOrder];
                }
            }
            if([[giftcode objectForKey:@"use_giftcode"] boolValue]) {
                [totalSection addRowWithIdentifier:CART_VIEW_GIFTCODE height:220 + 30*(giftcode.allValues.count - 1) sortOrder:sortOrder];
            }else {
                [totalSection addRowWithIdentifier:CART_VIEW_GIFTCODE height:30 sortOrder:sortOrder];
            }
        }else{
            if([giftCardData objectForKey:@"label"] && ![[giftCardData objectForKey:@"label"] isEqualToString:@""]){
                SimiRow *titleRow = [[SimiRow alloc] initWithIdentifier:CART_VIEW_GIFTCARD_TITLE height:70 sortOrder:sortOrder];
                [totalSection addRow:titleRow];
            }
        }
    }
}

- (void)cartViewCellForRow:(NSNotification *)noti {
    NSIndexPath *indexPath = [noti.userInfo valueForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.indexpath];
    cartViewController = [noti.userInfo valueForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.viewcontroller];
    cartCells = noti.object;
    SimiSection *section = [cartCells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    cartTableView = cartViewController.contentTableView;
    NSDictionary *giftCardData = [[SimiGlobalVar sharedInstance].cart.data valueForKey:@"gift_card"];
    NSDictionary *giftCode = [giftCardData objectForKey:@"giftcode"];
    NSDictionary *credit = [giftCardData objectForKey:@"credit"];
    NSDictionary *customerData = [giftCardData objectForKey:@"customer"];
    float paddingX = 10;
    float paddingY = 5;
    float viewWidth = cartTableView.frame.size.width - 2* paddingX;
    if([row.identifier isEqualToString:CART_VIEW_GIFTCODE]) {
        float cellY = paddingY;
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CART_VIEW_GIFTCODE];
        if(!giftCodeCb) {
            giftCodeCb = [[SimiCheckbox alloc] initWithTitle:[NSString stringWithFormat:@"%@",SCLocalizedString(@"Use Gift Card to check out")]];
            [giftCodeCb addTarget:self action:@selector(giftCodeCbChangedValue:) forControlEvents:UIControlEventValueChanged];
        }
        
        [cell.contentView addSubview:giftCodeCb];
        giftCodeCb.frame = CGRectMake(paddingX, cellY, viewWidth, 30);
        cellY += giftCodeCb.frame.size.height + paddingY;
        
        if(!didGetGiftCodeConfig){
            if([[giftCode objectForKey:@"use_giftcode"] boolValue]) {
                giftCodeCb.checkState = M13CheckboxStateChecked;
            }else {
                giftCodeCb.checkState = M13CheckboxStateUnchecked;
            }
            didGetGiftCodeConfig = YES;
        }
        if(giftCodeCb.checkState == M13CheckboxStateChecked) {
            if([[giftCode objectForKey:@"use_giftcode"] boolValue]){
                for(NSObject *giftCodeValue in giftCode.allValues) {
                    if([giftCodeValue isKindOfClass:[NSDictionary class]]) {
                        UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(paddingX, cellY - 5, 40, 40)];
                        [editButton setImage:[UIImage imageNamed:@"ic_address_edit"] forState:UIControlStateNormal];
                        editButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
                        editButton.simiObjectIdentifier = giftCodeValue;
                        [editButton addTarget:self action:@selector(giftCodeSelectedEditing:) forControlEvents:UIControlEventTouchUpInside];
                        [cell.contentView addSubview:editButton];
                        SimiLabel *giftCodeLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX + 40, cellY, viewWidth - 80, 30)];
                        giftCodeLabel.text = [NSString stringWithFormat:@"%@ (%@%@)",[((NSDictionary *)giftCodeValue) objectForKey:@"hidden_code"],[customerData objectForKey:@"currency_symbol"],[((NSDictionary *)giftCodeValue) objectForKey:@"amount"]];
                        [cell.contentView addSubview:giftCodeLabel];
                        UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(paddingX + viewWidth - 40, cellY - 5, 40, 40)];
                        [deleteButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
                        deleteButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
                        deleteButton.simiObjectIdentifier = giftCodeValue;
                        [deleteButton addTarget:self action:@selector(giftCodeSelectedDelete:) forControlEvents:UIControlEventTouchUpInside];
                        [cell.contentView addSubview:deleteButton];
                        cellY += 30 + paddingY;
                    }
                }
            }
            SimiLabel *giftCardLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX, cellY, viewWidth, 30)];
            giftCardLabel.text = @"Enter a Gift Card code";
            [cell.contentView addSubview:giftCardLabel];
            cellY += giftCardLabel.frame.size.height + paddingY;
            if(!giftCodeTextField) {
                giftCodeTextField = [[SimiTextField alloc] init];
                UIToolbar *giftCodeToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 140, SCREEN_WIDTH, 40)];
                giftCodeToolbar.items = @[[[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelGiftCodeSelection:)],[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],[[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneGiftCodeSelection:)]];
                giftCodeTextField.inputAccessoryView = giftCodeToolbar;
            }
            [cell.contentView addSubview:giftCodeTextField];
            giftCodeTextField.frame = CGRectMake(paddingX, cellY, viewWidth, 40);
            cellY += 40 + paddingY + 5;
            if(((NSArray *)[customerData objectForKey:@"list_code"]).count > 0){
                SimiLabel *giftCardExistingLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX, cellY, viewWidth, 30)];
                giftCardExistingLabel.text = @"or select from your existing Gift Card code(s)";
                giftCardExistingLabel.numberOfLines = 0;
                [giftCardExistingLabel sizeToFit];
                NSLog(@"giftCardExistingLabel height: %f",giftCardExistingLabel.frame.size.height);
                [cell.contentView addSubview:giftCardExistingLabel];
                cellY += giftCardExistingLabel.frame.size.height + paddingY;
                if(!existingCodeTextField) {
                    existingCodeTextField = [[SimiTextField alloc] init];
                    UIPickerView *existingCodePicker = [[UIPickerView alloc] init];
                    existingCodePicker.delegate = self;
                    existingCodePicker.dataSource = self;
                    existingCodeTextField.inputView = existingCodePicker;
                    UIToolbar *existingCodeToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 140, SCREEN_WIDTH, 40)];
                    existingCodeToolbar.items = @[[[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelExistingCodeSelection:)],[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],[[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"Select") style:UIBarButtonItemStyleDone target:self action:@selector(doneExistingCodeSelection:)]];
                    existingCodeTextField.inputAccessoryView = existingCodeToolbar;
                }
                [cell.contentView addSubview:existingCodeTextField];
                existingCodeTextField.frame = CGRectMake(paddingX, cellY, viewWidth, 40);
                cellY += 40 + paddingY;
            }
            SimiButton *applyGiftCodeButton = [[SimiButton alloc] initWithFrame:CGRectMake(paddingX + 10, cellY, viewWidth - 20, 40) title:@"Apply Gift Code" titleFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE]];
            [applyGiftCodeButton addTarget:self action:@selector(applyGiftCode:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:applyGiftCodeButton];
            cellY += applyGiftCodeButton.frame.size.height + paddingY;
        }
        row.height = cellY + 10;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
        cell.layoutMargins = UIEdgeInsetsZero;
         [SimiGlobalFunction sortViewForRTL:cell.contentView andWidth:CGRectGetWidth(cartTableView.frame)];
        row.tableCell = cell;
        cartViewController.isDiscontinue = YES;
    }else if([row.identifier isEqualToString:CART_VIEW_GIFTCART_CREDIT]) {
        float cellY = paddingY;
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CART_VIEW_GIFTCART_CREDIT];
        if(!giftCardCreditCb) {
            giftCardCreditCb = [[SimiCheckbox alloc] initWithTitle:[NSString stringWithFormat:@"%@(%@)",SCLocalizedString(@"Use Gift Card credit to check out"),[customerData objectForKey:@"balance"]]];;
            [giftCardCreditCb addTarget:self action:@selector(giftCardCreditCbChangedValue:) forControlEvents:UIControlEventValueChanged];
            giftCardCreditCb.frame = CGRectMake(paddingX, cellY, viewWidth, 30);
        }
        giftCardCreditCb.titleLabel.text = [NSString stringWithFormat:@"%@(%@)",SCLocalizedString(@"Use Gift Card credit to check out"),[customerData objectForKey:@"balance"]];
        [cell.contentView addSubview:giftCardCreditCb];
        cellY += giftCardCreditCb.frame.size.height + paddingY;
        if(!didGetCreditConfig){
            if([[credit objectForKey:@"use_credit"] boolValue]) {
                giftCardCreditCb.checkState = M13CheckboxStateChecked;
            }else {
                giftCardCreditCb.checkState = M13CheckboxStateUnchecked;
            }
            didGetCreditConfig = YES;
        }
        if(giftCardCreditCb.checkState == M13CheckboxStateChecked) {
            SimiLabel *giftCardCreditLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX, cellY, viewWidth, 30)];
            giftCardCreditLabel.text = @"Enter Gift Card credit amount to pay for this order";
            giftCardCreditLabel.numberOfLines = 0;
            [giftCardCreditLabel sizeToFit];
            [cell.contentView addSubview:giftCardCreditLabel];
            cellY += giftCardCreditLabel.frame.size.height + paddingY;
            if(!giftCardCreditTextField) {
                giftCardCreditTextField = [[SimiTextField alloc] initWithFrame:CGRectMake(paddingX, cellY, viewWidth, 40) placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE] textColor:THEME_CONTENT_COLOR];
                giftCardCreditTextField.keyboardType = UIKeyboardTypeDecimalPad;
                UIToolbar *giftCardCreditToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 140, SCREEN_WIDTH, 40)];
                giftCardCreditToolbar.items = @[[[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelGiftCardCreditSelection:)],[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],[[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneGiftCardCreditSelection:)]];
                giftCardCreditTextField.inputAccessoryView = giftCardCreditToolbar;
            }
            if([[credit objectForKey:@"use_credit"] boolValue]) {
                    giftCardCreditTextField.text = [NSString stringWithFormat:@"%@", [credit objectForKey:@"use_credit_amount"]];
            }else {
                giftCardCreditTextField.text = @"";
            }
            [cell.contentView addSubview:giftCardCreditTextField];
            cellY += giftCardCreditTextField.frame.size.height + paddingY;
            SimiButton *applyGiftCardCreditButton = [[SimiButton alloc] initWithFrame:CGRectMake(paddingX + 10, cellY, viewWidth - 20, 40) title:@"Apply Credit" titleFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
            [applyGiftCardCreditButton addTarget:self action:@selector(applyGiftCardCredit:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:applyGiftCardCreditButton];
            cellY += applyGiftCardCreditButton.frame.size.height + paddingY;
        }
        row.height = cellY + 10;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
        cell.layoutMargins = UIEdgeInsetsZero;
         [SimiGlobalFunction sortViewForRTL:cell.contentView andWidth:CGRectGetWidth(cartTableView.frame)];
        row.tableCell = cell;
        cartViewController.isDiscontinue = YES;
    }else if([row.identifier isEqualToString:CART_VIEW_GIFTCARD_TITLE]) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CART_VIEW_GIFTCARD_TITLE];
        float cellY = paddingY;
        SimiLabel *giftCardTitleLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX, cellY, viewWidth, 30)];
        giftCardTitleLabel.text = @"GIFT CARD";
        giftCardTitleLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE];
        [cell.contentView addSubview:giftCardTitleLabel];
        cellY += 30 + paddingY;
        if([giftCardData objectForKey:@"label"] && ![[giftCardData objectForKey:@"label"] isEqualToString:@""]){
            SimiLabel *nonUseLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX, cellY, viewWidth, 30)];
            nonUseLabel.text = [giftCardData objectForKey:@"label"];
            nonUseLabel.numberOfLines = 0;
            [nonUseLabel sizeToFit];
            [cell.contentView addSubview:nonUseLabel];
            cellY += nonUseLabel.frame.size.height + paddingY;
        }
        row.height = cellY + 10;
         [SimiGlobalFunction sortViewForRTL:cell.contentView andWidth:CGRectGetWidth(cartTableView.frame)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        row.tableCell = cell;
        cartViewController.isDiscontinue = YES;
    }
}

- (void)cancelGiftCodeSelection: (id)sender {
    giftCodeTextField.text = @"";
    [giftCodeTextField endEditing:YES];
}

- (void)doneGiftCodeSelection: (id)sender {
    [giftCodeTextField endEditing:YES];
}

- (void)cancelExistingCodeSelection: (id)sender {
    existingCodeTextField.text = @"";
    giftCodeSelected = @"";
    [existingCodeTextField endEditing:YES];
}

- (void)doneExistingCodeSelection: (id)sender {
    [existingCodeTextField endEditing:YES];
}

- (void)cancelGiftCardCreditSelection: (id)sender {
    giftCardCreditTextField.text = @"";
    [giftCardCreditTextField endEditing:YES];
}

- (void)doneGiftCardCreditSelection: (id)sender {
    [giftCardCreditTextField endEditing:YES];
}

- (void)giftCardCreditCbChangedValue: (SimiCheckbox *)checkbox {
    NSDictionary *giftCardData = [[SimiGlobalVar sharedInstance].cart.data valueForKey:@"gift_card"];
    NSDictionary *credit = [giftCardData objectForKey:@"credit"];
    if(checkbox.checkState == M13CheckboxStateChecked) {
    }else {
        if([[credit objectForKey:@"use_credit"] boolValue]){
            [self changeUsingGiftCardCredit:NO];
        }
    }
    [cartTableView reloadData];
}

- (void)giftCodeCbChangedValue: (SimiCheckbox *)checkbox {
    NSDictionary *giftCardData = [[SimiGlobalVar sharedInstance].cart.data valueForKey:@"gift_card"];
    NSDictionary *giftcode = [giftCardData objectForKey:@"giftcode"];
    if(checkbox.checkState == M13CheckboxStateChecked) {
    }else {
        if([[giftcode objectForKey:@"use_giftcode"] boolValue]){
            [self changeUsingGiftCode:NO];
        }
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
        if(giftCodeSelected && ![giftCodeSelected isEqualToString:@""]) {
            [params addEntriesFromDictionary:@{@"existed_giftcode":giftCodeSelected}];
            existingCodeTextField.text = @"";
        }
    }else {
        [params addEntriesFromDictionary:@{@"giftvoucher":@"0"}];
    }
    [[SimiGlobalVar sharedInstance].cart useGiftCodeWithParams:params];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUseGiftCode:) name:DidUseGiftCodeOnCart object:nil];
    [cartViewController startLoadingData];
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
    [cartViewController startLoadingData];
    
}

- (void)updateGiftCodeWithParams: (NSDictionary *)params {
    [[SimiGlobalVar sharedInstance].cart updateGiftCodeWithParams:params];
    [cartViewController startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateGiftCode:) name:DidUpdateGiftCodeOnCart object:nil];
}

- (void)didUseGiftCardCredit: (NSNotification *)noti {
    [self removeObserverForNotification:noti];
    [cartViewController stopLoadingData];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    NSDictionary *giftCardData = [[SimiGlobalVar sharedInstance].cart.data valueForKey:@"gift_card"];;
    if(responder.status == SUCCESS) {
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
        [cartViewController changeCartData:noti];
    }else {
        [cartViewController showAlertWithTitle:@"" message:responder.message];
    }
}

- (void)didUseGiftCode: (NSNotification *)noti {
    [self removeObserverForNotification:noti];
    [cartViewController stopLoadingData];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    if(responder.status == SUCCESS) {
        [self showGiftCardMessageOnCart];
        NSDictionary *giftCardData = [[SimiGlobalVar sharedInstance].cart.data valueForKey:@"gift_card"];;
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
        [cartViewController changeCartData:noti];
    }else {
        [cartViewController showAlertWithTitle:@"" message:responder.message];
    }
}

- (void)changeUsingGiftCode: (BOOL)usingGiftCode {
    [[SimiGlobalVar sharedInstance].cart useGiftCodeWithParams:@{@"giftvoucher":usingGiftCode?@"1":@"0"}];
    [cartViewController startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeUsingGiftCode:) name:DidUseGiftCodeOnCart object:nil];
}

- (void)changeUsingGiftCardCredit: (BOOL)usingGiftCardCredit {
    [[SimiGlobalVar sharedInstance].cart useGiftCardCreditWithParams:@{@"usecredit":usingGiftCardCredit ?@"1":@"0"}];
    [cartViewController startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeUsingGiftCardCredit:) name:DidUseGiftCardCreditOnCart object:nil];
}

- (void)didUpdateGiftCode: (NSNotification *)noti {
    [self removeObserverForNotification:noti];
    [cartViewController stopLoadingData];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    if(responder.status == SUCCESS) {
        [self showGiftCardMessageOnCart];
        NSDictionary *giftCardData = [[SimiGlobalVar sharedInstance].cart.data valueForKey:@"gift_card"];;
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
        [cartViewController changeCartData:noti];
    }else {
        [cartViewController showAlertWithTitle:@"" message:responder.message];
    }
}

- (void)didChangeUsingGiftCode: (NSNotification *)noti {
    [self removeObserverForNotification:noti];
    [cartViewController stopLoadingData];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    if(responder.status == SUCCESS) {
        [self showGiftCardMessageOnCart];
        [cartViewController changeCartData:noti];
    }else {
        [cartViewController showAlertWithTitle:@"" message:responder.message];
    }
}

- (void)didChangeUsingGiftCardCredit: (NSNotification *)noti {
    [self removeObserverForNotification:noti];
    [cartViewController stopLoadingData];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    if(responder.status == SUCCESS) {
        [self showGiftCardMessageOnCart];
        [cartViewController changeCartData:noti];
    }else {
        [cartViewController showAlertWithTitle:@"" message:responder.message];
    }
}

- (void)giftCodeSelectedDelete: (UIButton *)sender {
    NSDictionary *giftCodeValue = (NSDictionary *)sender.simiObjectIdentifier;
    [[SimiGlobalVar sharedInstance].cart removeGiftCodeWithParams:@{@"giftcode":[giftCodeValue objectForKey:@"gift_code"]}];
    [cartViewController startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveGiftCode:) name:DidRemoveGiftCodeOnCart object:nil];
}

- (void)didRemoveGiftCode: (NSNotification *)noti {
    [self removeObserverForNotification:noti];
    [cartViewController stopLoadingData];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    if(responder.status == SUCCESS) {
        [self showGiftCardMessageOnCart];
        NSDictionary *giftCardData = [[SimiGlobalVar sharedInstance].cart.data valueForKey:@"gift_card"];;
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
        [cartViewController changeCartData:noti];
    }else {
        [cartViewController showAlertWithTitle:@"" message:responder.message];
    }
}

- (void)giftCodeSelectedEditing: (UIButton *)sender {
    NSDictionary *giftCodeValue = (NSDictionary *)sender.simiObjectIdentifier;
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
//        float changedAmount = [amountTextField.text floatValue];
//        if(changedAmount > amount) {
//            [cartViewController showAlertWithTitle:@"" message:@"The new amount is exceeded the available amount"];
//        }else {
            [self updateGiftCodeWithParams:@{@"giftcode":[giftCodeValue objectForKey:@"gift_code"],@"amount":amountTextField.text}];
            
//        }
    }];
    [alertController addAction:editAction];
    [cartViewController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark UIPickerViewDelegate && UIPickerViewDataSource
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSArray* listCode = [[[[SimiGlobalVar sharedInstance].cart.data valueForKey:@"gift_card"] objectForKey:@"customer"] objectForKey:@"list_code"];
    if(row == 0) {
        existingCodeTextField.text = @"";
        giftCodeSelected = @"";
        return;
    }
    if(listCode.count > 0) {
        NSDictionary *code = [listCode objectAtIndex:row - 1];
        existingCodeTextField.text = [code objectForKey:@"hidden_code"];
        giftCodeSelected = [code objectForKey:@"gift_code"];
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray* listCode = [[[[SimiGlobalVar sharedInstance].cart.data valueForKey:@"gift_card"] objectForKey:@"customer"] objectForKey:@"list_code"];
    if(listCode.count > 0) {
        return listCode.count + 1;
    }else {
        return 0;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(row == 0)
        return SCLocalizedString(@"Please select");
    NSArray* listCode = [[[[SimiGlobalVar sharedInstance].cart.data valueForKey:@"gift_card"] objectForKey:@"customer"] objectForKey:@"list_code"];
    NSDictionary *code = [listCode objectAtIndex:row - 1];
    return [NSString stringWithFormat:@"%@(%@)",[code objectForKey:@"hidden_code"], [code objectForKey:@"balance"]];
}

- (void)showGiftCardMessageOnCart {
    NSDictionary *creditCardData = [[SimiGlobalVar sharedInstance].cart.data valueForKey:@"gift_card"];
    NSDictionary *message = [creditCardData objectForKey:@"message"];
    if([message isKindOfClass:[NSDictionary class]]) {
        NSString *success = [message objectForKey:@"success"];
        if([message objectForKey:@"notice"]) {
            NSString *notice = [message objectForKey:@"notice"];
            [cartViewController showAlertWithTitle:success message:notice];
        }else {
            [cartViewController showAlertWithTitle:@"" message:success];
        }
    }
}
@end
