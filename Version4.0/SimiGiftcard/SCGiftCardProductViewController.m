//
//  SCGiftCardProductViewController.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/9/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCGiftCardProductViewController.h"

@interface SCGiftCardProductViewController ()

@end

@implementation SCGiftCardProductViewController
@synthesize cells = _cells;

- (void)viewDidLoadAfter{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    if ([SCGiftCardGlobalVar sharedInstance].timeZoneModelCollection.count > 0) {
        timeZoneModelCollection = [SCGiftCardGlobalVar sharedInstance].timeZoneModelCollection;
        timeZoneTitles = [NSMutableArray new];
        timeZoneSelectedIndex = 0;
        for (NSDictionary *timeZoneUnit in timeZoneModelCollection) {
            [timeZoneTitles addObject:[timeZoneUnit valueForKey:@"label"]];
        }
    }
}

- (void)setCells:(SimiTable *)cells{
    if (cells) {
        _cells = cells;
    }else{
        _cells = [SimiTable new];
        SimiSection *mainSection = [[SimiSection alloc]initWithIdentifier:product_main_section];
        [_cells addObject:mainSection];
        [mainSection addRowWithIdentifier:product_images_row height:(tableWidth - paddingEdge*2)/1.88 + paddingEdge*2];
        [mainSection addRowWithIdentifier:giftcard_template_row height:180];
        [mainSection addRowWithIdentifier:product_nameandprice_row height:100];
        [mainSection addRowWithIdentifier:giftcard_sendpostoffice_checkbox_row height:44];
        [mainSection addRowWithIdentifier:giftcard_sendfriend_checkbox_row height:44];
        [mainSection addRowWithIdentifier:product_description_row height:200];
        if ([[self.product valueForKeyPath:@"additional"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *additional = [self.product valueForKeyPath:@"additional"];
            if (additional.count > 0) {
                [mainSection addRowWithIdentifier:product_techspecs_row height:50];
            }
        }
        
        appReviews = [self.product valueForKey:@"app_reviews"];
        if ([[appReviews valueForKey:@"number"]floatValue]) {
            hadReviews = YES;
        }
        if(!hadReviews){
            if ([SimiGlobalVar sharedInstance].isLogin || (![SimiGlobalVar sharedInstance].isLogin && [SimiGlobalVar sharedInstance].isReviewAllowGuest)) {
                SimiSection *reviewSection = [_cells addSectionWithIdentifier:product_reviews_section headerTitle:SCLocalizedString(@"Review")];
                [reviewSection addRowWithIdentifier:product_reviews_firstpeople_row height:50];
            }
        }
    }
    [self.productTableView reloadData];
}

- (void)getProductDetail{
    if (self.product == nil) {
        self.product = [SimiGiftCardModel new];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetProduct:) name:DidGetGiftCardDetail object:self.product];
    [(SimiGiftCardModel*)self.product getGiftCardWithID:self.productId params:@{}];
}

- (void)didGetProduct:(NSNotification *)noti{
    [self stopLoadingData];
    [self.productTableView setHidden:NO];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([noti.name isEqualToString:DidGetGiftCardDetail]) {
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            if ([[self.product valueForKey:@"simigift_template_ids"] isKindOfClass:[NSArray class]]) {
                NSArray *simiGiftTemplateIds = [self.product valueForKey:@"simigift_template_ids"];
                if (simiGiftTemplateIds.count > 0) {
                    NSDictionary *giftTemplate = [simiGiftTemplateIds objectAtIndex:0];
                    giftCardTemplateID = [NSString stringWithFormat:@"%@",[giftTemplate valueForKey:@"giftcard_template_id"]];
                    if ([[giftTemplate valueForKey:@"images"] isKindOfClass:[NSArray class]]) {
                        giftCardTemplateImages = [giftTemplate valueForKey:@"images"];
                    }
                }
            }
            if ([[self.product valueForKey:@"is_salable"]boolValue]) {
                [self initViewAction];
            }
            [self setCells:nil];
        }
        [[NSNotificationCenter defaultCenter]removeObserverForNotification:noti];
    }
}


