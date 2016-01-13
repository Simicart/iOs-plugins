//
//  ZThemeProductOptionViewController.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 6/2/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeProductOptionViewController.h"
#import <SimiCartBundle/SimiFormatter.h>
@interface ZThemeProductOptionViewController ()

@end
static NSString *IsSelected = @"is_selected";
static NSString *IsAvaiable = @"is_available";
static NSString *isHighLight = @"is_highlight";

@implementation ZThemeProductOptionViewController
{
    BOOL isShowKeyBoard;
    BOOL isHideKeyBoard;
}
@synthesize tableViewOption, cells, allKeys, optionDict;
#pragma mark Init
- (void)viewDidLoadAfter
{
    CGRect frame = self.view.frame;
    frame.origin.y += 60;
    frame.size.height -= 60;
    self.widthTable = 300;
    tableViewOption = [[SimiTableView alloc]initWithFrame:frame style:UITableViewStyleGrouped];
    tableViewOption.dataSource = self;
    tableViewOption.delegate = self;
    tableViewOption.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableViewOption];
    
    self.buttonDone = [[UIButton alloc]initWithFrame:CGRectMake(self.widthTable - 90, 10, 80, 30)];
    [self.buttonDone addTarget:self action:@selector(didTouchDone:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonDone setTitle:SCLocalizedString(@"Done") forState:UIControlStateNormal];
    [self.buttonDone setTitleColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#ba2027"] forState:UIControlStateNormal];
    [self.buttonDone.titleLabel setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:15]];
    [self.view addSubview:self.buttonDone];
    
    self.buttonCancel = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 80, 30)];
    [self.buttonCancel addTarget:self action:@selector(didTouchCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonCancel setTitle:SCLocalizedString(@"Cancel") forState:UIControlStateNormal];
    [self.buttonCancel setTitleColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#ba2027"] forState:UIControlStateNormal];
    [self.buttonCancel.titleLabel setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:15]];
    [self.view addSubview:self.buttonCancel];
    self.preferredContentSize = CGSizeMake(320, 500);
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    [self setCells:nil];
}

- (void)setCells:(SimiTable *)cells_
{
    if (self.selectedOptionPrice == nil) {
        self.selectedOptionPrice = [[NSMutableDictionary alloc] init];
    }
    for (NSString *tempKey in self.allKeys) {
        CGFloat optionPrice = 0;
        CGFloat optionPriceInclTax = 0;
        BOOL isSelected = NO;
        for (NSDictionary *opt in [self.optionDict valueForKey:tempKey]) {
            if ([[opt valueForKey:@"is_selected"] boolValue]) {
                if (self.product.productType == ProductTypeGrouped) {
                    optionPrice += [[opt valueForKey:@"option_price"] floatValue] * [[opt valueForKey:@"option_qty"] floatValue];
                    if([opt valueForKey:@"option_price_incl_tax"]){
                        optionPriceInclTax += [[opt valueForKey:@"option_price_incl_tax"] floatValue] * [[opt valueForKey:@"option_qty"] floatValue];
                    }else if([opt valueForKey:@"option_price"]){
                        optionPriceInclTax += [[opt valueForKey:@"option_price"] floatValue] * [[opt valueForKey:@"option_qty"] floatValue];
                    }
                }else{
                    CGFloat optionQty = 1.0f;
                    if ([[opt valueForKey:@"option_qty"] floatValue] > 0.01f) {
                        optionQty = [[opt valueForKey:@"option_qty"] floatValue];
                    }
                    optionPrice += optionQty * [[opt valueForKey:@"option_price"] floatValue];
                    if([opt valueForKey:@"option_price_incl_tax"]){
                        optionPriceInclTax += optionQty * [[opt valueForKey:@"option_price_incl_tax"] floatValue];
                    }else if([opt valueForKey:@"option_price"]){
                        optionPriceInclTax += optionQty * [[opt valueForKey:@"option_price"] floatValue];
                    }
                }
                isSelected = YES;
            }
        }
        if (isSelected) {
            [self.selectedOptionPrice setValue:[NSString stringWithFormat:@"%.2f", optionPrice] forKey:tempKey];
        }else{
            [self.selectedOptionPrice removeObjectForKey:tempKey];
        }
    }
    
    if (cells_ != nil) {
        cells = cells_;
    }else
    {
        cells = [SimiTable new];
        for (int i = 0; i < allKeys.count; i++) {
            ZThemeSection *section = [[ZThemeSection alloc]initWithHeaderTitle:[allKeys objectAtIndex:i] footerTitle:@""];
            section.identifier = [allKeys objectAtIndex:i];
            NSMutableArray *arrayValue = [optionDict valueForKey:section.identifier];
            section.zThemeSectionContentTypeArray = [arrayValue mutableCopy];
            for (int j = 0; j < arrayValue.count; j++) {
                NSDictionary *rowDictionary = [arrayValue objectAtIndex:j];
                NSString *rowIdentifier = @"";
                if ([rowDictionary valueForKey:@"option_value"]) {
                    rowIdentifier = [NSString stringWithFormat:@"%@_%@",section.identifier,[rowDictionary valueForKey:@"option_value"]];
                }else
                {
                    rowIdentifier = section.identifier;
                }
                ZThemeRow *row = [[ZThemeRow alloc]initWithIdentifier:rowIdentifier height:50];
                row.zThemeContentRow = [[NSMutableDictionary alloc]initWithDictionary:rowDictionary];
                if (self.product.productType == ProductTypeGrouped && [[row.zThemeContentRow valueForKey:@"option_type"] isEqualToString:@"text"]) {
                    row.height = 75 +((int)([NSString stringWithFormat:@"%@",[row.zThemeContentRow valueForKey:@"option_value"]].length/20))*15;
                }
                if ([[row.zThemeContentRow objectForKey:@"option_type"] isEqualToString:@"date"]
                    || [[row.zThemeContentRow objectForKey:@"option_type"] isEqualToString:@"date_time"]
                    || [[row.zThemeContentRow objectForKey:@"option_type"] isEqualToString:@"time"]
                    ) {
                    row.height = 162;
                }
                [section addObject:row];
            }
            [cells addObject:section];
        }
    }
    [tableViewOption reloadData];
}

