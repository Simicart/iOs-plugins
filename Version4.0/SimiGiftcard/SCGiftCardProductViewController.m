//
//  SCGiftCardProductViewController.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/9/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCGiftCardProductViewController.h"

@interface SCGiftCardProductViewController (){
    BOOL canInsertMoreText;
}

@end

@implementation SCGiftCardProductViewController{
    float insertRowHeight;
}
- (void)viewDidLoadAfter{
    if ([SCGiftCardGlobalVar sharedInstance].timeZoneModelCollection.count > 0) {
        timeZoneModelCollection = [SCGiftCardGlobalVar sharedInstance].timeZoneModelCollection;
        timeZoneTitles = [NSMutableArray new];
        timeZoneSelectedIndex = 0;
        for (NSDictionary *timeZoneUnit in timeZoneModelCollection.collectionData) {
            [timeZoneTitles addObject:[timeZoneUnit valueForKey:@"label"]];
        }
    }
}

- (void)setupTableView{
    self.contentTableView.tableFooterView = [UIView new];
    if (@available(iOS 11, *)) {
        self.contentTableView.estimatedRowHeight = 0;
    }
}

- (void)createCells{
    SimiSection *mainSection = [[SimiSection alloc]initWithIdentifier:product_main_section];
    [self.cells addObject:mainSection];
    [mainSection addRowWithIdentifier:product_images_row height:(tableWidth - paddingEdge*2)/1.88 + paddingEdge*2];
    [mainSection addRowWithIdentifier:giftcard_template_row height:180];
    [mainSection addRowWithIdentifier:product_nameandprice_row height:100];
    if ([[giftCardSettings valueForKey:@"simigift_postoffice"]boolValue]) {
        [mainSection addRowWithIdentifier:giftcard_sendpostoffice_checkbox_row height:44];
    }
    [mainSection addRowWithIdentifier:giftcard_sendfriend_checkbox_row height:44];
    [mainSection addRowWithIdentifier:product_description_row height:200];
    if (self.product.additional) {
        NSDictionary *additional = self.product.additional;
        if (additional.count > 0) {
            [mainSection addRowWithIdentifier:product_techspecs_row height:50];
        }
    }
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
    [self.contentTableView setHidden:NO];
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    if ([noti.name isEqualToString:DidGetGiftCardDetail]) {
        if (responder.status == SUCCESS) {
            [self initializedGiftCardInfo];
            if ([[self.product valueForKey:@"is_salable"]boolValue]) {
                [self initViewAction];
            }
            [self initMoreViewAction];
            [self initCells];
        }
        [[NSNotificationCenter defaultCenter]removeObserverForNotification:noti];
    }
}

- (void)initializedGiftCardInfo{
    if ([[self.product valueForKey:@"simigiftcard_settings"] isKindOfClass:[NSDictionary class]]) {
        giftCardSettings = [self.product valueForKey:@"simigiftcard_settings"];
    }
    if ([[self.product valueForKey:@"simigift_template_ids"] isKindOfClass:[NSArray class]]) {
        NSArray *templates = [self.product valueForKey:@"simigift_template_ids"];
        templateNames = [NSMutableArray new];
        simiGiftTemplates = [NSMutableArray new];
        for (NSDictionary *template in templates) {
            if ([[template valueForKey:@"status"] isEqualToString:@"1"]) {
                [simiGiftTemplates addObject:template];
                [templateNames addObject:[template valueForKey:@"template_name"]];
            }
        }
    }
    if (simiGiftTemplates.count > 0) {
        selectedTemplateIndex = 0;
        [self updateCellWhenChangeTemplate];
    }
}

- (UITableViewCell *)createProductImageCell:(SimiRow *)row{
    UITableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
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
    return cell;
}

