//
//  SCPProductViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 5/3/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPProductViewController.h"
#import "SCPGlobalVars.h"
#import "SCPProductImagesViewController.h"
#import "SCPOptionController.h"
#import "SCPPriceView.h"

@interface SCPProductViewController ()

@end

@implementation SCPProductViewController

- (void)viewDidLoadBefore {
    [super viewDidLoadBefore];
    paddingEdge = SCP_GLOBALVARS.padding;
    self.rootEventName = @"SCPProductViewController";
}

- (void)viewDidAppearBefore:(BOOL)animated{
    [super viewDidAppearBefore:animated];
    [self.contentTableView setContentInset:UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0)];
    self.contentTableView.backgroundColor = COLOR_WITH_HEX(@"#ededed");
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0, *)) {
        self.contentTableView.estimatedRowHeight = 0;
        self.contentTableView.estimatedSectionHeaderHeight = 0;
        self.contentTableView.estimatedSectionFooterHeight = 0;
    }
}

- (void)didGetProduct:(NSNotification *)noti{
    [self stopLoadingData];
    [self.contentTableView setHidden:NO];
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    if ([noti.name isEqualToString:Simi_DidGetProductModel]) {
        if (responder.status == SUCCESS) {
            [self initMoreViewAction];
            if (GLOBALVAR.isMagento2) {
                optionController = [[SCMagentoTwoOptionController alloc]initWithProduct:self.product];
            }else
                optionController = [[SCPOptionController alloc]initWithProduct:self.product];
            [self initCells];
            [self getRelatedProducts];
            if (self.product.name && self.product.entityId) {
                [[NSNotificationCenter defaultCenter]postNotificationName:TRACKINGEVENT object:@"page_view_action" userInfo:@{@"action":@"viewed_product_screen",@"product_name":self.product.name,@"product_id":self.product.entityId}];
            }
        }
        [[NSNotificationCenter defaultCenter]removeObserverForNotification:noti];
    }
}
#pragma mark -
#pragma mark Relate Products
- (void)didGetRelatedProducts:(NSNotification*)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    if (responder.status == SUCCESS) {
        if (relatedProducts.count > 0) {
            itemHeight = 220;
            SimiSection *relatedSection = [self.cells addSectionWithIdentifier:product_related_section];
            relatedSection.header = [[SimiSectionHeader alloc]initWithTitle:SCLocalizedString(@"Related Products") height:60];
            [relatedSection addRowWithIdentifier:product_related_row height:itemHeight];
            [self.contentTableView reloadData];
        }
    }
    [self removeObserverForNotification:noti];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SimiProductModel *relateProduct = [relatedProducts objectAtIndex:indexPath.row];
    NSString *identifier = relateProduct.entityId;
    [collectionView registerClass:[SCPProductCollectionViewCell class] forCellWithReuseIdentifier:identifier];
    SCPProductCollectionViewCell *productViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [productViewCell setProductModelForCell:relateProduct];
    return productViewCell;
}

#pragma mark -
#pragma mark Generate Cells
- (void)createCells{
    headerManages = [NSMutableDictionary new];
    if (PHONEDEVICE) {
        SimiSection *mainSection = [[SimiSection alloc]initWithIdentifier:product_main_section];
        [mainSection addRowWithIdentifier:product_images_row height:(tableWidth - paddingEdge)];
        [self.cells addObject:mainSection];
    }
    SimiSection *namePriceSection = [[SimiSection alloc]initWithIdentifier:scpproduct_nameprice_section];
    namePriceSection.footer = [[SimiSectionFooter alloc]initWithTitle:@"" height:1];
    [namePriceSection addRowWithIdentifier:scpproduct_name_row height:47];
    [namePriceSection addRowWithIdentifier:scpproduct_price_row height:44];
    [self.cells addObject:namePriceSection];
    if (self.product.productType == ProductTypeConfigurable) {
        [self addConfigOptionsToCells];
        [self addCustomOptionsToCells];
    }else if (self.product.productType == ProductTypeSimple){
        [self addCustomOptionsToCells];
    }else if (self.product.productType == ProductTypeBundle){
        [self addBundleOptionsToCells];
    }
    SimiSection *addToCartSection = [[SimiSection alloc]initWithIdentifier:scpproduct_addtocart_section];
    [addToCartSection addRowWithIdentifier:scpproduct_addtocart_row height:64];
    [self.cells addObject:addToCartSection];
    
    SimiSection *descriptionSection = [[SimiSection alloc]initWithIdentifier:scpproduct_description_section];
    descriptionSection.header = [[SimiSectionHeader alloc]initWithTitle:@"" height:paddingEdge];
    [descriptionSection addRowWithIdentifier:product_description_row height:200];
    [self.cells addObject:descriptionSection];
    
    if (self.product.additional) {
        NSDictionary *additional = self.product.additional;
        if (additional.count > 0) {
            SimiSection *techspecsSection = [[SimiSection alloc]initWithIdentifier:scpproduct_techspecs_section];
            techspecsSection.header = [[SimiSectionHeader alloc]initWithTitle:@"" height:paddingEdge];
            [techspecsSection addRowWithIdentifier:product_techspecs_row height:44];
            [self.cells addObject:techspecsSection];
        }
    }
    
}

- (void)addConfigOptionsToCells{
    for(SimiConfigurableOptionModel *configOptionModel in optionController.configureOptions){
        if ([[configOptionModel.code uppercaseString] isEqualToString:@"COLOR"]) {
            SCProductOptionSection *configOptionSection = [[SCProductOptionSection alloc]initWithIdentifier:scpproduct_configurableoption_section];
            configOptionSection.optionModel = configOptionModel;
            configOptionSection.isShow = YES;
            SCProductOptionRow *configOptionRow = [[SCProductOptionRow alloc]initWithIdentifier:scpproduct_option_item_select_row height:[self calculateHeightOfOption:configOptionModel]];
            configOptionRow.model = configOptionModel;
            [configOptionSection addRow:configOptionRow];
            [self.cells addObject:configOptionSection];
            break;
        }
    }
    for(SimiConfigurableOptionModel *configOptionModel in optionController.configureOptions){
        if ([[configOptionModel.code uppercaseString] isEqualToString:@"SIZE"]) {
            SCProductOptionSection *configOptionSection = [[SCProductOptionSection alloc]initWithIdentifier:scpproduct_configurableoption_section];
            configOptionSection.optionModel = configOptionModel;
            configOptionSection.isShow = YES;
            SCProductOptionRow *configOptionRow = [[SCProductOptionRow alloc]initWithIdentifier:scpproduct_option_item_select_row height:[self calculateHeightOfOption:configOptionModel]];
            configOptionRow.model = configOptionModel;
            [configOptionSection addRow:configOptionRow];
            [self.cells addObject:configOptionSection];
        }
    }
    for(SimiConfigurableOptionModel *configOptionModel in optionController.configureOptions){
        if (![[configOptionModel.code uppercaseString] isEqualToString:@"SIZE"] && ![[configOptionModel.code uppercaseString] isEqualToString:@"COLOR"]) {
            SCProductOptionSection *configOptionSection = [[SCProductOptionSection alloc]initWithIdentifier:scpproduct_configurableoption_section];
            configOptionSection.header = [[SimiSectionHeader alloc]initWithTitle:configOptionModel.title height:44];
            configOptionSection.optionModel = configOptionModel;
            configOptionSection.isShow = NO;
            for (SimiConfigurableOptionValueModel *valueModel in configOptionModel.values) {
                SCProductOptionRow *configOptionRow = [[SCProductOptionRow alloc]initWithIdentifier:scpproduct_option_single_select_row height:45];
                configOptionRow.optionValueModel = valueModel;
                [configOptionSection addRow:configOptionRow];
            }
            [self.cells addObject:configOptionSection];
        }
    }
}

