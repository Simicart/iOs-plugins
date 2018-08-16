//
//  SCCreditCardDetailViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 2/5/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCCreditCardDetailViewController.h"
#import "CreditCardModel.h"

#define INFORMATION @"INFORMATION"
#define BILLING_ADDRESS @"BILLING_ADDRESS"

@interface SCCreditCardDetailViewController ()

@end

@implementation SCCreditCardDetailViewController{
    SimiTextField *nameTF, *numberTF, *dateTF, *monthTF, *yearTF;
    SimiCheckbox *defaultCb;
    SimiTextField *titleTF, *firstNameTF, *lastNameTF, *companyTF, *jobTF, *phoneTF, *mobileTF, *emailTF, *faxTF, *addressTF, *street1TF, *street2TF, *cityTF, *stateTF, *zipCodeTF, *countryTF;
    NSMutableArray *years;
    NSArray *months,*titles;
    UIPickerView *monthPickerView, *yearPickerView, *countryPickerView, *titlePickerView, *statePickerView;
    NSDictionary *selectedMonth, *selectedYear, *selectedCountry;
    NSString *selectedTitle;
    NSDictionary *selectedState;
    NSArray *states;
    UIButton *stateRightView;
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
    titles = @[@"Mr.",@"Ms.",@"Mrs.",@"Miss",@"Dr.",@"Sir.",@"Prof."];
    self.navigationItem.title = SCLocalizedString(@"EDIT CREDIT CARD");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    [self initCells];
}

