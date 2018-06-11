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

@interface SCPProductViewController ()

@end

@implementation SCPProductViewController

- (void)viewDidLoadBefore {
    [super viewDidLoadBefore];
}

- (void)viewDidAppearBefore:(BOOL)animated{
    [super viewDidAppearBefore:animated];
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
            if (self.product.isSalable) {
                [self initViewAction];
            }
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

- (void)createCells{
    SimiSection *mainSection = [[SimiSection alloc]initWithIdentifier:product_main_section];
    [mainSection addRowWithIdentifier:product_images_row height:tableWidth];
    [self.cells addObject:mainSection];
    if (self.product.productType == ProductTypeConfigurable) {
        [self addConfigOptionsToCells];
        [self addCustomOptionsToCells];
    }else if (self.product.productType == ProductTypeSimple){
        [self addCustomOptionsToCells];
    }
    SimiSection *descriptionSection = [[SimiSection alloc]initWithIdentifier:scpproduct_description_section];
    [descriptionSection addRowWithIdentifier:product_description_row height:200];
    [self.cells addObject:descriptionSection];
}

- (void)addConfigOptionsToCells{
    for(SimiConfigurableOptionModel *configOptionModel in optionController.configureOptions){
        if ([[configOptionModel.code uppercaseString] isEqualToString:@"COLOR"]) {
            SCProductOptionSection *configOptionSection = [[SCProductOptionSection alloc]initWithIdentifier:scpproduct_configurableoption_section];
            configOptionSection.optionModel = configOptionModel;
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
        NSString *identifier = @"";
        for (SimiCustomOptionValueModel *valueModel in customOptionModel.values) {
            float rowHeight = 44;
            if ([customOptionModel.type isEqualToString:@"drop_down"]||[customOptionModel.type isEqualToString:@"radio"]) {
                identifier = scpproduct_option_single_select_row;
                rowHeight = 44;
            }else if ([customOptionModel.type isEqualToString:@"checkbox"]||[customOptionModel.type isEqualToString:@"multiple"]){
                identifier = scpproduct_option_multi_select_row;
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
        if ([row.identifier isEqualToString:scpproduct_option_single_select_row]){
            cell = [self createOptionSingleSelectCell:row];
        }else if ([row.identifier isEqualToString:scpproduct_option_multi_select_row]){
            cell = [self createOptionMultiSelectCell:row];
        }
    }else if ([section.identifier isEqualToString:scpproduct_description_section]){
        if ([row.identifier isEqualToString:product_description_row]) {
            cell = [self createDescriptionCell:row];
        }
    }
    return cell;
}

- (SimiTableViewCell*)createOptionItemSelectCell:(SimiRow*)row{
    SCPProductOptionTypeGridTableViewCell *cell = [[SCPProductOptionTypeGridTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.simiObjectName andRow:(SCProductOptionRow*)row];
    cell.delegate = self;
    return cell;
}

- (SimiTableViewCell*)createOptionSingleSelectCell:(SimiRow*)row{
    SCProductOptionRow *optionRow = (SCProductOptionRow*)row;
    SCPProductSingleSelectTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:optionRow.optionValueModel.valueId];
    if (cell == nil) {
        cell = [[SCPProductSingleSelectTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:optionRow.optionValueModel.valueId optionRow:optionRow productModel:self.product];
    }
    [cell updateCellWithRow:optionRow];
    return cell;
}

- (SimiTableViewCell*)createOptionMultiSelectCell:(SimiRow*)row{
    SCProductOptionRow *optionRow = (SCProductOptionRow*)row;
    SCPProductMultiSelectTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:optionRow.optionValueModel.valueId];
    if (cell == nil) {
        cell = [[SCPProductMultiSelectTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:optionRow.optionValueModel.valueId optionRow:optionRow productModel:self.product];
    }
    [cell updateCellWithRow:optionRow];
    return cell;
}

- (UIView *)contentTableViewViewForHeaderInSection:(NSInteger)section{
    SimiSection *simiSection = [self.cells objectAtIndex:section];
    float padding = SCP_GLOBALVARS.padding;
    float height = simiSection.header.height;
    if ([simiSection.identifier isEqualToString:scpproduct_configurableoption_section] ||[simiSection.identifier isEqualToString:scpproduct_customoption_section]) {
        SCProductOptionSection *optionSection = (SCProductOptionSection*)simiSection;
        SCPTableViewHeaderFooterView *headerView = [[SCPTableViewHeaderFooterView alloc]initWithReuseIdentifier:optionSection.optionModel.entityId];
        [headerView.contentView setBackgroundColor:[UIColor clearColor]];
        headerView.simiContentView = [[UIView alloc]initWithFrame:CGRectMake(padding, 0, CGRectGetWidth(self.contentTableView.frame) - padding*2, height)];
        [headerView.simiContentView setBackgroundColor:[UIColor whiteColor]];
        [headerView.contentView addSubview:headerView.simiContentView];
        SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, 0, 100, height) andFontName:SCP_FONT_SEMIBOLD andFontSize:FONT_SIZE_LARGE];
        [titleLabel setText:[optionSection.optionModel.title uppercaseString]];
        [headerView.simiContentView addSubview:titleLabel];
        return headerView;
    }
    return nil;
}



- (UITableViewCell *)createProductImageCell:(SimiRow *)row{
    UITableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = COLOR_WITH_HEX(@"#ededed");
        float imageWidth = tableWidth - paddingEdge*2;
        float imageHeight = row.height - 2*paddingEdge;
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
    }
    return cell;
}

- (UITableViewCell *)createNameCell:(SimiRow *)row{
    return [super createNameCell:row];
}

- (UITableViewCell *)createRelatedCell:(SimiRow *)row{
    return [super createRelatedCell:row];
}

- (UITableViewCell *)createDescriptionCell:(SimiRow *)row{
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if (cell == nil) {
        cell = [[SimiTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.backgroundColor = [UIColor clearColor];
        float heightCell = 0;
        UIView *descriptionView = [[UIView alloc] initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - 2*paddingEdge, 0)];
        [cell.contentView addSubview:descriptionView];
        descriptionView.backgroundColor = [UIColor whiteColor];
        UIImageView *nextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(descriptionView.frame) - paddingEdge - 30, paddingEdge, 20, 20)];
        nextImageView.image = [[UIImage imageNamed:@"scp_ic_next"] imageWithColor:SCP_ICON_COLOR];
        [descriptionView addSubview:nextImageView];
        SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, paddingEdge, CGRectGetWidth(descriptionView.frame) - paddingEdge*2 - 40, 30) andFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_LARGE];
        [titleLabel setText:[SCLocalizedString(@"Description") uppercaseString]];
        [descriptionView addSubview:titleLabel];
        heightCell += 40;
        
        if (self.product.shortDescription) {
            NSString *shortDescription = self.product.shortDescription;
            if (![shortDescription isEqualToString:@""]) {
                SimiLabel *shortDescriptionLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, CGRectGetWidth(descriptionView.frame) - paddingEdge*2, 30) andFontSize:FONT_SIZE_MEDIUM];
                NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithData:[shortDescription dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                [attributeString addAttributes:@{NSFontAttributeName:[UIFont fontWithName:THEME_FONT_NAME size:FONT_SIZE_MEDIUM]} range:NSMakeRange(0, attributeString.length)];
                shortDescriptionLabel.attributedText = attributeString;
                [descriptionView addSubview:shortDescriptionLabel];
                heightCell = [shortDescriptionLabel resizLabelToFit] + paddingEdge;
            }
        }
        CGRect frame = descriptionView.frame;
        frame.size.height = heightCell;
        descriptionView.frame = frame;
        cell.heightCell = heightCell + paddingEdge;
        [SimiGlobalFunction sortViewForRTL:descriptionView andWidth:CGRectGetWidth(descriptionView.frame)];
    }
    row.height = cell.heightCell;
    return cell;
}

- (void)tapToProductImage:(id)sender{
    SCPProductImagesViewController *imagesViewController = [SCPProductImagesViewController new];
    imagesViewController.productImages = [productImages valueForKey:@"url"];
    imagesViewController.currentIndexImage = imagesPageControll.currentPage;
    [self presentViewController:imagesViewController animated:YES completion:nil];
}

#pragma Collection Delegate
- (void)updateOptionsWithProductOptionModel:(SimiConfigurableOptionModel *)optionModel andValueModel:(SimiConfigurableOptionValueModel *)valueModel{
    [optionController activeDependenceWithConfigurableValueModel:valueModel configurableOptioModel:optionModel];
    [self.contentTableView reloadData];
}
@end