- (void)addCustomOptionsToCells{
    for (SimiCustomOptionModel *customOptionModel in optionController.customOptions) {
        SCProductOptionSection *section = [[SCProductOptionSection alloc]initWithIdentifier:scpproduct_customoption_section];
        section.header = [[SimiSectionHeader alloc]initWithTitle:customOptionModel.title height:44];
        section.optionModel = customOptionModel;
        section.isShow = NO;
        for (SimiCustomOptionValueModel *valueModel in customOptionModel.values) {
            NSString *identifier = @"";
            float rowHeight = 44;
            if ([customOptionModel.type isEqualToString:@"drop_down"]||[customOptionModel.type isEqualToString:@"radio"]) {
                identifier = scpproduct_option_single_select_row;
                rowHeight = 44;
            }else if ([customOptionModel.type isEqualToString:@"checkbox"]||[customOptionModel.type isEqualToString:@"multiple"]){
                identifier = scpproduct_option_multi_select_row;
                section.isMultiSelect = YES;
                rowHeight = 44;
            }else if([customOptionModel.type isEqualToString:@"area"] || [customOptionModel.type isEqualToString:@"field"]){
                identifier = scpproduct_option_textfield_row;
                rowHeight = 50;
            }else if ([customOptionModel.type isEqualToString:@"date_time"] || [customOptionModel.type isEqualToString:@"date"] || [customOptionModel.type isEqualToString:@"time"]){
                identifier = scpproduct_option_datetime_row;
                rowHeight = 170;
            }
            SCProductOptionRow *row = [[SCProductOptionRow alloc]initWithIdentifier:identifier height:rowHeight];
            row.optionValueModel = valueModel;
            row.model = customOptionModel;
            [section addObject:row];
        }
        [self.cells addObject:section];
    }
}
- (void)addBundleOptionsToCells{
    for (int i = 0; i < optionController.bundleOptions.count; i++) {
        SimiBundleOptionModel *bundleOptionModel = [optionController.bundleOptions objectAtIndex:i];
        SCProductOptionSection *section = [[SCProductOptionSection alloc]initWithIdentifier:scpproduct_bundleoption_section];
        section.header = [[SimiSectionHeader alloc]initWithTitle:bundleOptionModel.title height:44];
        section.optionModel = bundleOptionModel;
        for (SimiBundleOptionValueModel *valueModel in bundleOptionModel.values) {
            NSString *identifier = scpproduct_option_single_select_row;
            if (bundleOptionModel.isMulti) {
                identifier = scpproduct_option_multi_select_row;
            }
            SCProductOptionRow *row = [[SCProductOptionRow alloc]initWithIdentifier:identifier height:44];
            row.optionValueModel = valueModel;
            row.model = bundleOptionModel;
            [section addObject:row];
        }
        [self.cells addObject:section];
    }
}

- (float)calculateHeightOfOption:(SimiConfigurableOptionModel*)configurableOptionModel{
    NSMutableArray *itemWidthArray = [NSMutableArray new];
    for (SimiConfigurableOptionValueModel *optionValueModel in configurableOptionModel.values) {
        float itemWidth = [optionValueModel.title sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:SCP_FONT_SEMIBOLD size:FONT_SIZE_MEDIUM]}].width + 36 ;
        [itemWidthArray addObject:[NSNumber numberWithFloat:itemWidth]];
    }
    float numberItemRow = 0;
    float totalWidthInRow = 0;
    float collectionWidth = SCREEN_WIDTH - SCP_GLOBALVARS.padding*4 - 80;
    for (int i = 0; i < itemWidthArray.count; i++) {
        float itemWidth = [itemWidthArray[i] floatValue];
        totalWidthInRow += itemWidth + 18;
        if (totalWidthInRow < collectionWidth) {
            continue;
        }else{
            numberItemRow += 1;
            totalWidthInRow = itemWidth + 18;
        }
    }
    numberItemRow += 1;
    float height = numberItemRow * 44;
    return height;
}

#pragma mark -
#pragma mark TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == self.contentTableView){
        SimiSection *simiSection = [self.cells objectAtIndex:section];
        if ([simiSection isKindOfClass:[SCProductOptionSection class]]) {
            SCProductOptionSection *optionSection = (SCProductOptionSection*)simiSection;
            if (optionSection.isShow) {
                return optionSection.count;
            }else{
                return 0;
            }
        }
        return simiSection.count;
    }
    return 0;
}