#pragma mark TableView 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:row.identifier];
    if ([section.identifier isEqualToString:product_main_section]) {
#pragma mark Image
        if ([row.identifier isEqualToString:product_images_row]) {
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                if (giftCardImageView == nil) {
                    float imageWidth = tableWidth - paddingEdge*2;
                    float imageHeight = imageWidth/1.88;
                    giftCardImageView = [[UIImageView alloc]initWithFrame:CGRectMake(paddingEdge, paddingEdge, imageWidth, imageHeight)];
                    [giftCardImageView setContentMode:UIViewContentModeScaleAspectFit];
                    [cell addSubview:giftCardImageView];
                    
                    if (giftCardTemplateImages.count > 0) {
                        [giftCardImageView sd_setImageWithURL:[NSURL URLWithString:[[giftCardTemplateImages objectAtIndex:0] valueForKey:@"url"]] placeholderImage:[UIImage imageNamed:@"logo"]];
                    }
                }
            }
#pragma mark GiftCard Template
        }else if([row.identifier isEqualToString:giftcard_template_row]){
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                float heightCell = 10;
                SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - paddingEdge*2, 20) andFontName:THEME_FONT_NAME_REGULAR andFontSize:18 andTextColor:THEME_CONTENT_COLOR text:@"Choose an images"];
                [cell.contentView addSubview:titleLabel];
                heightCell += 20;
                
                UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
                flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
                flowLayout.minimumInteritemSpacing = 10;
                flowLayout.minimumLineSpacing = 10;
                templatesCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - paddingEdge*2, 80) collectionViewLayout:flowLayout];
                [templatesCollectionView setBackgroundColor:[UIColor whiteColor]];
                templatesCollectionView.delegate = self;
                templatesCollectionView.dataSource = self;
                [cell.contentView addSubview:templatesCollectionView];
                heightCell += 90;
                
                SimiLabel *uploadImageLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - paddingEdge*2, 20) andFontName:THEME_FONT_NAME_REGULAR andFontSize:18 andTextColor:THEME_CONTENT_COLOR text:@"Or upload your photo"];
                [cell.contentView addSubview:uploadImageLabel];
                heightCell += 30;
                
                SimiButton *uploadImageButton = [[SimiButton alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, 140, 30) title:@"Upload image" titleFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:16] cornerRadius:4 borderWidth:0 borderColor:0];
                [uploadImageButton addTarget:self action:@selector(uploadImage:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:uploadImageButton];
                
                uploadImageView = [[UIImageView alloc]initWithFrame:CGRectMake(paddingEdge + 160, heightCell, 80, 80)];
                uploadImageView.contentMode = UIViewContentModeScaleAspectFit;
                uploadImageView.userInteractionEnabled = YES;
                UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectUploadImage:)];
                [uploadImageView addGestureRecognizer:gesture];
                heightCell += 90;
                row.height = heightCell;
                [cell.contentView addSubview:uploadImageView];
            }
        }else if ([row.identifier isEqualToString:giftcard_sendpostoffice_checkbox_row]){
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                sendThroughPostOfficeCheckbox = [[M13Checkbox alloc]initWithFrame:CGRectMake(paddingEdge, 6, tableWidth - paddingEdge*3, 30) title:SCLocalizedString(@"Send through post office") checkHeight:20];
                [sendThroughPostOfficeCheckbox setStrokeColor:[UIColor grayColor]];
                [sendThroughPostOfficeCheckbox setCheckColor:[UIColor blackColor]];
                [sendThroughPostOfficeCheckbox addTarget:self action:@selector(changeSendPostOfficeState) forControlEvents:UIControlEventValueChanged];
                sendThroughPostOfficeCheckbox.checkAlignment = M13CheckboxAlignmentLeft;
                [sendThroughPostOfficeCheckbox.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:16]];
                [cell.contentView addSubview:sendThroughPostOfficeCheckbox];
            }
        }else if ([row.identifier isEqualToString:giftcard_sendfriend_checkbox_row]){
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                sendGiftcardToFriendCheckbox = [[M13Checkbox alloc]initWithFrame:CGRectMake(paddingEdge, 6, tableWidth - paddingEdge*3, 30) title:SCLocalizedString(@"Send Gift Card to friend") checkHeight:20];
                sendGiftcardToFriendCheckbox.checkAlignment = M13CheckboxAlignmentLeft;
                [sendGiftcardToFriendCheckbox setStrokeColor:[UIColor grayColor]];
                [sendGiftcardToFriendCheckbox setCheckColor:[UIColor blackColor]];
                [sendGiftcardToFriendCheckbox addTarget:self action:@selector(changeSendToFriendState) forControlEvents:UIControlEventValueChanged];
                [sendGiftcardToFriendCheckbox.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:16]];
                [cell.contentView addSubview:sendGiftcardToFriendCheckbox];
            }
        }else if ([row.identifier isEqualToString:giftcard_insertinfo_row]){
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                float cellHeight = 0;
                float labelHeight = 20;
                float textFieldHeight = 40;
                float textFieldWidth = tableWidth - paddingEdge*2;
                SimiLabel *senderNameLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, cellHeight, textFieldWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:16 andTextColor:THEME_CONTENT_COLOR text:@"Sender name"];
                [cell.contentView addSubview:senderNameLabel];
                cellHeight += labelHeight;
                
                senderNameTextField = [[SimiTextField alloc]initWithFrame:CGRectMake(paddingEdge, cellHeight, textFieldWidth, textFieldHeight) placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME size:16] textColor:THEME_CONTENT_COLOR borderWidth:1 borderColor:[UIColor lightGrayColor] cornerRadius:6 leftView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, textFieldHeight)] rightView:nil];
                senderNameTextField.delegate = self;
                [cell.contentView addSubview:senderNameTextField];
                cellHeight += textFieldHeight;
                
                SimiLabel *recipientNameLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, cellHeight, textFieldWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:16 andTextColor:THEME_CONTENT_COLOR text:[NSString stringWithFormat:@"%@*",SCLocalizedString(@"Recipient name")]];
                [cell.contentView addSubview:recipientNameLabel];
                cellHeight += labelHeight;
                
                recipientNameTextField = [[SimiTextField alloc]initWithFrame:CGRectMake(paddingEdge, cellHeight, textFieldWidth, textFieldHeight) placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME size:16] textColor:THEME_CONTENT_COLOR borderWidth:1 borderColor:[UIColor lightGrayColor] cornerRadius:6 leftView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, textFieldHeight)] rightView:nil];
                recipientNameTextField.delegate = self;
                [cell.contentView addSubview:recipientNameTextField];
                cellHeight += textFieldHeight;
                
                SimiLabel *recipientEmailLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, cellHeight, textFieldWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:16 andTextColor:THEME_CONTENT_COLOR text:[NSString stringWithFormat:@"%@*",SCLocalizedString(@"Recipient email address")]];
                [cell.contentView addSubview:recipientEmailLabel];
                cellHeight += labelHeight;
                
                recipientEmailTextField = [[SimiTextField alloc]initWithFrame:CGRectMake(paddingEdge, cellHeight, textFieldWidth, textFieldHeight) placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME size:16] textColor:THEME_CONTENT_COLOR borderWidth:1 borderColor:[UIColor lightGrayColor] cornerRadius:6 leftView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, textFieldHeight)] rightView:nil];
                recipientEmailTextField.keyboardType = UIKeyboardTypeEmailAddress;
                recipientEmailTextField.delegate = self;
                [cell.contentView addSubview:recipientEmailTextField];
                cellHeight += textFieldHeight;
                
                SimiLabel *customMessageLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, cellHeight, textFieldWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:16 andTextColor:THEME_CONTENT_COLOR text:@"Custom message"];
                [cell.contentView addSubview:customMessageLabel];
                cellHeight += labelHeight;
                
                customMessageTextView = [[UITextView alloc]initWithFrame:CGRectMake(paddingEdge, cellHeight, textFieldWidth, 100)];
                customMessageTextView.layer.borderWidth = 1;
                customMessageTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
                customMessageTextView.layer.cornerRadius = 6;
                [customMessageTextView setFont:[UIFont fontWithName:THEME_FONT_NAME size:13]];
                [cell.contentView addSubview:customMessageTextView];
                cellHeight += 100;
                
                getNotificationCheckbox = [[SimiCheckbox alloc]initWithTitle:@"Get notification email when your friend receives Gift Card"];
                [getNotificationCheckbox setFrame:CGRectMake(paddingEdge, cellHeight, textFieldWidth, 30)];
                [cell.contentView addSubview:getNotificationCheckbox];
                cellHeight += 30;
                
                SimiLabel *dayToSendLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, cellHeight, textFieldWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:16 andTextColor:THEME_CONTENT_COLOR text:[NSString stringWithFormat:@"%@*",SCLocalizedString(@"Day to send")]];
                [cell.contentView addSubview:dayToSendLabel];
                cellHeight += labelHeight;
                
                dayToSendTextField = [[SimiTextField alloc]initWithFrame:CGRectMake(paddingEdge, cellHeight, textFieldWidth, textFieldHeight) placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME size:16] textColor:THEME_CONTENT_COLOR borderWidth:1 borderColor:[UIColor lightGrayColor] cornerRadius:6 leftView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, textFieldHeight)] rightView:nil];
                dayToSendTextField.delegate = self;
                [cell.contentView addSubview:dayToSendTextField];
                cellHeight += textFieldHeight;
                
                if (timeZoneTitles.count > 0) {
                    SimiLabel *timeZoneLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, cellHeight, textFieldWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:16 andTextColor:THEME_CONTENT_COLOR text:@"Select time zone"];
                    [cell.contentView addSubview:timeZoneLabel];
                    cellHeight += labelHeight;
                    
                    UIImageView *dropdownImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 40)];
                    [dropdownImageView setContentMode:UIViewContentModeScaleAspectFit];
                    [dropdownImageView setImage:[UIImage imageNamed:@"ic_dropdown"]];
                    selectTimeZoneTextField = [[SimiTextField alloc]initWithFrame:CGRectMake(paddingEdge, cellHeight, textFieldWidth, textFieldHeight) placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME size:16] textColor:THEME_CONTENT_COLOR borderWidth:1 borderColor:[UIColor lightGrayColor] cornerRadius:6 leftView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, textFieldHeight)] rightView:dropdownImageView];
                    selectTimeZoneTextField.delegate = self;
                    selectTimeZoneTextField.text = [timeZoneTitles objectAtIndex:timeZoneSelectedIndex];
                    [cell.contentView addSubview:selectTimeZoneTextField];
                    cellHeight += textFieldHeight;
                }
                row.height = cellHeight+20;
            }
        }else if ([row.identifier isEqualToString:giftcard_recommendinfo_row]){
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                SimiLabel *infoLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, 0, tableWidth - paddingEdge*2, 60) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:[UIColor orangeColor] text:@"You need to fill in your friend's address as the shipping address on checkout page. We will send this Gift Card to that address"];
                infoLabel.numberOfLines = 0;
                [cell.contentView addSubview:infoLabel];
            }
        }
