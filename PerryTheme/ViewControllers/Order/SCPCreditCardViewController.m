//
//  SCPCreditCardViewController.m
//  SimiCartPluginFW
//
//  Created by Liam on 6/19/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPCreditCardViewController.h"
#import "SCPTableViewHeaderFooterView.h"

#define kVISA_TYPE          @"^4[0-9]{3}?"
#define kMASTER_CARD_TYPE   @"^5[1-5][0-9]{2}$"

@interface SCPCreditCardViewController (){
    UICollectionView *cardTypeCollectionView;
    NSDictionary *selectedCardTypeInfo;
    NSMutableArray *months;
    NSMutableArray *years;
    NSInteger selectedMonthIndex;
    NSInteger selectedYearIndex;
    NSString *defaultCardNumber;
    NSString *defaultCardUserName;
}

@end

@implementation SCPCreditCardViewController
- (void)viewDidLoadBefore{
    self.navigationItem.title = SCLocalizedString(@"Credit Card");
    [self initCells];
    self.contentTableView = [[SimiTableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.contentTableView.delegate = self;
    self.contentTableView.dataSource = self;
    self.contentTableView.backgroundColor = COLOR_WITH_HEX(@"#F2F2F2");
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.contentTableView];
    
    saveButton = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 55, CGRectGetWidth(self.view.frame), 55)];
    saveButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    [saveButton.titleLabel setFont:[UIFont fontWithName:SCP_FONT_SEMIBOLD size:24]];
    [saveButton setTitleColor:SCP_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
    [saveButton setBackgroundColor:SCP_BUTTON_BACKGROUND_COLOR];
    [saveButton addTarget:self action:@selector(saveCardInfo) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitle:SCLocalizedString(@"SAVE") forState:UIControlStateNormal];
    [self.view addSubview:saveButton];
    
    months = [NSMutableArray new];
    [months addObject:SCLocalizedString(@"January - 1")];
    [months addObject:SCLocalizedString(@"February - 2")];
    [months addObject:SCLocalizedString(@"March - 3")];
    [months addObject:SCLocalizedString(@"April - 4")];
    [months addObject:SCLocalizedString(@"May - 5")];
    [months addObject:SCLocalizedString(@"June - 6")];
    [months addObject:SCLocalizedString(@"July - 7")];
    [months addObject:SCLocalizedString(@"August - 8")];
    [months addObject:SCLocalizedString(@"September - 9")];
    [months addObject:SCLocalizedString(@"October - 10")];
    [months addObject:SCLocalizedString(@"November - 11")];
    [months addObject:SCLocalizedString(@"December - 12")];
    
    NSDate *currentDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear fromDate:currentDate];
    NSInteger year = [components year];
    years = [NSMutableArray new];
    for (int i = 0; i < 10; i++ ) {
        [years addObject:[NSString stringWithFormat:@"%ld",year+i]];
    }
    if (self.defaultCard != nil) {
        if ([self.defaultCard valueForKey:@"cc_username"]) {
            defaultCardUserName = [NSString stringWithFormat:@"%@",[self.defaultCard valueForKey:@"cc_username"]];
        }
        if ([self.defaultCard valueForKey:@"cc_exp_month"] && [self.defaultCard valueForKey:@"cc_exp_year"]) {
            selectedMonthIndex = [[self.defaultCard valueForKey:@"cc_exp_month"]integerValue] - 1;
            NSString *ccExpYear = [NSString stringWithFormat:@"%@",[self.defaultCard valueForKey:@"cc_exp_year"]];
            if ([years containsObject:ccExpYear]) {
                selectedYearIndex = [years indexOfObject:ccExpYear];
            }
        }
        if ([self.defaultCard valueForKey:@"cc_number"]) {
            defaultCardNumber = [NSString stringWithFormat:@"%@",[self.defaultCard valueForKey:@"cc_number"]];
            NSMutableString *stringWithAddedSpaces = [NSMutableString new];
            for (NSUInteger i = 0; i<[defaultCardNumber length]; i++) {
                if ((i>0) && ((i % 4) == 0)) {
                    [stringWithAddedSpaces appendString:@" - "];
                }
                unichar characterToAdd = [defaultCardNumber characterAtIndex:i];
                NSString *stringToAdd = [NSString stringWithCharacters:&characterToAdd length:1];
                [stringWithAddedSpaces appendString:stringToAdd];
            }
            defaultCardNumber = stringWithAddedSpaces;
        }
        if ([[self.defaultCard valueForKey:@"cc_type"] isKindOfClass:[NSDictionary class]]) {
            selectedCardTypeInfo = [self.defaultCard valueForKey:@"cc_type"];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)createCells{
    SimiSection *cardTypeSection = [[SimiSection alloc]initWithIdentifier:scpcreditcard_cardtype_section];
    cardTypeSection.header = [[SimiSectionHeader alloc]initWithTitle:SCLocalizedString(@"CREDIT CARD TYPE") height:50];
    [cardTypeSection addRowWithIdentifier:scpcreditcard_cardtype_section height:200];
    [self.cells addObject:cardTypeSection];
    
    if (self.isShowName) {
        SimiSection *cardUserNameSection = [[SimiSection alloc]initWithIdentifier:scpcreditcard_cardusername_section];
        cardUserNameSection.header = [[SimiSectionHeader alloc]initWithTitle:SCLocalizedString(@"Name On Card") height:50];
        [cardUserNameSection addRowWithIdentifier:scpcreditcard_cardusername_section height:60];
        [self.cells addObject:cardUserNameSection];
    }
    SimiSection *cardNumberSection = [[SimiSection alloc]initWithIdentifier:scpcreditcard_cardnumber_section];
    cardNumberSection.header = [[SimiSectionHeader alloc]initWithTitle:SCLocalizedString(@"Credit Card Number") height:50];
    [cardNumberSection addRowWithIdentifier:scpcreditcard_cardnumber_section height:60];
    [self.cells addObject:cardNumberSection];
    
    SimiSection *cardExpiredSection = [[SimiSection alloc]initWithIdentifier:scpcreditcard_cardexpired_section];
    cardExpiredSection.header = [[SimiSectionHeader alloc]initWithTitle:SCLocalizedString(@"Year") height:50];
    [cardExpiredSection addRowWithIdentifier:scpcreditcard_cardexpired_section height:60];
    [self.cells addObject:cardExpiredSection];
    
    if (self.isUseCVV) {
        SimiSection *cardCVVSection = [[SimiSection alloc]initWithIdentifier:scpcreditcard_cardcvv_section];
        cardCVVSection.header = [[SimiSectionHeader alloc]initWithTitle:SCLocalizedString(@"CVV") height:50];
        [cardCVVSection addRowWithIdentifier:scpcreditcard_cardcvv_section height:60];
        [self.cells addObject:cardCVVSection];
    }
}

- (UIView *)contentTableViewViewForHeaderInSection:(NSInteger)section{
    SimiSection *cardSection = [self.cells objectAtIndex:section];
    SCPTableViewHeaderFooterView *headerView = [self.contentTableView dequeueReusableHeaderFooterViewWithIdentifier:cardSection.identifier];
    if (headerView == nil) {
        headerView = [[SCPTableViewHeaderFooterView alloc]initWithReuseIdentifier:cardSection.identifier];
        [headerView.contentView setBackgroundColor:COLOR_WITH_HEX(@"#F2F2F2")];
        float padding = SCP_GLOBALVARS.padding + 5;
        if ([cardSection.identifier isEqualToString:scpcreditcard_cardexpired_section]) {
            headerView.titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, 0, 185, cardSection.header.height) andFontName:SCP_FONT_REGULAR andFontSize:FONT_SIZE_HEADER andTextColor:COLOR_WITH_HEX(@"#272727")];
            [headerView.titleLabel setText:[NSString stringWithFormat:@"%@*",SCLocalizedString(@"Month")]];
            [headerView.contentView addSubview:headerView.titleLabel];
            
            SimiLabel *yearTitleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding*2+185, 0, CGRectGetWidth(self.contentTableView.frame) - (padding*3+185), cardSection.header.height) andFontName:SCP_FONT_REGULAR andFontSize:FONT_SIZE_HEADER andTextColor:COLOR_WITH_HEX(@"#272727")];
            [yearTitleLabel setText:[NSString stringWithFormat:@"%@*",SCLocalizedString(@"Year")]];
            [headerView.contentView addSubview:yearTitleLabel];
        }else{
            headerView.titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, 0, CGRectGetWidth(self.contentTableView.frame) - padding*2, cardSection.header.height) andFontName:SCP_FONT_REGULAR andFontSize:FONT_SIZE_HEADER andTextColor:COLOR_WITH_HEX(@"#272727")];
            [headerView.titleLabel setText:[NSString stringWithFormat:@"%@*",cardSection.header.title]];
            [headerView.contentView addSubview:headerView.titleLabel];
        }
    }
    return headerView;
}