#pragma mark TableView DataSource & Table View Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZThemeSection *zThemeSection = [cells objectAtIndex:indexPath.section];
    ZThemeRow *zThemeRow = (ZThemeRow *)[zThemeSection objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:zThemeRow.identifier];
#pragma mark Group Product
    if (self.product.productType == ProductTypeGrouped) {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:zThemeRow.identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            SCOptionGroupViewCell * optionViewCell = [[SCOptionGroupViewCell alloc]initWithFrame:CGRectMake(15, 0, self.widthTable - 140, zThemeRow.height)];
            
            
            UIButton *_plusButton = [[UIButton alloc] initWithFrame:CGRectMake(self.widthTable - 70, (zThemeRow.height - 38)/2, 38, 38)];
            
            [_plusButton setImage:[UIImage imageNamed:@"plus.png"] forState:UIControlStateNormal];
            _plusButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
            [_plusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_plusButton.layer setCornerRadius:14.0f];
            [_plusButton.layer setMasksToBounds:YES];
            [_plusButton setAdjustsImageWhenHighlighted:YES];
            [_plusButton setAdjustsImageWhenDisabled:YES];
            [_plusButton addTarget:self action:@selector(didSelectPlusButtonOption:) forControlEvents:UIControlEventTouchUpInside];
            _plusButton.simiObjectIdentifier = zThemeSection.identifier;
            
           
            UIButton *_minusButton = [[UIButton alloc] initWithFrame:CGRectMake(self.widthTable - 130, (zThemeRow.height - 38)/2, 38, 38)];
            [_minusButton setImage:[UIImage imageNamed:@"minus.png"] forState:UIControlStateNormal];
            _minusButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
            [_minusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _minusButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            [_minusButton.layer setCornerRadius:14.0f];
            [_minusButton.layer setMasksToBounds:YES];
            [_minusButton setAdjustsImageWhenHighlighted:YES];
            [_minusButton setAdjustsImageWhenDisabled:YES];
            [_minusButton addTarget:self action:@selector(didSelectMinusButtonOptionQty:) forControlEvents:UIControlEventTouchUpInside];
            _minusButton.simiObjectIdentifier = zThemeSection.identifier;
            
            for (UIView *subview in optionViewCell.subviews) {
                [subview removeFromSuperview];
            }
            [optionViewCell setPriceOption:zThemeRow.zThemeContentRow];
            [cell addSubview:_plusButton];
            [cell addSubview:_minusButton];
            [cell addSubview:optionViewCell];
        }
        return cell;
    }
    
