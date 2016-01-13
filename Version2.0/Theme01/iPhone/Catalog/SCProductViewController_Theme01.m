//
//  SCProductViewController.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/12/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <SimiCartBundle/SCProductImageViewController.h>
#import <SimiCartBundle/SimiResponder.h>
#import <SimiCartBundle/UIImageView+WebCache.h>
#import <SimiCartBundle/NSObject+SimiObject.h>
#import <SimiCartBundle/SimiSection.h>
#import <QuartzCore/QuartzCore.h>
#import <SimiCartBundle/SimiFormatter.h>
#import <SimiCartBundle/NSString+HTML.h>
#import <SimiCartBundle/UILabelDynamicSize.h>

#import "SCProductViewController_Theme01.h"
#import "SCProductInfoView_Theme01.h"
#import "SCCollectionViewController_Theme01.h"
#import "SCProductDetailViewController_Theme01.h"
#import "SimiGlobalVar+Theme01.h"
#import "SCReviewDetailController_Theme01.h"
#import "SCOptionGroupViewCell_Theme01.h"
#import "SimiViewController+Theme01.h"
#import <SimiCartBundle/UIImage+SimiCustom.h>

@interface SCProductViewController_Theme01 ()

@property (nonatomic, strong) SCOptionGroupViewCell_Theme01 * optionViewCell;

@end

@implementation SCProductViewController_Theme01