- (UITableViewCell *)contentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    UITableViewCell *cell;
    if ([section.identifier isEqualToString:product_main_section]) {
        if ([row.identifier isEqualToString:product_images_row]) {
            cell = [self createProductImageCell:row];
        }else if([row.identifier isEqualToString:product_nameandprice_row]){
            cell =  [self createNameCell:row];
        }
    }else if([section.identifier isEqualToString:scpproduct_configurableoption_section]){
        if ([row.identifier isEqualToString:scpproduct_option_item_select_row]) {
            cell = [self createOptionItemSelectCell:row];
        }else if ([row.identifier isEqualToString:scpproduct_option_single_select_row]){
            cell = [self createOptionSingleSelectCell:row];
        }
    }else if([section.identifier isEqualToString:scpproduct_customoption_section]){
        SCProductOptionSection *optionSection = (SCProductOptionSection*)section;
        SCProductOptionRow *optionRow = (SCProductOptionRow*)row;
        if ([row.identifier isEqualToString:scpproduct_option_single_select_row]){
            cell = [self createOptionSingleSelectCell:row];
        }else if ([row.identifier isEqualToString:scpproduct_option_multi_select_row]){
            cell = [self createOptionMultiSelectCell:row];
        }else if ([row.identifier isEqualToString:scpproduct_option_textfield_row]){
            cell = [self createOptionTextFieldWithSection:optionSection row:optionRow];
        }else if ([row.identifier isEqualToString:scpproduct_option_datetime_row]){
            cell = [self createOptionDateTimeWithSection:optionSection row:optionRow];
        }
    }else if ([section.identifier isEqualToString:scpproduct_description_section]){
        if ([row.identifier isEqualToString:product_description_row]) {
            cell = [self createDescriptionCell:row];
        }
    }else if ([section.identifier isEqualToString:scpproduct_bundleoption_section]){
        if ([row.identifier isEqualToString:scpproduct_option_single_select_row]){
            cell = [self createBundleOptionSingleSelectCell:row];
        }else if ([row.identifier isEqualToString:scpproduct_option_multi_select_row]){
            cell = [self createBundleOptionMultiSelectCell:row];
        }
    }else if ([section.identifier isEqualToString:product_related_section]){
        if ([row.identifier isEqualToString:product_related_row]){
            cell = [self createRelatedCell:row];
        }
    }else if ([section.identifier isEqualToString:scpproduct_techspecs_section]){
        if ([row.identifier isEqualToString:product_techspecs_row]) {
            cell = [self createTechSpecsCell:row];
        }
    }else if ([section.identifier isEqualToString:scpproduct_nameprice_section]){
        if ([row.identifier isEqualToString:scpproduct_name_row]) {
            cell = [self createNameCell:row];
        }else if ([row.identifier isEqualToString:scpproduct_price_row]){
            cell = [self createPriceCell:row];
        }
    }else if ([section.identifier isEqualToString:scpproduct_addtocart_section]){
        if ([row.identifier isEqualToString:scpproduct_addtocart_row]) {
            cell = [self createAddToCartCell:row];
        }
    }
    return cell;
}

- (SimiTableViewCell*)createOptionItemSelectCell:(SimiRow*)row{
    SCPOptionGridTableViewCell *cell = [[SCPOptionGridTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.simiObjectName andRow:(SCProductOptionRow*)row];
    cell.delegate = self;
    return cell;
}

- (SimiTableViewCell*)createOptionSingleSelectCell:(SimiRow*)row{
    SCProductOptionRow *optionRow = (SCProductOptionRow*)row;
    SCPOptionSingleSelectTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:optionRow.optionValueModel.valueId];
    if (cell == nil) {
        cell = [[SCPOptionSingleSelectTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:optionRow.optionValueModel.valueId optionRow:optionRow productModel:self.product];
    }
    [cell updateCellWithRow:optionRow];
    return cell;
}

- (SimiTableViewCell*)createOptionMultiSelectCell:(SimiRow*)row{
    SCProductOptionRow *optionRow = (SCProductOptionRow*)row;
    SCPOptionMultiSelectTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:optionRow.optionValueModel.valueId];
    if (cell == nil) {
        cell = [[SCPOptionMultiSelectTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:optionRow.optionValueModel.valueId optionRow:optionRow productModel:self.product];
    }
    [cell updateCellWithRow:optionRow];
    return cell;
}

- (SimiTableViewCell*)createOptionTextFieldWithSection:(SCProductOptionSection*)section row:(SCProductOptionRow*)row{
    SCPOptionTextFieldTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:section.optionModel.optionId];
    if (cell == nil) {
        cell = [[SCPOptionTextFieldTableViewCell alloc]initWithReuseIdentifier:section.optionModel.optionId optionRow:row];
        cell.optionTextField.delegate = self;
        cell.optionTextField.simiObjectIdentifier = section;
        [cell.optionTextField addTarget:self action:@selector(optionTextFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
    }
    cell.optionTextField.placeholder = section.optionModel.title;
    cell.optionTextField.text = [section.optionModel valueForKey:@"option_value"];
    return cell;
}

- (SimiTableViewCell*)createOptionDateTimeWithSection:(SCProductOptionSection*)section row:(SCProductOptionRow*)row{
    SCPOptionDateTimeTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:section.optionModel.optionId];
    if (cell == nil) {
        cell = [[SCPOptionDateTimeTableViewCell alloc]initWithReuseIdentifier:section.optionModel.optionId optionRow:row];
        cell.datePicker.simiObjectIdentifier = section;
        [cell.datePicker addTarget:self action:@selector(optionDateTimeUpdate:) forControlEvents:UIControlEventValueChanged];
    }
    SimiCustomOptionModel *optionModel = (SimiCustomOptionModel*)section.optionModel;
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    if ([optionModel.type isEqualToString:@"date"]) {
        [dateFormater setDateFormat:@"yyyy-MM-dd"];
    } else if ([optionModel.type isEqualToString:@"date_time"]) {
        [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    } else {
        [dateFormater setDateFormat:@"HH:mm:ss"];
    }
    if ([optionModel objectForKey:@"option_value"]) {
        cell.datePicker.date = [dateFormater dateFromString:[optionModel objectForKey:@"option_value"]];
    } else {
        cell.datePicker.date = [NSDate date];
    }
    return cell;
}

- (SimiTableViewCell*)createBundleOptionMultiSelectCell:(SimiRow*)row{
    SCProductOptionRow *optionRow = (SCProductOptionRow*)row;
    SCPBundleOptionMultiSelectTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:optionRow.optionValueModel.valueId];
    if (cell == nil) {
        cell = [[SCPBundleOptionMultiSelectTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:optionRow.optionValueModel.valueId optionRow:optionRow productModel:self.product];
    }
    [cell updateCellWithRow:optionRow];
    return cell;
}

- (SimiTableViewCell*)createBundleOptionSingleSelectCell:(SimiRow*)row{
    SCProductOptionRow *optionRow = (SCProductOptionRow*)row;
    SCPBundleOptionSingleSelectTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:optionRow.optionValueModel.valueId];
    if (cell == nil) {
        cell = [[SCPBundleOptionSingleSelectTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:optionRow.optionValueModel.valueId optionRow:optionRow productModel:self.product];
    }
    [cell updateCellWithRow:optionRow];
    return cell;
}


- (UITableViewCell *)createProductImageCell:(SimiRow *)row{
    UITableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = COLOR_WITH_HEX(@"#ededed");
        float imageWidth = tableWidth - paddingEdge*2;
        float imageHeight = row.height - paddingEdge;
        UIView *imageView = [[UIView alloc] initWithFrame:CGRectMake(paddingEdge, paddingEdge, imageWidth, imageHeight)];
        imageView.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:imageView];
        if (imagesScrollView == nil) {
            imagesScrollView = [[UIScrollView alloc]initWithFrame:imageView.bounds];
            imagesScrollView.pagingEnabled = YES;
            imagesScrollView.showsHorizontalScrollIndicator = NO;
            imagesScrollView.delegate = self;
            [imageView addSubview:imagesScrollView];
            if (self.product.images) {
                productImages = [[NSMutableArray alloc]initWithArray:self.product.images];
            }
            for (int i = 0; i < productImages.count; i++) {
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i*imageWidth, 0,imageWidth, imageHeight)];
                NSDictionary *imageDict = [productImages objectAtIndex:i];
                if([imageDict valueForKey:@"url"])
                    [imageView sd_setImageWithURL:[imageDict valueForKey:@"url"] placeholderImage:[UIImage imageNamed:@"logo"] options:SDWebImageRetryFailed];
                [imageView setContentMode:UIViewContentModeScaleAspectFit];
                [imagesScrollView addSubview:imageView];
            }
            
            if (productImages.count == 0) {
                [imagesScrollView setContentSize:CGSizeMake(imageWidth, imageHeight)];
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:imagesScrollView.bounds];
                [imageView setImage:[UIImage imageNamed:@"logo"]];
                [imageView setContentMode:UIViewContentModeScaleAspectFit];
                [imagesScrollView addSubview:imageView];
            }else
                [imagesScrollView setContentSize:CGSizeMake(imageWidth *productImages.count, imageHeight)];
            UITapGestureRecognizer *imageTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToProductImage:)];
            [imagesScrollView addGestureRecognizer:imageTapGesture];
            
            imagesPageControll = [[UIPageControl alloc]initWithFrame:CGRectMake(0, imageHeight - 15, CGRectGetWidth(imageView.frame), 15)];
            imagesPageControll.autoresizingMask = UIViewAutoresizingNone;
            if (productImages.count > 0)
                imagesPageControll.numberOfPages = productImages.count;
            else
                imagesPageControll.numberOfPages = 1;
            imagesPageControll.currentPageIndicatorTintColor = SCP_ICON_HIGHLIGHT_COLOR;
            imagesPageControll.tintColor = SCP_ICON_HIGHLIGHT_COLOR;
            [imageView addSubview:imagesPageControll];
        }
        
        if ([[self.product.appPrices valueForKey:@"has_special_price"]intValue] == 1) {
            UIImageView *saleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageWidth - 54, 10, 44, 44)];
            saleImageView.image = [UIImage imageNamed:@"scp_ic_sale"];
            [imageView addSubview:saleImageView];
        }
    }
    return cell;
}