#pragma mark Name&Price
        else if([row.identifier isEqualToString:product_nameandprice_row]){
            if (cell == nil) {
                float heightCell = 5;
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                self.labelProductName = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - paddingEdge*2, 20) andFontName:THEME_FONT_NAME_REGULAR andFontSize:THEME_FONT_SIZE + 2];
                [self.labelProductName setText:[NSString stringWithFormat:@"%@",[self.product valueForKey:@"name"]]];
                [cell.contentView addSubview:self.labelProductName];
                heightCell = [self.labelProductName resizLabelToFit];
                
                if (![[self.product valueForKey:@"is_salable"]boolValue]) {
                    SimiLabel *stockStatusLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - paddingEdge*2, 20) andFontName:THEME_FONT_NAME_REGULAR];
                    [stockStatusLabel setText:SCLocalizedString(@"Out of stock")];
                    [cell.contentView addSubview:stockStatusLabel];
                    heightCell += 20;
                }
                
                giftCardPrices = [self.product valueForKey:@"giftcard_prices"];
                priceLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - paddingEdge*2, 30) andFontName:THEME_FONT_NAME_REGULAR andFontSize:20 andTextColor:THEME_PRICE_COLOR];
                [cell.contentView addSubview:priceLabel];
                heightCell += 30;
                giftCardTypeValue = [NSString stringWithFormat:@"%@",[giftCardPrices valueForKey:@"type_value"]];
                if ([giftCardTypeValue isEqualToString:@"fixed"]){
                    NSString *price = [NSString stringWithFormat:@"%@",[giftCardPrices valueForKey:@"price"]];
                    [priceLabel setText:[[SimiFormatter sharedInstance]priceWithPrice:price]];
                    SimiLabel *giftCardValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - paddingEdge*2, 25) andFontName:THEME_FONT_NAME_REGULAR andFontSize:16];
                    NSString *giftCardValueString = [NSString stringWithFormat:@"%@",[giftCardPrices valueForKey:@"value"]];
                    [giftCardValueLabel setText:[NSString stringWithFormat:@"%@: %@",SCLocalizedString(@"Gift Card value"), [[SimiFormatter sharedInstance] priceWithPrice:giftCardValueString]]];
                    [cell.contentView addSubview:giftCardValueLabel];
                    heightCell += 35;
                }else if([giftCardTypeValue isEqualToString:@"dropdown"]){
                    valueSelectedIndex = 0;
                    priceValues = [giftCardPrices valueForKey:@"prices_dropdown"];
                    giftCardValues = [giftCardPrices valueForKey:@"options_value"];
                    giftCardValueTitles = [NSMutableArray new];
                    for (int i = 0; i < giftCardValues.count; i++) {
                        NSString *value = [NSString stringWithFormat:@"%@",[giftCardValues objectAtIndex:i]];
                        [giftCardValueTitles addObject:[[SimiFormatter sharedInstance] priceWithPrice:value]];
                    }
                    NSString *currentGiftValue = [NSString stringWithFormat:@"%@",[giftCardValues objectAtIndex:valueSelectedIndex]];
                    NSString *price = [NSString stringWithFormat:@"%@",[priceValues valueForKey:currentGiftValue]];
                    [priceLabel setText:[[SimiFormatter sharedInstance]priceWithPrice:price]];
                    
                    SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, 140, 40) andFontName:THEME_FONT_NAME_REGULAR andFontSize:16 andTextColor:THEME_CONTENT_COLOR text:[NSString stringWithFormat:@"%@:",SCLocalizedString(@"Select value")]];
                    [cell.contentView addSubview:titleLabel];
                    
                    UIImageView *dropdownImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 40)];
                    [dropdownImageView setContentMode:UIViewContentModeScaleAspectFit];
                    [dropdownImageView setImage:[UIImage imageNamed:@"ic_dropdown"]];
                    giftCardValueTextField = [[SimiTextField alloc]initWithFrame:CGRectMake(paddingEdge + 160, heightCell, 120, 40) placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:16] textColor:THEME_CONTENT_COLOR borderWidth:1 borderColor:[UIColor lightGrayColor] cornerRadius:6 leftView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 40)]  rightView:dropdownImageView];
                    [giftCardValueTextField setText:[giftCardValueTitles objectAtIndex:valueSelectedIndex]];
                    giftCardValueTextField.delegate = self;
                    [cell.contentView addSubview:giftCardValueTextField];
                    heightCell += 50;
                }else if ([giftCardTypeValue isEqualToString:@"range"]){
                    minValue = [[giftCardPrices valueForKey:@"from"]floatValue];
                    maxValue = [[giftCardPrices valueForKey:@"to"]floatValue];
                    giftCardValue = minValue;
                    if ([[giftCardPrices valueForKey:@"type_price"] isEqualToString:@"default"]) {
                        percentValue = 100;
                    }else{
                        percentValue = [[giftCardPrices valueForKey:@"percent_value"]floatValue];
                    }
                    priceValue = giftCardValue*percentValue/100;
                    [priceLabel setText:[[SimiFormatter sharedInstance]priceWithPrice:[NSString stringWithFormat:@"%f",priceValue]]];
                    
                    SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, 140, 20) andFontName:THEME_FONT_NAME_REGULAR andFontSize:16 andTextColor:THEME_CONTENT_COLOR text:[NSString stringWithFormat:@"%@:",SCLocalizedString(@"Enter value")]];
                    [cell.contentView addSubview:titleLabel];
                    heightCell += 25;
                    
                    giftCardValueTextField = [[SimiTextField alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, 140, 40) placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:16] textColor:THEME_CONTENT_COLOR borderWidth:1 borderColor:[UIColor lightGrayColor] cornerRadius:6 leftView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 40)]  rightView:nil];
                    giftCardValueTextField.keyboardType = UIKeyboardTypeDecimalPad;
                    giftCardValueTextField.text = [NSString stringWithFormat:@"%.f",giftCardValue];
                    giftCardValueTextField.delegate = self;
                    UIToolbar *giftCardValueToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 140, SCREEN_WIDTH, 40)];
                    giftCardValueToolbar.items = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],[[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneEditGiftCardValue:)]];
                    giftCardValueTextField.inputAccessoryView = giftCardValueToolbar;
                    
                    [cell.contentView addSubview:giftCardValueTextField];
                    heightCell += 40;
                    
                    NSString *fromString = [[SimiFormatter sharedInstance]priceWithPrice:[NSString stringWithFormat:@"%f",minValue]];
                    NSString *toString = [[SimiFormatter sharedInstance]priceWithPrice:[NSString stringWithFormat:@"%f",maxValue]];
                    SimiLabel *priceRangeLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, 140, 20) andFontName:THEME_FONT_NAME_REGULAR andFontSize:16 andTextColor:THEME_CONTENT_COLOR text:[NSString stringWithFormat:@"%@-%@",fromString,toString]];
                    [cell.contentView addSubview:priceRangeLabel];
                    heightCell += 25;
                }
                
                row.height = heightCell;
                [SimiGlobalVar sortViewForRTL:cell.contentView andWidth:tableWidth];
            }
