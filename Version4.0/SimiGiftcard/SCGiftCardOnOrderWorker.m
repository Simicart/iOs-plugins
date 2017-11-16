//
//  SCGiftCardOnOrderWorker.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 8/11/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCGiftCardOnOrderWorker.h"
#import <SimiCartBundle/SimiTable.h>
#import <SimiCartBundle/SCOrderViewControllerPad.h>
#import "SimiOrderModel+SimiGiftCard.h"

#define ORDER_VIEW_GIFTCARD_CREDIT @"ORDER_VIEW_GIFTCARD_CREDIT"
#define ORDER_VIEW_GIFTCODE @"CART_VIEW_GIFTCODE"
#define ORDER_VIEW_GIFTCARD_TITLE @"ORDER_VIEW_GIFTCARD_TITLE"

@implementation SCGiftCardOnOrderWorker {
    SimiTable *orderTable;
    SimiOrderModel *order;
    UITableView *orderTableView;
    SCOrderViewController *orderVC;
    SimiCheckbox *giftCardCreditCb, *giftCodeCb;
    SimiTextField *giftCodeTextField, *giftCardCreditTextField, *existingCodeTextField;
    NSString *giftCodeSelected;
    BOOL didGetGiftCodeConfig,didGetCreditConfig;
}
- (id)init {
    if(self == [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderViewInitCells:) name:[NSString stringWithFormat:@"%@%@",SCOrderViewController_RootEventName, SimiTableViewController_SubKey_InitCells_End] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderViewCellForRow:) name:[NSString stringWithFormat:@"%@%@",SCOrderViewController_RootEventName, SimiTableViewController_SubKey_InitializedCell_End] object:nil];
        if(PHONEDEVICE){
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderViewWillAppear:) name:@"SCOrderViewControllerViewWillAppear" object:nil];
        }else{
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderViewWillAppear:) name:@"SCOrderViewControllerPadViewWillAppear" object:nil];
        }
    }
    return self;
}

- (void)orderViewWillAppear:(NSNotification *)noti{
    didGetCreditConfig = NO;
    didGetGiftCodeConfig = NO;
}

- (void)orderViewInitCells: (NSNotification *)noti {
    orderVC = [noti.userInfo valueForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.viewcontroller];
    order = orderVC.order;
    if([order objectForKey:@"gift_card"]) {
        NSDictionary *giftCardData = [order objectForKey:@"gift_card"];
        orderTable = noti.object;
        SimiSection *totalSection = [orderTable getSectionByIdentifier:ORDER_TOTALS_SECTION];
        SimiRow *totalRow = [totalSection getRowByIdentifier:ORDER_VIEW_TOTAL];
        float sortOrder = totalRow.sortOrder - 1;
        if([[giftCardData objectForKey:@"use_giftcard"] boolValue]) {
            SimiRow *titleRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_GIFTCARD_TITLE height:44 sortOrder:sortOrder];
            [totalSection addObject:titleRow];
            NSDictionary *credit = [giftCardData objectForKey:@"credit"];
            NSDictionary *giftcode = [giftCardData objectForKey:@"giftcode"];
            NSDictionary *customer = [giftCardData objectForKey:@"customer"];
            if([customer objectForKey:@"balance"]){
                if([[credit objectForKey:@"use_credit"] boolValue]) {
                    [totalSection addRowWithIdentifier:ORDER_VIEW_GIFTCARD_CREDIT height:150 sortOrder:sortOrder];
                }else {
                    [totalSection addRowWithIdentifier:ORDER_VIEW_GIFTCARD_CREDIT height:30 sortOrder:sortOrder];
                }
            }
            if([[giftcode objectForKey:@"use_giftcode"] boolValue]) {
                [totalSection addRowWithIdentifier:ORDER_VIEW_GIFTCODE height:220 + 30*(giftcode.allValues.count - 1) sortOrder:sortOrder];
            }else {
                [totalSection addRowWithIdentifier:ORDER_VIEW_GIFTCODE height:30 sortOrder:sortOrder];
            }
        }else {
            if([giftCardData objectForKey:@"label"] && ![[giftCardData objectForKey:@"label"] isEqualToString:@""]){
                [totalSection addRowWithIdentifier:ORDER_VIEW_GIFTCARD_TITLE height:70 sortOrder:sortOrder];
            }
        }
    }
}