- (SimiTableViewCell *)createNameCell:(SimiRow *)row{
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if (cell == nil) {
        cell = [[SimiTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor clearColor]];
        
        cell.simiContentView = [[UIView alloc] initWithFrame:CGRectMake(paddingEdge, 0, tableWidth - 2*paddingEdge, row.height)];
        cell.simiContentView.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:cell.simiContentView];
    
        float heightCell = 17;
        self.labelProductName = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, CGRectGetWidth(cell.simiContentView.frame) - paddingEdge*2, 20) andFontName:SCP_FONT_REGULAR andFontSize:FONT_SIZE_HEADER+2];
        [self.labelProductName setTextAlignment:NSTextAlignmentCenter];
        [self.labelProductName setText:self.product.name];
        [cell.simiContentView addSubview:self.labelProductName];
        BOOL hasVideo = NO;
        NSArray *youtubeArray = [self.product valueForKey:@"product_video"];
        if(youtubeArray.count > 0){
            hasVideo = YES;
        }
        if (hasVideo) {
            UIImageView *videoIconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 22, 20, 20)];
            [videoIconImageView setImage:[UIImage imageNamed:@"scp_ic_video_small"]];
            [cell.simiContentView addSubview:videoIconImageView];
            float nameWidth = [self.product.name sizeWithAttributes:@{NSFontAttributeName:self.labelProductName.font}].width;
            CGRect frame = videoIconImageView.frame;
            if (nameWidth < (CGRectGetWidth(cell.simiContentView.frame) - paddingEdge*2 - 20)) {
                frame.origin.x = CGRectGetWidth(cell.simiContentView.frame)/2 + nameWidth/2;
            }else{
                frame.origin.x = CGRectGetWidth(cell.simiContentView.frame) - paddingEdge - 20;
            }
            [videoIconImageView setFrame:frame];
            
            frame = self.labelProductName.frame;
            frame.size.width -= 20;
            [self.labelProductName setFrame:frame];
        }
        [self.labelProductName resizLabelToFit];
        CGRect frame = self.labelProductName.frame;
        if (CGRectGetHeight(frame) < 20) {
            frame.size.height = 20;
            [self.labelProductName setFrame:frame];
        }
        heightCell += CGRectGetHeight(frame) + 15;
        frame = cell.simiContentView.frame;
        frame.size.height = heightCell;
        [cell.simiContentView setFrame:frame];
        row.height = heightCell;
    }
    return cell;
}

- (SimiTableViewCell *)createPriceCell:(SimiRow *)row{
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if (cell == nil) {
        cell = [[SimiTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor clearColor]];
        
        cell.simiContentView = [[UIView alloc] initWithFrame:CGRectMake(paddingEdge, 0, tableWidth - 2*paddingEdge, row.height)];
        cell.simiContentView.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:cell.simiContentView];
        
        self.priceView = [[SCPPriceView alloc]initWithFrame:CGRectMake(paddingEdge, 0, CGRectGetWidth(cell.simiContentView.frame) - paddingEdge*2,20)];
        [self.priceView showPriceWithProduct:self.product optionController:optionController widthView:CGRectGetWidth(self.priceView.frame) showTierPrice:YES];
        [cell.simiContentView addSubview:self.priceView];
        cell.heightCell = CGRectGetHeight(self.priceView.frame)+paddingEdge;
        CGRect frame = cell.simiContentView.frame;
        frame.size.height = cell.heightCell;
        [cell.simiContentView setFrame:frame];
        row.height = cell.heightCell;
    }
    return cell;
}