#pragma mark Description
        }else if([row.identifier isEqualToString:product_description_row])
        {
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                float heightCell = 10;
                SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - paddingEdge*3, 30) andFontName:THEME_FONT_NAME_REGULAR andFontSize:THEME_FONT_SIZE + 2];
                [titleLabel setText:SCLocalizedString(@"Description")];
                [cell.contentView addSubview:titleLabel];
                heightCell += 40;
                
                if ([self.product valueForKey:@"short_description"]) {
                    NSString *shortDescription = [NSString stringWithFormat:@"%@",[self.product valueForKey:@"short_description"]];
                    if (![shortDescription isEqualToString:@""]) {
                        SimiLabel *shortDescriptionLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - paddingEdge*3, 30) andFontSize:THEME_FONT_SIZE_REGULAR];
                        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithData:[shortDescription dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                        [attributeString addAttributes:@{NSFontAttributeName:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE_REGULAR]} range:NSMakeRange(0, attributeString.length)];
                        shortDescriptionLabel.attributedText = attributeString;
                        [cell.contentView addSubview:shortDescriptionLabel];
                        heightCell = [shortDescriptionLabel resizLabelToFit] + 10;
                    }
                }
                row.height = heightCell;
                [SimiGlobalVar sortViewForRTL:cell.contentView andWidth:tableWidth - paddingEdge];
            }
        }