#pragma mark Select Option
    if ([[zThemeRow.zThemeContentRow valueForKey:@"option_type"] isEqualToString:@"single"]) {
        if (cell == nil) {
            cell = [[ProductOptionSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:zThemeRow.identifier];
            ((ProductOptionSelectCell*)cell).isMultiSelect = NO;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [(ProductOptionSelectCell*)cell setDataForCell:zThemeRow.zThemeContentRow];
        return cell;
    }
#pragma mark Multi Select Option
    if ([[zThemeRow.zThemeContentRow valueForKey:@"option_type"] isEqualToString:@"multi"]) {
        if (cell == nil) {
            cell = [[ProductOptionSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:zThemeRow.identifier];
            ((ProductOptionSelectCell*)cell).isMultiSelect = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [(ProductOptionSelectCell*)cell setDataForCell:zThemeRow.zThemeContentRow];
        return cell;
    }
#pragma mark Text Option
    if ([[zThemeRow.zThemeContentRow valueForKey:@"option_type"] isEqualToString:@"text"]) {
        if (cell == nil) {
            cell = [[ProductOptionTextCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:zThemeRow.identifier];
            ((ProductOptionTextCell*)cell).textOption = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, self.widthTable - 10, zThemeRow.height)];
            ((ProductOptionTextCell*)cell).textOption.simiObjectIdentifier = zThemeSection.identifier;
            ((ProductOptionTextCell*)cell).textOption.delegate = self;
            ((ProductOptionTextCell*)cell).textOption.clearButtonMode = UITextFieldViewModeWhileEditing;
            [((ProductOptionTextCell*)cell).textOption addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboardInputText) name:UIKeyboardDidShowNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboardInputText) name:UIKeyboardWillHideNotification object:nil];
            [cell addSubview:((ProductOptionTextCell*)cell).textOption];
        }
        ((ProductOptionTextCell*)cell).textOption.placeholder = zThemeSection.identifier;
        ((ProductOptionTextCell*)cell).textOption.text = [zThemeRow.zThemeContentRow objectForKey:@"option_value"];
        return cell;
    }
#pragma mark Date Time Option
    if ([[zThemeRow.zThemeContentRow valueForKey:@"option_type"] isEqualToString:@"date"]||[[zThemeRow.zThemeContentRow valueForKey:@"option_type"] isEqualToString:@"date_time"]||[[zThemeRow.zThemeContentRow valueForKey:@"option_type"] isEqualToString:@"time"]) {
        if (cell == nil) {
            cell = [[ProductOptionDateTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:zThemeRow.identifier];
            ((ProductOptionDateTimeCell*)cell).datePicker = [[UIDatePicker alloc] init];
            ((ProductOptionDateTimeCell*)cell).datePicker.frame = CGRectMake(10.0f, 0.0f, 240.0f, 120.0f);
            [((ProductOptionDateTimeCell*)cell).datePicker addTarget:self action:@selector(changeDatePicker:) forControlEvents:UIControlEventValueChanged];
            ((ProductOptionDateTimeCell*)cell).datePicker.simiObjectIdentifier = zThemeSection.identifier;
            [cell addSubview:((ProductOptionDateTimeCell*)cell).datePicker];
        }
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
        if ([[zThemeRow.zThemeContentRow objectForKey:@"option_type"] isEqualToString:@"date"]) {
            ((ProductOptionDateTimeCell*)cell).datePicker.datePickerMode = UIDatePickerModeDate;
            [dateFormater setDateFormat:@"yyyy-MM-dd"];
        } else if ([[zThemeRow.zThemeContentRow objectForKey:@"option_type"] isEqualToString:@"date_time"]) {
            ((ProductOptionDateTimeCell*)cell).datePicker.datePickerMode = UIDatePickerModeDateAndTime;
            [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        } else {
            ((ProductOptionDateTimeCell*)cell).datePicker.datePickerMode = UIDatePickerModeTime;
            [dateFormater setDateFormat:@"HH:mm:ss"];
        }
        if ([zThemeRow.zThemeContentRow objectForKey:@"option_value"]) {
            ((ProductOptionDateTimeCell*)cell).datePicker.date = [dateFormater dateFromString:[zThemeRow.zThemeContentRow objectForKey:@"option_value"]];
        } else {
            ((ProductOptionDateTimeCell*)cell).datePicker.date = [NSDate date];
        }
        return cell;
    }
    
    if (cell == nil) {
        cell = [UITableViewCell new];
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return cells.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ZThemeSection *zthemeSection = [cells objectAtIndex:section];
    return zthemeSection.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *viewHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.widthTable - 20, 40)];
    [viewHeader setBackgroundColor:[[SimiGlobalVar sharedInstance]colorWithHexString:@"#ededed"]];
    
    ZThemeSection *zthemeSection = [cells objectAtIndex:section];
    ZThemeRow *zThemeRow = (ZThemeRow*)[zthemeSection objectAtIndex:0];
    UILabel *lblHeader = [UILabel new];
    [lblHeader setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:15]];
    [lblHeader setTextColor:[UIColor blackColor]];
    [lblHeader setBackgroundColor:[UIColor clearColor]];
    
    UILabel *lblPrice = [UILabel new];
    [lblPrice setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:14]];
    [lblPrice setTextColor:ZTHEME_PRICE_COLOR];
    [lblPrice setBackgroundColor:[UIColor clearColor]];
    
    NSString *stringHeaderTitle = @"";
    if (self.product.productType == ProductTypeGrouped) {
        stringHeaderTitle = [NSString stringWithFormat:@"%@ x %@", [zThemeRow.zThemeContentRow valueForKey:@"option_qty"], zthemeSection.identifier];
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            stringHeaderTitle = [NSString stringWithFormat:@"%@ x %@", zthemeSection.identifier, [zThemeRow.zThemeContentRow valueForKey:@"option_qty"]];
            [lblHeader setTextAlignment:NSTextAlignmentRight];
        }
        //  End RTL
        lblHeader.text = stringHeaderTitle;
        [lblHeader setFrame:CGRectMake(20, 0, self.widthTable - 40, 40)];
        [viewHeader addSubview:lblHeader];
    }else
    {
        if ([self.selectedOptionPrice valueForKey:zthemeSection.identifier] && ![[self.selectedOptionPrice valueForKey:zthemeSection.identifier] isEqualToString:@""]) {
            [lblHeader setFrame:CGRectMake(20, 0, self.widthTable - 100, 40)];
            lblHeader.text = zthemeSection.identifier;
            [lblPrice setFrame:CGRectMake(self.widthTable - 80, 0, 80, 40)];
            lblPrice.text = [[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:[[self.selectedOptionPrice valueForKey:zthemeSection.identifier] floatValue]]];
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                [lblHeader setFrame:CGRectMake(100, 0, self.widthTable - 120, 40)];
                [lblPrice setFrame:CGRectMake(20, 0, 80, 40)];
                [lblHeader setTextAlignment:NSTextAlignmentRight];
                [lblPrice setTextAlignment:NSTextAlignmentRight];
                
            }
            //  End RTL
            [viewHeader addSubview:lblHeader];
            [viewHeader addSubview:lblPrice];
        }else
        {
            if ([[zThemeRow.zThemeContentRow valueForKey:@"is_required"]boolValue]) {
                lblHeader.text = [NSString stringWithFormat:@"%@ (*)",zthemeSection.identifier];
                [lblHeader setFrame:CGRectMake(20, 0, self.widthTable - 40, 40)];
                //  Liam Update RTL
                if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                    lblHeader.text = [NSString stringWithFormat:@" (*) %@",zthemeSection.identifier];
                }
                //  End RTL
                [viewHeader addSubview:lblHeader];
            }else
            {
                lblHeader.text = zthemeSection.identifier;
                [lblHeader setFrame:CGRectMake(20, 0, self.widthTable - 40, 40)];
                [viewHeader addSubview:lblHeader];
            }
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                [lblHeader setTextAlignment:NSTextAlignmentRight];
            }
            //  End RTL
        }
    }
    
    return viewHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZThemeSection *zThemeSection = [cells objectAtIndex:indexPath.section];
    ZThemeRow *zThemeRow = (ZThemeRow *)[zThemeSection objectAtIndex:indexPath.row];
    
    return zThemeRow.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZThemeSection *zThemeSection = [cells objectAtIndex:indexPath.section];
    ZThemeRow *zThemeRow = (ZThemeRow *)[zThemeSection objectAtIndex:indexPath.row];
    if ([[zThemeRow.zThemeContentRow valueForKey:@"option_type"] isEqualToString:@"single"]) {
        for (int i = 0; i < zThemeSection.count; i++) {
            if (i != indexPath.row) {
                ZThemeRow *zThemeRowTemp = (ZThemeRow *)[zThemeSection objectAtIndex:i];
                [zThemeRowTemp.zThemeContentRow setObject:@"NO" forKey:IsSelected];
                [zThemeSection.zThemeSectionContentTypeArray replaceObjectAtIndex:i withObject:zThemeRowTemp.zThemeContentRow];
            }
        }
        if ([[zThemeRow.zThemeContentRow valueForKey:IsSelected]boolValue]) {
            [zThemeRow.zThemeContentRow setObject:@"NO" forKey:IsSelected];
        }else
        {
            [zThemeRow.zThemeContentRow setObject:@"YES" forKey:IsSelected];
        }
        [self activeDependenceWith:zThemeRow andKey:zThemeSection.identifier];
        [zThemeSection.zThemeSectionContentTypeArray replaceObjectAtIndex:indexPath.row withObject:zThemeRow.zThemeContentRow];
        [optionDict setValue:zThemeSection.zThemeSectionContentTypeArray forKey:zThemeSection.identifier];
        [self configSelectedOption];
        [self.tableViewOption reloadData];
    }
    
    if ([[zThemeRow.zThemeContentRow valueForKey:@"option_type"] isEqualToString:@"multi"]) {
        if ([[zThemeRow.zThemeContentRow valueForKey:IsSelected]boolValue]) {
            [zThemeRow.zThemeContentRow setObject:@"NO" forKey:IsSelected];
        }else
        {
            [zThemeRow.zThemeContentRow setObject:@"YES" forKey:IsSelected];
        }
        [self activeDependenceWith:zThemeRow andKey:zThemeSection.identifier];
        [zThemeSection.zThemeSectionContentTypeArray replaceObjectAtIndex:indexPath.row withObject:zThemeRow.zThemeContentRow];
        [optionDict setValue:zThemeSection.zThemeSectionContentTypeArray forKey:zThemeSection.identifier];
        [self configSelectedOption];
        [self.tableViewOption reloadData];
    }
}