- (SimiTableViewCell*)createAddToCartCell:(SimiRow*)row{
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if (cell == nil) {
        cell = [[SimiTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor clearColor]];
        
        cell.simiContentView = [[UIView alloc] initWithFrame:CGRectMake(paddingEdge, 1, tableWidth - 2*paddingEdge, row.height - 1)];
        cell.simiContentView.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:cell.simiContentView];
        
        minusQuantityButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 10, 44, 44)];
        [minusQuantityButton setImage:[UIImage imageNamed:@"scp_ic_minus"] forState:UIControlStateNormal];
        [minusQuantityButton addTarget:self action:@selector(decreaseQuantity:) forControlEvents:UIControlEventTouchUpInside];
        [minusQuantityButton setImageEdgeInsets:UIEdgeInsetsMake(13.5, 18, 13.5, 9)];
        [cell.simiContentView addSubview:minusQuantityButton];
        
        quantityButton = [[UIButton alloc]initWithFrame:CGRectMake(44, 15, 52, 34)];
        [quantityButton setTitleColor:COLOR_WITH_HEX(@"#272727") forState:UIControlStateNormal];
        [quantityButton.titleLabel setFont:[UIFont fontWithName:SCP_FONT_SEMIBOLD size:FONT_SIZE_HEADER]];
        quantityButton.layer.borderColor = SCP_BUTTON_BACKGROUND_COLOR.CGColor;
        quantityButton.layer.borderWidth = 1;
        quantityButton.layer.cornerRadius = 17;
        [cell.simiContentView addSubview:quantityButton];
        
        plusQuantityButton = [[UIButton alloc]initWithFrame:CGRectMake(96, 10, 44, 44)];
        [plusQuantityButton setImage:[UIImage imageNamed:@"scp_ic_plus"] forState:UIControlStateNormal];
        [plusQuantityButton addTarget:self action:@selector(increaseQuantity:) forControlEvents:UIControlEventTouchUpInside];
        [plusQuantityButton setImageEdgeInsets:UIEdgeInsetsMake(13.5, 9, 13.5, 18)];
        [cell.simiContentView addSubview:plusQuantityButton];
        
        self.buttonAddToCart = [[SimiButton alloc]initWithFrame:CGRectMake(140, 12, CGRectGetWidth(cell.simiContentView.frame) - 158, 40) title:SCLocalizedString(@"Add to Cart") titleFont:[UIFont fontWithName:SCP_FONT_SEMIBOLD size:FONT_SIZE_HEADER] cornerRadius:20];
        [self.buttonAddToCart addTarget:self action:@selector(addToCart) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonAddToCart setBackgroundColor:SCP_BUTTON_BACKGROUND_COLOR];
        [self.buttonAddToCart setTitleColor:SCP_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
        [cell.simiContentView addSubview:self.buttonAddToCart];
        
        if(self.product.maxQty > 10000)
            self.product.maxQty = 10000;
        qty = (int)self.product.minQty;
        [quantityButton setTitle:[NSString stringWithFormat:@"%d",qty] forState:UIControlStateNormal];
        [quantityButton addTarget:self action:@selector(editQty:) forControlEvents:UIControlEventTouchUpInside];
        if (!self.product.isSalable) {
            [self updateAddToCartState:NO];
        }
    }
    return cell;
}

- (UITableViewCell*)createRelatedCell:(SimiRow*)row{
    UITableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        itemWidth = 140;
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        flowLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
        flowLayout.minimumInteritemSpacing = SCP_GLOBALVARS.interitemSpacing;
        flowLayout.minimumLineSpacing = SCP_GLOBALVARS.lineSpacing;
        relatedProductCollectionView =[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, itemHeight) collectionViewLayout:flowLayout];
        [relatedProductCollectionView setContentInset:UIEdgeInsetsMake(0, paddingEdge, 0, paddingEdge)];
        relatedProductCollectionView.dataSource = self;
        relatedProductCollectionView.delegate = self;
        [relatedProductCollectionView setBackgroundColor:[UIColor clearColor]];
        relatedProductCollectionView.showsHorizontalScrollIndicator = NO;
        [cell.contentView addSubview: relatedProductCollectionView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (UITableViewCell *)createDescriptionCell:(SimiRow *)row{
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if (cell == nil) {
        cell = [[SimiTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.backgroundColor = [UIColor clearColor];
        float heightCell = 0;
        cell.simiContentView = [[UIView alloc] initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - 2*paddingEdge, 0)];
        cell.simiContentView.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:cell.simiContentView];
        
        UIImageView *nextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(cell.simiContentView.frame) - paddingEdge - 18, 13, 18, 18)];
        nextImageView.image = [[UIImage imageNamed:@"scp_ic_next"] imageWithColor:SCP_ICON_COLOR];
        [cell.simiContentView addSubview:nextImageView];
        
        SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, 13, CGRectGetWidth(cell.simiContentView.frame) - paddingEdge*2 - 40, 18) andFontName:SCP_FONT_SEMIBOLD andFontSize:FONT_SIZE_LARGE];
        [titleLabel setText:[SCLocalizedString(@"Description") uppercaseString]];
        [cell.simiContentView addSubview:titleLabel];
        heightCell += 40;
        
        if (self.product.shortDescription) {
            NSString *shortDescription = self.product.shortDescription;
            if (![shortDescription isEqualToString:@""]) {
                SimiLabel *shortDescriptionLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, CGRectGetWidth(cell.simiContentView.frame) - paddingEdge*2, 30) andFontSize:FONT_SIZE_MEDIUM];
                NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithData:[shortDescription dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                [attributeString addAttributes:@{NSFontAttributeName:[UIFont fontWithName:SCP_FONT_LIGHT size:FONT_SIZE_MEDIUM]} range:NSMakeRange(0, attributeString.length)];
                shortDescriptionLabel.attributedText = attributeString;
                [cell.simiContentView addSubview:shortDescriptionLabel];
                heightCell = [shortDescriptionLabel resizLabelToFit] + paddingEdge;
            }
        }
        CGRect frame = cell.simiContentView.frame;
        frame.size.height = heightCell;
        cell.simiContentView.frame = frame;
        cell.heightCell = heightCell;
        [SimiGlobalFunction sortViewForRTL:cell.simiContentView andWidth:CGRectGetWidth(cell.simiContentView.frame)];
    }
    row.height = cell.heightCell;
    return cell;
}

- (UITableViewCell*)createTechSpecsCell:(SimiRow*)row{
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if (cell == nil) {
        cell = [[SimiTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.backgroundColor = [UIColor clearColor];
        float heightCell = 0;
        cell.simiContentView = [[UIView alloc] initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - 2*paddingEdge, row.height)];
        cell.simiContentView.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:cell.simiContentView];
        
        UIImageView *nextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(cell.simiContentView.frame) - paddingEdge - 18, 13, 18, 18)];
        nextImageView.image = [[UIImage imageNamed:@"scp_ic_next"] imageWithColor:SCP_ICON_COLOR];
        [cell.simiContentView addSubview:nextImageView];
        
        SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, 13, CGRectGetWidth(cell.simiContentView.frame) - paddingEdge*2 - 40, 18) andFontName:SCP_FONT_SEMIBOLD andFontSize:FONT_SIZE_LARGE];
        [titleLabel setText:[SCLocalizedString(@"Tech Specs") uppercaseString]];
        [cell.simiContentView addSubview:titleLabel];
    }
    return cell;
}