- (UITableViewCell *)contentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    UITableViewCell *cell;
    if([section.identifier isEqualToString:scpcreditcard_cardtype_section]){
        if([row.identifier isEqualToString:scpcreditcard_cardtype_section]){
            cell = [self createCardTypeCellWithRow:row];
        }
    }else if ([section.identifier isEqualToString:scpcreditcard_cardnumber_section]){
        if ([row.identifier isEqualToString:scpcreditcard_cardnumber_section]) {
            cell = [self createCardNumberCellWithRow:row];
        }
    }else if ([section.identifier isEqualToString:scpcreditcard_cardexpired_section]){
        if ([row.identifier isEqualToString:scpcreditcard_cardexpired_section]) {
            cell = [self createExpiredDateCellWithRow:row];
        }
    }else if ([section.identifier isEqualToString:scpcreditcard_cardcvv_section]){
        if ([row.identifier isEqualToString:scpcreditcard_cardcvv_section]) {
            cell = [self createCardCVVCellWithRow:row];
        }
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (SimiTableViewCell*)createCardTypeCellWithRow:(SimiRow*)row{
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if (cell == nil) {
        cell = [[SimiTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        [cell.contentView setBackgroundColor:COLOR_WITH_HEX(@"#F2F2F2")];
        UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
        flowLayout.itemSize = CGSizeMake(126, 165);
        flowLayout.minimumLineSpacing = SCP_GLOBALVARS.lineSpacing;
        flowLayout.minimumInteritemSpacing = SCP_GLOBALVARS.interitemSpacing;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        cardTypeCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentTableView.frame), 165) collectionViewLayout:flowLayout];
        [cardTypeCollectionView setBackgroundColor:[UIColor clearColor]];
        [cardTypeCollectionView setContentInset:UIEdgeInsetsMake(0, SCP_GLOBALVARS.padding, 0, SCP_GLOBALVARS.padding)];
        cardTypeCollectionView.delegate = self;
        cardTypeCollectionView.dataSource = self;
        [cell.contentView addSubview:cardTypeCollectionView];
        [cardTypeCollectionView registerClass:[SCPCreditCardTypeCollectionViewCell class] forCellWithReuseIdentifier:@"card_type"];
    }
    return cell;
}

