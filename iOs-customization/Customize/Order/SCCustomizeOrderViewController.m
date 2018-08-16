//
//  SCCustomizeOrderViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 2/4/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCCustomizeOrderViewController.h"
#import <SimiCartBundle/SimiTextView.h>

@interface SCCustomizeOrderViewController ()

@end

@implementation SCCustomizeOrderViewController{
    SimiLabel *purchasOrderLabel;
    SimiTextField *purchaseOrderTextField;
    float purchaseOrderHeight;
    SimiTextField *selectTF, *nameTF, *numberTF, *monthTF, *yearTF, *cvvTF;
    SimiLabel *nameLabel, *numberLabel, *dateLabel, *cvvLabel;
    UIPickerView *cardPicker, *monthPicker, *yearPicker;
    SimiCheckbox *saveCb;
    UIButton *editButton;
    NSArray *listCards, *cardTypes;
    NSDictionary *selectedCard, *selectedMonth, *selectedYear;;
    BOOL isEdittingCard;
    UIView *cardView;
    NSDate *selectedDate;
    NSArray *months;
    NSMutableArray *years;
    SimiTextView *commentTextView;
}
- (void)viewDidLoadBefore{
    [super viewDidLoadBefore];
    months = @[@{@"label":@"01 - January",@"value":@"1"},@{@"label":@"02 - February",@"value":@"2"},@{@"label":@"03 - March",@"value":@"3"},@{@"label":@"04 - April",@"value":@"4"},@{@"label":@"05 - May",@"value":@"5"},@{@"label":@"06 - June",@"value":@"6"},@{@"label":@"07 - July",@"value":@"7"},@{@"label":@"08 - August",@"value":@"8"},@{@"label":@"09 - September",@"value":@"9"},@{@"label":@"10 - October",@"value":@"10"},@{@"label":@"11 - November",@"value":@"11"},@{@"label":@"12 - December",@"value":@"12"}];
    NSDate *date = [NSDate new];
    NSDateFormatter *formater = [NSDateFormatter new];
    formater.dateFormat = @"yyyy";
    int currentDate = [[formater stringFromDate:date] intValue];
    years = [NSMutableArray new];
    for(int i = 0; i<11;i++){
        int year = currentDate + i;
        NSString *yearString = [NSString stringWithFormat:@"%d",year];
        [years addObject:@{@"label":yearString,@"value":yearString}];
    }
}
- (void)didGetOrderConfig:(NSNotification *)noti{
    [super didGetOrderConfig:noti];
}