#pragma mark Action Group
- (void)didSelectPlusButtonOption:(id)sender
{
    UIButton *button = (UIButton *)sender;
    ZThemeSection *section = nil;
    int currentSectionIndex = -1;
    for (int i = 0; i < cells.count; i++) {
        ZThemeSection *sectionTemp = [cells objectAtIndex:i];
        if ([sectionTemp.identifier isEqualToString:(NSString*)(button.simiObjectIdentifier)]) {
            section = sectionTemp;
            currentSectionIndex = i;
            break;
        }
    }
    ZThemeRow *row = (ZThemeRow*)[section objectAtIndex:0];
    if ([row.zThemeContentRow valueForKey:@"option_qty"]) {
        NSInteger count = 1;
        count += [[row.zThemeContentRow valueForKey:@"option_qty"] integerValue];
        [row.zThemeContentRow setValue:[NSString stringWithFormat:@"%ld", (long)count] forKey:@"option_qty"];
        [row.zThemeContentRow setValue:@"YES" forKey:IsSelected];
    }else{
        [row.zThemeContentRow setValue:@"0" forKey:@"option_qty"];
    }
    [section.zThemeSectionContentTypeArray replaceObjectAtIndex:0 withObject:row.zThemeContentRow];
    [optionDict setValue:section.zThemeSectionContentTypeArray forKey:section.identifier];
    if (currentSectionIndex >= 0) {
        [self.tableViewOption reloadSections:[NSIndexSet indexSetWithIndex:currentSectionIndex] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)didSelectMinusButtonOptionQty:(id)sender
{
    UIButton *button = (UIButton *)sender;
    ZThemeSection *section = nil;
    int currentSectionIndex = -1;
    for (int i = 0; i < cells.count; i++) {
        ZThemeSection *sectionTemp = [cells objectAtIndex:i];
        if ([sectionTemp.identifier isEqualToString:(NSString*)(button.simiObjectIdentifier)]) {
            section = sectionTemp;
            currentSectionIndex = i;
            break;
        }
    }
    ZThemeRow *row = (ZThemeRow*)[section objectAtIndex:0];
    if ([[row.zThemeContentRow valueForKey:@"option_qty"]intValue] > 0) {
        NSInteger count = [[row.zThemeContentRow valueForKey:@"option_qty"] integerValue];
        count -= 1;
        [row.zThemeContentRow setValue:[NSString stringWithFormat:@"%ld", (long)count] forKey:@"option_qty"];
        if (count == 0) {
            [row.zThemeContentRow setValue:@"NO" forKey:IsSelected];
        }
    }else{
        [row.zThemeContentRow setValue:@"0" forKey:@"option_qty"];
    }
    [section.zThemeSectionContentTypeArray replaceObjectAtIndex:0 withObject:row.zThemeContentRow];
    [optionDict setValue:section.zThemeSectionContentTypeArray forKey:section.identifier];
    if (currentSectionIndex >= 0) {
        [self.tableViewOption reloadSections:[NSIndexSet indexSetWithIndex:currentSectionIndex] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark UITextField Delegate
- (void)showKeyboardInputText
{
    isHideKeyBoard = NO;
    if (!isShowKeyBoard) {
        isShowKeyBoard = YES;
        CGRect frame = self.view.frame;
        frame.size.height -= 180;
        self.view.frame = frame;
    }
}

- (void)hideKeyboardInputText
{
    isShowKeyBoard = NO;
    if (!isHideKeyBoard) {
        isHideKeyBoard = YES;
        CGRect frame = self.view.frame;
        frame.size.height += 180;
        self.view.frame = frame;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    ZThemeSection *section = nil;
    int currentSectionIndex = -1;
    for (int i = 0; i < cells.count; i++) {
        ZThemeSection *sectionTemp = [cells objectAtIndex:i];
        if ([sectionTemp.identifier isEqualToString:(NSString*)(textField.simiObjectIdentifier)]) {
            section = sectionTemp;
            currentSectionIndex = i;
            break;
        }
    }
    ZThemeRow *row = (ZThemeRow*)[section objectAtIndex:0];
    NSString *text = textField.text;
    [self.selectedOptionPrice setValue:@"" forKey:section.identifier];
    if (text == nil || [text isEqualToString:@""]) {
        [row.zThemeContentRow removeObjectForKey:@"option_value"];
        [row.zThemeContentRow setValue:@"NO" forKey:@"is_selected"];
    } else {
        [row.zThemeContentRow setValue:text forKey:@"option_value"];
        [row.zThemeContentRow setValue:@"YES" forKey:@"is_selected"];
        [self.selectedOptionPrice setValue:[NSString stringWithFormat:@"%@",[row.zThemeContentRow valueForKey:@"option_price"]] forKey:section.identifier];
    }
    [section.zThemeSectionContentTypeArray replaceObjectAtIndex:0 withObject:row.zThemeContentRow];
    [optionDict setValue:section.zThemeSectionContentTypeArray forKey:section.identifier];
    if (currentSectionIndex >= 0) {
        [self.tableViewOption reloadSections:[NSIndexSet indexSetWithIndex:currentSectionIndex] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Datetime Picker Action
- (void)changeDatePicker:(UIDatePicker *)datePicker
{
    ZThemeSection *section = nil;
    int currentSectionIndex = -1;
    for (int i = 0; i < cells.count; i++) {
        ZThemeSection *sectionTemp = [cells objectAtIndex:i];
        if ([sectionTemp.identifier isEqualToString:(NSString*)(datePicker.simiObjectIdentifier)]) {
            section = sectionTemp;
            currentSectionIndex = i;
            break;
        }
    }
    ZThemeRow *row = (ZThemeRow*)[section objectAtIndex:0];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    if ([[row.zThemeContentRow objectForKey:@"option_type"] isEqualToString:@"date"]) {
        [dateFormater setDateFormat:@"yyyy-MM-dd"];
    } else if ([[row.zThemeContentRow objectForKey:@"option_type"] isEqualToString:@"date_time"]) {
        [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    } else {
        [dateFormater setDateFormat:@"HH:mm:ss"];
    }
    if ([row.zThemeContentRow objectForKey:@"option_value"] == nil) {
        // Change option value and title
        [row.zThemeContentRow setValue:@"YES" forKey:@"is_selected"];
        [self.selectedOptionPrice setValue:[NSString stringWithFormat:@"%@",[row.zThemeContentRow valueForKey:@"option_price"]] forKey:section.identifier];
    }
    [row.zThemeContentRow setValue:[dateFormater stringFromDate:datePicker.date] forKey:@"option_value"];
    [section.zThemeSectionContentTypeArray replaceObjectAtIndex:0 withObject:row.zThemeContentRow];
    [optionDict setValue:section.zThemeSectionContentTypeArray forKey:section.identifier];
    if (currentSectionIndex >= 0) {
        [self.tableViewOption reloadSections:[NSIndexSet indexSetWithIndex:currentSectionIndex] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark Done & Cancel action
- (void)didTouchDone:(id)sender
{
    [self.delegate doneButtonTouch];
}

- (void)didTouchCancel:(id)sender
{
    [self.delegate cancelButtonTouch];
}

#pragma mark Dependence_option_ids
-  (void)activeDependenceWith:(ZThemeRow*)row andKey:(NSString*)key
{
    NSMutableDictionary *option = row.zThemeContentRow;
    
    NSArray *dependenceOptionIds = [option valueForKey:@"dependence_option_ids"];
    NSMutableSet *depenceOptionSet = [NSMutableSet setWithArray:dependenceOptionIds];
    if ([[option valueForKey:IsSelected]boolValue]) {
        if (dependenceOptionIds.count > 0) {
            for (NSString *key2 in self.allKeys) {
                if (![key2 isEqualToString:key]) {
                    for (NSDictionary *opt in [self.optionDict valueForKey:key2]) {
                        NSMutableSet *tempSet = [NSMutableSet setWithArray:[opt valueForKey:@"dependence_option_ids"]];
                        [tempSet intersectSet:depenceOptionSet];
                        if ([[tempSet allObjects] count] > 0) {
                            [opt setValue:@"YES" forKey:@"is_available"];
                            if ([[opt valueForKey:@"is_selected"] boolValue]) {
                                depenceOptionSet = tempSet;
                            }
                        }else{
                            [opt setValue:@"NO" forKey:@"is_available"];
                            [opt setValue:@"NO" forKey:@"is_selected"];
                        }
                    }
                }
            }
        }
        if (dependenceOptionIds.count > 0) {
            for (int i = 0; i < cells.count; i++) {
                ZThemeSection *zThemeSection = [cells objectAtIndex:i];
                if (![zThemeSection.identifier isEqualToString:key]) {
                    //  Diffirent section
                    for (int j = 0; j < zThemeSection.count; j++) {
                        ZThemeRow *zThemeRow = (ZThemeRow*)[zThemeSection objectAtIndex:j];
                        NSMutableSet *tempSet = [NSMutableSet setWithArray:[zThemeRow.zThemeContentRow valueForKey:@"dependence_option_ids"]];
                        [tempSet intersectSet:depenceOptionSet];
                        if ([[tempSet allObjects] count] > 0) {
                            [zThemeRow.zThemeContentRow setValue:@"YES" forKey:@"is_available"];
                            [zThemeRow.zThemeContentRow setValue:@"YES" forKey:isHighLight];
                            if ([[zThemeRow.zThemeContentRow valueForKey:@"is_selected"] boolValue]) {
                                depenceOptionSet = tempSet;
                            }
                        }else{
                            [zThemeRow.zThemeContentRow setValue:@"NO" forKey:@"is_available"];
                            [zThemeRow.zThemeContentRow setValue:@"NO" forKey:@"is_selected"];
                            [zThemeRow.zThemeContentRow setValue:@"NO" forKey:isHighLight];
                        }
                    }
                }else
                {
                    //  same section
                    if ([[row.zThemeContentRow valueForKey:@"option_type"] isEqualToString:@"single"]) {
                        for (int j = 0; j < zThemeSection.count; j++) {
                            ZThemeRow *zThemeRow = (ZThemeRow*)[zThemeSection objectAtIndex:j];
                            if (![zThemeRow.identifier isEqualToString:row.identifier]) {
                                [zThemeRow.zThemeContentRow setValue:@"NO" forKey:isHighLight];
                            }
                        }
                    }
                }
            }
        }
    }else
    {
        BOOL isOnHighLight = NO;
        if (dependenceOptionIds.count > 0) {
            for (int i = 0; i < cells.count; i++) {
                ZThemeSection *zThemeSection = [cells objectAtIndex:i];
                if (![zThemeSection.identifier isEqualToString:key]) {
                    for (int j = 0; j < zThemeSection.count; j++) {
                        ZThemeRow *zThemeRow = (ZThemeRow*)[zThemeSection objectAtIndex:j];
                        NSMutableSet *tempSet = [NSMutableSet setWithArray:[zThemeRow.zThemeContentRow valueForKey:@"dependence_option_ids"]];
                        [tempSet intersectSet:depenceOptionSet];
                        if ([[tempSet allObjects] count] > 0) {
                            if ([[zThemeRow.zThemeContentRow valueForKey:@"is_selected"] boolValue]) {
                                depenceOptionSet = tempSet;
                                isOnHighLight = YES;
                                break;
                            }
                        }
                    }
                }
                if (isOnHighLight) {
                    break;
                }
            }
        }
        if (!isOnHighLight) {
            if (dependenceOptionIds.count > 0) {
                for (int i = 0; i < cells.count; i++) {
                    ZThemeSection *zThemeSection = [cells objectAtIndex:i];
                    if (![zThemeSection.identifier isEqualToString:key]) {
                        for (int j = 0; j < zThemeSection.count; j++) {
                            ZThemeRow *zThemeRow = (ZThemeRow*)[zThemeSection objectAtIndex:j];
                            NSMutableSet *tempSet = [NSMutableSet setWithArray:[zThemeRow.zThemeContentRow valueForKey:@"dependence_option_ids"]];
                            [tempSet intersectSet:depenceOptionSet];
                            if ([[tempSet allObjects] count] > 0) {
                                [zThemeRow.zThemeContentRow setValue:@"YES" forKey:@"is_available"];
                                [zThemeRow.zThemeContentRow setValue:@"NO" forKey:isHighLight];
                                if ([[zThemeRow.zThemeContentRow valueForKey:@"is_selected"] boolValue]) {
                                    depenceOptionSet = tempSet;
                                }
                            }
                        }
                    }
                }
            }
            [row.zThemeContentRow setValue:@"NO" forKey:isHighLight];
        }
        [self configSelectedOption];
    }
}

- (void)configSelectedOption
{
    if (self.selectedOptionPrice == nil) {
        self.selectedOptionPrice = [[NSMutableDictionary alloc] init];
    }
    for (NSString *tempKey in self.allKeys) {
        CGFloat optionPrice = 0;
        CGFloat optionPriceInclTax = 0;
        BOOL isSelected = NO;
        for (NSDictionary *opt in [self.optionDict valueForKey:tempKey]) {
            if ([[opt valueForKey:@"is_selected"] boolValue]) {
                if (self.product.productType == ProductTypeGrouped) {
                    optionPrice += [[opt valueForKey:@"option_price"] floatValue] * [[opt valueForKey:@"option_qty"] floatValue];
                    if([opt valueForKey:@"option_price_incl_tax"]){
                        optionPriceInclTax += [[opt valueForKey:@"option_price_incl_tax"] floatValue] * [[opt valueForKey:@"option_qty"] floatValue];
                    }else if([opt valueForKey:@"option_price"]){
                        optionPriceInclTax += [[opt valueForKey:@"option_price"] floatValue] * [[opt valueForKey:@"option_qty"] floatValue];
                    }
                }else{
                    CGFloat optionQty = 1.0f;
                    if ([[opt valueForKey:@"option_qty"] floatValue] > 0.01f) {
                        optionQty = [[opt valueForKey:@"option_qty"] floatValue];
                    }
                    optionPrice += optionQty * [[opt valueForKey:@"option_price"] floatValue];
                    if([opt valueForKey:@"option_price_incl_tax"]){
                        optionPriceInclTax += optionQty * [[opt valueForKey:@"option_price_incl_tax"] floatValue];
                    }else if([opt valueForKey:@"option_price"]){
                        optionPriceInclTax += optionQty * [[opt valueForKey:@"option_price"] floatValue];
                    }
                }
                isSelected = YES;
            }
        }
        if (isSelected) {
            [self.selectedOptionPrice setValue:[NSString stringWithFormat:@"%.2f", optionPrice] forKey:tempKey];
        }else{
            [self.selectedOptionPrice removeObjectForKey:tempKey];
        }
    }
}
@end


#pragma mark ProductOption Select Cell
@implementation ProductOptionSelectCell
@synthesize lblNameOption, lblPriceExclTax, lblPriceInclTax, imageSelect, isMultiSelect, isSelected, dataCell;
- (void)setDataForCell:(NSDictionary *)data
{
    if (![dataCell isEqualToDictionary:data]) {
        dataCell = [data copy];
        if (lblNameOption == nil) {
            lblNameOption = [[UILabel alloc]init];
            lblNameOption.numberOfLines = 2;
            [lblNameOption setTextAlignment:NSTextAlignmentLeft];
            [lblNameOption setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_LIGHT size:12]];
            [self addSubview:lblNameOption];
        }
        if (lblPriceExclTax == nil) {
            lblPriceExclTax = [[UILabel alloc]init];
            lblPriceExclTax.numberOfLines = 1;
            [lblPriceExclTax setTextAlignment:NSTextAlignmentLeft];
            [lblPriceExclTax setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:12]];
            [self addSubview:lblPriceExclTax];
        }
        
        if (lblPriceInclTax == nil) {
            lblPriceInclTax = [[UILabel alloc]init];
            lblPriceInclTax.numberOfLines = 1;
            [lblPriceInclTax setTextAlignment:NSTextAlignmentLeft];
            [lblPriceInclTax setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:12]];
            [self addSubview:lblPriceInclTax];
        }
        
        if (imageSelect == nil) {
            imageSelect = [[UIImageView alloc]initWithFrame:CGRectMake(270, 17, 16, 16)];
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                [imageSelect setFrame:CGRectMake(20, 17, 16, 16)];
            }
            //  End RTL
        }
        if ([dataCell valueForKey:@"option_price_incl_tax"]) {
            [lblNameOption setFrame:CGRectMake(10, 0, 150, 50)];
            int quality = [[dataCell valueForKey:@"option_qty"] intValue];
            if (quality > 1) {
                [lblNameOption setText:[NSString stringWithFormat:@"%@ x %d",[dataCell valueForKey:@"option_value"],quality]];
            }else
            {
                [lblNameOption setText:[dataCell valueForKey:@"option_value"]];
            }
            
            [lblPriceExclTax setFrame:CGRectMake(170, 5, 90, 20)];
            //cody
            if (([[SimiGlobalVar sharedInstance] isShowZeroPrice])||([[dataCell valueForKey:@"option_price"] floatValue] != 0)) {
                    [lblPriceExclTax setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:[[dataCell valueForKey:@"option_price"] floatValue]]]];
                }
            //end
            //[lblPriceExclTax setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:[[dataCell valueForKey:@"option_price"] floatValue]]]];
            
            [lblPriceInclTax setFrame:CGRectMake(170, 25, 90, 20)];
            NSString *priceInclTax = [[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:[[dataCell valueForKey:@"option_price_incl_tax"] floatValue]]];
            //cody
            
            if (([[SimiGlobalVar sharedInstance] isShowZeroPrice])|| ([[dataCell valueForKey:@"option_price_incl_tax"] floatValue] != 0)) {
                    [lblPriceInclTax setText:[NSString stringWithFormat:@"%@ %@",priceInclTax, SCLocalizedString(@"Incl.Tax")]];
                }
//            [lblPriceInclTax setText:[NSString stringWithFormat:@"%@ %@",priceInclTax, SCLocalizedString(@"Incl.Tax")]];
            //end
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                [lblNameOption setFrame:CGRectMake(140, 0, 150, 50)];
                [lblPriceExclTax setFrame:CGRectMake(40, 5, 90, 20)];
                [lblPriceInclTax setFrame:CGRectMake(40, 25, 90, 20)];
                [lblNameOption setTextAlignment:NSTextAlignmentRight];
                [lblPriceExclTax setTextAlignment:NSTextAlignmentRight];
                [lblPriceInclTax setTextAlignment:NSTextAlignmentRight];
            }
            //  End RTL

            if (!self.isMultiSelect) {
                if ([[dataCell valueForKey:IsSelected]boolValue] && [[dataCell valueForKey:IsAvaiable]boolValue]) {
                    [imageSelect setImage:[UIImage imageNamed:@"ztheme_selected"]];
                }else
                {
                    [imageSelect setImage:[UIImage imageNamed:@"ztheme_unselected"]];
                }
            }else
            {
                if ([[dataCell valueForKey:IsSelected]boolValue] && [[dataCell valueForKey:IsAvaiable]boolValue]) {
                    [imageSelect setImage:[UIImage imageNamed:@"ztheme_multiselected"]];
                }else
                {
                    [imageSelect setImage:[UIImage imageNamed:@"ztheme_unmultiselected"]];
                }
            }
            [self addSubview:imageSelect];
        }else if([dataCell valueForKey:@"option_price"])
        {
            [lblNameOption setFrame:CGRectMake(10, 0, 150, 50)];
            int quality = [[dataCell valueForKey:@"option_qty"] intValue];
            if (quality > 1) {
                [lblNameOption setText:[NSString stringWithFormat:@"%@ x %d",[dataCell valueForKey:@"option_value"],quality]];
            }else
            {
                [lblNameOption setText:[dataCell valueForKey:@"option_value"]];
            }
            
            [lblPriceExclTax setFrame:CGRectMake(170, 15, 90, 20)];
            //cody
            
            if (([[SimiGlobalVar sharedInstance] isShowZeroPrice]) || ([[dataCell valueForKey:@"option_price"] floatValue] != 0)) {
                    [lblPriceExclTax setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:[[dataCell valueForKey:@"option_price"] floatValue]]]];
                }
//            [lblPriceExclTax setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:[[dataCell valueForKey:@"option_price"] floatValue]]]];
            //end
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                [lblNameOption setFrame:CGRectMake(140, 0, 150, 50)];
                [lblPriceExclTax setFrame:CGRectMake(40, 15, 90, 20)];
                [lblNameOption setTextAlignment:NSTextAlignmentRight];
                [lblPriceExclTax setTextAlignment:NSTextAlignmentRight];
            }
            //  End RTL
            
            if (!self.isMultiSelect) {
                if ([[dataCell valueForKey:IsSelected]boolValue]) {
                    [imageSelect setImage:[UIImage imageNamed:@"ztheme_selected"]];
                }else
                {
                    [imageSelect setImage:[UIImage imageNamed:@"ztheme_unselected"]];
                }
            }else
            {
                if ([[dataCell valueForKey:IsSelected]boolValue]) {
                    [imageSelect setImage:[UIImage imageNamed:@"ztheme_multiselected"]];
                }else
                {
                    [imageSelect setImage:[UIImage imageNamed:@"ztheme_unmultiselected"]];
                }
            }
            [self addSubview:imageSelect];
        }
        if ([[dataCell valueForKey:isHighLight]boolValue] && ![[dataCell valueForKey:IsSelected]boolValue]) {
            [self setBackgroundColor:[UIColor lightGrayColor]];
        }else
        {
            [self setBackgroundColor:[UIColor whiteColor]];
        }
    }
}
@end

#pragma mark Option Text Cell
@implementation ProductOptionTextCell
@synthesize textOption;
@end

#pragma mark DateTime Option Cell

@implementation ProductOptionDateTimeCell
@synthesize datePicker;
@end