- (UITableViewCell*)createGiftCardTemplateCell:(SimiRow*)row{
    UITableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        float heightCell = 10;
        if (simiGiftTemplates.count > 0) {
            if(simiGiftTemplates.count > 1){
                SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - paddingEdge*2, 20) andFontName:THEME_FONT_NAME_REGULAR andFontSize:18 andTextColor:THEME_CONTENT_COLOR text:@"Select a template"];
                [cell.contentView addSubview:titleLabel];
                heightCell += 20;
                
                UIImageView *dropdownImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 40)];
                [dropdownImageView setContentMode:UIViewContentModeScaleAspectFit];
                [dropdownImageView setImage:[UIImage imageNamed:@"ic_dropdown"]];
                selectTemplateTextField = [[SimiTextField alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - paddingEdge*2, 40) placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME size:16] textColor:THEME_CONTENT_COLOR borderWidth:1 borderColor:[UIColor lightGrayColor] cornerRadius:4 leftView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 40)] rightView:dropdownImageView];
                selectTemplateTextField.delegate = self;
                [selectTemplateTextField setText:[selectedTemplate valueForKey:@"template_name"]];
                [cell.contentView addSubview:selectTemplateTextField];
                heightCell += 50;
            }else{
                SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - paddingEdge*2, 20) andFontName:THEME_FONT_NAME_REGULAR andFontSize:18 andTextColor:THEME_CONTENT_COLOR text:@"Choose an images"];
                [cell.contentView addSubview:titleLabel];
                heightCell += 20;
            }
            
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
        }
        
        if ([giftCardSettings valueForKey:@"simigift_template_upload"]) {
            BOOL useTemplateUpload = [[giftCardSettings valueForKey:@"simigift_template_upload"]boolValue];
            if (useTemplateUpload) {
                SimiLabel *uploadImageLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - paddingEdge*2, 20) andFontName:THEME_FONT_NAME_REGULAR andFontSize:18 andTextColor:THEME_CONTENT_COLOR text:@"Or upload your photo"];
                [cell.contentView addSubview:uploadImageLabel];
                heightCell += 30;
                
                SimiButton *uploadImageButton = [[SimiButton alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, 140, 30) title:@"Upload" titleFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:16] cornerRadius:4 borderWidth:0 borderColor:0];
                [uploadImageButton addTarget:self action:@selector(uploadImage:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:uploadImageButton];
                
                uploadImageView = [[UIImageView alloc]initWithFrame:CGRectMake(paddingEdge + 160, heightCell, 80, 80)];
                uploadImageView.contentMode = UIViewContentModeScaleAspectFit;
                uploadImageView.userInteractionEnabled = YES;
                UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectUploadImage:)];
                [uploadImageView addGestureRecognizer:gesture];
                heightCell += 90;
                [cell.contentView addSubview:uploadImageView];
            }
        }
        row.height = heightCell;
    }
    return cell;
}

- (UITableViewCell*)createSendPostOfficeCheckBoxRow:(SimiRow*)row{
    UITableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        sendThroughPostOfficeCheckbox = [[SimiCheckbox alloc]initWithFrame:CGRectMake(paddingEdge, 6, tableWidth - paddingEdge*3, 30) title:SCLocalizedString(@"Send through post office") checkHeight:20];
        [sendThroughPostOfficeCheckbox setStrokeColor:[UIColor grayColor]];
        [sendThroughPostOfficeCheckbox setCheckColor:[UIColor blackColor]];
        [sendThroughPostOfficeCheckbox addTarget:self action:@selector(changeSendPostOfficeState) forControlEvents:UIControlEventValueChanged];
        [sendThroughPostOfficeCheckbox.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:16]];
        [cell.contentView addSubview:sendThroughPostOfficeCheckbox];
    }
    return cell;
}

- (UITableViewCell*)createSendFriendCheckBoxRow:(SimiRow*)row{
    UITableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        sendGiftcardToFriendCheckbox = [[SimiCheckbox alloc]initWithFrame:CGRectMake(paddingEdge, 6, tableWidth - paddingEdge*3, 30) title:SCLocalizedString(@"Send Gift Card to friend") checkHeight:20];
        [sendGiftcardToFriendCheckbox setStrokeColor:[UIColor grayColor]];
        [sendGiftcardToFriendCheckbox setCheckColor:[UIColor blackColor]];
        [sendGiftcardToFriendCheckbox addTarget:self action:@selector(changeSendToFriendState) forControlEvents:UIControlEventValueChanged];
        [sendGiftcardToFriendCheckbox.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:16]];
        [cell.contentView addSubview:sendGiftcardToFriendCheckbox];
    }
    return cell;
}

