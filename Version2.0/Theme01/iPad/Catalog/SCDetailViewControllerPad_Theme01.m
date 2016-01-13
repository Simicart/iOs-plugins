//
//  SCDetailViewControllerPad_Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/24/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiRow.h>
#import <SimiCartBundle/UIImage+SimiCustom.h>
#import <SimiCartBundle/SimiProductModelCollection.h>
#import "SCDetailViewControllerPad_Theme01.h"

@implementation SCDetailViewControllerPad_Theme01
@synthesize tableViewProduct = _tableViewProduct, product = _product, allKeys = _allKeys;
@synthesize cells = _cells, numberOfRequired = _numberOfRequired, currentOptionIndexPath = _currentOptionIndexPath;
@synthesize currentValueOptionIndexPaths = _currentValueOptionIndexPaths, optionDict = _optionDict;
@synthesize plusButton = _plusButton, minusButton = _minusButton, textOption = _textOption, dateTimeOption = _dateTimeOption, selectedOptionPrice = _selectedOptionPrice;

- (void)viewDidLoadBefore
{
    if (productInfoViewPad_Theme01 == nil) {
        productInfoViewPad_Theme01 = [[SCProductInfoViewPad_Theme01 alloc] init];
    }
    [productInfoViewPad_Theme01 cusSetProduct:_product];
    
    _tableViewProduct = [[SimiTableView alloc] initWithFrame:self.view.bounds];
    _tableViewProduct.dataSource = self;
    _tableViewProduct.delegate = self;
    _tableViewProduct.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableViewProduct.delaysContentTouches = NO;
    _tableViewProduct.showsHorizontalScrollIndicator = NO;
    _tableViewProduct.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_tableViewProduct];
    
    _allKeys = [[NSArray alloc] init];
    _relatedCollection = [[SimiProductModelCollection alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetRelateProduct:) name:@"DidGetRelatedProductCollection" object:_relatedCollection];
    [_relatedCollection getRelatedProductCollectionWithProductId:[_product valueForKey:@"product_id"] limit:10 otherParams:@{}];
    [self startLoadingData];
    [self convertOptionToDictFromArray:[_product valueForKey:@"options"]];
    [self sortOption];
    [self setCells:nil];
    _numberOfRequired = [self countNumberOfRequired];
}