@synthesize tableViewProduct, product, productId, relatedProductCollection;
@synthesize relatedProductScrollView, optionDict, allKeys, currentOptionIndexPath;
@synthesize actionView, productImageView, currentValueOptionIndexPaths, selectedOptionPrice, numberOfRequired;
@synthesize plusButton = _plusButton, minusButton = _minusButton, cells = _cells;
@synthesize dateTimeOption = _dateTimeOption, textOption = _textOption;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoadBefore
{
    [self setToSimiView];
    [self setNavigationBarOnViewDidLoadForTheme01];
    self.navigationItem.title = [[NSString stringWithFormat:@"%@...", SCLocalizedString(@"Loading")] uppercaseString];
    if (SIMI_SYSTEM_IOS >= 7.0) {
        [[UITableView appearanceWhenContainedIn:[self class], nil] setSeparatorInset:UIEdgeInsetsZero];
    }
    tableViewProduct = [[SimiTableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    tableViewProduct.dataSource = self;
    tableViewProduct.delegate = self;
    tableViewProduct.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableViewProduct.delaysContentTouches = NO;
    heightCellOptionValue = 50;
    [self.view addSubview:tableViewProduct];
    
    allKeys = [[NSArray alloc] init];
    relatedProductCollection = [[SCTheme01ProductModelCollection alloc] init];
    
    [self setCells:nil];
    [self getProduct];
}

- (void)viewWillAppearAfter:(BOOL)animated
{
    [self setNavigationBarOnViewWillAppearForTheme01];
    [tableViewProduct deselectRowAtIndexPath:[tableViewProduct indexPathForSelectedRow] animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SCProductViewController_SendProductInfomation" object:self.product];
}

- (void)addToCart{
    if ((self.optionDict.count > 0 && [self isCheckedAllRequiredOptions]) || (self.optionDict.count == 0)) {
        //Create animation
        UIImageView *thumnailView = [[UIImageView alloc]initWithFrame:productInfoViewTheme01.scrollImageProduct.frame];
        thumnailView.image = ((UIImageView*)[productInfoViewTheme01.scrollImageProduct.subviews objectAtIndex:productInfoViewTheme01.currentIndex]).image;
        [thumnailView setContentMode:UIViewContentModeScaleAspectFit];
        [self.view addSubview:thumnailView];
        [UIView animateWithDuration:0.6
                              delay:0
                            options:UIViewAnimationOptionAllowAnimatedContent
                         animations:^{
                             CGRect frame = self.view.frame;
                             thumnailView.frame = CGRectMake(3*frame.size.width/4+15, self.navigationController.navigationBar.frame.size.height/3, 60, 90);
                             thumnailView.transform = CGAffineTransformMakeRotation(140);
                         }
                         completion:^(BOOL finished){
                             [thumnailView removeFromSuperview];
                         }];
        [self startLoadingData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddToCart" object:nil userInfo:@{@"data":product}];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidAddToCart" object:nil];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Required options are not selected.") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)setCells:(NSMutableArray *)cells{
    if (cells) {
        _cells = cells;
    }else{
        _cells = [[NSMutableArray alloc] init];
        SimiSection *section = [[SimiSection alloc] init];
        NSInteger height = 400;
        NSArray *showPriceV2 = [product valueForKeyPath:@"show_price_v2"];
        if([showPriceV2 valueForKey:@"special_price_label"]){
            height += 30;
        }
        if(product.productType == ProductTypeBundle){
            if([showPriceV2 valueForKey:@"excl_tax_from"] && [showPriceV2 valueForKey:@"incl_tax_from"]){
                height += 130;
            }else if([showPriceV2 valueForKey:@"excl_tax_minimal"] && [showPriceV2 valueForKey:@"incl_tax_minimal"]){
                height += 80;
            }else{
                height += 30;
            }
        }
        [section addRowWithIdentifier:PRODUCT_IMAGE_CELL_ID height:height];
        [section addRowWithIdentifier:PRODUCT_DESCRIPTION_CELL_ID height:100];
        if(product.productType == ProductTypeGrouped){
            for (int i = 0; i < allKeys.count; i++) {
                [section addRowWithIdentifier:PRODUCT_OPTION_TYPE_CELL_ID height:60];
            }
        }else{
            for (int i = 0; i < allKeys.count; i++) {
                [section addRowWithIdentifier:PRODUCT_OPTION_TYPE_CELL_ID height:40];
            }
        }
        [section addRowWithIdentifier:PRODUCT_ACTION_CELL_ID height:80];
        if (relatedProductCollection.count > 0) {
            [section addRowWithIdentifier:PRODUCT_RELATED_CELL_ID height:210];
        }
        [_cells addObject:section];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SCProductViewController-InitCellsAfter" object:_cells userInfo:@{@"controller": self}];
}

#pragma mark Did Receive Notification
- (void)didReceiveNotification:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([noti.name isEqualToString:@"DidGetProductWithProductId"]) {
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            isLoading = NO;
            self.navigationItem.title = [SCLocalizedString(@"Product Detail") uppercaseString];
            [self convertOptionToDictFromArray:[product valueForKey:@"options"]];
            [self sortOption];
            [self setCells:nil];
            numberOfRequired = [self countNumberOfRequired];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetRelatedProductCollection" object:relatedProductCollection];
            [relatedProductCollection getRelatedProductCollectionWithProductId:productId limit:10 otherParams:nil];
            [tableViewProduct reloadData];
        }
        [self removeObserverForNotification:noti];
    }else if ([noti.name isEqualToString:@"DidGetRelatedProductCollection"]){
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            if (relatedProductCollection.count > 0) {
                [self setCells:nil];
                [tableViewProduct reloadData];
            }
        }
    }else if([noti.name isEqualToString:@"DidAddToCart"]){
        [self stopLoadingData];
        [self removeObserverForNotification:noti];
    }
}

#pragma mark Handle Option

- (void)loadOptionPrice:(NSString *)tempKey
{
    //Set option price
    CGFloat price = [[self.product valueForKey:@"product_price"] floatValue];
    switch (self.product.productType) {
        case ProductTypeGrouped:
            price = 0;
            break;
        default:
            break;
    }
    NSString *optionProductName = [self.product valueForKeyPath:@"product_name"];
    if (selectedOptionPrice == nil) {
        selectedOptionPrice = [[NSMutableDictionary alloc] init];
    }
    CGFloat totalOptionPrice = 0;
    CGFloat optionPrice = 0;
    CGFloat optionPriceInclTax = 0;
    BOOL hasDefaultOption = NO;
    [self.selectedOptionPrice removeObjectForKey:tempKey];
    for (NSDictionary *opt in [optionDict valueForKey:tempKey]) {
        if ([[opt valueForKey:@"is_default"] boolValue]) {
            [opt setValue:@"YES" forKey:@"is_selected"];
            [opt setValue:@"YES" forKey:@"is_available"];
            if (self.product.productType == ProductTypeGrouped) {
                optionPrice += [[opt valueForKey:@"option_price"] floatValue] * [[opt valueForKey:@"option_qty"] floatValue];
                optionProductName = [NSString stringWithFormat:@"%@, %@x%@", optionProductName, [opt valueForKey:@"option_qty"], [opt valueForKeyPath:@"option_value"]];
                if([opt valueForKey:@"option_price_incl_tax"]){
                    optionPriceInclTax += [[opt valueForKey:@"option_price_incl_tax"] floatValue] * [[opt valueForKey:@"option_qty"] floatValue];
                }else if([opt valueForKey:@"option_price"]){
                    optionPriceInclTax += [[opt valueForKey:@"option_price"] floatValue] * [[opt valueForKey:@"option_qty"] floatValue];
                }
            }else{
                optionPrice = [[opt valueForKey:@"option_price"] floatValue];
                optionProductName = [NSString stringWithFormat:@"%@, %@", optionProductName, [opt valueForKeyPath:@"option_value"]];
                if([opt valueForKey:@"option_price_incl_tax"]){
                    optionPriceInclTax = [[opt valueForKey:@"option_price_incl_tax"] floatValue];
                }else if([opt valueForKey:@"option_price"]){
                    optionPriceInclTax = [[opt valueForKey:@"option_price"] floatValue];
                }
            }
            totalOptionPrice += optionPrice;
            self.defaultOptionPrice += optionPrice;
            self.defaultOptionPriceIclTax += optionPriceInclTax;
            hasDefaultOption = YES;
        }
    }
    if(hasDefaultOption){
        [self.selectedOptionPrice setValue:[NSString stringWithFormat:@"%.2f", totalOptionPrice] forKey:tempKey];
    }
    
    //Set product price
    [self.product setValue:[NSString stringWithFormat:@"%.2f", self.defaultOptionPrice] forKey:@"total_option_price"];
    [self.product setValue:[NSString stringWithFormat:@"%.2f", self.defaultOptionPriceIclTax] forKey:@"total_option_price_incl_tax"];
    [productInfoViewTheme01 cusSetProduct:self.product];
}

#pragma mark Table View Data Source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiRow *row = [[_cells objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([row.identifier isEqualToString:PRODUCT_OPTION_VALUE_CELL_ID]) {
        // Special height for datetime input
        NSUInteger bias = [(SimiSection *)[_cells objectAtIndex:0] getRowIndexByIdentifier:PRODUCT_OPTION_TYPE_CELL_ID];
        NSString *key = [allKeys objectAtIndex:(currentOptionIndexPath.row - bias)];
        NSDictionary *option = [[self.optionDict valueForKey:key] objectAtIndex:0];
        if ([[option objectForKey:@"option_type"] isEqualToString:@"date"]
            || [[option objectForKey:@"option_type"] isEqualToString:@"date_time"]
            || [[option objectForKey:@"option_type"] isEqualToString:@"time"]
            ) {
            return 162;
        }
        if ([[option valueForKey:@"option_type"] isEqualToString:@"text"]&&[product productType] == ProductTypeGrouped) {
            NSArray *optionV2 = [option valueForKey:@"show_price_v2"];
            if([optionV2 valueForKey:@"excl_tax_special"] && [optionV2 valueForKey:@"incl_tax_special"]){
                return 100;
            }
            return 60;
        }
    }
    return row.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell;
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    NSString *identifier = simiRow.identifier;
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
#pragma mark Product Information
    if ([identifier isEqualToString:PRODUCT_IMAGE_CELL_ID]) {
        if (productInfoViewTheme01 == nil) {
            productInfoViewTheme01 = [[SCProductInfoView_Theme01 alloc] init];
        }
        [productInfoViewTheme01 cusSetProduct:product];
        productInfoViewTheme01.delegate = self;
        productInfoViewTheme01.frame = CGRectMake(0, 0, productInfoViewTheme01.mainFrame.size.width, 400);
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapgesture:)];
        
        [productInfoViewTheme01.scrollImageProduct addGestureRecognizer:gesture];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            [cell addSubview:productInfoViewTheme01];
            CGRect frame = productInfoViewTheme01.scrollImageProduct.frame;
            
            frame.origin.x = (self.view.frame.size.width - frame.size.width)/2;
            UIButton *btlRate = [[UIButton alloc]init];
            frame.size.width = 100;
            frame.size.height= 45;
            frame.origin.y = frame.origin.y - 40;
            frame.origin.x = (self.view.frame.size.width - frame.size.width)/2;
            btlRate.frame = frame;
            [btlRate addTarget:self action:@selector(didSelectProductRate:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell addSubview:btlRate];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }else if ([identifier isEqualToString:PRODUCT_DESCRIPTION_CELL_ID]){
#pragma mark Product Short Description
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
            UILabel *shortLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 18, 270, 20)];
            shortLabel.text = [SCLocalizedString(@"Description") stringByAppendingString:@" :"];
            [shortLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR]];
            NSString *shortDescription = @"";
            if([product valueForKey:@"product_short_description"])
                shortDescription = [[product valueForKey:@"product_short_description"] stringByConvertingHTMLToPlainText];
            UILabel *shortDescriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 38, self.view.frame.size.width - 50, 40)];
            shortDescriptionLabel.text = shortDescription;
            [shortDescriptionLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR]];
            shortDescriptionLabel.numberOfLines = 2;
            [shortDescriptionLabel sizeToFit];
            [cell addSubview:shortLabel];
            [cell addSubview:shortDescriptionLabel];
            UIImage *arrow = [UIImage imageNamed:@"theme01_catalog_description_arrow"];
            UIImageView *arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 25, 42, 11, 32)];
            arrowImage.image = arrow;
            [cell addSubview:arrowImage];
            
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                shortLabel.text = [NSString stringWithFormat:@":%@",SCLocalizedString(@"Description")];
                [shortLabel setTextAlignment:NSTextAlignmentRight];
                [shortDescriptionLabel setTextAlignment:NSTextAlignmentRight];
            }
            //  End RTL
        }
    }else if ([identifier isEqualToString:PRODUCT_ACTION_CELL_ID]){
#pragma mark Product Action
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            //Action
            if (actionView == nil) {
                actionView = [[UIView alloc] initWithFrame:cell.frame];
                CGRect frame = cell.frame;
                frame.origin.x = 10;
                frame.origin.y = 20;
                frame.size.width = cell.frame.size.width - 20;
                frame.size.height = 40;
                UIButton *button = [[UIButton alloc] initWithFrame: frame];
                button.backgroundColor = THEME_COLOR;
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                button.titleLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:18];
                [button.layer setCornerRadius:5.0f];
                [button.layer setMasksToBounds:YES];
                [button setAdjustsImageWhenHighlighted:YES];
                [button setAdjustsImageWhenDisabled:YES];
                [button setTitle:SCLocalizedString(@"Add To Cart") forState:UIControlStateNormal];
                [button addTarget:self action:@selector(addToCart) forControlEvents:UIControlEventTouchUpInside];
                [actionView addSubview:button];
                if (![[product valueForKey:@"stock_status"] boolValue]) {
                    [button setTitle:SCLocalizedString(@"Out Stock") forState:UIControlStateNormal];
                    button.enabled = NO;
                }
                actionView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
                [cell addSubview:actionView];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
    }else if ([identifier isEqualToString:PRODUCT_RELATED_CELL_ID]){
#pragma mark Product Related
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            //Related Products
            if (relatedProductScrollView == nil) {
                CGRect frame = cell.frame;
                frame.origin.y = 15;
                frame.size.height = 156;
                relatedProductScrollView = [[UIScrollView alloc] initWithFrame:frame];
                relatedProductScrollView.showsHorizontalScrollIndicator = NO;
                relatedProductScrollView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 150, 30)];
                label.text = SCLocalizedString(@"Related Products");
                label.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", THEME01_FONT_NAME_LIGHT] size:THEME_FONT_SIZE_REGULAR];
                UIView *relateView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 30)];
                relateView.backgroundColor = THEME01_OPTION_COLOR;
                [relateView addSubview:label];
                [cell addSubview:relatedProductScrollView];
                [cell addSubview:relateView];
                for (NSInteger i = 0; i < relatedProductCollection.count; i++) {
                    SCCollectionViewCell_Theme01 *productView = [[SCCollectionViewCell_Theme01 alloc]initWithNibName:@"SCCollectionViewCell_Theme01"];
                    [productView cusSetProductModel:[relatedProductCollection objectAtIndex:i]];
                    ScrollViewCell *productViewCell = [[ScrollViewCell alloc] initWithFrame:CGRectMake(0, 20, 156, 156)];
                    CGRect frame = productViewCell.frame;
                    frame.origin.x = 160 * i;
                    productViewCell.frame = frame;
                    [productViewCell addSubview:productView];
                    [relatedProductScrollView addSubview:productViewCell];
                    productViewCell = nil;
                    UIButton *selectedProduct = [[UIButton alloc]init];
                    selectedProduct.frame = frame;
                    selectedProduct.tag = [[[relatedProductCollection objectAtIndex:i] valueForKey:scTheme01_03_product_id] integerValue];
                    [selectedProduct addTarget:self action:@selector(didSelectRelatedProduct:) forControlEvents:UIControlEventTouchUpInside];
                    [relatedProductScrollView addSubview:selectedProduct];
                }
                CGFloat scrollViewHeight = relatedProductScrollView.frame.size.height;
                CGFloat scrollViewWidth = 0.0f;
                scrollViewWidth = relatedProductCollection.count * 160;
                [relatedProductScrollView setContentSize:(CGSizeMake(scrollViewWidth, scrollViewHeight))];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
    }else if ([identifier isEqualToString:PRODUCT_OPTION_TYPE_CELL_ID]){
#pragma mark Option Type Cell
        //Option type
        NSDictionary *option;
        NSInteger number = 0;
        if (indexPath.row > currentOptionIndexPath.row) {
            number = [self numberOfShowedOption];
        }
        
        NSString *requiredText = @"";
        NSUInteger bias = [(SimiSection *)[_cells objectAtIndex:0] getRowIndexByIdentifier:PRODUCT_OPTION_TYPE_CELL_ID];
        NSString *key = [allKeys objectAtIndex:(indexPath.row - number - bias)];
        NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%@", identifier, key ];
        option = [[self.optionDict valueForKey:key] objectAtIndex:0];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                cell.detailTextLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_BOLD] size:THEME_FONT_SIZE_REGULAR];
                cell.detailTextLabel.textColor = [UIColor blackColor];
                cell.detailTextLabel.backgroundColor = THEME01_PRICE_COLOR;
                cell.backgroundColor = THEME01_OPTION_COLOR;
                cell.accessoryType = UITableViewCellAccessoryNone;
                option = [[self.optionDict valueForKey:key] objectAtIndex:0];
                if([[option valueForKey:@"is_default"] boolValue]){
                    [option setValue:@"YES" forKey:@"is_selected"];
                    [option setValue:@"YES" forKey:@"is_available"];
                }
                switch (product.productType) {
                    case ProductTypeGrouped:{
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ x %@", key, [option valueForKey:@"option_qty"]];
                        cell.detailTextLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_BOLD] size:14];
                        [cell.textLabel resizLabelToFit];
                    }
                        break;
                        
                    default:{
                        cell.detailTextLabel.text = key;
                        if ([selectedOptionPrice valueForKeyPath:key] != nil || [[option valueForKey:@"is_default"] boolValue]) {
                            if([[selectedOptionPrice valueForKey:key] floatValue] > 0){
                                cell.textLabel.text = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[NSNumber numberWithFloat:[[selectedOptionPrice valueForKey:key] floatValue]]];
                                cell.textLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:12.0];
                                cell.textLabel.textColor = THEME01_PRICE_COLOR;
                            }
                        }else{
                            
                        }
                        if ([[option valueForKey:@"is_required"] boolValue]) {
                            requiredText = SCLocalizedString(@"(*)");
                        }else{
                            requiredText = @"";
                        }
                        
                    }
                        break;
                }
                if(![requiredText isEqualToString:@""] && !([selectedOptionPrice valueForKeyPath:key] != nil)){
                    CGFloat labelWidth = [cell.detailTextLabel.text sizeWithFont:cell.textLabel.font].width;
                    CGRect frame = cell.detailTextLabel.frame;
                    frame.origin.x = CGRectGetWidth(self.view.frame) - labelWidth - 20;
                    frame.size.width = 15;
                    frame.size.height = 15;
                    frame.origin.y = 10;
                    UILabel *requiredLabel = [[UILabel alloc]initWithFrame:frame];
                    requiredLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:12.0];
                    requiredLabel.textColor = THEME01_PRICE_COLOR;
                    requiredLabel.text = requiredText;
                    [cell addSubview:requiredLabel];
                }
            }else
            {
                cell.textLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_BOLD] size:THEME_FONT_SIZE_REGULAR];
                cell.textLabel.textColor = [UIColor blackColor];
                cell.textLabel.backgroundColor = THEME01_PRICE_COLOR;
                cell.backgroundColor = THEME01_OPTION_COLOR;
                cell.accessoryType = UITableViewCellAccessoryNone;
                option = [[self.optionDict valueForKey:key] objectAtIndex:0];
                if([[option valueForKey:@"is_default"] boolValue]){
                    [option setValue:@"YES" forKey:@"is_selected"];
                    [option setValue:@"YES" forKey:@"is_available"];
                }
                switch (product.productType) {
                    case ProductTypeGrouped:{
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ x %@", [option valueForKey:@"option_qty"], key];
                        cell.textLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_BOLD] size:14];
                        [cell.textLabel resizLabelToFit];
                    }
                        break;
                        
                    default:{
                        cell.textLabel.text = key;
                        if ([selectedOptionPrice valueForKeyPath:key] != nil || [[option valueForKey:@"is_default"] boolValue]) {
                            if([[selectedOptionPrice valueForKey:key] floatValue] > 0){
                                cell.detailTextLabel.text = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[NSNumber numberWithFloat:[[selectedOptionPrice valueForKey:key] floatValue]]];
                                cell.detailTextLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:12.0];
                                cell.detailTextLabel.textColor = THEME01_PRICE_COLOR;
                            }
                        }else{
                            
                        }
                        if ([[option valueForKey:@"is_required"] boolValue]) {
                            requiredText = SCLocalizedString(@"(*)");
                        }else{
                            requiredText = @"";
                        }
                        
                    }
                        break;
                }
                if(![requiredText isEqualToString:@""] && !([selectedOptionPrice valueForKeyPath:key] != nil)){
                    CGFloat labelWidth = [cell.textLabel.text sizeWithFont:cell.textLabel.font].width;
                    CGRect frame = cell.textLabel.frame;
                    frame.origin.x = cell.textLabel.frame.origin.x + labelWidth + 18;
                    frame.origin.y = cell.textLabel.frame.origin.y + 10;
                    frame.size.width = 15;
                    frame.size.height = 15;
                    UILabel *requiredLabel = [[UILabel alloc]initWithFrame:frame];
                    requiredLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:12.0];
                    requiredLabel.textColor = THEME01_PRICE_COLOR;
                    requiredLabel.text = requiredText;
                    [cell addSubview:requiredLabel];
                }
            }
            //  End RTL
        }
    }else if ([identifier isEqualToString:PRODUCT_OPTION_VALUE_CELL_ID]){
#pragma mark Option Value Cell
        NSUInteger bias = [(SimiSection *)[_cells objectAtIndex:0] getRowIndexByIdentifier:PRODUCT_OPTION_TYPE_CELL_ID];
        NSString *key = [allKeys objectAtIndex:(currentOptionIndexPath.row - bias)];
        NSMutableDictionary *option = [[self.optionDict valueForKey:key] objectAtIndex:(indexPath.row - currentOptionIndexPath.row - 1)];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        
        CGRect frame = cell.textLabel.frame;
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
            frame = CGRectMake(37, 0, 180, 50);
            UILabel *optionNameLabel = [UILabel new];
            optionNameLabel.text = optionName;
            optionNameLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:14.0];
            optionNameLabel.textColor = [UIColor blackColor];
            CGFloat labelWidth = [optionNameLabel.text sizeWithFont:optionNameLabel.font].width;
            if(labelWidth < 180){
                frame.origin.y -= 5;
            }
            optionNameLabel.frame = frame;
            optionNameLabel.numberOfLines = 3;
            optionNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                frame.origin.x = 170;
                frame.size.width = 140;
                [optionNameLabel setFrame:frame];
                [optionNameLabel setTextAlignment:NSTextAlignmentRight];
            }
            //  End RTL
            [cell addSubview:optionNameLabel];
            if([[SimiGlobalVar sharedInstance] isShowZeroPrice] || [[option valueForKey:@"option_price"] integerValue] != 0){
                if([option valueForKey:@"option_price_incl_tax"]){
                    //Add Option Price
                    frame = CGRectMake(215, 5, 125, 20);
                    NSString *optionPrice = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[NSNumber numberWithFloat:[[option valueForKey:@"option_price"] floatValue]]];
                    UILabel *optionPriceLabel = [[UILabel alloc]initWithFrame:frame];
                    optionPriceLabel.text = optionPrice;
                    optionPriceLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:14.0];
                    optionPriceLabel.textColor = THEME01_PRICE_COLOR;
                    [optionPriceLabel removeFromSuperview];
                    [cell addSubview:optionPriceLabel];
                    //  Liam Update RTL
                    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                        frame.origin.x = 40;
                        [optionPriceLabel setFrame:frame];
                    }
                    //  End RTL
                    
                    //Add Option Tax Price
                    frame = CGRectMake(205, 25, 125, 20);
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
                        frame.origin.x = 40;
                        [optionTaxPriceLabel setFrame:frame];
                    }
                    //  End RTL
                    [cell addSubview:optionTaxPriceLabel];
                }else{
                    //Add Option Price
                    frame = CGRectMake(225, 15, 125, 20);
                    NSString *optionPrice = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[NSNumber numberWithFloat:[[option valueForKey:@"option_price"] floatValue]]];
                    UILabel *optionPriceLabel = [[UILabel alloc]initWithFrame:frame];
                    optionPriceLabel.text = optionPrice;
                    optionPriceLabel.font = [UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:14.0];
                    optionPriceLabel.textColor = THEME01_PRICE_COLOR;
                    [optionPriceLabel removeFromSuperview];
                    //  Liam Update RTL
                    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                        frame.origin.x = 45;
                        [optionPriceLabel setFrame:frame];
                    }
                    //  End RTL
                    [cell addSubview:optionPriceLabel];
                    //Add Option Tax Price
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
        switch (product.productType) {
            case ProductTypeGrouped:{
                cell.textLabel.text = @"";
                cell.detailTextLabel.text=@"";
                if (_plusButton == nil) {
                    _plusButton = [[UIButton alloc] initWithFrame:CGRectMake(cell.frame.size.width - 60, 15, 48, 40)];
                    
                    [_plusButton setImage:[[UIImage imageNamed:@"theme1_option_plus"] imageWithColor:THEME01_SUB_PART_COLOR] forState:UIControlStateNormal];
                    _plusButton.imageEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
                    [_plusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [_plusButton.layer setCornerRadius:14.0f];
                    [_plusButton.layer setMasksToBounds:YES];
                    [_plusButton setAdjustsImageWhenHighlighted:YES];
                    [_plusButton setAdjustsImageWhenDisabled:YES];
                    [_plusButton addTarget:self action:@selector(didSelectPlusButtonOptionQty:) forControlEvents:UIControlEventTouchUpInside];
                }
                _plusButton.simiObjectIdentifier = indexPath;
                
                if (_minusButton == nil) {
                    _minusButton = [[UIButton alloc] initWithFrame:CGRectMake(cell.frame.size.width - 115, 15, 48, 40)];
                    [_minusButton setImage:[[UIImage imageNamed:@"theme1_option_minus"] imageWithColor:THEME01_SUB_PART_COLOR] forState:UIControlStateNormal];
                    _minusButton.imageEdgeInsets = UIEdgeInsetsMake(6, 10, 6, 10);
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
                    _optionViewCell = [[SCOptionGroupViewCell_Theme01 alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width - 95, cell.frame.size.height)];
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
                if([[option valueForKey:@"is_default"] boolValue]){
                    [option setValue:@"YES" forKey:@"is_selected"];
                    [option setValue:@"YES" forKey:@"is_available"];
                }
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
                UIImageView *optionImageView = [[UIImageView alloc]initWithFrame:CGRectMake(18, 15, 12, 12)];
                optionImageView.image = optionImage;
                [cell addSubview:optionImageView];
                // Check for text field and datetime option
                if ([[option objectForKey:@"option_type"] isEqualToString:@"text"]) {
                    // Text Option
                    if (_textOption == nil) {
                        _textOption = [[UITextField alloc] initWithFrame:CGRectInset(cell.bounds, 15, 0)];
                        _textOption.delegate = self;
                        _textOption.clearButtonMode = UITextFieldViewModeWhileEditing;
                        [_textOption addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingChanged];
                        [_textOption addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboardInputText) name:UIKeyboardDidShowNotification object:nil];
                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboardInputText) name:UIKeyboardWillHideNotification object:nil];
                        //  Liam Update RTL
                        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                            [_textOption setTextAlignment:NSTextAlignmentRight];
                        }
                        //  End RTL
                    }
                    _textOption.placeholder = [allKeys objectAtIndex:indexPath.row - 3];
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
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedProductCell-After" object:cell userInfo:@{@"indexPath": indexPath, @"productmodel":product, @"controller":self}];
    return cell;
}