- (UIView *)contentTableViewViewForHeaderInSection:(NSInteger)section{
    SimiSection *simiSection = [self.cells objectAtIndex:section];
    if ([simiSection.identifier isEqualToString:scpproduct_configurableoption_section]){
        SCProductOptionSection *optionSection = (SCProductOptionSection*)simiSection;
        SimiConfigurableOptionModel *configOptionModel = (SimiConfigurableOptionModel*)optionSection.optionModel;
        if (![[configOptionModel.code uppercaseString] isEqualToString:@"COLOR"]&&![[configOptionModel.code uppercaseString] isEqualToString:@"SIZE"]) {
            return [self generateDropdownHeaderViewWithSection:optionSection];
        }
    }else if ([simiSection.identifier isEqualToString:scpproduct_customoption_section]) {
        SCProductOptionSection *optionSection = (SCProductOptionSection*)simiSection;
        return [self generateDropdownHeaderViewWithSection:optionSection];
    }else if ([simiSection.identifier isEqualToString:scpproduct_bundleoption_section]) {
        SCProductOptionSection *optionSection = (SCProductOptionSection*)simiSection;
        return [self generateDropdownHeaderViewWithBundleSection:optionSection];
    }else if ([simiSection.identifier isEqualToString:scpproduct_description_section] || [simiSection.identifier isEqualToString:scpproduct_techspecs_section] || [simiSection.identifier isEqualToString:@"product_reviews_section"]){
        SCPTableViewHeaderFooterView *headerView = [[SCPTableViewHeaderFooterView alloc]initWithReuseIdentifier:simiSection.identifier];
        [headerView.contentView setBackgroundColor:[UIColor clearColor]];
        return headerView;
    }else if ([simiSection.identifier isEqualToString:product_related_section]){
        return [self generateRelatedHeaderViewWithSection:simiSection];
    }
    return nil;
}

- (SCPTableViewHeaderFooterView*)generateDropdownHeaderViewWithSection:(SCProductOptionSection*)optionSection{
    float padding = SCP_GLOBALVARS.padding;
    float height = optionSection.header.height;
    SCPTableViewHeaderFooterView *headerView = [self.contentTableView dequeueReusableHeaderFooterViewWithIdentifier:optionSection.optionModel.entityId];
    if (headerView == nil) {
        headerView = [[SCPTableViewHeaderFooterView alloc]initWithReuseIdentifier:optionSection.optionModel.entityId];
        [headerView.contentView setBackgroundColor:[UIColor clearColor]];
        headerView.simiContentView = [[UIView alloc]initWithFrame:CGRectMake(padding, 0, CGRectGetWidth(self.contentTableView.frame) - padding*2, height)];
        [headerView.simiContentView setBackgroundColor:[UIColor whiteColor]];
        [headerView.contentView addSubview:headerView.simiContentView];
        float titleWidth = [[optionSection.optionModel.title uppercaseString] sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:SCP_FONT_SEMIBOLD size:FONT_SIZE_LARGE]}].width;
        headerView.titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, 0, titleWidth, height) andFontName:SCP_FONT_SEMIBOLD andFontSize:FONT_SIZE_LARGE];
        [headerView.titleLabel setText:[optionSection.optionModel.title uppercaseString]];
        [headerView.simiContentView addSubview:headerView.titleLabel];
        
        headerView.iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(headerView.simiContentView.frame) - padding - 9, 17.5, 9, 9)];
        if (optionSection.isShow) {
            [headerView.iconImageView setImage:[UIImage imageNamed:@"scp_ic_option_up"]];
        }else{
            [headerView.iconImageView setImage:[UIImage imageNamed:@"scp_ic_option_down"]];
        }
        [headerView.simiContentView addSubview:headerView.iconImageView];
        
        UIButton *headerButton = [[UIButton alloc]initWithFrame:headerView.simiContentView.bounds];
        [headerButton addTarget:self action:@selector(updateOptionSectionState:) forControlEvents:UIControlEventTouchUpInside];
        headerButton.simiObjectIdentifier = headerView.iconImageView;
        headerView.iconImageView.simiObjectIdentifier = optionSection;
        [headerButton setBackgroundColor:[UIColor clearColor]];
        [headerView.simiContentView addSubview:headerButton];
    }
    return headerView;
}

- (SCPTableViewHeaderFooterView*)generateDropdownHeaderViewWithBundleSection:(SCProductOptionSection*)optionSection{
    SCPTableViewHeaderFooterView *headerView = [self generateDropdownHeaderViewWithSection:optionSection];
    [headerView.simiContentView setBackgroundColor:COLOR_WITH_HEX(@"#fafafa")];
    return headerView;
}

- (SCPTableViewHeaderFooterView*)generateRelatedHeaderViewWithSection:(SimiSection*)section{
    float padding = SCP_GLOBALVARS.padding;
    float height = section.header.height;
    SCPTableViewHeaderFooterView *headerView = [[SCPTableViewHeaderFooterView alloc]initWithReuseIdentifier:section.identifier];
    [headerView.contentView setBackgroundColor:[UIColor clearColor]];
    
    headerView.titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, 0, CGRectGetWidth(self.contentTableView.frame) - padding*2, height) andFontName:SCP_FONT_SEMIBOLD andFontSize:FONT_SIZE_HEADER];
    [headerView.titleLabel setText:[section.header.title uppercaseString]];
    [headerView.contentView addSubview:headerView.titleLabel];
    return headerView;
}
#pragma mark -
#pragma mark Option Action
- (void)updateOptionSectionState:(UIButton*)sender{
    UIImageView *iconImageView = (UIImageView*)sender.simiObjectIdentifier;
    SCProductOptionSection *optionSection = (SCProductOptionSection *)iconImageView.simiObjectIdentifier;
    NSInteger sectionIndex = [self.cells indexOfObject:optionSection];
    NSMutableArray *indexPaths = [NSMutableArray new];
    for (int i = 0; i < optionSection.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:sectionIndex];
        [indexPaths addObject:indexPath];
    }
    optionSection.isShow = !optionSection.isShow;
    if (optionSection.isShow) {
        [self.contentTableView beginUpdates];
        [self.contentTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.contentTableView endUpdates];
    }else{
        [self.contentTableView beginUpdates];
        [self.contentTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.contentTableView endUpdates];
    }
    if (optionSection.isShow) {
        [iconImageView setImage:[UIImage imageNamed:@"scp_ic_option_up"]];
    }else{
        [iconImageView setImage:[UIImage imageNamed:@"scp_ic_option_down"]];
    }
}