- (UITableViewCell*)createInsertInfoRow:(SimiRow*)row{
    UITableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
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
        cellHeight += textFieldHeight + 5;
        
        SimiLabel *recipientNameLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, cellHeight, textFieldWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:16 andTextColor:THEME_CONTENT_COLOR text:[NSString stringWithFormat:@"%@*",SCLocalizedString(@"Recipient name")]];
        [cell.contentView addSubview:recipientNameLabel];
        cellHeight += labelHeight;
        
        recipientNameTextField = [[SimiTextField alloc]initWithFrame:CGRectMake(paddingEdge, cellHeight, textFieldWidth, textFieldHeight) placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME size:16] textColor:THEME_CONTENT_COLOR borderWidth:1 borderColor:[UIColor lightGrayColor] cornerRadius:6 leftView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, textFieldHeight)] rightView:nil];
        recipientNameTextField.delegate = self;
        [cell.contentView addSubview:recipientNameTextField];
        cellHeight += textFieldHeight + 5;
        
        SimiLabel *recipientEmailLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, cellHeight, textFieldWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:16 andTextColor:THEME_CONTENT_COLOR text:[NSString stringWithFormat:@"%@*",SCLocalizedString(@"Recipient email address")]];
        [cell.contentView addSubview:recipientEmailLabel];
        cellHeight += labelHeight;
        
        recipientEmailTextField = [[SimiTextField alloc]initWithFrame:CGRectMake(paddingEdge, cellHeight, textFieldWidth, textFieldHeight) placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME size:16] textColor:THEME_CONTENT_COLOR borderWidth:1 borderColor:[UIColor lightGrayColor] cornerRadius:6 leftView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, textFieldHeight)] rightView:nil];
        recipientEmailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        recipientEmailTextField.delegate = self;
        [cell.contentView addSubview:recipientEmailTextField];
        cellHeight += textFieldHeight + 5;
        
        SimiLabel *customMessageLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, cellHeight, textFieldWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:16 andTextColor:THEME_CONTENT_COLOR text:@"Custom message"];
        [cell.contentView addSubview:customMessageLabel];
        cellHeight += labelHeight;
        
        customMessageTextView = [[SimiTextView alloc]initWithFrame:CGRectMake(paddingEdge, cellHeight, textFieldWidth, 100)];
        customMessageTextView.layer.borderWidth = 1;
        customMessageTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        customMessageTextView.layer.cornerRadius = 6;
        customMessageTextView.delegate = self;
        [customMessageTextView setFont:[UIFont fontWithName:THEME_FONT_NAME size:13]];
        [cell.contentView addSubview:customMessageTextView];
        cellHeight += 105;
        
        getNotificationCheckbox = [[SimiCheckbox alloc]initWithTitle:@"Get notification email when your friend receives Gift Card"];
        [getNotificationCheckbox setFrame:CGRectMake(paddingEdge, cellHeight, textFieldWidth, 30)];
        [cell.contentView addSubview:getNotificationCheckbox];
        cellHeight += 45;
        if ([[giftCardSettings valueForKey:@"is_day_to_send"]boolValue]) {
            SimiLabel *dayToSendLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, cellHeight, textFieldWidth, labelHeight) andFontName:THEME_FONT_NAME_REGULAR andFontSize:16 andTextColor:THEME_CONTENT_COLOR text:[NSString stringWithFormat:@"%@*",SCLocalizedString(@"Day to send")]];
            [cell.contentView addSubview:dayToSendLabel];
            cellHeight += labelHeight;
            
            dayToSendTextField = [[SimiTextField alloc]initWithFrame:CGRectMake(paddingEdge, cellHeight, textFieldWidth, textFieldHeight) placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME size:16] textColor:THEME_CONTENT_COLOR borderWidth:1 borderColor:[UIColor lightGrayColor] cornerRadius:6 leftView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, textFieldHeight)] rightView:nil];
            dayToSendTextField.delegate = self;
            [cell.contentView addSubview:dayToSendTextField];
            cellHeight += textFieldHeight + 5;
            
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
        }
        
        row.height = cellHeight+20;
        insertRowHeight = row.height;
    }
    return cell;
}