- (SimiTableViewCell*)createCardUserNameCellWithRow:(SimiRow*)row{
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if (cell == nil) {
        cell = [[SimiTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        [cell.contentView setBackgroundColor:COLOR_WITH_HEX(@"#F2F2F2")];
        cartUserNameTextField = [[SimiTextField alloc]initWithFrame:CGRectMake(SCP_GLOBALVARS.padding, 5, CGRectGetWidth(self.contentTableView.frame) - 2*SCP_GLOBALVARS.padding, 40) placeHolder:@"" font:[UIFont fontWithName:SCP_FONT_LIGHT size:FONT_SIZE_HEADER] textColor:COLOR_WITH_HEX(@"##272727") backgroundColor:[UIColor whiteColor] borderWidth:0 borderColor:nil cornerRadius:4 leftView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 40)] rightView:nil leftBarTitle:nil rightBarTitle:@"Done"];
        cartUserNameTextField.simiTextFieldDelegate = self;
        if (defaultCardUserName != nil) {
            [cartUserNameTextField setText:defaultCardUserName];
        }
        [cell.contentView addSubview:cartUserNameTextField];
    }
    return cell;
}

- (SimiTableViewCell*)createCardNumberCellWithRow:(SimiRow*)row{
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if (cell == nil) {
        cell = [[SimiTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        [cell.contentView setBackgroundColor:COLOR_WITH_HEX(@"#F2F2F2")];
        numberTextField = [[SimiTextField alloc]initWithFrame:CGRectMake(SCP_GLOBALVARS.padding, 5, CGRectGetWidth(self.contentTableView.frame) - 2*SCP_GLOBALVARS.padding, 40) placeHolder:@"XXXX - XXXX - XXXX - XXXX" font:[UIFont fontWithName:SCP_FONT_LIGHT size:FONT_SIZE_HEADER] textColor:COLOR_WITH_HEX(@"##272727") backgroundColor:[UIColor whiteColor] borderWidth:0 borderColor:nil cornerRadius:4 leftView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 40)] rightView:nil leftBarTitle:nil rightBarTitle:@"Done"];
        numberTextField.simiTextFieldDelegate = self;
        numberTextField.delegate = self;
        numberTextField.keyboardType = UIKeyboardTypeNumberPad;
        if (defaultCardNumber != nil) {
            [numberTextField setText:defaultCardNumber];
        }
        [cell.contentView addSubview:numberTextField];
    }
    return cell;
}