#pragma mark Tech specs
        else if([row.identifier isEqualToString:product_techspecs_row])
        {
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, 10, tableWidth - paddingEdge*3, 30) andFontName:THEME_FONT_NAME_REGULAR andFontSize:THEME_FONT_SIZE + 2];
                [titleLabel setText:SCLocalizedString(@"Tech Specs")];
                [cell.contentView addSubview:titleLabel];
                [SimiGlobalVar sortViewForRTL:cell.contentView andWidth:tableWidth - paddingEdge];
            }
        }
#pragma mark Reviews
    }else if ([section.identifier isEqualToString:product_reviews_section])
    {
        if ([row.identifier isEqualToString:product_reviews_normal_row]) {
            SimiModel *reviewModel = [self.reviewCollection objectAtIndex:indexPath.row];
            NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%@",row.identifier,[reviewModel valueForKey:@"review_id"]];
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                SCProductReviewShortCell *cellShort = [[SCProductReviewShortCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier reviewData:reviewModel numberTitleLine:1 numberBodyLine:2];
                row.height = cellShort.cellHeight;
                cell = cellShort;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        else if([row.identifier isEqualToString:product_reviews_add_row]){
            cell = [tableView dequeueReusableCellWithIdentifier:row.identifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, 10, tableWidth - paddingEdge*3, 30) andFontName:THEME_FONT_NAME_REGULAR];
                [titleLabel setText:SCLocalizedString(@"Add Your Review")];
                [cell.contentView addSubview:titleLabel];
                [SimiGlobalVar sortViewForRTL:cell.contentView andWidth:tableWidth - paddingEdge];
            }
        }
        else if ([row.identifier isEqualToString:product_reviews_firstpeople_row])
        {
            cell = [tableView dequeueReusableCellWithIdentifier:row.identifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, 10, tableWidth - paddingEdge*3, 30) andFontName:THEME_FONT_NAME_REGULAR];
                [titleLabel setText:SCLocalizedString(@"Be the first to review this product")];
                [cell.contentView addSubview:titleLabel];
                [SimiGlobalVar sortViewForRTL:cell.contentView andWidth:tableWidth - paddingEdge];
            }
        }else if ([row.identifier isEqualToString:product_reviews_viewall_row])
        {
            cell = [tableView dequeueReusableCellWithIdentifier:row.identifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, 10, tableWidth - paddingEdge*3, 30) andFontName:THEME_FONT_NAME_REGULAR];
                [titleLabel setTextAlignment:NSTextAlignmentCenter];
                [titleLabel setText:SCLocalizedString(@"View all")];
                [cell.contentView addSubview:titleLabel];
                [SimiGlobalVar sortViewForRTL:cell.contentView andWidth:tableWidth-paddingEdge];
            }
        }
    }
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedProductCell-After" object:self userInfo:@{@"tableView": tableView, @"indexPath": indexPath, @"section": section, @"row": row, @"cell": cell}];
    return cell;
}