- (UITableViewCell*)createRecommendInfoRow:(SimiRow*)row{
    UITableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        SimiLabel *infoLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, 0, tableWidth - paddingEdge*2, 60) andFontName:THEME_FONT_NAME andFontSize:14 andTextColor:[UIColor orangeColor] text:@"You need to fill in your friend's address as the shipping address on checkout page. We will send this Gift Card to that address"];
        infoLabel.numberOfLines = 0;
        [cell.contentView addSubview:infoLabel];
    }
    return cell;
}

- (UITableViewCell*)createNameCell:(SimiRow *)row{
    UITableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if (cell == nil) {
        float heightCell = 5;
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.labelProductName = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - paddingEdge*2, 20) andFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_HEADER];
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
        [SimiGlobalFunction sortViewForRTL:cell.contentView andWidth:tableWidth];
    }
    return cell;
}

#pragma mark TableView
- (UITableViewCell *)contentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    UITableViewCell *cell = nil;
    if ([section.identifier isEqualToString:product_main_section]) {
#pragma mark Image
        if ([row.identifier isEqualToString:product_images_row]) {
            cell = [self createProductImageCell:row];
#pragma mark GiftCard Template
        }else if([row.identifier isEqualToString:giftcard_template_row]){
            cell = [self createGiftCardTemplateCell:row];
        }else if ([row.identifier isEqualToString:giftcard_sendpostoffice_checkbox_row]){
            cell = [self createSendPostOfficeCheckBoxRow:row];
        }else if ([row.identifier isEqualToString:giftcard_sendfriend_checkbox_row]){
            cell = [self createSendFriendCheckBoxRow:row];
        }else if ([row.identifier isEqualToString:giftcard_insertinfo_row]){
            cell = [self createInsertInfoRow:row];
        }else if ([row.identifier isEqualToString:giftcard_recommendinfo_row]){
            cell = [self createRecommendInfoRow:row];
        }
#pragma mark Name&Price
        else if([row.identifier isEqualToString:product_nameandprice_row]){
            cell = [self createNameCell:row];
#pragma mark Description
        }else if([row.identifier isEqualToString:product_description_row]){
            cell = [self createDescriptionCell:row];
        }
#pragma mark Tech specs
        else if([row.identifier isEqualToString:product_techspecs_row]){
            cell = [self createTechSpecsCell:row];
        }
#pragma mark Reviews
    }
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
        [self uploadImageWithParams:@{@"image_content":UIImagePNGRepresentation([self resizeImage:image maxWidth:400.0f maxHeight:400.0f])}];
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
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    if (responder.status == SUCCESS) {
        [uploadImageView setHidden:NO];
        self.useUploadImage = YES;
    }else{
        self.useUploadImage = NO;
        [self showAlertWithTitle:@"Fail" message:responder.message];
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

- (void)updateCellWhenChangeTemplate{
    selectedTemplate = [simiGiftTemplates objectAtIndex:selectedTemplateIndex];
    giftCardTemplateID = [NSString stringWithFormat:@"%@",[selectedTemplate valueForKey:@"giftcard_template_id"]];
    if ([[selectedTemplate valueForKey:@"images"] isKindOfClass:[NSArray class]]) {
        giftCardTemplateImages = [selectedTemplate valueForKey:@"images"];
    }
    templateImageSelectedIndex = 0;
    if (giftCardTemplateImages.count > 0) {
        [giftCardImageView sd_setImageWithURL:[NSURL URLWithString:[[giftCardTemplateImages objectAtIndex:0] valueForKey:@"url"]] placeholderImage:[UIImage imageNamed:@"logo"]];
    }
    selectTemplateTextField.text = [templateNames objectAtIndex:selectedTemplateIndex];
    [templatesCollectionView reloadData];
}
#pragma mark Checkbox Action
- (void)changeSendPostOfficeState{
//    if (sendThroughPostOfficeCheckbox.checkState == M13CheckboxStateChecked) {
//        isSendThroughPostOffice = YES;
//    }else{
//        isSendThroughPostOffice = NO;
//    }
    SimiSection *mainSection = [self.cells getSectionByIdentifier:product_main_section];
//    float sectionIndex = [self.cells getSectionIndexByIdentifier:product_main_section];
    if (sendThroughPostOfficeCheckbox.checkState == M13CheckboxStateChecked) {
//        float rowIndex = [mainSection getRowIndexByIdentifier:giftcard_sendpostoffice_checkbox_row];
        SimiRow *sendPostOfficeRow = [mainSection getRowByIdentifier:giftcard_sendpostoffice_checkbox_row];
        [mainSection addRowWithIdentifier:giftcard_recommendinfo_row height:60 sortOrder:sendPostOfficeRow.sortOrder + 1];
        [mainSection sortItems];
//        [self.contentTableView beginUpdates];
//        [self.contentTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowIndex+1 inSection:sectionIndex]] withRowAnimation:UITableViewRowAnimationFade];
//        [self.contentTableView endUpdates];
        [self.contentTableView reloadData];
//        [self.contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }else{
        float rowIndex = [mainSection getRowIndexByIdentifier:giftcard_recommendinfo_row];
        [mainSection removeRowAtIndex:rowIndex];
//        [self.contentTableView beginUpdates];
//        [self.contentTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex]] withRowAnimation:UITableViewRowAnimationFade];
//        [self.contentTableView endUpdates];
         [self.contentTableView reloadData];
//        [self.contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)changeSendToFriendState{
//    if (sendGiftcardToFriendCheckbox.checkState == M13CheckboxStateChecked) {
//        isSendGiftcardToFriend = YES;
//    }else{
//        isSendGiftcardToFriend = NO;
//    }
    SimiSection *mainSection = [self.cells getSectionByIdentifier:product_main_section];
//    float sectionIndex = [self.cells getSectionIndexByIdentifier:product_main_section];
    if (sendGiftcardToFriendCheckbox.checkState == M13CheckboxStateChecked) {
//        float rowIndex = [mainSection getRowIndexByIdentifier:giftcard_sendfriend_checkbox_row];
        SimiRow *sendFriendRow = [mainSection getRowByIdentifier:giftcard_sendfriend_checkbox_row];
        [mainSection addRowWithIdentifier:giftcard_insertinfo_row height:insertRowHeight sortOrder:sendFriendRow.sortOrder+1];
        [mainSection sortItems];
//        [self.contentTableView beginUpdates];
//        [self.contentTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowIndex+1 inSection:sectionIndex]] withRowAnimation:UITableViewRowAnimationFade];
//        [self.contentTableView endUpdates];
        [self.contentTableView reloadData];
//        [self.contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }else{
        float rowIndex = [mainSection getRowIndexByIdentifier:giftcard_insertinfo_row];
        [mainSection removeRowAtIndex:rowIndex];
//        [self.contentTableView beginUpdates];
//        [self.contentTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex]] withRowAnimation:UITableViewRowAnimationFade];
//        [self.contentTableView endUpdates];
        [self.contentTableView reloadData];
//        [self.contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSInteger limit = [[giftCardSettings valueForKey:@"simigift_message_max"]integerValue];
    return textView.text.length + (text.length - range.length) <= limit;
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
    if ([textField isEqual:selectTemplateTextField]) {
        ActionSheetStringPicker *templatePicker = [[ActionSheetStringPicker alloc]initWithTitle:SCLocalizedString(@"Select a template") rows:templateNames initialSelection:selectedTemplateIndex doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            if (selectedIndex != selectedTemplateIndex) {
                selectedTemplateIndex = selectedIndex;
                [self updateCellWhenChangeTemplate];
            }
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            
        } origin:textField];
        [templatePicker showActionSheetPicker];
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
    if (sendGiftcardToFriendCheckbox.checkState == M13CheckboxStateChecked) {
        if ([self isEnterAllRequireFields]) {
            canAddToCart =  YES;
        }
    }else
        canAddToCart = YES;
    if (canAddToCart) {
        [self startLoadingData];
        NSMutableDictionary* cartItem = [[NSMutableDictionary alloc]initWithDictionary:@{@"product":[self.product valueForKey:@"entity_id"],@"giftcard_template_id":giftCardTemplateID, @"qty":[NSString stringWithFormat:@"%d",qty]}];
        if (self.useUploadImage) {
            [cartItem setValue:@"1" forKey:@"giftcard_use_custom_image"];
            [cartItem setValue:[uploadImageModel valueForKey:@"file"] forKey:@"giftcard_template_image"];
            [cartItem setValue:[uploadImageModel valueForKey:@"url"] forKey:@"url_image"];
        }else{
            [cartItem setValue:@"0" forKey:@"giftcard_use_custom_image"];
            [cartItem setValue:[[giftCardTemplateImages objectAtIndex:templateImageSelectedIndex] valueForKey:@"image"] forKey:@"giftcard_template_image"];
            [cartItem setValue:[[giftCardTemplateImages objectAtIndex:templateImageSelectedIndex] valueForKey:@"url"] forKey:@"url_image"];
        }
        if (sendThroughPostOfficeCheckbox.checkState == M13CheckboxStateChecked) {
            [cartItem setValue:@"1" forKey:@"recipient_ship"];
        }else
            [cartItem setValue:@"0" forKey:@"recipient_ship"];
        
        if (sendGiftcardToFriendCheckbox.checkState == M13CheckboxStateChecked) {
            [cartItem setValue:@"1" forKey:@"send_friend"];
            [cartItem setValue:senderNameTextField.text forKey:@"customer_name"];
            [cartItem setValue:recipientNameTextField.text forKey:@"recipient_name"];
            [cartItem setValue:recipientEmailTextField.text forKey:@"recipient_email"];
            [cartItem setValue:customMessageTextView.text forKey:@"message"];
            if([[giftCardSettings valueForKey:@"is_day_to_send"]boolValue]){
                [cartItem setValue:dayToSendTextField.text forKey:@"day_to_send"];
                [cartItem setValue:[[timeZoneModelCollection objectAtIndex:timeZoneSelectedIndex] valueForKey:@"value"] forKey:@"timezone_to_send"];
            }
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
        [[NSNotificationCenter defaultCenter] postNotificationName:Simi_AddToCart object:nil userInfo:@{@"data":cartItem}];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddToCart:) name:Simi_DidAddToCart object:nil];
    }
}

- (BOOL)isEnterAllRequireFields{
    if ([recipientNameTextField.text isEqualToString:@""] || [recipientEmailTextField.text isEqualToString:@""] || ([dayToSendTextField.text isEqualToString:@""] && [[giftCardSettings valueForKey:@"is_day_to_send"]boolValue])) {
        [self showToastMessage:@"Please enter all required fields" duration:1.5];
        return NO;
    }
    if (![SimiGlobalFunction validateEmail:recipientEmailTextField.text]) {
        [self showToastMessage:@"Email is not valid" duration:1.5];
        return NO;
    }
    return YES;
}

-(UIImage *)resizeImage:(UIImage *)image maxWidth:(float)width maxHeight:(float)height
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = width;
    float maxWidth = height;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 1;//50 percent compression
    
    if (actualHeight > maxHeight || actualWidth > maxWidth)
    {
        if(imgRatio < maxRatio)
        {
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio)
        {
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else
        {
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithData:imageData];
    
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