- (SimiTableViewCell*)createExpiredDateCellWithRow:(SimiRow*)row{
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if (cell == nil) {
        cell = [[SimiTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        [cell.contentView setBackgroundColor:COLOR_WITH_HEX(@"#F2F2F2")];
        monthTextField = [[SimiTextField alloc]initWithFrame:CGRectMake(SCP_GLOBALVARS.padding, 5, 190, 40) placeHolder:@"" font:[UIFont fontWithName:SCP_FONT_LIGHT size:FONT_SIZE_HEADER] textColor:COLOR_WITH_HEX(@"##272727") backgroundColor:[UIColor whiteColor] borderWidth:0 borderColor:nil cornerRadius:4 leftView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 40)] rightView:nil leftBarTitle:nil rightBarTitle:nil];
        monthTextField.simiTextFieldDelegate = self;
        monthTextField.delegate = self;
        [monthTextField setText:[months objectAtIndex:selectedMonthIndex]];
        [cell.contentView addSubview:monthTextField];
        
        yearTextField = [[SimiTextField alloc]initWithFrame:CGRectMake(SCP_GLOBALVARS.padding*2 + 190, 5, CGRectGetWidth(self.contentTableView.frame) - (SCP_GLOBALVARS.padding*3 + 190), 40) placeHolder:@"" font:[UIFont fontWithName:SCP_FONT_LIGHT size:FONT_SIZE_HEADER] textColor:COLOR_WITH_HEX(@"##272727") backgroundColor:[UIColor whiteColor] borderWidth:0 borderColor:nil cornerRadius:4 leftView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 40)] rightView:nil leftBarTitle:nil rightBarTitle:nil];
        yearTextField.simiTextFieldDelegate = self;
        yearTextField.delegate = self;
        [yearTextField setText:[years objectAtIndex:selectedYearIndex]];
        [cell.contentView addSubview:yearTextField];
    }
    return cell;
}