#pragma mark CollectionView Delegate&DataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *data = [giftCardTemplateImages objectAtIndex:indexPath.row];
    NSString *identifier = [data valueForKey:@"image"];
    [collectionView registerClass:[GiftCardTemplateCollectionViewCell class] forCellWithReuseIdentifier:identifier];
    GiftCardTemplateCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [cell setImagePath:[data valueForKey:@"url"]];
    if (indexPath.row == templateImageSelectedIndex) {
        cell.imageView.layer.borderWidth = 2;
    }else{
        cell.imageView.layer.borderWidth = 0;
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return giftCardTemplateImages.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(80, 80);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row != templateImageSelectedIndex) {
        templateImageSelectedIndex = indexPath.row;
        self.useUploadImage = NO;
    }
}

#pragma mark Upload Image
- (void)uploadImage:(UIButton*)sender{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //You can retrieve the actual UIImage
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        [uploadImageView setImage:image];
        [self uploadImageWithParams:@{@"image_content":UIImagePNGRepresentation(image)}];
    }];
}

- (void)uploadImageWithParams:(NSDictionary*)params{
    [uploadImageView setHidden:YES];
    uploadImageModel = [SimiGiftCardModel new];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didUploadImage:) name:DidUploadImage object:uploadImageModel];
    [uploadImageModel uploadImageWithParams:params];
    [self startLoadingData];
}

- (void)didUploadImage:(NSNotification*)noti{
    [self removeObserverForNotification:noti];
    [self stopLoadingData];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        [uploadImageView setHidden:NO];
        self.useUploadImage = YES;
    }else{
        self.useUploadImage = NO;
    }
    [templatesCollectionView reloadData];
}

- (void)setUseUploadImage:(BOOL)useUploadImage{
    _useUploadImage = useUploadImage;
    if (useUploadImage) {
        templateImageSelectedIndex = -1;
        uploadImageView.layer.borderWidth = 2;
        uploadImageView.layer.borderColor = [UIColor orangeColor].CGColor;
        [giftCardImageView setImage:uploadImageView.image];
    }else{
        if (templateImageSelectedIndex == -1) {
            templateImageSelectedIndex = 0;
        }
        uploadImageView.layer.borderWidth = 0;
        [giftCardImageView sd_setImageWithURL:[NSURL URLWithString:[[giftCardTemplateImages objectAtIndex:templateImageSelectedIndex] valueForKey:@"url"]] placeholderImage:[UIImage imageNamed:@"logo"]];
    }
    [templatesCollectionView reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectUploadImage:(UIGestureRecognizer*)gesture{
    self.useUploadImage = !self.useUploadImage;
}
#pragma mark Checkbox Action
- (void)changeSendPostOfficeState{
    if (sendThroughPostOfficeCheckbox.checkState == M13CheckboxStateChecked) {
        isSendThroughPostOffice = YES;
    }else{
        isSendThroughPostOffice = NO;
    }
    SimiSection *mainSection = [self.cells getSectionByIdentifier:product_main_section];
    float sectionIndex = [self.cells getSectionIndexByIdentifier:product_main_section];
    if (isSendThroughPostOffice) {
        float rowIndex = [mainSection getRowIndexByIdentifier:giftcard_sendpostoffice_checkbox_row];
        SimiRow *sendPostOfficeRow = [mainSection getRowByIdentifier:giftcard_sendpostoffice_checkbox_row];
        [mainSection addRowWithIdentifier:giftcard_recommendinfo_row height:60 sortOrder:sendPostOfficeRow.sortOrder + 1];
        [mainSection sortItems];
        [self.productTableView beginUpdates];
        [self.productTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowIndex+1 inSection:sectionIndex]] withRowAnimation:UITableViewRowAnimationFade];
        [self.productTableView endUpdates];
    }else{
        float rowIndex = [mainSection getRowIndexByIdentifier:giftcard_recommendinfo_row];
        [mainSection removeRowAtIndex:rowIndex];
        [self.productTableView beginUpdates];
        [self.productTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex]] withRowAnimation:UITableViewRowAnimationFade];
        [self.productTableView endUpdates];
    }
}