#pragma mark SET CELLS
- (void)setCells:(NSMutableArray *)cells{
    if (cells) {
        _cells = cells;
    }else{
        _cells = [[NSMutableArray alloc] init];
        SimiSection *section = [[SimiSection alloc] init];
        
        [section addRowWithIdentifier:PRODUCT_PRICE_CELL_ID height:productInfoViewPad_Theme01.heightofInfoView];
        [section addRowWithIdentifier:PRODUCT_DESCRIPTION_CELL_ID height:100];
        for (int i = 0; i < _allKeys.count; i++) {
            [section addRowWithIdentifier:PRODUCT_OPTION_TYPE_CELL_ID height:60];
        }
        [section addRowWithIdentifier:PRODUCT_ADDTOCART_CELL_ID height:120];
        if (_relatedCollection.count > 0) {
            float height = (_relatedCollection.count/2 +1)*260;
            [section addRowWithIdentifier:PRODUCT_RELATED_CELL_ID height:height];
        }
        [_cells addObject:section];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SCProductViewController-InitCellsAfter" object:_cells userInfo:@{@"controller": self}];
}

#pragma mark UI TABLEVIEW DATASOURCE
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _cells.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return isLoading ? 0 : [[_cells objectAtIndex:section] count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiRow *row = [[_cells objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if ([row.identifier isEqualToString:PRODUCT_OPTION_VALUE_CELL_ID]) {
//        Special height for datetime input
        NSUInteger bias = [(SimiSection *)[_cells objectAtIndex:0] getRowIndexByIdentifier:PRODUCT_OPTION_TYPE_CELL_ID];
        NSString *key = [_allKeys objectAtIndex:(_currentOptionIndexPath.row - bias)];
        NSDictionary *option = [[_optionDict valueForKey:key] objectAtIndex:0];
        if ([[option objectForKey:@"option_type"] isEqualToString:@"date"]
            || [[option objectForKey:@"option_type"] isEqualToString:@"date_time"]
            || [[option objectForKey:@"option_type"] isEqualToString:@"time"]
            ) {
            return 162;
        }
        if ([[option valueForKey:@"option_type"] isEqualToString:@"text"]&&[_product productType] == ProductTypeGrouped) {
            return 100;
        }
    }
    return row.height;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    NSString *identifier = simiRow.identifier;
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if ([identifier isEqualToString:PRODUCT_PRICE_CELL_ID]) {
#pragma mark Product Information
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
            CGRect frame = cell.bounds;
            frame.origin.x += 15;
            [productInfoViewPad_Theme01 setFrame:frame];
            [cell addSubview:productInfoViewPad_Theme01];
        }
        [productInfoViewPad_Theme01 cusSetProduct:_product];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else if ([identifier isEqualToString:PRODUCT_DESCRIPTION_CELL_ID]){
#pragma mark Product Short Description
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            UILabel *shortLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 380, 20)];
            shortLabel.text = [SCLocalizedString(@"Description") stringByAppendingString:@" :"];
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                [shortLabel setTextAlignment:NSTextAlignmentRight];
                [shortLabel setText:[NSString stringWithFormat:@":%@", SCLocalizedString(@"Description")]];
            }
            //  End RTL
            
            [shortLabel setFont:[UIFont fontWithName:THEME01_FONT_NAME_BOLD size:18]];
            NSString *shortDescription = @"";
            if([_product valueForKey:@"product_short_description"])
                shortDescription = [[_product valueForKey:@"product_short_description"] stringByConvertingHTMLToPlainText];
            UILabel *shortDescriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 38, self.view.frame.size.width - 50, 40)];
            shortDescriptionLabel.text = shortDescription;
            [shortDescriptionLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_LIGHT] size:16]];
            shortDescriptionLabel.numberOfLines = 2;
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                [shortDescriptionLabel setTextAlignment:NSTextAlignmentRight];
                shortDescriptionLabel.numberOfLines = 2;
            }
            //  End RTL
            UIImageView *imageNext = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"theme1_descriptionnext"]];
            imageNext.frame = CGRectMake(self.view.frame.size.width - 30, 27, 18, 43);
            [cell addSubview:imageNext];
            [cell addSubview:shortLabel];
            [cell addSubview:shortDescriptionLabel];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }else if ([identifier isEqualToString:PRODUCT_RELATED_CELL_ID]){
#pragma mark Product Related
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UICollectionViewLayout* stackLayout = [[UICollectionViewLayout alloc] init];
            _relatedProductViewController = [[SCCollectionViewControllerPad_Theme01 alloc]initWithCollectionViewLayout:stackLayout];
            _relatedProductViewController.productCollection = [_relatedCollection mutableCopy];
            _relatedProductViewController.delegate = self;
            _relatedProductViewController.isRelatedProduct = YES;
            _relatedProductViewController.collectionView.scrollEnabled = NO;
            [_relatedProductViewController.collectionView setFrame:cell.bounds];
            [cell addSubview:_relatedProductViewController.collectionView];
            
            CGRect frame = CGRectMake(15, 0, 410, 40);
            UILabel *lblRelate = [[UILabel alloc]initWithFrame:frame];
            [lblRelate setFont:[UIFont fontWithName:THEME01_FONT_NAME_BOLD size:22]];
            [lblRelate setTextAlignment:NSTextAlignmentLeft];
            [lblRelate setTextColor:[UIColor blackColor]];
            [lblRelate setBackgroundColor:[UIColor colorWithRed:236.0/255 green:236.0/255 blue:236.0/255 alpha:236.0/255]];
            [lblRelate setText:@"Relate Product"];
            [cell addSubview:lblRelate];
        }
    }else if([identifier isEqualToString:PRODUCT_ADDTOCART_CELL_ID])
    {
#pragma mark Add To Cart
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UIImageView *imageAddToCart = [[UIImageView alloc]initWithFrame:CGRectMake(15, 30, 410, 60)];
            [imageAddToCart setBackgroundColor:THEME_COLOR];
            [cell addSubview:imageAddToCart];
            
            UILabel *lblAddToCart = [[UILabel alloc]initWithFrame:CGRectMake(15, 45, 410, 30)];
            [lblAddToCart setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:30]];
            [lblAddToCart setTextColor:[UIColor whiteColor]];
            [lblAddToCart setTextAlignment:NSTextAlignmentCenter];
            [lblAddToCart setText:[SCLocalizedString(@"Add To Cart") uppercaseString]];
            [cell addSubview:lblAddToCart];
            
            UIButton *btnAddToCart = [[UIButton alloc]initWithFrame:CGRectMake(15, 30, 410, 60)];
            [btnAddToCart addTarget:self action:@selector(addToCart) forControlEvents:UIControlEventTouchUpInside];
            [btnAddToCart setBackgroundColor:[UIColor clearColor]];
            [cell addSubview:btnAddToCart];
            if (![[_product valueForKey:@"stock_status"]boolValue]) {
                btnAddToCart.enabled = NO;
                imageAddToCart.alpha = 0.3;
                lblAddToCart.alpha = 0.3;
            }
        }
    }else if ([identifier isEqualToString:PRODUCT_OPTION_TYPE_CELL_ID]){
#pragma mark Option Type Cell
        //Option type
        NSDictionary *option;
        NSInteger number = 0;
        if (indexPath.row > _currentOptionIndexPath.row) {
            number = [self numberOfShowedOption];
        }
        
        NSString *requiredText = @"";
        NSUInteger bias = [(SimiSection *)[_cells objectAtIndex:0] getRowIndexByIdentifier:PRODUCT_OPTION_TYPE_CELL_ID];
        NSString *key = [_allKeys objectAtIndex:(indexPath.row - number - bias)];
        option = [[_optionDict valueForKey:key] objectAtIndex:0];
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        CGRect frame = CGRectMake(15, 0, 410, simiRow.height);
        SCOptionTypeView_Theme01 *optionTypeView  = [[SCOptionTypeView_Theme01 alloc]initWithFrame:frame];
        optionTypeView.backgroundColor = THEME01_OPTION_COLOR;
        [cell addSubview:optionTypeView];
        
        switch (_product.productType) {
            case ProductTypeGrouped:
            {
                optionTypeView.lblOptionName.text = [NSString stringWithFormat:@"%@ x %@", [option valueForKey:@"option_qty"], key];
            }
                break;
            default:
            {
                optionTypeView.lblOptionName.text = key;
                if ([_selectedOptionPrice valueForKeyPath:key] != nil) {
                    if([[_selectedOptionPrice valueForKey:key] floatValue] > 0){
                        optionTypeView.lblOptionPrice.text = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[NSNumber numberWithFloat:[[_selectedOptionPrice valueForKey:key] floatValue]]];
                        [optionTypeView.imageDropdown setHidden:YES];
                        [optionTypeView.lblRequire setHidden:YES];
                    }
                }else{
                    if ([[option valueForKey:@"is_required"] boolValue]) {
                        requiredText = SCLocalizedString(@"(*)");
                    }else{
                        requiredText = @"";
                    }
                }
            }
                break;
        }
        [optionTypeView changeLocation];
        optionTypeView.lblRequire .text = requiredText;
    }else if ([identifier isEqualToString:PRODUCT_OPTION_VALUE_CELL_ID]){
#pragma mark Option Value Cell
        
        NSUInteger bias = [(SimiSection *)[_cells objectAtIndex:0] getRowIndexByIdentifier:PRODUCT_OPTION_TYPE_CELL_ID];
        NSString *key = [_allKeys objectAtIndex:(_currentOptionIndexPath.row - bias)];
        NSMutableDictionary *option = [[_optionDict valueForKey:key] objectAtIndex:(indexPath.row - _currentOptionIndexPath.row - 1)];
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        CGRect frame = cell.textLabel.frame;
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if([[option objectForKey:@"option_type"] isEqualToString:@"single"] || [[option objectForKey:@"option_type"] isEqualToString:@"multi"]){
            CGFloat optionQty = [[option valueForKey:@"option_qty"] floatValue];
            NSString *optionName = @"";
            if (optionQty > 1.0f) {
                optionName = [NSString stringWithFormat:@"%.0f x %@", optionQty, [option valueForKey:@"option_value"]];
            } else {
                optionName = [option valueForKey:@"option_value"];
            }
            UILabel *optionNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 0, 200, 50)];
            optionNameLabel.text = optionName;
            optionNameLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:14.0];
            optionNameLabel.textColor = [UIColor blackColor];
            optionNameLabel.numberOfLines = 3;
            optionNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                [optionNameLabel setFrame:CGRectMake(200, 0, 200, 50)];
                [optionNameLabel setTextAlignment:NSTextAlignmentRight];
            }
            //  End RTL
            [cell addSubview:optionNameLabel];
            
            if([[SimiGlobalVar sharedInstance] isShowZeroPrice] || [[option valueForKey:@"option_price"] integerValue] != 0){
                //Add Option Price
                frame = CGRectMake(285, 5, 125, 20);
                NSString *optionPrice = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[NSNumber numberWithFloat:[[option valueForKey:@"option_price"] floatValue]]];
                UILabel *optionPriceLabel = [[UILabel alloc]initWithFrame:frame];
                optionPriceLabel.text = optionPrice;
                optionPriceLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:14.0];
                optionPriceLabel.textColor = THEME01_PRICE_COLOR;
                [optionPriceLabel removeFromSuperview];
                //  Liam Update RTL
                if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                    [optionPriceLabel setFrame:CGRectMake(75, 5, 120, 20)];
                    [optionPriceLabel setTextAlignment:NSTextAlignmentRight];
                }
                //  End RTL
                [cell addSubview:optionPriceLabel];
                //Add Option Tax Price
                if([option valueForKey:@"option_price_incl_tax"]){
//                    Add Option Tax Price
                    frame = CGRectMake(280, 25, 125, 20);
                    UILabel *optionTaxPriceLabel = [[UILabel alloc]initWithFrame:frame];
                    NSString *optionPiceInclTax = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[NSNumber numberWithFloat:[[option valueForKey:@"option_price_incl_tax"] floatValue]]];
                    optionPiceInclTax = [[optionPiceInclTax stringByAppendingString:@" "] stringByAppendingString:SCLocalizedString(@"Incl. Tax")];
                    optionPiceInclTax = [[@" (" stringByAppendingString:optionPiceInclTax] stringByAppendingString:@")"];
                    optionTaxPriceLabel.text = optionPiceInclTax;
                    optionTaxPriceLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:14.0];
                    optionTaxPriceLabel.textColor = THEME01_PRICE_COLOR;
                    [optionTaxPriceLabel removeFromSuperview];
                    //  Liam Update RTL
                    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                        [optionTaxPriceLabel setFrame:CGRectMake(75, 25, 120, 20)];
                        [optionTaxPriceLabel setTextAlignment:NSTextAlignmentRight];
                    }
                    //  End RTL
                    [cell addSubview:optionTaxPriceLabel];
                }
            }else{
                cell.detailTextLabel.text = @"";
            }
        }
        if ([[option valueForKey:@"is_available"] boolValue]) {
            cell.textLabel.enabled = YES;
            cell.detailTextLabel.enabled = YES;
        }else{
            cell.textLabel.enabled = NO;
            cell.detailTextLabel.enabled = NO;
        }
        switch (_product.productType) {
            case ProductTypeGrouped:{
                cell.textLabel.text = @"";
                cell.detailTextLabel.text=@"";
                if (_plusButton == nil) {
                    _plusButton = [[UIButton alloc] initWithFrame:CGRectMake(370, 6, 44, 44)];
                    
                    [_plusButton setImage:[[UIImage imageNamed:@"theme1_option_plus"] imageWithColor:THEME01_SUB_PART_COLOR] forState:UIControlStateNormal];
                    _plusButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
                    _plusButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
                    [_plusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [_plusButton.layer setCornerRadius:14.0f];
                    [_plusButton.layer setMasksToBounds:YES];
                    [_plusButton setAdjustsImageWhenHighlighted:YES];
                    [_plusButton setAdjustsImageWhenDisabled:YES];
                    [_plusButton addTarget:self action:@selector(didSelectPlusButtonOptionQty:) forControlEvents:UIControlEventTouchUpInside];
                }
                _plusButton.simiObjectIdentifier = indexPath;
                
                if (_minusButton == nil) {
                    _minusButton = [[UIButton alloc] initWithFrame:CGRectMake(310, 6, 44, 44)];
                    [_minusButton setImage:[[UIImage imageNamed:@"theme1_option_minus"] imageWithColor:THEME01_SUB_PART_COLOR] forState:UIControlStateNormal];
                    _minusButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
                    _minusButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
                    [_minusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    _minusButton.titleLabel.adjustsFontSizeToFitWidth = YES;
                    [_minusButton.layer setCornerRadius:14.0f];
                    [_minusButton.layer setMasksToBounds:YES];
                    [_minusButton setAdjustsImageWhenHighlighted:YES];
                    [_minusButton setAdjustsImageWhenDisabled:YES];
                    [_minusButton addTarget:self action:@selector(didSelectMinusButtonOptionQty:) forControlEvents:UIControlEventTouchUpInside];
                }
                _minusButton.simiObjectIdentifier = indexPath;
                
                if (_optionViewCell == nil) {
                    _optionViewCell = [[SCOptionGroupViewCellPad_Theme01 alloc]initWithFrame:CGRectMake(25, 20, cell.frame.size.width - 160, cell.frame.size.height - 20)];
                }
                [cell addSubview:_plusButton];
                [cell addSubview:_minusButton];
                for (UIView *subview in _optionViewCell.subviews) {
                    [subview removeFromSuperview];
                }
                [_optionViewCell setPriceOption:option];
                [cell addSubview:_optionViewCell];
            }
                break;
            default:{
                NSString *optionImageName = @"";
                if ([[option valueForKey:@"is_selected"] boolValue] && [[option valueForKey:@"is_available"] boolValue]) {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    if([[option objectForKey:@"option_type"] isEqualToString:@"single"]){
                        optionImageName = @"theme1_option_round_checked";
                    }else if([[option objectForKey:@"option_type"] isEqualToString:@"multi"]){
                        optionImageName = @"theme1_option_square_checked";
                    }
                }else{
                    if([[option objectForKey:@"option_type"] isEqualToString:@"single"]){
                        optionImageName = @"theme1_option_round";
                    }else if([[option objectForKey:@"option_type"] isEqualToString:@"multi"]){
                        optionImageName = @"theme1_option_square";
                    }
                    
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                UIImage *optionImage = [[UIImage imageNamed:optionImageName] imageWithColor:THEME01_SUB_PART_COLOR];
                UIImageView *optionImageView = [[UIImageView alloc]initWithFrame:CGRectMake(55, 19, 12, 12)];
                optionImageView.image = optionImage;
                [cell addSubview:optionImageView];
                // Check for text field and datetime option
                if ([[option objectForKey:@"option_type"] isEqualToString:@"text"]) {
                    // Text Option
                    if (_textOption == nil) {
                        _textOption = [[UITextField alloc] initWithFrame:CGRectMake(15, 5, 400, 40)];
                        _textOption.delegate = self;
                        _textOption.clearButtonMode = UITextFieldViewModeWhileEditing;
                        [_textOption addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingChanged];
                        [_textOption addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboardInputText) name:UIKeyboardDidShowNotification object:nil];
                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboardInputText) name:UIKeyboardWillHideNotification object:nil];
                    }
                    _textOption.placeholder = [_allKeys objectAtIndex:indexPath.row - 3];
                    _textOption.text = [option objectForKey:@"option_value"];
                    _textOption.simiObjectIdentifier = indexPath;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    [cell addSubview:_textOption];
                } else if ([[option objectForKey:@"option_type"] isEqualToString:@"date"]
                           || [[option objectForKey:@"option_type"] isEqualToString:@"date_time"]
                           || [[option objectForKey:@"option_type"] isEqualToString:@"time"]
                           ) {
                    // Datetime Option
                    if (_dateTimeOption == nil) {
                        _dateTimeOption = [[UIDatePicker alloc] init];
                        _dateTimeOption.frame = CGRectMake(0.0f, 0.0f, cell.bounds.size.width, 162);
                        [_dateTimeOption addTarget:self action:@selector(changeDatePicker:) forControlEvents:UIControlEventValueChanged];
                    }
                    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
                    if ([[option objectForKey:@"option_type"] isEqualToString:@"date"]) {
                        _dateTimeOption.datePickerMode = UIDatePickerModeDate;
                        [dateFormater setDateFormat:@"yyyy-MM-dd"];
                    } else if ([[option objectForKey:@"option_type"] isEqualToString:@"date_time"]) {
                        _dateTimeOption.datePickerMode = UIDatePickerModeDateAndTime;
                        [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    } else {
                        _dateTimeOption.datePickerMode = UIDatePickerModeTime;
                        [dateFormater setDateFormat:@"HH:mm:ss"];
                    }
                    _dateTimeOption.simiObjectIdentifier = indexPath;
                    if ([option objectForKey:@"option_value"]) {
                        _dateTimeOption.date = [dateFormater dateFromString:[option objectForKey:@"option_value"]];
                    } else {
                        _dateTimeOption.date = [NSDate date];
                    }
                    cell.textLabel.text = nil;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.detailTextLabel.text = nil;
                    [cell addSubview:_dateTimeOption];
                }
            }
                break;
        }
    }
    for (id obj in cell.subviews){
        if ([NSStringFromClass([obj class]) isEqualToString:@"UITableViewCellScrollView"]){
            UIScrollView *scroll = (UIScrollView *) obj;
            scroll.delaysContentTouches = NO;
            break;
        }
    }
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedProductCell-After" object:cell userInfo:@{@"indexPath": indexPath, @"productmodel":self.product, @"controller":self}];
    return cell;
}