- (void)createCells{
    self.cells = [SimiTable new];
    SimiSection *section = [self.cells addSectionWithIdentifier:INFORMATION];
    section.header = [[SimiSectionHeader alloc] initWithTitle:@"CREDIT CARD INFORMATION" height:44];
    [section addRowWithIdentifier:INFORMATION];
    SimiSection *billingAddress = [self.cells addSectionWithIdentifier:BILLING_ADDRESS];
    billingAddress.header = [[SimiSectionHeader alloc] initWithTitle:@"BILLING ADDRESS" height:44];
    [billingAddress addRowWithIdentifier:BILLING_ADDRESS];
}
- (UITableViewCell *)contentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    SimiCustomizeTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if(!cell){
        cell = [[SimiCustomizeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.delegate = self;
        cell.paddingY = 5;
        if([row.identifier isEqualToString:INFORMATION]){
            nameTF = [cell addFieldWithLabel:[NSString stringWithFormat:@"%@*",SCLocalizedString(@"Name on Card")] text:@""];
            numberTF = [cell addFieldWithLabel:[NSString stringWithFormat:@"%@*",SCLocalizedString(@"Credit Card Number")] text:@""];
            numberTF.keyboardType = UIKeyboardTypeNumberPad;
            if(_creditCard){
                numberTF.userInteractionEnabled = NO;
            }
            [cell addLabelWithText:[NSString stringWithFormat:@"%@*",SCLocalizedString(@"Expiration Date")]];
            UIButton *rightView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            [rightView setImage:[UIImage imageNamed:@"ic_narrow_down"] forState:UIControlStateNormal];
            rightView.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
            rightView.userInteractionEnabled = NO;
            monthTF = [[SimiTextField alloc] initWithFrame:CGRectMake(cell.paddingX, cell.heightCell, 2*cell.contentWidth/3 - 5, 40) placeHolder:@"Month" font:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE] textColor:THEME_CONTENT_COLOR borderWidth:1 borderColor:[UIColor lightGrayColor] cornerRadius:0 leftView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 40)] rightView:rightView];
            monthPickerView = [UIPickerView new];
            monthPickerView.delegate = self;
            monthPickerView.dataSource = self;
            monthTF.inputView = monthPickerView;
            [self addAccessoryInputViewForTextField:monthTF];
            [cell.contentView addSubview:monthTF];
            UIButton *rightView1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            [rightView1 setImage:[UIImage imageNamed:@"ic_narrow_down"] forState:UIControlStateNormal];
            rightView1.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
            rightView1.userInteractionEnabled = NO;
            yearTF = [[SimiTextField alloc] initWithFrame:CGRectMake(cell.paddingX + 2*cell.contentWidth/3, cell.heightCell, cell.contentWidth/3, 40) placeHolder:@"Year" font:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE] textColor:THEME_CONTENT_COLOR borderWidth:1 borderColor:[UIColor lightGrayColor] cornerRadius:0 leftView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 40)] rightView:rightView1];
            yearPickerView = [UIPickerView new];
            yearPickerView.delegate = self;
            yearPickerView.dataSource = self;
            yearTF.inputView = yearPickerView;
            [self addAccessoryInputViewForTextField:yearTF];
            [cell.contentView addSubview:yearTF];
            cell.heightCell += 40;
            defaultCb = [cell addCheckboxWithTitle:@"Default Credit Card"];
        }else if([row.identifier isEqualToString:BILLING_ADDRESS]){
            titleTF = [cell addFieldWithLabel:@"Title" text:@""];
            UIButton *rightView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            [rightView setImage:[UIImage imageNamed:@"ic_narrow_down"] forState:UIControlStateNormal];
            rightView.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
            rightView.userInteractionEnabled = NO;
            titleTF.rightView = rightView;
            titleTF.rightViewMode = UITextFieldViewModeAlways;
            titlePickerView = [UIPickerView new];
            titlePickerView.delegate = self;
            titlePickerView.dataSource = self;
            titleTF.inputView = titlePickerView;
            firstNameTF = [cell addFieldWithLabel:[NSString stringWithFormat:@"%@*",SCLocalizedString(@"First Name")] text:@""];
            lastNameTF = [cell addFieldWithLabel:[NSString stringWithFormat:@"%@*",SCLocalizedString(@"Last Name")] text:@""];
            companyTF = [cell addFieldWithLabel:@"Company" text:@""];
            jobTF = [cell addFieldWithLabel:@"Job Description" text:@""];
            phoneTF = [cell addFieldWithLabel:[NSString stringWithFormat:@"%@*",SCLocalizedString(@"Phone")] text:@""];
            phoneTF.keyboardType = UIKeyboardTypePhonePad;
            mobileTF = [cell addFieldWithLabel:@"Mobile" text:@""];
            mobileTF.keyboardType = UIKeyboardTypePhonePad;
            emailTF = [cell addFieldWithLabel:@"Email" text:@""];
            emailTF.keyboardType = UIKeyboardTypeEmailAddress;
            faxTF = [cell addFieldWithLabel:@"Fax" text:@""];
            street1TF = [cell addFieldWithLabel:[NSString stringWithFormat:@"%@*",SCLocalizedString(@"Street Address")] text:@"" placeHolder:@""];
            street2TF = [cell addTextFieldWithPlaceHolder:@""];
            cityTF = [cell addFieldWithLabel:[NSString stringWithFormat:@"%@*",SCLocalizedString(@"City")] text:@""];
            stateTF = [cell addFieldWithLabel:[NSString stringWithFormat:@"%@",SCLocalizedString(@"State")] text:@""];
            stateRightView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            [stateRightView setImage:[UIImage imageNamed:@"ic_narrow_down"] forState:UIControlStateNormal];
            stateRightView.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
            stateRightView.userInteractionEnabled = NO;
            statePickerView = [UIPickerView new];
            statePickerView.delegate = self;
            statePickerView.dataSource = self;
            zipCodeTF = [cell addFieldWithLabel:[NSString stringWithFormat:@"%@*",SCLocalizedString(@"Zip Code")] text:@""];
            countryTF = [cell addFieldWithLabel:[NSString stringWithFormat:@"%@*",SCLocalizedString(@"Country")] text:@""];
            UIButton *rightView1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            [rightView1 setImage:[UIImage imageNamed:@"ic_narrow_down"] forState:UIControlStateNormal];
            rightView1.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
            rightView1.userInteractionEnabled = NO;
            countryTF.rightView = rightView1;
            countryTF.rightViewMode = UITextFieldViewModeAlways;
            countryPickerView = [UIPickerView new];
            countryPickerView.delegate = self;
            countryPickerView.dataSource = self;
            countryTF.inputView = countryPickerView;
        }
        if(_creditCard){
            NSDictionary *address = [_creditCard objectForKey:@"address"];
            if([row.identifier isEqualToString:INFORMATION]){
                if([_creditCard objectForKey:@"cc_owner"]){
                    nameTF.text = [_creditCard objectForKey:@"cc_owner"];
                }
                if([_creditCard objectForKey:@"card"]){
                    numberTF.text = [_creditCard objectForKey:@"card"];
                }
                if([_creditCard objectForKey:@"cc_exp_month"]){
                    for(NSDictionary *month in months){
                        if([[month objectForKey:@"value"] isEqualToString:[_creditCard objectForKey:@"cc_exp_month"]]){
                            selectedMonth = month;
                            monthTF.text = [month objectForKey:@"label"];
                            [monthPickerView selectRow:[months indexOfObject:month] inComponent:0 animated:NO];
                            break;
                        }
                    }
                }
                if([_creditCard objectForKey:@"cc_exp_year"]){
                    for(NSDictionary *year in years){
                        if([[year objectForKey:@"value"] isEqualToString:[_creditCard objectForKey:@"cc_exp_year"]]){
                            selectedYear = year;
                            yearTF.text = [year objectForKey:@"label"];
                            [yearPickerView selectRow:[years indexOfObject:year] inComponent:0 animated:NO];
                            break;
                        }
                    }
                }
                if([_creditCard objectForKey:@"is_default"]){
                    defaultCb.checkState = [[_creditCard objectForKey:@"is_default"] boolValue]?M13CheckboxStateChecked:M13CheckboxStateUnchecked;
                }
            }else if([row.identifier isEqualToString:BILLING_ADDRESS]){
                if([address objectForKey:@"prefix"]){
                    for(NSString *title in titles){
                        if([title isEqualToString:[address objectForKey:@"prefix"]]){
                            selectedTitle = title;
                            titleTF.text = title;
                            [titlePickerView selectRow:[titles indexOfObject:title] inComponent:0 animated:NO];
                            break;
                        }
                    }
                }
                if([address objectForKey:@"firstname"]){
                    firstNameTF.text = [address objectForKey:@"firstname"];
                }
                if([address objectForKey:@"lastname"]){
                    lastNameTF.text = [address objectForKey:@"lastname"];
                }
                if([address objectForKey:@"companyname"]){
                    companyTF.text = [address objectForKey:@"companyname"];
                }
                if([address objectForKey:@"job_description"]){
                    jobTF.text = [address objectForKey:@"job_description"];
                }
                if([address objectForKey:@"telephone"]){
                    phoneTF.text = [address objectForKey:@"telephone"];
                }
                if([address objectForKey:@"mobile"]){
                    mobileTF.text = [address objectForKey:@"mobile"];
                }
                if([address objectForKey:@"email"]){
                    emailTF.text = [address objectForKey:@"email"];
                }
                if([address objectForKey:@"fax"]){
                    faxTF.text = [address objectForKey:@"fax"];
                }
                if([address objectForKey:@"street1"]){
                    street1TF.text = [address objectForKey:@"street1"];
                }
                if([address objectForKey:@"street2"]){
                    street2TF.text = [address objectForKey:@"street2"];
                }
                if([address objectForKey:@"city"]){
                    cityTF.text = [address objectForKey:@"city"];
                }
                if([address objectForKey:@"postalcode"]){
                    zipCodeTF.text = [address objectForKey:@"postalcode"];
                }
                if([address objectForKey:@"postalcode"]){
                    zipCodeTF.text = [address objectForKey:@"postalcode"];
                }
                if([address objectForKey:@"country_id"]){
                    for(NSDictionary *country in GLOBALVAR.storeView.allowedCountries){
                        if([[[country objectForKey:@"country_code"] uppercaseString] isEqualToString:[[address objectForKey:@"country_id"] uppercaseString]]){
                            selectedCountry = country;
                            countryTF.text = [selectedCountry objectForKey:@"country_name"];
                            states = [country objectForKey:@"states"];
                            [countryPickerView selectRow:[GLOBALVAR.storeView.allowedCountries indexOfObject:country] inComponent:0 animated:NO];
                            break;
                        }
                    }
                }
                if([address objectForKey:@"region"]){
                    stateTF.text = [address objectForKey:@"region"];
                }
                if(states.count > 0){
                    stateTF.inputView = statePickerView;
                    stateTF.rightView = stateRightView;
                    stateTF.rightViewMode = UITextFieldViewModeAlways;
                    if([address objectForKey:@"region_id"]){
                        for(NSDictionary *state in states){
                            if([[state objectForKey:@"state_id"] isEqualToString:[address objectForKey:@"region_id"]]){
                                selectedState = state;
                                stateTF.text = [state objectForKey:@"state_name"];
                                [statePickerView selectRow:[states indexOfObject:state] inComponent:0 animated:NO];
                                break;
                            }
                        }
                    }else{
                        selectedState = [states objectAtIndex:0];
                        [statePickerView selectRow:0 inComponent:0 animated:NO];
                        stateTF.text = [selectedState objectForKey:@"state_name"];
                        stateTF.rightView = nil;
                    }
                }else{
                    stateTF.inputView = nil;
                }
            }
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    row.height = cell.heightCell + 5;
    return cell;
}