- (SimiTableViewCell*)createCardCVVCellWithRow:(SimiRow*)row{
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if (cell == nil) {
        cell = [[SimiTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        [cell.contentView setBackgroundColor:COLOR_WITH_HEX(@"#F2F2F2")];
        cvvTextField = [[SimiTextField alloc]initWithFrame:CGRectMake(SCP_GLOBALVARS.padding, 5, 190, 40) placeHolder:@"XXX" font:[UIFont fontWithName:SCP_FONT_LIGHT size:FONT_SIZE_HEADER] textColor:COLOR_WITH_HEX(@"##272727") backgroundColor:[UIColor whiteColor] borderWidth:0 borderColor:nil cornerRadius:4 leftView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 40)] rightView:nil leftBarTitle:nil rightBarTitle:@"Done"];
        cvvTextField.simiTextFieldDelegate = self;
        cvvTextField.delegate = self;
        cvvTextField.keyboardType = UIKeyboardTypeNumberPad;
        [cell.contentView addSubview:cvvTextField];
    }
    return cell;
}

#pragma mark -
#pragma mark Text Field Delegate
- (void)rightBarAction:(UITextField *)textField{
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if ([textField isEqual:monthTextField]) {
        ActionSheetStringPicker *stringPicker = [[ActionSheetStringPicker alloc]initWithTitle:SCLocalizedString(@"Choose expired month") rows:months initialSelection:selectedMonthIndex doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            selectedMonthIndex = selectedIndex;
            [monthTextField setText:[months objectAtIndex:selectedMonthIndex]];
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            
        } origin:self.view];
        [stringPicker showActionSheetPicker];
        return NO;
    }else if ([textField isEqual:yearTextField]){
        ActionSheetStringPicker *stringPicker = [[ActionSheetStringPicker alloc]initWithTitle:SCLocalizedString(@"Choose expired year") rows:years initialSelection:selectedYearIndex doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            selectedYearIndex = selectedIndex;
            [yearTextField setText:[years objectAtIndex:selectedYearIndex]];
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            
        } origin:self.view];
        [stringPicker showActionSheetPicker];
        return NO;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *textAfterReplacing = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    // In order to make the cursor end up positioned correctly, we need to explicitly reposition it after we inject spaces into the text.
    // No matter how the user changes the content - whether by deletion, insertion, or replacement of existing content by selecting and typing or pasting - we always want the cursor to end up at the end of the replacement string.
    // targetCursorPosition keeps track of where the cursor needs to end up as we modify the string, and at the end we set the cursor position to it.
    NSUInteger targetCursorPosition = range.location + [string length];
    
    NSString *cardNumberWithoutSpaces = [self removeNonDigits:textAfterReplacing andPreserveCursorPosition:&targetCursorPosition];
    
    if ([cardNumberWithoutSpaces length] > 16) {
        // If the user is trying to enter more than 16 digits, we cancel the entire operation and leave the text field as it was.
        return NO;
    }
    
    NSString *cardNumberWithSpaces = [self insertSpacesEveryFourDigitsIntoString:(NSString *)cardNumberWithoutSpaces andPreserveCursorPosition:&targetCursorPosition];
    
    textField.text = cardNumberWithSpaces;
    UITextPosition *targetPosition = [textField positionFromPosition:[textField beginningOfDocument] offset:targetCursorPosition];
    [textField setSelectedTextRange:[textField textRangeFromPosition:targetPosition toPosition:targetPosition]];
    CreditCardBrand cardBrand = [self checkCardBrandWithNumber:cardNumberWithoutSpaces];
    switch (cardBrand) {
        case CreditCardBrandVisa:{
            [self updateCardTypeInfoWithCode:@"VI"];
        }
            break;
        case CreditCardBrandMasterCard:{
            [self updateCardTypeInfoWithCode:@"MC"];
        }
            break;
        default:
            break;
    }
    return NO;
}