#pragma mark TABLE VIEW DELEGATE
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectProductCellAtIndexPath" object:tableView userInfo:@{@"indexPath": indexPath}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    SimiSection *section = [_cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    NSString *identifier = row.identifier;
    if ([identifier isEqualToString:PRODUCT_DESCRIPTION_CELL_ID]){
        [self.delegate didSelectDescriptionRow];
//        Basic Product info
    }else if ([identifier isEqualToString:PRODUCT_OPTION_TYPE_CELL_ID]){
//        Option type cell
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self didSelectOptionTypeAtIndexPath:indexPath];
    }else if ([identifier isEqualToString:PRODUCT_OPTION_VALUE_CELL_ID]){
//        Option value cell
        if (_product.productType != ProductTypeGrouped) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self didSelectOptionValueAtIndexPath:indexPath];
        }
    }
}

#pragma mark ACTION OPTION CHOICE

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (!_currentOptionIndexPath) {
        return;
    }
    NSString *text = textField.text;
    NSUInteger bias = [(SimiSection *)[_cells objectAtIndex:0] getRowIndexByIdentifier:PRODUCT_OPTION_TYPE_CELL_ID];
    NSString *key = [_allKeys objectAtIndex:(_currentOptionIndexPath.row - bias)];
    NSMutableDictionary *option = [[_optionDict valueForKey:key] objectAtIndex:0];
    if (text == nil || [text isEqualToString:@""]) {
        [option removeObjectForKey:@"option_value"];
        [option setValue:@"NO" forKey:@"is_selected"];
    } else {
        [option setValue:text forKey:@"option_value"];
        [option setValue:@"YES" forKey:@"is_selected"];
    }
    //Set option price
    CGFloat price = [[_product valueForKey:@"product_price"] floatValue];
    switch (_product.productType) {
        case ProductTypeGrouped:
            price = 0;
            break;
        default:
            break;
    }
    NSString *optionProductName = [_product valueForKeyPath:@"product_name"];
    if (_selectedOptionPrice == nil) {
        _selectedOptionPrice = [[NSMutableDictionary alloc] init];
    }
    CGFloat totalOptionPrice = 0;
    CGFloat totalOptionPriceInclTax = 0;
    for (NSString *tempKey in _allKeys) {
        CGFloat optionPrice = 0;
        CGFloat optionPriceInclTax = 0;
        BOOL isSelected = NO;
        for (NSDictionary *opt in [_optionDict valueForKey:tempKey]) {
            if ([[opt valueForKey:@"is_selected"] boolValue]) {
                if (_product.productType == ProductTypeGrouped) {
                    optionPrice += [[opt valueForKey:@"option_price"] floatValue] * [[opt valueForKey:@"option_qty"] floatValue];
                    optionProductName = [NSString stringWithFormat:@"%@, %@x%@", optionProductName, [opt valueForKey:@"option_qty"], [opt valueForKeyPath:@"option_value"]];
                    if([opt valueForKey:@"option_price_incl_tax"]){
                        optionPriceInclTax += [[opt valueForKey:@"option_price_incl_tax"] floatValue] * [[opt valueForKey:@"option_qty"] floatValue];
                    }else if([opt valueForKey:@"option_price"]){
                        optionPriceInclTax += [[opt valueForKey:@"option_price"] floatValue] * [[opt valueForKey:@"option_qty"] floatValue];
                    }
                }else{
                    optionPrice += [[opt valueForKey:@"option_price"] floatValue];
                    optionProductName = [NSString stringWithFormat:@"%@, %@", optionProductName, [opt valueForKeyPath:@"option_value"]];
                    if([opt valueForKey:@"option_price_incl_tax"]){
                        optionPriceInclTax += [[opt valueForKey:@"option_price_incl_tax"] floatValue];
                    }else if([opt valueForKey:@"option_price"]){
                        optionPriceInclTax += [[opt valueForKey:@"option_price"] floatValue];
                    }
                }
                isSelected = YES;
            }
        }
        if (isSelected) {
            [_selectedOptionPrice setValue:[NSString stringWithFormat:@"%.2f", optionPrice] forKey:tempKey];
        }else{
            [_selectedOptionPrice removeObjectForKey:tempKey];
        }
        price += optionPrice;
        totalOptionPrice += optionPrice;
        totalOptionPriceInclTax += optionPriceInclTax;
    }
    