- (void)save:(id)sender{
    if([nameTF.text isEqualToString:@""] || [numberTF.text isEqualToString:@""] || [monthTF.text isEqualToString:@""] || [yearTF.text isEqualToString:@""] || [firstNameTF.text isEqualToString:@""] || [lastNameTF.text isEqualToString:@""] || [phoneTF.text isEqualToString:@""] || ([street1TF.text isEqualToString:@""] && [street2TF.text isEqualToString:@""]) || [cityTF.text isEqualToString:@""] || [zipCodeTF.text isEqualToString:@""] || [countryTF.text isEqualToString:@""]){
        [self showAlertWithTitle:@"" message:@"Please fill all required fields"];
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSMutableDictionary *payment = [NSMutableDictionary new];
    NSMutableDictionary *addressParams = [NSMutableDictionary new];
    [payment addEntriesFromDictionary:@{@"cc_owner":nameTF.text,@"cc_exp_month":selectedMonth?[selectedMonth objectForKey:@"value"]:@"",@"cc_exp_year":selectedYear?[selectedYear objectForKey:@"value"]:@""}];
    if(_creditCard){
        [payment addEntriesFromDictionary:@{@"cc_type":[_creditCard objectForKey:@"type"]?[_creditCard objectForKey:@"type"]:@""}];
    }
    [addressParams addEntriesFromDictionary:@{@"prefix":selectedTitle?selectedTitle:@"",@"firstname":firstNameTF.text,@"lastname":lastNameTF.text,@"company":companyTF.text,@"job_description":jobTF.text,@"telephone":phoneTF.text,@"mobile":mobileTF.text,@"email":emailTF.text,@"fax":faxTF.text,@"street":@[street1TF.text,street2TF.text],@"city":cityTF.text,@"region":stateTF.text,@"postcode":zipCodeTF.text,@"region_id":selectedState?[selectedState objectForKey:@"state_id"]:@"",@"country_id":selectedCountry?[selectedCountry objectForKey:@"country_code"]:@""}];
    NSDictionary *address = [_creditCard objectForKey:@"address"];
    if(!_creditCard){
        [payment addEntriesFromDictionary:@{@"cc_number":numberTF.text}];
    }
    [params addEntriesFromDictionary:@{@"payment":payment,@"address":addressParams,@"is_default":defaultCb.checkState == M13CheckboxStateChecked?@"1":@"0"}];
    if([address objectForKey:@"tokencustomerid"]){
        [params addEntriesFromDictionary:@{@"TokenCustomerID":[address objectForKey:@"tokencustomerid"]}];
    }
    if(!_creditCard){
        [params addEntriesFromDictionary:@{@"EWAY_CARDNUMBER":numberTF.text}];
    }
    if(_creditCard){
        [params addEntriesFromDictionary:@{@"token_id":[_creditCard objectForKey:@"token_id"]?[_creditCard objectForKey:@"token_id"]:@""}];
    }
    [[CreditCardModel new] editCardWithParams:params];
    [self startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEditCreditCard:) name:DidEditCreditCard object:nil];
}
- (void)didEditCreditCard:(NSNotification *)noti{
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    if(responder.status == SUCCESS){
        CreditCardModel *model = noti.object;
        NSString *message = [model objectForKey:@"message"];
        [self showAlertWithTitle:@"" message:message];
        [self.delegate didSaveCreditCard];
    }else{
        [self showAlertWithTitle:@"" message:responder.message];
    }
}
- (void)addAccessoryInputViewForTextField:(UITextField *)textField{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    toolbar.items = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditting:)]];
    textField.inputAccessoryView = toolbar;
}
- (void)doneEditting:(id)sender{
    [self.view endEditing:YES];
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(pickerView == monthPickerView){
        return months.count;
    }else if(pickerView == yearPickerView){
        return years.count;
    }else if(pickerView == titlePickerView){
        return titles.count;
    }else if(pickerView == countryPickerView){
        return GLOBALVAR.storeView.allowedCountries.count;
    }else if(pickerView == statePickerView){
        if(states.count){
            return states.count;
        }
    }
    return 0;
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if(pickerView == monthPickerView){
        return [[months objectAtIndex:row] objectForKey:@"label"];
    }else if(pickerView == yearPickerView){
        return [[years objectAtIndex:row] objectForKey:@"label"];
    }else if(pickerView == titlePickerView){
        return [titles objectAtIndex:row];
    }else if(pickerView == countryPickerView){
        return [[GLOBALVAR.storeView.allowedCountries objectAtIndex:row] objectForKey:@"country_name"];
    }else if(pickerView == statePickerView){
        if(states.count){
            return [[states objectAtIndex:row] objectForKey:@"state_name"];
        }
    }
    return @"";
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if(pickerView == monthPickerView){
        if(selectedMonth != [months objectAtIndex:row]){
            selectedMonth = [months objectAtIndex:row];
            monthTF.text = [selectedMonth objectForKey:@"label"];
        }
    }else if(pickerView == yearPickerView){
        if(selectedYear != [years objectAtIndex:row]){
            selectedYear = [years objectAtIndex:row];
            yearTF.text = [selectedYear objectForKey:@"label"];
        }
    }else if(pickerView == titlePickerView){
        if(selectedTitle != [titles objectAtIndex:row]){
            selectedTitle = [titles objectAtIndex:row];
            titleTF.text = selectedTitle;
        }
    }else if(pickerView == countryPickerView){
        if(selectedCountry != [GLOBALVAR.storeView.allowedCountries objectAtIndex:row]){
            selectedCountry = [GLOBALVAR.storeView.allowedCountries objectAtIndex:row];
            states = [selectedCountry objectForKey:@"states"];
            if(states.count){
                selectedState = [states objectAtIndex:0];
                stateTF.text = [selectedState objectForKey:@"state_name"];
                stateTF.inputView = statePickerView;
                stateTF.rightView = stateRightView;
                stateTF.rightViewMode = UITextFieldViewModeAlways;
                [statePickerView selectRow:0 inComponent:0 animated:NO];
            }else{
                stateTF.text = @"";
                stateTF.inputView = nil;
                stateTF.rightView = nil;
                selectedState = nil;
            }
            countryTF.text = [selectedCountry objectForKey:@"country_name"];
        }
    }else if(pickerView == statePickerView){
        if(selectedState != [states objectAtIndex:row]){
            selectedState = [states objectAtIndex:row];
            stateTF.text = [selectedState objectForKey:@"state_name"];
        }
    }
}
- (void)doneEditting{
    [self.view endEditing:YES];
}
@end