- (CreditCardBrand)checkCardBrandWithNumber:(NSString *)_cardNumber
{
    if([_cardNumber length] < 4)
        return CreditCardBrandUnknown;
    
    CreditCardBrand cardType;
    NSRegularExpression *regex;
    NSError *error;
    
    for(NSUInteger i = 0; i < CreditCardBrandUnknown; ++i) {
        cardType = i;
        switch(i) {
            case CreditCardBrandVisa:
                regex = [NSRegularExpression regularExpressionWithPattern:kVISA_TYPE options:0 error:&error];
                break;
            case CreditCardBrandMasterCard:
                regex = [NSRegularExpression regularExpressionWithPattern:kMASTER_CARD_TYPE options:0 error:&error];
                break;
            default:
                break;
        }
        
        NSUInteger matches = [regex numberOfMatchesInString:_cardNumber options:0 range:NSMakeRange(0, 4)];
        if(matches == 1)
            return cardType;
    }
    return CreditCardBrandUnknown;
}

- (void)updateCardTypeInfoWithCode:(NSString*)code{
    for (NSDictionary *cardTypeInfo in self.creditCardList) {
        if ([code isEqualToString:[cardTypeInfo valueForKey:@"cc_code"]]) {
            selectedCardTypeInfo = cardTypeInfo;
            [cardTypeCollectionView reloadData];
            return;
        }
    }
}

/*
 Removes non-digits from the string, decrementing `cursorPosition` as
 appropriate so that, for instance, if we pass in `@"1111 1123 1111"`
 and a cursor position of `8`, the cursor position will be changed to
 `7` (keeping it between the '2' and the '3' after the spaces are removed).
 */
- (NSString *)removeNonDigits:(NSString *)string andPreserveCursorPosition:(NSUInteger *)cursorPosition {
    NSUInteger targetCursorPositionInOriginalReplacementString = *cursorPosition;
    NSMutableString *digitsOnlyString = [NSMutableString new];
    for (NSUInteger i=0; i<[string length]; i++) {
        unichar characterToAdd = [string characterAtIndex:i];
        if (isdigit(characterToAdd)) {
            NSString *stringToAdd = [NSString stringWithCharacters:&characterToAdd length:1];
            [digitsOnlyString appendString:stringToAdd];
        }
        else {
            if (i < targetCursorPositionInOriginalReplacementString) {
                (*cursorPosition)--;
            }
        }
    }
    
    return digitsOnlyString;
}

/*
 Inserts spaces into the string to format it as a credit card number,
 incrementing `cursorPosition` as appropriate so that, for instance, if we
 pass in `@"111111231111"` and a cursor position of `7`, the cursor position
 will be changed to `8` (keeping it between the '2' and the '3' after the
 spaces are added).
 */
- (NSString *)insertSpacesEveryFourDigitsIntoString:(NSString *)string andPreserveCursorPosition:(NSUInteger *)cursorPosition {
    NSMutableString *stringWithAddedSpaces = [NSMutableString new];
    NSUInteger cursorPositionInSpacelessString = *cursorPosition;
    for (NSUInteger i=0; i<[string length]; i++) {
        if ((i>0) && ((i % 4) == 0)) {
            [stringWithAddedSpaces appendString:@" - "];
            if (i < cursorPositionInSpacelessString) {
                (*cursorPosition) += 3;
            }
        }
        unichar characterToAdd = [string characterAtIndex:i];
        NSString *stringToAdd = [NSString stringWithCharacters:&characterToAdd length:1];
        [stringWithAddedSpaces appendString:stringToAdd];
    }
    
    return stringWithAddedSpaces;
}