- (void)orderViewCellForRow:(NSNotification *)noti {
    NSIndexPath *indexPath = [noti.userInfo valueForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.indexpath];
    SimiTable *cells = noti.object;
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if([row.identifier isEqualToString:ORDER_VIEW_GIFTCODE] || [row.identifier isEqualToString:ORDER_VIEW_GIFTCARD_CREDIT] || [row.identifier isEqualToString:ORDER_VIEW_GIFTCARD_TITLE]) {
        orderVC = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.viewcontroller];
        orderTableView = orderVC.contentTableView;
        NSDictionary *giftCardData = [order objectForKey:@"gift_card"];
        NSDictionary *customerData = [giftCardData objectForKey:@"customer"];
        NSDictionary *giftCode = [giftCardData objectForKey:@"giftcode"];
        NSDictionary *credit = [giftCardData objectForKey:@"credit"];
        float paddingX = 10;
        float paddingY = 5;
        float viewWidth = orderTableView.frame.size.width - 2* paddingX;
        
        if([row.identifier isEqualToString:ORDER_VIEW_GIFTCODE]) {
            float cellY = paddingY;
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_VIEW_GIFTCODE];
            if(!giftCodeCb) {
                giftCodeCb = [[SimiCheckbox alloc] initWithTitle:[NSString stringWithFormat:@"%@",SCLocalizedString(@"Use Gift Card to check out")]];
                [giftCodeCb addTarget:self action:@selector(giftCodeCbChangedValue:) forControlEvents:UIControlEventValueChanged];
            }
            if(!didGetGiftCodeConfig){
                if([[giftCode objectForKey:@"use_giftcode"] boolValue]) {
                    giftCodeCb.checkState = M13CheckboxStateChecked;
                }else {
                    giftCodeCb.checkState = M13CheckboxStateUnchecked;
                }
                didGetGiftCodeConfig = YES;
            }
            [cell.contentView addSubview:giftCodeCb];
            giftCodeCb.frame = CGRectMake(paddingX, cellY, viewWidth, 30);
            cellY += giftCodeCb.frame.size.height + paddingY;
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
                            giftCodeLabel.text = [NSString stringWithFormat:@"%@ (%@%@)",[((NSDictionary *)giftCodeValue) objectForKey:@"hidden_code"],[customerData objectForKey:@"currency_symbol"], [((NSDictionary *)giftCodeValue) objectForKey:@"amount"]];
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
                    [cell.contentView addSubview:giftCardExistingLabel];
                    cellY += giftCardExistingLabel.frame.size.height;
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
                SimiButton *applyGiftCodeButton = [[SimiButton alloc] initWithFrame:CGRectMake(paddingX + 10, cellY, viewWidth - 2*paddingX - 20, 40) title:@"Apply Gift Code" titleFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE]];
                [applyGiftCodeButton addTarget:self action:@selector(applyGiftCode:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:applyGiftCodeButton];
                cellY += applyGiftCodeButton.frame.size.height + paddingY;
            }
            row.height = cellY + 10;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
            cell.layoutMargins = UIEdgeInsetsZero;
            orderVC.isDiscontinue = YES;
             [SimiGlobalFunction sortViewForRTL:cell.contentView andWidth:CGRectGetWidth(orderTableView.frame)];
            row.tableCell = cell;
        }else if([row.identifier isEqualToString:ORDER_VIEW_GIFTCARD_CREDIT]) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_VIEW_GIFTCARD_CREDIT];
            float cellY = 0;
            if(!giftCardCreditCb) {
                giftCardCreditCb = [[SimiCheckbox alloc] initWithTitle:[NSString stringWithFormat:@"%@(%@)",SCLocalizedString(@"Use Gift Card credit to check out"),[customerData objectForKey:@"balance"]]];
                [giftCardCreditCb addTarget:self action:@selector(giftCardCreditCbChangedValue:) forControlEvents:UIControlEventValueChanged];
            }
            if(!didGetCreditConfig){
                if([[credit objectForKey:@"use_credit"] boolValue]) {
                    giftCardCreditCb.checkState = M13CheckboxStateChecked;
                }else {
                    giftCardCreditCb.checkState = M13CheckboxStateUnchecked;
                }
                didGetCreditConfig = YES;
            }
            giftCardCreditCb.frame = CGRectMake(paddingX, cellY, viewWidth, 30);
            giftCardCreditCb.titleLabel.text = [NSString stringWithFormat:@"%@(%@)",SCLocalizedString(@"Use Gift Card credit to check out"),[customerData objectForKey:@"balance"]];
            [cell.contentView addSubview:giftCardCreditCb];
            cellY += giftCardCreditCb.frame.size.height + paddingY;
            if(giftCardCreditCb.checkState == M13CheckboxStateChecked) {
                SimiLabel *giftCardCreditLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX, cellY, viewWidth, 30)];
                giftCardCreditLabel.text = @"Enter Gift Card credit amount to pay for this order";
                giftCardCreditLabel.numberOfLines = 0;
                [giftCardCreditLabel sizeToFit];
                [cell.contentView addSubview:giftCardCreditLabel];
                cellY += giftCardCreditLabel.frame.size.height + paddingY;
                if(!giftCardCreditTextField) {
                    giftCardCreditTextField = [[SimiTextField alloc] initWithFrame:CGRectMake(paddingX, cellY, viewWidth, 40) placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE] textColor:THEME_CONTENT_COLOR];
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
                SimiButton *applyGiftCardCreditButton = [[SimiButton alloc] initWithFrame:CGRectMake(paddingX + 10, cellY, viewWidth - 2*paddingX - 20, 40) title:@"Apply Credit" titleFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE]];
                [applyGiftCardCreditButton addTarget:self action:@selector(applyGiftCardCredit:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:applyGiftCardCreditButton];
                cellY += applyGiftCardCreditButton.frame.size.height + paddingY;
            }
            row.height = cellY + 10;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
            cell.layoutMargins = UIEdgeInsetsZero;
            orderVC.isDiscontinue = YES;
             [SimiGlobalFunction sortViewForRTL:cell.contentView andWidth:CGRectGetWidth(orderTableView.frame)];
            row.tableCell = cell;
        }else if([row.identifier isEqualToString:ORDER_VIEW_GIFTCARD_TITLE]) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_VIEW_GIFTCARD_TITLE];
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
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            orderVC.isDiscontinue = YES;
            [SimiGlobalFunction sortViewForRTL:cell.contentView andWidth:CGRectGetWidth(orderTableView.frame)];
            row.tableCell = cell;
        }
        
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
    [orderTableView reloadData];
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
    [orderTableView reloadData];
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
    [order useGiftCodeWithParams:params];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUseGiftCode:) name:DidUseGiftCodeOnOrder object:nil];
    [orderVC startLoadingData];
}