- (void)changeSendToFriendState{
    if (sendGiftcardToFriendCheckbox.checkState == M13CheckboxStateChecked) {
        isSendGiftcardToFriend = YES;
    }else{
        isSendGiftcardToFriend = NO;
    }
    SimiSection *mainSection = [self.cells getSectionByIdentifier:product_main_section];
    float sectionIndex = [self.cells getSectionIndexByIdentifier:product_main_section];
    if (isSendGiftcardToFriend) {
        float rowIndex = [mainSection getRowIndexByIdentifier:giftcard_sendfriend_checkbox_row];
        SimiRow *sendFriendRow = [mainSection getRowByIdentifier:giftcard_sendfriend_checkbox_row];
        [mainSection addRowWithIdentifier:giftcard_insertinfo_row height:400 sortOrder:sendFriendRow.sortOrder+1];
        [mainSection sortItems];
        [self.productTableView beginUpdates];
        [self.productTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowIndex+1 inSection:sectionIndex]] withRowAnimation:UITableViewRowAnimationFade];
        [self.productTableView endUpdates];
    }else{
        float rowIndex = [mainSection getRowIndexByIdentifier:giftcard_insertinfo_row];
        [mainSection removeRowAtIndex:rowIndex];
        [self.productTableView beginUpdates];
        [self.productTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex]] withRowAnimation:UITableViewRowAnimationFade];
        [self.productTableView endUpdates];
    }
}