#pragma mark Table View Delegate
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
        //Basic Product info
        SCProductDetailViewController_Theme01 *productDetailController = [[SCProductDetailViewController_Theme01 alloc] init];
        [productDetailController setProduct:product];
        [self.navigationController pushViewController:productDetailController animated:YES];
    }else if ([identifier isEqualToString:PRODUCT_OPTION_TYPE_CELL_ID]){
        //Option type cell
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self didSelectOptionTypeAtIndexPath:indexPath];
    }else if ([identifier isEqualToString:PRODUCT_OPTION_VALUE_CELL_ID]){
        //Option value cell
        if (product.productType != ProductTypeGrouped) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self didSelectOptionValueAtIndexPath:indexPath];
        }
    }
}

#pragma Scroll View Delegate
- (void)didSelectProduct:(NSString *)productID{
    SCProductViewController_Theme01 *productViewController = [[SCProductViewController_Theme01 alloc] init];
    productViewController.productId = productID;
    [self.navigationController pushViewController:productViewController animated:YES];
}
#pragma mark - Text options

-(void) tapgesture :(UITapGestureRecognizer*)gesture
{
    SCProductImageViewController *imageController = [[SCProductImageViewController alloc] init];
    [imageController setImageArray:[product valueForKey:@"product_images"]];
    [self.navigationController pushViewController:imageController animated:YES];
}

- (void) didSelectProductImage: (id) sender
{
    SCProductImageViewController *imageController = [[SCProductImageViewController alloc] init];
    [imageController setImageArray:[product valueForKey:@"product_images"]];
}

- (void) didSelectProductRate : (id) sender
{
    SCReviewDetailController_Theme01 *reviewDetailController = [[SCReviewDetailController_Theme01 alloc] init];
    [reviewDetailController setProduct:product];
    [self.navigationController pushViewController:reviewDetailController animated:YES];
}

- (void) didSelectRelatedProduct:(id) sender
{
    UIButton *button = (UIButton*)sender;
    SCProductViewController_Theme01 *productController = [[SCProductViewController_Theme01 alloc] init];
    [productController setProductId: [NSString stringWithFormat:@"%d", (int)button.tag]];
    [self.navigationController pushViewController:productController animated:YES];
}
@end