- (void)applyGiftCardCredit: (SimiButton *)button {
    NSMutableDictionary *params = [NSMutableDictionary new];
    if([giftCardCreditTextField.text floatValue] > 0) {
        [params addEntriesFromDictionary:@{@"usecredit":@"1",@"credit_amount":giftCardCreditTextField.text}];
    }else {
        [params addEntriesFromDictionary:@{@"usecredit":@"0"}];
    }
    [order useGiftCardCreditWithParams:params];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUseGiftCardCredit:) name:DidUseGiftCardCreditOnOrder object:nil];
    [orderVC startLoadingData];
    
}

- (void)updateGiftCodeWithParams: (NSDictionary *)params {
    [order updateGiftCodeWithParams:params];
    [orderVC startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateGiftCode:) name:DidUpdateGiftCodeOnOrder object:nil];
}

- (void)didUseGiftCardCredit: (NSNotification *)noti {
    [self removeObserverForNotification:noti];
    [orderVC stopLoadingData];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    if(responder.status == SUCCESS) {
        [self showGiftCardMessageOnOrder];
        NSDictionary *giftCardData = [order objectForKey:@"gift_card"];
        NSDictionary *credit = [giftCardData objectForKey:@"credit"];
        SimiSection *cartTotalSection = [orderTable getSectionByIdentifier:ORDER_TOTALS_SECTION];
        SimiRow *giftCardCreditRow = [cartTotalSection getRowByIdentifier:ORDER_VIEW_GIFTCARD_CREDIT];
        if([[credit objectForKey:@"use_credit"] boolValue]) {
            giftCardCreditCb.checkState = M13CheckboxStateChecked;
            giftCardCreditRow.height = 150;
        }else {
            giftCardCreditCb.checkState = M13CheckboxStateUnchecked;
            giftCardCreditRow.height = 30;
        }
        [orderVC didGetOrderConfig:noti];
    }else {
       [orderVC showAlertWithTitle:@"" message:responder.message];
    }
}