#pragma mark Keyboard State
- (void)keyboardWillShow:(NSNotification *)noti{
    float keyboardHeight = [[[noti userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    self.productTableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
}

- (void)keyboardWillHide:(NSNotification *)noti{
    self.productTableView.contentInset = UIEdgeInsetsMake(0, 0, heightViewAction, 0);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (customMessageTextView.isFirstResponder) {
        [customMessageTextView resignFirstResponder];
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)doneEditGiftCardValue:(UIButton*)sender{
    [giftCardValueTextField resignFirstResponder];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if ([textField isEqual:dayToSendTextField]) {
        ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc]initWithTitle:SCLocalizedString(@"Choose Day to Send") datePickerMode:UIDatePickerModeDate selectedDate:[NSDate date] minimumDate:[NSDate date] maximumDate:nil target:self action:@selector(didSelectDayToSend:element:) cancelAction:@selector(cancelActionSheet:) origin:textField];
        [datePicker showActionSheetPicker];
        [self.view endEditing:YES];
        return NO;
    }
    if ([textField isEqual:giftCardValueTextField] && [giftCardTypeValue isEqualToString:@"dropdown"]) {
        ActionSheetStringPicker *giftValuePicker = [[ActionSheetStringPicker alloc]initWithTitle:SCLocalizedString(@"Choose Gift Card value") rows:giftCardValueTitles initialSelection:valueSelectedIndex target:self successAction:@selector(didSelectGiftCardValue:element:) cancelAction:@selector(cancelActionSheet:) origin:textField];
        [giftValuePicker showActionSheetPicker];
        [self.view endEditing:YES];
        return NO;
    }
    if ([textField isEqual:selectTimeZoneTextField]) {
        ActionSheetStringPicker *timeZonePicker = [[ActionSheetStringPicker alloc]initWithTitle:SCLocalizedString(@"Choose Time Zone") rows:timeZoneTitles initialSelection:timeZoneSelectedIndex target:self successAction:@selector(didSelectTimeZoneValue:element:) cancelAction:@selector(cancelActionSheet:) origin:textField];
        [timeZonePicker showActionSheetPicker];
        [self.view endEditing:YES];
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if ([textField isEqual:giftCardValueTextField] && [giftCardTypeValue isEqualToString:@"range"]) {
        giftCardValue = [giftCardValueTextField.text floatValue];
        if (giftCardValue > maxValue) {
            giftCardValue = maxValue;
        }
        if (giftCardValue < minValue) {
            giftCardValue = minValue;
        }
        textField.text = [NSString stringWithFormat:@"%.2f",giftCardValue];
        priceValue = giftCardValue*percentValue/100;
        [priceLabel setText:[[SimiFormatter sharedInstance]priceWithPrice:[NSString stringWithFormat:@"%f",priceValue]]];
    }
}

- (void)didSelectDayToSend:(NSDate *)date element:(id)element{
    selectedDate = date;
    NSDateFormatter *dateFormater = [NSDateFormatter new];
    dateFormater.dateFormat = @"MM/dd/YYYY";
    dayToSendTextField.text = [dateFormater stringFromDate:date];
}

- (void)didSelectGiftCardValue:(NSNumber *)selectedIndex element:(id)element{
    valueSelectedIndex = [selectedIndex integerValue];
    NSString *currentGiftValue = [NSString stringWithFormat:@"%@",[giftCardValues objectAtIndex:valueSelectedIndex]];
    NSString *price = [NSString stringWithFormat:@"%@",[priceValues valueForKey:currentGiftValue]];
    [priceLabel setText:[[SimiFormatter sharedInstance]priceWithPrice:price]];
    [giftCardValueTextField setText:[giftCardValueTitles objectAtIndex:valueSelectedIndex]];
}

- (void)didSelectTimeZoneValue:(NSNumber *)selectedIndex element:(id)element{
    timeZoneSelectedIndex = [selectedIndex integerValue];
    [selectTimeZoneTextField setText:[timeZoneTitles objectAtIndex:timeZoneSelectedIndex]];
}

- (void)cancelActionSheet:(id)sender{
    
}

#pragma mark Add To Cart
- (void)addToCart{
    BOOL canAddToCart = NO;
    if (isSendGiftcardToFriend) {
        if ([self isEnterAllRequireFields]) {
            canAddToCart =  YES;
        }
    }else
        canAddToCart = YES;
    if (canAddToCart) {
        [self startLoadingData];
        NSMutableDictionary* cartItem = [[NSMutableDictionary alloc]initWithDictionary:@{@"product":[self.product valueForKey:@"entity_id"],@"giftcard_template_id":giftCardTemplateID, @"qty":[NSString stringWithFormat:@"%d",self.qty]}];
        if (self.useUploadImage) {
            [cartItem setValue:@"1" forKey:@"giftcard_use_custom_image"];
            [cartItem setValue:[uploadImageModel valueForKey:@"file"] forKey:@"giftcard_template_image"];
            [cartItem setValue:[uploadImageModel valueForKey:@"url"] forKey:@"url_image"];
        }else{
            [cartItem setValue:@"0" forKey:@"giftcard_use_custom_image"];
            [cartItem setValue:[[giftCardTemplateImages objectAtIndex:templateImageSelectedIndex] valueForKey:@"image"] forKey:@"giftcard_template_image"];
            [cartItem setValue:[[giftCardTemplateImages objectAtIndex:templateImageSelectedIndex] valueForKey:@"url"] forKey:@"url_image"];
        }
        if (isSendThroughPostOffice) {
            [cartItem setValue:@"1" forKey:@"recipient_ship"];
        }else
            [cartItem setValue:@"0" forKey:@"recipient_ship"];
        
        if (isSendGiftcardToFriend) {
            [cartItem setValue:@"1" forKey:@"send_friend"];
            [cartItem setValue:senderNameTextField.text forKey:@"customer_name"];
            [cartItem setValue:recipientNameTextField.text forKey:@"recipient_name"];
            [cartItem setValue:recipientEmailTextField.text forKey:@"recipient_email"];
            [cartItem setValue:customMessageTextView.text forKey:@"message"];
            [cartItem setValue:dayToSendTextField.text forKey:@"day_to_send"];
            [cartItem setValue:[[timeZoneModelCollection objectAtIndex:timeZoneSelectedIndex] valueForKey:@"value"] forKey:@"timezone_to_send"];
            if (getNotificationCheckbox.checkState == M13CheckboxStateChecked) {
                [cartItem setValue:@"1" forKey:@"notify_success"];
            }else{
                [cartItem setValue:@"0" forKey:@"notify_success"];
            }
        }else
            [cartItem setValue:@"0" forKey:@"send_friend"];
        if ([giftCardTypeValue isEqualToString:@"fixed"]) {
            [cartItem setValue:[giftCardPrices valueForKey:@"price"] forKey:@"price_amount"];
            [cartItem setValue:[giftCardPrices valueForKey:@"value"] forKey:@"amount"];
        }else if([giftCardTypeValue isEqualToString:@"dropdown"]){
            NSString *currentGiftValue = [NSString stringWithFormat:@"%@",[giftCardValues objectAtIndex:valueSelectedIndex]];
            NSString *price = [NSString stringWithFormat:@"%@",[priceValues valueForKey:currentGiftValue]];
            [cartItem setValue:price forKey:@"price_amount"];
            [cartItem setValue:currentGiftValue forKey:@"amount"];
        }else{
            NSString *currentGiftValue = [NSString stringWithFormat:@"%.2f",giftCardValue];
            NSString *price = [NSString stringWithFormat:@"%.2f",priceValue];
            [cartItem setValue:price forKey:@"price_amount"];
            [cartItem setValue:currentGiftValue forKey:@"amount"];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddToCart" object:nil userInfo:@{@"data":cartItem}];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddToCart:) name:@"DidAddToCart" object:nil];
    }
}

- (BOOL)isEnterAllRequireFields{
    if ([recipientNameTextField.text isEqualToString:@""] || [recipientEmailTextField.text isEqualToString:@""] || [dayToSendTextField.text isEqualToString:@""]) {
        [self showToastMessage:@"Please enter all required fields" duration:1.5];
        return NO;
    }
    if (![SimiGlobalVar validateEmail:recipientEmailTextField.text]) {
        [self showToastMessage:@"Email is not valid" duration:1.5];
        return NO;
    }
    return YES;
}
@end

@implementation GiftCardTemplateCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
        _imageView.layer.borderWidth = 2;
        _imageView.layer.borderColor = [UIColor orangeColor].CGColor;
        [self.contentView addSubview:_imageView];
    }
    return self;
}

- (void)setImagePath:(NSString *)imagePath{
    if (_imagePath == nil) {
        _imagePath = imagePath;
        [_imageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:[UIImage imageNamed:@"logo"]];
    }
}
@end