- (void)optionTextFieldDidEndEditing:(UITextField *)textField{
    SCProductOptionSection *section = (SCProductOptionSection*)textField.simiObjectIdentifier;
    if (section != nil) {
        SimiCustomOptionModel *customOptionModel = (SimiCustomOptionModel*)section.optionModel;
        if ([optionController.selectedCustomOptions objectForKey:section.identifier]) {
            [optionController.selectedCustomOptions removeObjectForKey:section.identifier];
        }
        SimiCustomOptionValueModel *valueModel = [customOptionModel.values objectAtIndex:0];
        NSString *text = textField.text;
        if (text == nil || [text isEqualToString:@""]) {
            [customOptionModel removeObjectForKey:@"option_value"];
            customOptionModel.isSelected = NO;
            valueModel.isSelected = NO;
        }else{
            [customOptionModel setValue:text forKey:@"option_value"];
            customOptionModel.isSelected = YES;
            valueModel.isSelected = YES;
        }
        [self handleSelectedOption];
    }
}

- (void)optionDateTimeUpdate:(UIDatePicker *)datePicker{
    SCProductOptionSection *section = (SCProductOptionSection*)datePicker.simiObjectIdentifier;
    if (section != nil) {
        SimiCustomOptionModel *customOptionModel = (SimiCustomOptionModel*)section.optionModel;
        if ([optionController.selectedCustomOptions objectForKey:section.identifier]) {
            [optionController.selectedCustomOptions removeObjectForKey:section.identifier];
        }
        SimiCustomOptionValueModel *valueModel = [customOptionModel.values objectAtIndex:0];
        valueModel.isSelected = YES;
        customOptionModel.isSelected = YES;
        
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
        if ([customOptionModel.type isEqualToString:@"date"]) {
            [dateFormater setDateFormat:@"yyyy-MM-dd"];
        } else if ([customOptionModel.type isEqualToString:@"date_time"]) {
            [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        } else {
            [dateFormater setDateFormat:@"HH:mm:ss"];
        }
        [customOptionModel setValue:[dateFormater stringFromDate:datePicker.date] forKey:@"option_value"];
        [customOptionModel setValue:datePicker.date forKey:@"date_value"];
        [self handleSelectedOption];
    }
}

- (void)updateAddToCartState:(BOOL)availabelAddToCart{
    if(availabelAddToCart){
        [minusQuantityButton setEnabled:YES];
        [plusQuantityButton setEnabled:YES];
        [quantityButton setEnabled:YES];
        [self.buttonAddToCart setEnabled:YES];
        [self.buttonAddToCart setTitle:SCLocalizedString(@"Add to Cart") forState:UIControlStateNormal];
        self.buttonAddToCart.alpha = 1;
    }else{
        [minusQuantityButton setEnabled:NO];
        [plusQuantityButton setEnabled:NO];
        [quantityButton setEnabled:NO];
        [self.buttonAddToCart setEnabled:NO];
        [self.buttonAddToCart setTitle:SCLocalizedString(@"Out of stock") forState:UIControlStateNormal];
        self.buttonAddToCart.alpha = 0.4;
    }
}

#pragma mark -
#pragma mark Product Detail Action
- (void)handleSelectedOption{
    [optionController handleSelectedOption];
    [self.contentTableView reloadData];
    [self.priceView showPriceWithProduct:self.product optionController:optionController widthView:CGRectGetWidth(self.priceView.frame) showTierPrice:YES];
}

- (void)increaseQuantity:(UIButton*)sender{
    float qtyIncrement = 1;
    if (self.product.qtyIncrement > 0) {
        qtyIncrement = self.product.qtyIncrement;
    }
    qty += qtyIncrement;
    [quantityButton setTitle:[NSString stringWithFormat:@"%d",qty] forState:UIControlStateNormal];
}

- (void)decreaseQuantity:(UIButton*)sender{
    float qtyIncrement = 1;
    if (self.product.qtyIncrement > 0) {
        qtyIncrement = self.product.qtyIncrement;
    }
    if (qty > self.product.minQty) {
        qty -= qtyIncrement;
    }
    [quantityButton setTitle:[NSString stringWithFormat:@"%d",qty] forState:UIControlStateNormal];
}

- (void)addToCart{
    if ([optionController enableAddProductToCart]) {
        //Create animation
        UIImageView *thumnailView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 100, 300, 400)];
        thumnailView.image = currentImageProduct.image;
        [thumnailView setContentMode:UIViewContentModeScaleAspectFit];
        [self.view addSubview:thumnailView];
        [UIView animateWithDuration:0.6
                              delay:0
                            options:UIViewAnimationOptionAllowAnimatedContent
                         animations:^{
                             thumnailView.frame = CGRectMake(260, 0, 60, 90);
                             thumnailView.transform = CGAffineTransformMakeRotation(140);
                         }
                         completion:^(BOOL finished){
                             [thumnailView removeFromSuperview];
                         }];
        [self startLoadingData];
        NSDictionary* cartItem = [self cartItem];
        [[NSNotificationCenter defaultCenter] postNotificationName:Simi_AddToCart object:nil userInfo:@{@"data":cartItem}];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddToCart:) name:Simi_DidAddToCart object:nil];
        return;
    }else{
        [self showAlertWithTitle:@"" message:@"Please select all require options"];
    }
}
#pragma mark -
#pragma mark Option Collection Delegate
- (void)updateOptionsWithProductOptionModel:(SimiConfigurableOptionModel *)optionModel andValueModel:(SimiConfigurableOptionValueModel *)valueModel{
    [optionController activeDependenceWithConfigurableValueModel:valueModel configurableOptioModel:optionModel];
    [self updateAddToCartState:((SCPOptionController*)optionController).availableAddToCart];
    [self.contentTableView reloadData];
}

#pragma mark -
#pragma mark TableViewDelegate & Action
- (void)tapToProductImage:(id)sender{
    SCPProductImagesViewController *imagesViewController = [SCPProductImagesViewController new];
    imagesViewController.productImages = [productImages valueForKey:@"url"];
    imagesViewController.currentIndexImage = imagesPageControll.currentPage;
    [self presentViewController:imagesViewController animated:YES completion:nil];
}