- (void)createCells{
    [super createCells];
    SimiSection *totalSection = [self.cells getSectionByIdentifier:ORDER_TOTALS_SECTION];
    if(totalSection){
        SimiSection *comment = [self.cells addSectionWithIdentifier:ORDER_COMMENT sortOrder:totalSection.sortOrder - 1];
        [comment addRowWithIdentifier:ORDER_COMMENT height:180];
    }
}
- (UITableViewCell *)contentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if([row.identifier isEqualToString:ORDER_COMMENT]){
        SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
        if(!cell){
            cell = [[SimiTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
            float paddingX = 15;
            float cellWidth = CGRectGetWidth(self.contentTableView.frame) - 2*paddingX;
            float cellY = 5;
            SimiLabel *titleLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX, cellY, cellWidth, 25) andFontName:THEME_FONT_NAME_REGULAR andFontSize:THEME_FONT_SIZE andTextColor:THEME_CONTENT_COLOR text:@"Order Notes & Special Delivery Instructions"];
            [titleLabel resizLabelToFit];
            [cell.contentView addSubview:titleLabel];
            cellY += titleLabel.labelHeight + 5;
            commentTextView = [[SimiTextView alloc] initWithFrame:CGRectMake(paddingX, cellY, cellWidth, 150) font:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE] borderWidth:1 borderColor:THEME_CONTENT_COLOR leftTitle:nil rightTitle:@"Done"];
            [cell.contentView addSubview:commentTextView];
            cellY += commentTextView.frame.size.height;
            cell.heightCell = cellY + 5;
        }
        row.height = cell.heightCell;
        return cell;
    }else{
        return [super contentTableViewCellForRowAtIndexPath:indexPath];
    }
}
- (SCOrderMethodCell*)createPaymentMethodCellWithIndex:(NSIndexPath*)indexPath tableView:(UITableView*)tableView cells:(SimiTable*)cells{
    SCOrderMethodCell *cell = [super createPaymentMethodCellWithIndex:indexPath tableView:tableView cells:cells];
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    SimiPaymentMethodModel *payment = (SimiPaymentMethodModel*)row.model;
    if([payment.code isEqualToString:@"PURCHASEORDER"]){
        if(!purchasOrderLabel){
            purchasOrderLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(15,cell.heightCell, CGRectGetWidth(tableView.frame) - 30, 25)];
            purchasOrderLabel.text = @"Purchase Order Number";
            [cell.contentView addSubview:purchasOrderLabel];
            cell.heightCell += 25;
            purchaseOrderTextField = [[SimiTextField alloc] initWithFrame:CGRectMake(15, cell.heightCell, CGRectGetWidth(tableView.frame) - 30, 40) placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE] textColor:THEME_CONTENT_COLOR backgroundColor:COLOR_WITH_HEX(@"#c8c8c8") borderWidth:0 borderColor:nil paddingLeft:5];
            [self addAccessoryInputViewForTextField:purchaseOrderTextField];
            [cell.contentView addSubview:purchaseOrderTextField];
            cell.heightCell += 40;
            purchasOrderLabel.hidden = YES;
            purchaseOrderTextField.hidden = YES;
            purchaseOrderHeight = cell.heightCell += 5;
        }
        if(payment.isSelected){
            purchasOrderLabel.hidden = NO;
            purchaseOrderTextField.hidden = NO;
            row.height = purchaseOrderHeight;
        }else{
            purchaseOrderTextField.hidden = YES;
            purchasOrderLabel.hidden = YES;
        }
    }else if([payment.code isEqualToString:@"EWAYRAPID_EWAYONE"]){
        NSString *defaultToken = [NSString stringWithFormat:@"%@",[[payment objectForKey:@"token_list"] objectForKey:@"default_token"]];
        listCards = [[payment objectForKey:@"token_list"] objectForKey:@"cards_list"];
        cardTypes = [payment objectForKey:@"cc_types"];
        if(!cardView){
            cardView = [[UIView alloc]init];
            selectTF = [[SimiTextField alloc] initWithFrame:CGRectZero placeHolder:@"Please select" font:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE] textColor:THEME_CONTENT_COLOR backgroundColor:[UIColor whiteColor] borderWidth:1 borderColor:[UIColor lightGrayColor] paddingLeft:5];
            UIButton *rightView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            [rightView setImage:[[UIImage imageNamed:@"ic_narrow_down"] imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
            [rightView setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            rightView.userInteractionEnabled = NO;
            selectTF.rightView = rightView;
            selectTF.rightViewMode = UITextFieldViewModeAlways;
            [self addAccessoryInputViewForTextField:selectTF];
            [cardView addSubview:selectTF];
            cardPicker = [UIPickerView new];
            cardPicker.delegate = self;
            cardPicker.dataSource = self;
            selectTF.inputView = cardPicker;
            if(listCards.count){
                selectedCard = [listCards objectAtIndex:0];
                if(defaultToken && ![defaultToken isEqualToString:@""] && ![defaultToken isEqual:[NSNull null]]){
                    for(NSDictionary *creditCard in listCards){
                        if([[NSString stringWithFormat:@"%@",[creditCard objectForKey:@"id"]] isEqualToString:defaultToken]){
                            selectedCard = creditCard;
                            [cardPicker selectRow:[listCards indexOfObject:creditCard] inComponent:0 animated:NO];
                            break;
                        }
                    }
                }
            }
            editButton = [UIButton new];
            [editButton setTitle:@"Edit" forState:UIControlStateNormal];
            [editButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            editButton.titleLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE];
            [editButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [editButton addTarget:self action:@selector(editCard:) forControlEvents:UIControlEventTouchUpInside];
            [cardView addSubview:editButton];
            nameLabel = [SimiLabel new];
            nameLabel.text = @"Name on Card";
            [cardView addSubview:nameLabel];
            nameTF = [[SimiTextField alloc] initWithFrame:CGRectZero placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE] textColor:THEME_CONTENT_COLOR backgroundColor:[UIColor whiteColor] borderWidth:1 borderColor:[UIColor lightGrayColor] paddingLeft:5];
            [cardView addSubview:nameTF];
            [self addAccessoryInputViewForTextField:nameTF];
            numberLabel = [SimiLabel new];
            numberLabel.text = @"Credit Card Number";
            [cardView addSubview:numberLabel];
            numberTF = [[SimiTextField alloc] initWithFrame:CGRectZero placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE] textColor:THEME_CONTENT_COLOR backgroundColor:[UIColor whiteColor] borderWidth:1 borderColor:[UIColor lightGrayColor] paddingLeft:5];
            [self addAccessoryInputViewForTextField:numberTF];
            numberTF.keyboardType = UIKeyboardTypeNumberPad;
            [cardView addSubview:numberTF];
            dateLabel = [SimiLabel new];
            dateLabel.text = @"Expiration Date";
            [cardView addSubview:dateLabel];
            monthTF = [[SimiTextField alloc] initWithFrame:CGRectZero placeHolder:@"Month" font:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE] textColor:THEME_CONTENT_COLOR backgroundColor:[UIColor whiteColor] borderWidth:1 borderColor:[UIColor lightGrayColor] paddingLeft:5];
            UIButton *rightView1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            [rightView1 setImage:[[UIImage imageNamed:@"ic_narrow_down"] imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
            [rightView1 setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            rightView1.userInteractionEnabled = NO;
            monthTF.rightView = rightView1;
            monthTF.rightViewMode = UITextFieldViewModeAlways;
            
            monthPicker = [UIPickerView new];
            monthPicker.delegate = self;
            monthPicker.dataSource = self;
            monthTF.inputView = monthPicker;
            [self addAccessoryInputViewForTextField:monthTF];
            yearTF = [[SimiTextField alloc] initWithFrame:CGRectZero placeHolder:@"Year" font:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE] textColor:THEME_CONTENT_COLOR backgroundColor:[UIColor whiteColor] borderWidth:1 borderColor:[UIColor lightGrayColor] paddingLeft:5];
            UIButton *rightView2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            [rightView2 setImage:[[UIImage imageNamed:@"ic_narrow_down"] imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
            [rightView2 setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            rightView2.userInteractionEnabled = NO;
            yearTF.rightView = rightView2;
            yearTF.rightViewMode = UITextFieldViewModeAlways;
            yearPicker = [UIPickerView new];
            yearPicker.delegate = self;
            yearPicker.dataSource = self;
            yearTF.inputView = yearPicker;
            [self addAccessoryInputViewForTextField:yearTF];
            [cardView addSubview:monthTF];
            [cardView addSubview:yearTF];
            cvvLabel = [SimiLabel new];
            cvvLabel.text = @"Card Verification Number";
            [cardView addSubview:cvvLabel];
            cvvTF = [[SimiTextField alloc] initWithFrame:CGRectZero placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE] textColor:THEME_CONTENT_COLOR backgroundColor:[UIColor whiteColor] borderWidth:1 borderColor:[UIColor lightGrayColor] paddingLeft:5];
            [self addAccessoryInputViewForTextField:cvvTF];
            cvvTF.keyboardType = UIKeyboardTypeNumberPad;
            [cardView addSubview:cvvTF];
            saveCb = [[SimiCheckbox alloc] initWithFrame:CGRectZero title:@"Save my details" checkHeight:20];
            [cardView addSubview:saveCb];
            [cell.contentView addSubview:cardView];
        }
        float paddingX = 15;
        float contentWidth = CGRectGetWidth(tableView.frame) - 2*paddingX;
        float cellY = 0;
        if(selectedCard){
            selectTF.frame = CGRectMake(paddingX, cellY, contentWidth - 105, 40);
            selectTF.text = [selectedCard objectForKey:@"Card"];
            editButton.frame = CGRectMake(paddingX + contentWidth - 100, cellY, 100, 40);
            editButton.hidden = NO;
            cellY += 40;
            nameLabel.hidden = YES;
            nameTF.hidden = YES;
            numberLabel.hidden = YES;
            numberTF.hidden = YES;
            monthTF.hidden = YES;
            yearTF.hidden = YES;
            dateLabel.hidden = YES;
            saveCb.hidden = YES;
            nameTF.text = [selectedCard objectForKey:@"Owner"];
            numberTF.text = [selectedCard objectForKey:@"Card"];
            monthTF.text = [selectedCard objectForKey:@"ExpMonth"];
            for(NSDictionary *month in months){
                if([[month objectForKey:@"value"] isEqualToString:[selectedCard objectForKey:@"ExpMonth"]]){
                    selectedMonth = month;
                    monthTF.text = [month objectForKey:@"label"];
                    [monthPicker selectRow:[months indexOfObject:month] inComponent:0 animated:NO];
                    break;
                }
            }
            for(NSDictionary *year in years){
                if([[year objectForKey:@"value"] isEqualToString:[selectedCard objectForKey:@"ExpYear"]]){
                    selectedYear = year;
                    yearTF.text = [year objectForKey:@"label"];
                    [yearPicker selectRow:[years indexOfObject:year] inComponent:0 animated:NO];
                    break;
                }
            }
            if(isEdittingCard){
                nameLabel.frame = CGRectMake(paddingX, cellY, contentWidth, 25);
                nameLabel.hidden = NO;
                cellY += 25;
                nameTF.frame = CGRectMake(paddingX, cellY, contentWidth, 40);
                nameTF.hidden = NO;
                cellY += 40;
                numberLabel.frame = CGRectMake(paddingX, cellY, contentWidth, 25);
                numberLabel.hidden = NO;
                cellY += 25;
                numberTF.frame = CGRectMake(paddingX, cellY, contentWidth, 40);
                numberTF.userInteractionEnabled = NO;
                numberTF.hidden = NO;
                cellY += 40;
                dateLabel.frame = CGRectMake(paddingX, cellY, contentWidth, 25);
                dateLabel.hidden = NO;
                cellY += 25;
                monthTF.frame = CGRectMake(paddingX, cellY, 2* contentWidth /3 - 5, 40);
                monthTF.hidden = NO;
                yearTF.frame = CGRectMake(paddingX + 2* contentWidth /3, cellY, contentWidth /3, 40);
                yearTF.hidden = NO;
                cellY += 40;
                [editButton setTitle:SCLocalizedString(@"Cancel Edit") forState:UIControlStateNormal];
            }else{
                [editButton setTitle:SCLocalizedString(@"Edit") forState:UIControlStateNormal];
            }
            cvvLabel.frame = CGRectMake(paddingX, cellY, contentWidth, 30);
            cellY += 30;
            cvvTF.frame = CGRectMake(paddingX, cellY, contentWidth, 40);
            cellY +=40;
            if(isEdittingCard){
                saveCb.frame = CGRectMake(paddingX, cellY, contentWidth, 30);
                saveCb.hidden = NO;
                cellY += 30;
            }
        }else{
            selectTF.frame = CGRectMake(paddingX, cellY, contentWidth, 40);
            editButton.hidden = YES;
            cellY += 40;
            nameLabel.frame = CGRectMake(paddingX, cellY, contentWidth, 25);
            nameLabel.hidden = NO;
            cellY += 25;
            nameTF.frame = CGRectMake(paddingX, cellY, contentWidth, 40);
            nameTF.hidden = NO;
            cellY += 40;
            numberLabel.frame = CGRectMake(paddingX, cellY, contentWidth, 25);
            numberTF.userInteractionEnabled = YES;
            numberLabel.hidden = NO;
            cellY += 25;
            numberTF.frame = CGRectMake(paddingX, cellY, contentWidth, 40);
            numberTF.hidden = NO;
            cellY += 40;
            dateLabel.frame = CGRectMake(paddingX, cellY, contentWidth, 25);
            dateLabel.hidden = NO;
            cellY += 25;
            monthTF.frame = CGRectMake(paddingX, cellY, 2* contentWidth /3 - 5, 40);
            monthTF.hidden = NO;
            yearTF.frame = CGRectMake(paddingX + 2* contentWidth /3, cellY, contentWidth /3, 40);
            yearTF.hidden = NO;
            cellY += 40;
            cvvLabel.frame = CGRectMake(paddingX, cellY, contentWidth, 30);
            cellY += 30;
            cvvTF.frame = CGRectMake(paddingX, cellY, contentWidth, 40);
            cellY +=40;
            saveCb.frame = CGRectMake(paddingX, cellY, contentWidth, 30);
            saveCb.hidden = NO;
            cellY += 30;
        }
        cardView.frame = CGRectMake(0, cell.heightCell, CGRectGetWidth(tableView.frame), cellY);
        if(payment.isSelected){
            row.height = cell.heightCell + cellY + 5;
            cardView.hidden = NO;
        }else{
            row.height = cell.heightCell;
            cardView.hidden = YES;
        }
    }
    return cell;
}

- (void)didSelectPaymentCellWithIndex:(NSIndexPath*)indexPath{
    SimiSection *simiSection = [self.cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    selectingPaymentModel = (SimiPaymentMethodModel *)simiRow.model;
    [self savePaymentMethod:selectingPaymentModel];
    [self.contentTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)editCard:(id)sender{
    if(!isEdittingCard){
        isEdittingCard = YES;
    }else{
        isEdittingCard = NO;
    }
    [self.contentTableView reloadData];
}
#pragma mark Place Order
- (void)placeOrder{
    [self trackingWithProperties:@{@"action":@"clicked_place_order_button"}];
    if (selectedPaymentModel != nil && ((selectedShippingMedthodModel != nil && self.order.shippingMethods.count > 0) || self.order.shippingMethods == nil || self.order.shippingMethods.count == 0)) {
        canPlaceOrder = YES;
        if ([termAndConditions count]) {
            canPlaceOrder = NO;
            for (NSDictionary *term in termAndConditions) {
                if (![[term objectForKey:@"checked"] boolValue]) {
                    // Scroll to term and condition
                    [self.contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([self.contentTableView numberOfRowsInSection:[self.cells getSectionIndexByIdentifier:ORDER_TOTALS_SECTION]] - 1) inSection:[self.cells getSectionIndexByIdentifier:ORDER_TOTALS_SECTION]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    [self.contentTableView deselectRowAtIndexPath:[self.contentTableView indexPathForSelectedRow] animated:YES];
                    // Show alert
                    [self showAlertWithTitle:@"" message:@"Please agree to all the terms and conditions before placing the order"];
                    return;
                }
            }
            canPlaceOrder = YES;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlaceOrder:) name:Simi_DidPlaceOrder object:self.order];
        NSMutableDictionary *placeOrderParams = [NSMutableDictionary new];
        if([selectedPaymentModel.code isEqualToString:@"PURCHASEORDER"]){
            if(![[purchaseOrderTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]){
                [placeOrderParams addEntriesFromDictionary:@{@"po_number":purchaseOrderTextField.text}];
            }
        }else if([selectedPaymentModel.code isEqualToString:@"EWAYRAPID_EWAYONE"]){
            NSMutableDictionary *ewayParams = [NSMutableDictionary new];
            [ewayParams setValue:@"EWAYRAPID_EWAYONE" forKey:@"method"];
            if(!selectedCard){
                [ewayParams setValue:@"new" forKey:@"saved_token"];
            }else{
                [ewayParams setValue:[selectedCard objectForKey:@"id"] forKey:@"saved_token"];
            }
            [ewayParams setValue:nameTF.text forKey:@"cc_owner"];
            [ewayParams setValue:numberTF.text forKey:@"cc_number"];
            [ewayParams setValue:[selectedCard objectForKey:@"Type"] forKey:@"cc_type"];
            [ewayParams setValue:[selectedMonth objectForKey:@"value"] forKey:@"cc_exp_month"];
            [ewayParams setValue:[selectedYear objectForKey:@"value"] forKey:@"cc_exp_year"];
            [ewayParams setValue:cvvTF.text forKey:@"cc_cid"];
            [ewayParams setValue:saveCb.checkState == M13CheckboxStateChecked?@"1":@"0" forKey:@"save_card"];
            [placeOrderParams setObject:ewayParams forKey:@"p_method"];
        }
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        if(![commentTextView.text isEqualToString:@""]){
            [placeOrderParams setObject:commentTextView.text forKey:@"comments"];
        }
        [self.order placeOrderWithParams:placeOrderParams];
        [self startLoadingData];
        return;
    }
    [super placeOrder];
}
#pragma mark UIPickerViewDataSource and Delegate
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(pickerView == cardPicker){
        return listCards.count + 1;
    }else if(pickerView == monthPicker){
        return months.count;
    }else {
        return years.count;
    }
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if(pickerView == cardPicker){
        if(row == listCards.count){
            return SCLocalizedString(@"Use a new card");
        }
        NSDictionary *card = [listCards objectAtIndex:row];
        return [card objectForKey:@"Card"];
    }else if(pickerView == monthPicker){
        NSDictionary *month = [months objectAtIndex:row];
        return [month objectForKey:@"label"];
    }else{
        NSDictionary *year = [years objectAtIndex:row];
        return [year objectForKey:@"label"];
    }
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if(pickerView == cardPicker){
        selectTF.text = [self pickerView:pickerView titleForRow:row forComponent:component];
        if(row == listCards.count){
            selectedCard = nil;
            isEdittingCard = NO;
            nameTF.text = @"";
            numberTF.text = @"";
            monthTF.text = @"";
            [monthPicker selectRow:0 inComponent:0 animated:NO];
            yearTF.text = @"";
            [yearPicker selectRow:0 inComponent:0 animated:NO];
            cvvTF.text = @"";
            saveCb.checkState = M13CheckboxStateUnchecked;
        }else{
            selectedCard = [listCards objectAtIndex:row];
        }
    }else if(pickerView == monthPicker){
        selectedMonth = [months objectAtIndex:row];
        monthTF.text = [selectedMonth objectForKey:@"label"];
    }else if(pickerView == yearPicker){
        selectedYear = [years objectAtIndex:row];
        yearTF.text = [selectedYear objectForKey:@"label"];
    }
}
- (void)addAccessoryInputViewForTextField:(UITextField *)textField{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditting:)];
    doneButton.simiObjectIdentifier = textField;
    toolbar.items = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],doneButton];
    textField.inputAccessoryView = toolbar;
}
- (void)doneEditting:(UIBarButtonItem *)sender{
    [self.view endEditing:YES];
    UITextField *textField = (UITextField *)sender.simiObjectIdentifier;
    if(textField == selectTF){
        [self.contentTableView reloadData];
    }
}
@end