- (void)didUseGiftCode: (NSNotification *)noti {
    [self removeObserverForNotification:noti];
    [orderVC stopLoadingData];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    if(responder.status == SUCCESS) {
        [self showGiftCardMessageOnOrder];
        NSDictionary *giftCardData = [order objectForKey:@"gift_card"];
        NSDictionary *giftCode = [giftCardData objectForKey:@"giftcode"];
        SimiSection *cartTotalSection = [orderTable getSectionByIdentifier:ORDER_TOTALS_SECTION];
        SimiRow *giftCardRow = [cartTotalSection getRowByIdentifier:ORDER_VIEW_GIFTCODE];
        if([[giftCode objectForKey:@"use_giftcode"] boolValue]) {
            giftCardRow.height = 220 + 30*(giftCode.allValues.count - 1);
            giftCodeCb.checkState = M13CheckboxStateChecked;
        }else {
            giftCardRow.height = 30;
            giftCodeCb.checkState = M13CheckboxStateUnchecked;
        }
        [orderVC didGetOrderConfig:noti];
    }else {
       [orderVC showAlertWithTitle:@"" message:responder.message];
    }
}

- (void)changeUsingGiftCode: (BOOL)usingGiftCode {
    [order useGiftCodeWithParams:@{@"giftvoucher":usingGiftCode?@"1":@"0"}];
    [orderVC startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeUsingGiftCode:) name:DidUseGiftCodeOnOrder object:nil];
}

- (void)changeUsingGiftCardCredit: (BOOL)usingGiftCardCredit {
    [order useGiftCardCreditWithParams:@{@"usecredit":usingGiftCardCredit?@"1":@"0"}];
    [orderVC startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeUsingGiftCardCredit:) name:DidUseGiftCardCreditOnOrder object:nil];
}

- (void)didUpdateGiftCode: (NSNotification *)noti {
    [self removeObserverForNotification:noti];
    [orderVC stopLoadingData];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    if(responder.status == SUCCESS) {
        [self showGiftCardMessageOnOrder];
        NSDictionary *giftCardData = [order objectForKey:@"gift_card"];
        NSDictionary *giftCode = [giftCardData objectForKey:@"giftcode"];
        SimiSection *cartTotalSection = [orderTable getSectionByIdentifier:ORDER_TOTALS_SECTION];
        SimiRow *giftCardRow = [cartTotalSection getRowByIdentifier:ORDER_VIEW_GIFTCODE];
        if([[giftCode objectForKey:@"use_giftcode"] boolValue]) {
            giftCardRow.height = 220 + 30*(giftCode.allValues.count - 1);
            giftCodeCb.checkState = M13CheckboxStateChecked;
        }else {
            giftCardRow.height = 30;
            giftCodeCb.checkState = M13CheckboxStateUnchecked;
        }
        [orderVC didGetOrderConfig:noti];
    }else {
        [orderVC showAlertWithTitle:@"" message:responder.message];
    }
}