- (void)contentTableViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if ([section.identifier isEqualToString:scpproduct_description_section]) {
        if ([row.identifier isEqualToString:product_description_row]){
            [self didSelectDescriptionRow];
        }
    }else if ([section.identifier isEqualToString:scpproduct_configurableoption_section]){
        if([row.identifier isEqualToString:scpproduct_option_single_select_row]){
            [self didSelectConfigurableOptionAtIndexPath:indexPath];
        }
    }else if ([section.identifier isEqualToString:scpproduct_customoption_section]){
        [self didSelectCustomOptionAtIndexPath:indexPath];
    }else if ([section.identifier isEqualToString:scpproduct_bundleoption_section]){
        [self didSelectBundleOptionAtIndexPath:indexPath];
    }else if ([section.identifier isEqualToString:scpproduct_techspecs_section]){
        if ([row.identifier isEqualToString:product_techspecs_row]){
            [self didSelectTechSpecsRow];
        }
    }
    [self.contentTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didSelectConfigurableOptionAtIndexPath:(NSIndexPath *)indexPath{
    SCProductOptionSection *simiSection = [self.cells objectAtIndex:indexPath.section];
    SCProductOptionRow *simiRow = (SCProductOptionRow *)[simiSection objectAtIndex:indexPath.row];
    SimiConfigurableOptionModel *optionModel = (SimiConfigurableOptionModel*)simiSection.optionModel;
    for (int i = 0; i < optionModel.values.count; i++) {
        SimiConfigurableOptionValueModel *valueModel = [optionModel.values objectAtIndex:i];
        if (i != indexPath.row) {
            valueModel.isSelected = NO;
        }
    }
    if (!simiRow.optionValueModel.isSelected) {
        simiRow.optionValueModel.isSelected = YES;
        [optionController activeDependenceWithConfigurableValueModel:(SimiConfigurableOptionValueModel*)simiRow.optionValueModel configurableOptioModel:optionModel];
        [self updateAddToCartState:((SCPOptionController*)optionController).availableAddToCart];
    }
    [self handleSelectedOption];
}

- (void)didSelectCustomOptionAtIndexPath:(NSIndexPath *)indexPath{
    SCProductOptionSection *simiSection = [self.cells objectAtIndex:indexPath.section];
    SCProductOptionRow *simiRow = (SCProductOptionRow *)[simiSection objectAtIndex:indexPath.row];
    SimiCustomOptionModel *customOptionModel = (SimiCustomOptionModel*)simiSection.optionModel;
    if([simiRow.identifier isEqualToString:scpproduct_option_single_select_row]){
        for (int i = 0; i < customOptionModel.values.count;i++) {
            SimiCustomOptionValueModel *valueModel = [customOptionModel.values objectAtIndex:i];
            if (i != indexPath.row) {
                valueModel.isSelected = NO;
            }
        }
        if (!simiRow.optionValueModel.isSelected) {
            simiRow.optionValueModel.isSelected = YES;
        }else
            simiRow.optionValueModel.isSelected = NO;
        [self handleSelectedOption];
    }else if([simiRow.identifier isEqualToString:scpproduct_option_multi_select_row]){
        if (!simiRow.optionValueModel.isSelected) {
            simiRow.optionValueModel.isSelected = YES;
        }else
            simiRow.optionValueModel.isSelected = NO;
        [self handleSelectedOption];
    }
}

- (void)didSelectBundleOptionAtIndexPath:(NSIndexPath *)indexPath{
    SCProductOptionSection *simiSection = [self.cells objectAtIndex:indexPath.section];
    SCProductOptionRow *simiRow = (SCProductOptionRow *)[simiSection objectAtIndex:indexPath.row];
    SimiBundleOptionModel *optionModel = (SimiBundleOptionModel*)simiSection.optionModel;
    if([simiRow.identifier isEqualToString:scpproduct_option_single_select_row]){
        for (int i = 0; i < optionModel.values.count;i++) {
            SimiCustomOptionValueModel *valueModel = [optionModel.values objectAtIndex:i];
            if (i != indexPath.row) {
                valueModel.isSelected = NO;
            }
        }
        if (!simiRow.optionValueModel.isSelected) {
            simiRow.optionValueModel.isSelected = YES;
        }else
            simiRow.optionValueModel.isSelected = NO;
        [self handleSelectedOption];
    }else if([simiRow.identifier isEqualToString:scpproduct_option_multi_select_row]){
        if (!simiRow.optionValueModel.isSelected) {
            simiRow.optionValueModel.isSelected = YES;
        }else
            simiRow.optionValueModel.isSelected = NO;
        [self handleSelectedOption];
    }
}

#pragma mark More Action
- (void)initMoreViewAction
{
    float sizeButton = 50;
    float sizePlus = 18;
    float tabbarHeight = CGRectGetHeight(self.tabBarController.tabBar.frame);
    float moreButtonOrgionX = CGRectGetWidth(self.view.frame) - sizeButton - paddingEdge/2;
    float moreButtonOrgionY = CGRectGetHeight(self.view.frame) - sizeButton - tabbarHeight - paddingEdge;
    float paddingIcon = 20;
    
    self.buttonMoreAction = [[UIButton alloc]initWithFrame:CGRectMake(moreButtonOrgionX, moreButtonOrgionY, sizeButton, sizeButton)];
    [self.buttonMoreAction addTarget:self action:@selector(didTouchMoreAction) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonMoreAction setBackgroundColor:THEME_BUTTON_BACKGROUND_COLOR];
    [self.buttonMoreAction.layer setCornerRadius:sizeButton/2.0f];
    [self.buttonMoreAction.layer setShadowOffset:CGSizeMake(1, 1)];
    [self.buttonMoreAction.layer setShadowRadius:2];
    self.buttonMoreAction.layer.shadowOpacity = 0.5;
    [self.buttonMoreAction setImage:[[UIImage imageNamed:@"ic_cong"]imageWithColor:THEME_BUTTON_TEXT_COLOR] forState:UIControlStateNormal];
    [self.buttonMoreAction setImageEdgeInsets:UIEdgeInsetsMake((sizeButton - sizePlus)/2, (sizeButton - sizePlus)/2, (sizeButton - sizePlus)/2, (sizeButton - sizePlus)/2)];
    
    CGRect frame = self.buttonMoreAction.frame;
    frame.size.height = 0;
    frame.size.width += paddingEdge *2;
    frame.origin.x -=  paddingEdge;
    
    self.viewMoreAction = [[MoreActionView alloc]initWithFrame:frame];
    [self.viewMoreAction setBackgroundColor:[UIColor clearColor]];
    self.viewMoreAction.arrayIcon = [NSMutableArray new];
    self.viewMoreAction.clipsToBounds = YES;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:SCProductViewControllerInitViewMoreAction object:self.viewMoreAction];
    NSArray *sortedArrayIcon = [self.viewMoreAction.arrayIcon sortedArrayUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
        NSInteger view1Tag = view1.tag;
        NSInteger view2Tag = view2.tag;
        if(view1Tag < view2Tag) {
            return NSOrderedAscending;
        }else if(view1Tag > view2Tag) {
            return NSOrderedDescending;
        }else {
            return NSOrderedSame;
        }
    }];
    self.viewMoreAction.arrayIcon = [[NSMutableArray alloc] initWithArray:sortedArrayIcon];
    self.viewMoreAction.heightMoreView = (paddingIcon + sizeButton) * (self.viewMoreAction.arrayIcon.count) + paddingIcon;
    if (self.viewMoreAction.arrayIcon.count > 0) {
        [self setInterFaceViewMore];
        [self.view addSubview:self.viewMoreAction];
        [self.view addSubview:self.buttonMoreAction];
    }
}
@end