//    Set product price
    [_product setValue:[NSString stringWithFormat:@"%.2f", price] forKey:@"option_product_price"];
    [_product setValue:[NSString stringWithFormat:@"%.2f", totalOptionPrice] forKey:@"total_option_price"];
    [_product setValue:[NSString stringWithFormat:@"%.2f", totalOptionPriceInclTax] forKey:@"total_option_price_incl_tax"];
    [_product setValue:optionProductName forKey:@"option_product_name"];
    
    [_tableViewProduct reloadRowsAtIndexPaths:@[_currentOptionIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)changeDatePicker:(UIDatePicker *)datePicker
{
    if (!_currentOptionIndexPath) {
        return;
    }
    NSUInteger bias = [(SimiSection *)[_cells objectAtIndex:0] getRowIndexByIdentifier:PRODUCT_OPTION_TYPE_CELL_ID];
    NSString *key = [_allKeys objectAtIndex:(_currentOptionIndexPath.row - bias)];
    NSMutableDictionary *option = [[_optionDict valueForKey:key] objectAtIndex:0];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    if ([[option objectForKey:@"option_type"] isEqualToString:@"date"]) {
        [dateFormater setDateFormat:@"yyyy-MM-dd"];
    } else if ([[option objectForKey:@"option_type"] isEqualToString:@"date_time"]) {
        [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    } else {
        [dateFormater setDateFormat:@"HH:mm:ss"];
    }
    if ([option objectForKey:@"option_value"] == nil) {
//        Change option value and title
        [option setValue:@"YES" forKey:@"is_selected"];
    }
    [option setValue:[dateFormater stringFromDate:datePicker.date] forKey:@"option_value"];
    
    //Set option price
    CGFloat price = [[_product valueForKey:@"product_price"] floatValue];
    CGFloat totalOptionPrice = 0;
    CGFloat totalOptionPriceInclTax = 0;
    NSString *optionProductName = [_product valueForKeyPath:@"product_name"];
    if (_selectedOptionPrice == nil) {
        _selectedOptionPrice = [[NSMutableDictionary alloc] init];
    }
    for (NSString *tempKey in _allKeys) {
        CGFloat optionPrice = 0;
        CGFloat optionPriceInclTax = 0;
        BOOL isSelected = NO;
        for (NSDictionary *opt in [_optionDict valueForKey:tempKey]) {
            if ([[opt valueForKey:@"is_selected"] boolValue]) {
                if (_product.productType == ProductTypeGrouped) {
                    optionPrice += [[opt valueForKey:@"option_price"] floatValue] * [[opt valueForKey:@"option_qty"] floatValue];
                    optionProductName = [NSString stringWithFormat:@"%@, %@x%@", optionProductName, [opt valueForKey:@"option_qty"], [opt valueForKeyPath:@"option_value"]];
                    if([opt valueForKey:@"option_price_incl_tax"]){
                        optionPriceInclTax += [[opt valueForKey:@"option_price_incl_tax"] floatValue] * [[opt valueForKey:@"option_qty"] floatValue];
                    }else if([opt valueForKey:@"option_price"]){
                        optionPriceInclTax += [[opt valueForKey:@"option_price"] floatValue] * [[opt valueForKey:@"option_qty"] floatValue];
                    }
                }else{
                    optionPrice += [[opt valueForKey:@"option_price"] floatValue];
                    optionProductName = [NSString stringWithFormat:@"%@, %@", optionProductName, [opt valueForKeyPath:@"option_value"]];
                    optionPriceInclTax += [[opt valueForKey:@"option_price_incl_tax"] floatValue];
                }
                isSelected = YES;
            }
        }
        if (isSelected) {
            [_selectedOptionPrice setValue:[NSString stringWithFormat:@"%.2f", optionPrice] forKey:tempKey];
        }else{
            [_selectedOptionPrice removeObjectForKey:tempKey];
        }
        price += optionPrice;
        totalOptionPrice += optionPrice;
        totalOptionPriceInclTax += optionPriceInclTax;
    }
//    Set product price
    [_product setValue:[NSString stringWithFormat:@"%.2f", price] forKey:@"option_product_price"];
    [_product setValue:optionProductName forKey:@"option_product_name"];
    [_product setValue:[NSString stringWithFormat:@"%.2f", totalOptionPrice] forKey:@"total_option_price"];
    [_product setValue:[NSString stringWithFormat:@"%.2f", totalOptionPriceInclTax] forKey:@"total_option_price_incl_tax"];
    [_tableViewProduct reloadRowsAtIndexPaths:@[_currentOptionIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    [_tableViewProduct reloadData];
}

#pragma mark OPTION HANDLE TASK
- (void)didSelectOptionTypeAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath isEqual:self.currentOptionIndexPath]) {
        //Hide Option
        self.currentOptionIndexPath = nil;
        NSMutableIndexSet *deleteSet = [[NSMutableIndexSet alloc] init];
        for (int i = 0; i < self.currentValueOptionIndexPaths.count; i++) {
            NSIndexPath *deleteIndexPath = [self.currentValueOptionIndexPaths objectAtIndex:i];
            [deleteSet addIndex:deleteIndexPath.row];
        }
        SimiSection *section = [self.cells objectAtIndex:indexPath.section];
        [section removeRowsAtIndexes:deleteSet];
        
        [self.tableViewProduct beginUpdates];
        [self.tableViewProduct deleteRowsAtIndexPaths:self.currentValueOptionIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableViewProduct endUpdates];
        [self.currentValueOptionIndexPaths removeAllObjects];
    }else{
        NSInteger number = 0;
        if (indexPath.row > self.currentOptionIndexPath.row) {
            number = [self numberOfShowedOption];
        }
        if (self.currentOptionIndexPath != nil) {
            //Hide previous option
            [self didSelectOptionTypeAtIndexPath:self.currentOptionIndexPath];
        }
        self.currentOptionIndexPath = indexPath;
        //Get correct index path for option
        self.currentOptionIndexPath = [NSIndexPath indexPathForRow:(self.currentOptionIndexPath.row - number) inSection:indexPath.section];
        //Show option
        NSUInteger bias = [(SimiSection *)[self.cells objectAtIndex:0] getRowIndexByIdentifier:PRODUCT_OPTION_TYPE_CELL_ID];
        NSString *key = [self.allKeys objectAtIndex:(self.currentOptionIndexPath.row - bias)];
        NSArray *options = [self.optionDict valueForKey:key];
        if (self.currentValueOptionIndexPaths == nil) {
            self.currentValueOptionIndexPaths = [[NSMutableArray alloc] init];
        }
        [self.currentValueOptionIndexPaths removeAllObjects];
        for (int i = 0; i < options.count; i++) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:(i+self.currentOptionIndexPath.row+1) inSection:indexPath.section];
            SimiSection *section = [self.cells objectAtIndex:indexPath.section];
            SimiRow *row = [[SimiRow alloc] initWithIdentifier:PRODUCT_OPTION_VALUE_CELL_ID height:50];
            [section insertObject:row inRowsAtIndex:path.row];
            [self.currentValueOptionIndexPaths addObject:path];
        }
        [self.tableViewProduct beginUpdates];
        [self.tableViewProduct insertRowsAtIndexPaths:self.currentValueOptionIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableViewProduct endUpdates];
    }
}