- (void)didChangeUsingGiftCode: (NSNotification *)noti {
    [self removeObserverForNotification:noti];
    [orderVC stopLoadingData];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    if(responder.status == SUCCESS) {
        [orderVC didGetOrderConfig:noti];
        [self showGiftCardMessageOnOrder];
    }else {
        [orderVC showAlertWithTitle:@"" message:responder.message];
    }
}

- (void)didChangeUsingGiftCardCredit: (NSNotification *)noti {
    [self removeObserverForNotification:noti];
    [orderVC stopLoadingData];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    if(responder.status == SUCCESS) {
        [self showGiftCardMessageOnOrder];
        [orderVC didGetOrderConfig:noti];
    }else {
        [orderVC showAlertWithTitle:@"" message:responder.message];
    }
}

- (void)giftCodeSelectedDelete: (UIButton *)sender {
    NSDictionary *giftCodeValue = (NSDictionary *)sender.simiObjectIdentifier;
    [order removeGiftCodeWithParams:@{@"giftcode":[giftCodeValue objectForKey:@"gift_code"]}];
    [orderVC startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveGiftCode:) name:DidRemoveGiftCodeOnOrder object:nil];
}

- (void)didRemoveGiftCode: (NSNotification *)noti {
    [self removeObserverForNotification:noti];
    [orderVC stopLoadingData];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    if(responder.status == SUCCESS) {
        [self showGiftCardMessageOnOrder];
        NSDictionary *giftCardData = [order objectForKey:@"gift_card"];
        NSDictionary *giftCode = [giftCardData objectForKey:@"giftcode"];
        SimiSection *cartTotalSection = [orderTable getSectionByIdentifier:ORDER_TOTALS_SECTION];
        SimiRow *giftCardRow = [cartTotalSection getRowByIdentifier:ORDER_VIEW_GIFTCODE];
        if([[giftCode objectForKey:@"use_giftcode"] boolValue]) {
            giftCardRow.height = 220 + 30*(giftCode.allValues.count - 1);
            giftCodeCb.checkState = M13CheckboxStateChecked;
        }else {
            giftCardRow.height = 30;
            giftCodeCb.checkState = M13CheckboxStateUnchecked;
        }
        [orderVC didGetOrderConfig:noti];
    }else {
        [orderVC showAlertWithTitle:@"" message:responder.message];
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
//            [orderVC showAlertWithTitle:@"" message:@"The new amount is exceeded the available amount"];
//        }else {
        [self updateGiftCodeWithParams:@{@"giftcode":[giftCodeValue objectForKey:@"gift_code"],@"amount":amountTextField.text}];
            
//        }
    }];
    [alertController addAction:editAction];
    [orderVC presentViewController:alertController animated:YES completion:nil];
}

#pragma mark UIPickerViewDelegate && UIPickerViewDataSource
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSArray* listCode = [[[order objectForKey:@"gift_card"] objectForKey:@"customer"] objectForKey:@"list_code"];
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
    NSArray* listCode = [[[order objectForKey:@"gift_card"] objectForKey:@"customer"] objectForKey:@"list_code"];
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
    if(row == 0) {
        return SCLocalizedString(@"Please select");
    }
    NSArray* listCode = [[[order objectForKey:@"gift_card"] objectForKey:@"customer"] objectForKey:@"list_code"];
    NSDictionary *code = [listCode objectAtIndex:row - 1];
    return [NSString stringWithFormat:@"%@(%@)",[code objectForKey:@"hidden_code"], [code objectForKey:@"balance"]];
}

- (void)showGiftCardMessageOnOrder {
    NSDictionary *creditCardData = [order objectForKey:@"gift_card"];
    NSDictionary *message = [creditCardData objectForKey:@"message"];
    if([message isKindOfClass:[NSDictionary class]]) {
        NSString *success = [message objectForKey:@"success"];
        if([message objectForKey:@"notice"]) {
            NSString *notice = [message objectForKey:@"notice"];
            [orderVC showAlertWithTitle:success message:notice];
        }else {
            [orderVC showAlertWithTitle:@"" message:success];
        }
    }
}

@end