#pragma mark -
#pragma mark Collection View DataSource&Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.creditCardList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SCPCreditCardTypeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"card_type" forIndexPath:indexPath];
    NSDictionary *cardTypeInfo = [self.creditCardList objectAtIndex:indexPath.row];
    BOOL cellState = NO;
    if (selectedCardTypeInfo != nil && [selectedCardTypeInfo isEqualToDictionary:cardTypeInfo]) {
        cellState = YES;
    }
    [cell updateCellInfo:cardTypeInfo state:cellState];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    selectedCardTypeInfo = [self.creditCardList objectAtIndex:indexPath.row];
    [collectionView reloadData];
}

- (void)saveCardInfo{
    BOOL checked = YES;
    if (selectedCardTypeInfo == nil || [numberTextField.text isEqualToString:@""] || [monthTextField.text isEqualToString:@""] || [yearTextField.text isEqualToString:@""]) {
        checked = NO;
    }
    if (self.isShowName && [cartUserNameTextField.text isEqualToString:@""]) {
        checked = NO;
    }
    if (self.isUseCVV && [cvvTextField.text isEqualToString:@""]) {
        checked = NO;
    }
    if (!checked) {
        [self showToastMessage:@"Please complete all require fields" duration:1.5];
        return;
    }
    
    NSString *cardNumber = [numberTextField.text stringByReplacingOccurrencesOfString:@" - " withString:@""];
    NSString *expiredMonth = [NSString stringWithFormat:@"%ld",selectedMonthIndex+1];
    NSString *expiredYear = [years objectAtIndex:selectedYearIndex];
    NSString *cvv = @"";
    if (self.isUseCVV) {
        cvv = cvvTextField.text;
    }
    NSString *owner = @"";
    if (self.isShowName) {
        owner = cartUserNameTextField.text;
    }
    [self.delegate didEnterCreditCardWithCardType:selectedCardTypeInfo cardNumber:cardNumber expiredMonth:expiredMonth expiredYear:expiredYear cvv:cvv owner:owner];
    if (PHONEDEVICE) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end

@implementation SCPCreditCardTypeCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        iconSelectImageView = [[UIImageView alloc]initWithFrame:CGRectMake(14, 10, 12, 12)];
        [self.contentView addSubview:iconSelectImageView];
        
        logoCardImageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 19, 95, 95)];
        [self.contentView addSubview:logoCardImageView];
        
        cardTypeNameLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(15, 122, 95, 40) andFontName:SCP_FONT_REGULAR andFontSize:FONT_SIZE_MEDIUM andTextColor:COLOR_WITH_HEX(@"#272727")];
        cardTypeNameLabel.numberOfLines = 0;
        [cardTypeNameLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:cardTypeNameLabel];
        imageNames = @{@"AE":@"scp_card_ae",@"VI":@"scp_card_visa",@"MC":@"scp_card_master",@"DI":@"scp_card_discover",@"JCB":@"scp_card_jcb",@"DN":@"scp_card_diners",@"SO":@"scp_card_solo",@"MI":@"scp_card_maestro",@"OT":@"scp_card_other"};
    }
    return self;
}

- (void)updateCellInfo:(NSDictionary *)info state:(BOOL)state{
    self.cardTypeInfo = info;
    NSString *ccCode = [[NSString stringWithFormat:@"%@",[info valueForKey:@"cc_code"]] uppercaseString];
    NSString *ccName = [NSString stringWithFormat:@"%@",[info valueForKey:@"cc_name"]];
    if (state) {
        [iconSelectImageView setImage:[UIImage imageNamed:@"scp_ic_option_selected"]];
    }else{
        [iconSelectImageView setImage:[UIImage imageNamed:@"scp_ic_option_unselect"]];
    }
    [cardTypeNameLabel setText:ccName];
    NSString *imageName = @"scp_card_other";
    if ([imageNames valueForKey:ccCode]) {
        imageName = [imageNames valueForKey:ccCode];
    }
    [logoCardImageView setImage:[UIImage imageNamed:imageName]];
}
@end