- (void)didSelectOptionValueAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger bias = [(SimiSection *)[_cells objectAtIndex:0] getRowIndexByIdentifier:PRODUCT_OPTION_TYPE_CELL_ID];
    NSString *key = [_allKeys objectAtIndex:(_currentOptionIndexPath.row - bias)];
    //Set option is selected
    NSDictionary *option = [[_optionDict valueForKey:key] objectAtIndex:(indexPath.row - _currentOptionIndexPath.row - 1)];
    if (_product.productType == ProductTypeGrouped) {
        if ([[option valueForKey:@"option_qty"] integerValue] > 0) {
            [option setValue:@"YES" forKey:@"is_selected"];
        }else{
            [option setValue:@"NO" forKey:@"is_selected"];
        }
    }else{
        // Text option is not required select
        if ([[option objectForKey:@"option_type"] isEqualToString:@"text"]) {
            return;
        }
        if ([[option valueForKey:@"is_selected"] boolValue]){
            //De-select option if it was chosen
            [option setValue:@"NO" forKey:@"is_selected"];
        }else{
            [option setValue:@"YES" forKey:@"is_selected"];
            //De-select other option if it is single type
            if ([[option valueForKey:@"option_type"] isEqualToString:@"single"]) {
                for (NSDictionary *opt in [_optionDict valueForKey:key]) {
                    if (![opt isEqual:option] && [[opt valueForKey:@"is_selected"] boolValue]) {
                        [opt setValue:@"NO" forKey:@"is_selected"];
                    }
                }
            }
            if (![[option valueForKey:@"is_available"] boolValue]) {
                for (NSDictionary *opt in [_optionDict valueForKey:key]) {
                    if ([[opt valueForKey:@"is_available"] boolValue]) {
                        [opt setValue:@"NO" forKey:@"is_available"];
                    }else{
                        [opt setValue:@"YES" forKey:@"is_available"];
                    }
                }
            }
        }
    }
    
    //Handle dependence options
    NSArray *dependenceOptionIds = [option valueForKey:@"dependence_option_ids"];
    NSMutableSet *depenceOptionSet = [NSMutableSet setWithArray:dependenceOptionIds];
    if (dependenceOptionIds.count > 0) {
        for (NSString *key2 in _allKeys) {
            if (![key2 isEqualToString:key]) {
                for (NSDictionary *opt in [_optionDict valueForKey:key2]) {
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
    
    //Set option price
    CGFloat price = [[_product valueForKey:@"product_price"] floatValue];
    switch (_product.productType) {
        case ProductTypeGrouped:
            price = 0;
            break;
        default:
            break;
    }
    NSString *optionProductName = [_product valueForKeyPath:@"product_name"];
    if (_selectedOptionPrice == nil) {
        _selectedOptionPrice = [[NSMutableDictionary alloc] init];
    }
    CGFloat totalOptionPrice = 0;
    CGFloat totalOptionPriceInclTax = 0;
    for (NSString *tempKey in _allKeys) {
        CGFloat optionPrice = 0;
        CGFloat optionPriceInclTax = 0;
        BOOL isSelected = NO;
        for (NSDictionary *opt in [_optionDict valueForKey:tempKey]) {
            if ([[opt valueForKey:@"is_selected"] boolValue]) {
                if (_product.productType == ProductTypeGrouped) {
                    optionPrice += [[opt valueForKey:@"option_price"] floatValue] * [[opt valueForKey:@"option_qty"] floatValue];
                    optionProductName = [NSString stringWithFormat:@"%@, %@x%@", optionProductName, [opt valueForKey:@"option_qty"], [opt valueForKeyPath:@"option_value"]];
                    if([opt valueForKey:@"option_price_incl_tax"]){
                        optionPriceInclTax += [[opt valueForKey:@"option_price_incl_tax"] floatValue] * [[opt valueForKey:@"option_qty"] floatValue];
                    }else if([opt valueForKey:@"option_price"]){
                        optionPriceInclTax += [[opt valueForKey:@"option_price"] floatValue] * [[opt valueForKey:@"option_qty"] floatValue];
                    }
                }else{
                    optionPrice += [[opt valueForKey:@"option_price"] floatValue];
                    optionProductName = [NSString stringWithFormat:@"%@, %@", optionProductName, [opt valueForKeyPath:@"option_value"]];
                    if([opt valueForKey:@"option_price_incl_tax"]){
                        optionPriceInclTax += [[opt valueForKey:@"option_price_incl_tax"] floatValue];
                    }else if([opt valueForKey:@"option_price"]){
                        optionPriceInclTax += [[opt valueForKey:@"option_price"] floatValue];
                    }
                }
                isSelected = YES;
            }
        }
        if (isSelected) {
            [_selectedOptionPrice setValue:[NSString stringWithFormat:@"%.2f", optionPrice] forKey:tempKey];
        }else{
            [_selectedOptionPrice removeObjectForKey:tempKey];
        }
        price += optionPrice;
        totalOptionPrice += optionPrice;
        totalOptionPriceInclTax += optionPriceInclTax;
        
    }
    
    //Set product price
    [_product setValue:[NSString stringWithFormat:@"%.2f", price] forKey:@"option_product_price"];
    [_product setValue:[NSString stringWithFormat:@"%.2f", totalOptionPrice] forKey:@"total_option_price"];
    [_product setValue:[NSString stringWithFormat:@"%.2f", totalOptionPriceInclTax] forKey:@"total_option_price_incl_tax"];
    [_product setValue:optionProductName forKey:@"option_product_name"];
    [_tableViewProduct reloadData];
}

#pragma mark ADD TO CART
- (BOOL)isCheckedAllRequiredOptions{
    NSInteger count = 0;
    BOOL checked = YES;
    for (NSString *key in [_optionDict allKeys]) {
        NSArray *arr = [_optionDict valueForKey:key];
        if ([[[arr objectAtIndex:0] valueForKeyPath:@"is_required"] boolValue] || _product.productType == ProductTypeGrouped) {
            for (NSDictionary *op in arr) {
                if ([[op valueForKey:@"is_selected"] boolValue]) {
                    count++;
                    break;
                }
            }
        }
    }
    if (_product.productType == ProductTypeGrouped) {
        _numberOfRequired = 1;
    }
    if (count < _numberOfRequired){
        checked = NO;
    }
    return checked;
}
- (void)addToCart
{
    if ((self.optionDict.count > 0 && [self isCheckedAllRequiredOptions]) || (self.optionDict.count == 0)) {
        [self startLoadingData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddToCart" object:nil userInfo:@{@"data":self.product}];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidAddToCart" object:nil];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Required options are not selected.") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
}

#pragma mark DID GET RELATEPRODUCT
- (void)didGetRelateProduct:(NSNotification*)noti
{
    SimiResponder *respond = (SimiResponder*)[noti.userInfo valueForKey:@"responder"];
    if ([[respond.status uppercaseString] isEqualToString:@"SUCCESS"]) {
        [self setCells:nil];
        [_tableViewProduct reloadData];
    }
    [self stopLoadingData];
}

#pragma mark Receive Noti
- (void)didReceiveNotification:(NSNotification*)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([[responder.status uppercaseString] isEqualToString:@"SUCCESS"]) {
        if([noti.name isEqualToString:@"DidAddToCart"]){
            [self stopLoadingData];
            [self removeObserverForNotification:noti];
        }
    }
}

#pragma mark CollectionView Delegate
- (void)selectedProduct:(NSString *)productId
{
    [self.delegate selectedProductRelate:productId];
}
@end

