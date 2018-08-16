//
//  SCCustomizeProductOptionViewController.m
//  SimiCartPluginFW
//
//  Created by Liam on 3/6/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCCustomizeProductOptionViewController.h"

@interface SCCustomizeProductOptionViewController ()

@end

@implementation SCCustomizeProductOptionViewController
- (void)setupTableView{
    self.contentTableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentTableView.frame), CGFLOAT_MIN)];
    self.contentTableView.tableFooterView = [UIView new];
}

- (void)createCells{
    heightHeader = 60;
    self.allKeys = [NSMutableArray new];
    switch (self.product.productType) {
        case ProductTypeConfigurable:{
            [self addConfigOptionsToCells];
            [self addCustomOptionsToCells];
        }
            break;
        case ProductTypeDownloadable:{
            [self addDownloadOptionsToCells];
            [self addCustomOptionsToCells];
        }
            break;
        case ProductTypeSimple:{
            [self addCustomOptionsToCells];
        }
            break;
        case ProductTypeBundle:{
            [self addBundleOptionsToCells];
            [self addCustomOptionsToCells];
        }
            break;
        case ProductTypeGrouped:{
            [self addGroupOptionsToCells];
        }
            break;
        default:
            break;
    }
    self.expendSections = [NSMutableDictionary new];
    for (NSString *key in self.allKeys) {
        [self.expendSections setValue:@"YES" forKey:key];
    }
    [self.contentTableView reloadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    SCProductOptionSection *simiSection = [self.cells objectAtIndex:section];
    UITableViewHeaderFooterView *viewHeader = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:nil];
    [viewHeader.contentView setBackgroundColor:[SimiGlobalFunction colorWithHexString:@"#ededed"]];
    viewHeader.tag = section;
    
    SimiLabel *lblHeader = [[SimiLabel alloc]initWithFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_MEDIUM andTextColor:[SimiGlobalFunction colorWithHexString:@"#131313"]];
    [lblHeader setBackgroundColor:[UIColor clearColor]];
    lblHeader.numberOfLines = 0;
    
    SimiLabel *lblPrice = [[SimiLabel alloc]initWithFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_LARGE andTextColor:THEME_PRICE_COLOR];
    [lblPrice setBackgroundColor:[UIColor clearColor]];
    float price = -1;
    [lblHeader setFrame:CGRectMake(paddingEdge, 0, widthTitle, heightHeader)];
    [lblPrice setFrame:CGRectMake(self.widthTable - widthValue - 26, 0, widthValue - 10, heightHeader)];
    [viewHeader addSubview:lblHeader];
    
    NSString *stringHeaderTitle = simiSection.header.title;
    if (simiSection.optionModel.isRequire) {
        stringHeaderTitle = [NSString stringWithFormat:@"%@ (*)",simiSection.header.title];
        if (GLOBALVAR.isReverseLanguage) {
            stringHeaderTitle = [NSString stringWithFormat:@"(*) %@",simiSection.header.title];
        }
    }
#pragma mark Configurable
    if ([simiSection.simiObjectName isEqualToString:Option_Configurable]) {
        if([[self.optionController.selectedConfigureOptions valueForKey:simiSection.identifier] isKindOfClass:[NSDictionary class]]){
            price = [self headerPriceForConfigurableOption:section];
        }
#pragma mark Downloadable
    }else if ([simiSection.simiObjectName isEqualToString:Option_Downloadable]){
        if([[self.optionController.selectedDownloadableOptions valueForKey:simiSection.identifier] isKindOfClass:[NSDictionary class]]){
            price = [self headerPriceForDownloadableOption:section];
        }
#pragma mark Custom
    }else if ([simiSection.simiObjectName isEqualToString:Option_Custom])
    {
        if([[self.optionController.selectedCustomOptions valueForKey:simiSection.identifier] isKindOfClass:[NSDictionary class]]){
            price = [self headerPriceForCustomOption:section];
        }
#pragma mark Bundle
    }else if ([simiSection.simiObjectName isEqualToString:Option_Bundle])
    {
        if([[self.optionController.selectedBundleOptions valueForKey:simiSection.identifier] isKindOfClass:[NSDictionary class]]){
            price = [self headerPriceForBundleOption:section];
        }
#pragma mark Group
    }else if ([simiSection.simiObjectName isEqualToString:Option_Group]) {
        SimiGroupOptionModel *groupOptionModel = (SimiGroupOptionModel*)simiSection.optionModel;
        stringHeaderTitle = [NSString stringWithFormat:@"%.f x %@", groupOptionModel.qty, groupOptionModel.title];
        if (GLOBALVAR.isReverseLanguage) {
            stringHeaderTitle = [NSString stringWithFormat:@"%@ x %.f",groupOptionModel.title, groupOptionModel.qty];
        }
        [lblHeader setFrame:CGRectMake(paddingEdge, 0, self.widthTable - paddingEdge - 30, heightHeader)];
    }
    lblHeader.text = stringHeaderTitle;
    if (price >= 0) {
        lblPrice.text = [[SimiFormatter sharedInstance]priceWithPrice:[NSString stringWithFormat:@"%0.2f",price]];
        if (price == 0 && ![GLOBALVAR isShowZeroPrice]) {
            [lblPrice setHidden:YES];
        }
        [lblPrice setTextAlignment:NSTextAlignmentRight];
        [viewHeader addSubview:lblPrice];
    }
    
    UIImageView *narrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.contentTableView.frame.size.width - 26, 15, 10, 10)];
    if ([(NSString *)[self.expendSections objectForKey:[self.allKeys objectAtIndex:section]] boolValue]) {
        [narrowImage setImage:[UIImage imageNamed:@"ic_narrow_up"]];
    }else{
        [narrowImage setImage:[UIImage imageNamed:@"ic_narrow_down"]];
    }
    [viewHeader addSubview:narrowImage];
    UITapGestureRecognizer  *headerTapped   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionHeaderTapped:)];
    [viewHeader addGestureRecognizer:headerTapped];
    [SimiGlobalFunction sortViewForRTL:viewHeader andWidth:self.widthTable];
    [self endInitializedHeaderView:viewHeader atSection:section];
    return viewHeader;
}

- (UITableViewCell *)createGroupOptionCellWithIndexPath:(NSIndexPath *)indexPath{
    SCProductOptionSection *simiSection = [self.cells objectAtIndex:indexPath.section];
    SCProductOptionRow *simiRow = (SCProductOptionRow *)[simiSection objectAtIndex:indexPath.row];
    SCCustomizeGroupOptionCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:simiRow.identifier];
    if (cell == nil) {
        cell = [[SCCustomizeGroupOptionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier groupOptionModel:(SimiGroupOptionModel*)simiSection.optionModel];
        cell.delegate = self;
    }
    simiRow.height = cell.heightCell;
    return cell;
}

- (void)plusGroupOption:(SimiGroupOptionModel *)groupOptionModel{
    groupOptionModel.qty += 1;
    groupOptionModel.isSelected = YES;
    [self handleSelectedOption];
    [self.contentTableView reloadData];
}

- (void)minusGroupOption:(SimiGroupOptionModel *)groupOptionModel{
    if (groupOptionModel.qty > 0) {
        groupOptionModel.qty -= 1;
    }
    if (groupOptionModel.qty > 0) {
        groupOptionModel.isSelected = YES;
    }else{
        groupOptionModel.isSelected = NO;
    }
    [self handleSelectedOption];
    [self.contentTableView reloadData];
}
@end

@implementation SCCustomizeGroupOptionCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier groupOptionModel:(SimiGroupOptionModel *)groupOptionModel{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.groupOptionModel = groupOptionModel;
    if (self) {
        NSMutableArray *infos = nil;
        NSMutableArray *tierPrices = nil;
        if ([[groupOptionModel valueForKey:@"info"] isKindOfClass:[NSArray class]]) {
            infos = [[NSMutableArray alloc]initWithArray:[groupOptionModel valueForKey:@"info"]];
        }
        if ([[groupOptionModel valueForKey:@"tier_price"] isKindOfClass:[NSArray class]]) {
            tierPrices = [[NSMutableArray alloc]initWithArray:[groupOptionModel valueForKey:@"tier_price"]];
        }
        self.heightCell = 0;
        float padding = 15;
        float cellWidth = PHONEDEVICE?SCREEN_WIDTH - 30:SCREEN_WIDTH*2/3;
        if (infos.count > 0) {
            for (int i = 0; i < infos.count; i++) {
                NSDictionary *info = [infos objectAtIndex:i];
                if (info.count > 0) {
                    NSString *title = [NSString stringWithFormat:@"%@",[info.allKeys objectAtIndex:0]];
                    NSString *value = [NSString stringWithFormat:@"%@",[info.allValues objectAtIndex:0]];
                    SimiLabel *optionLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(padding, self.heightCell, cellWidth, 25)];
                    [optionLabel setTextWithTitle:title value:value fontSize:FONT_SIZE_LARGE];
                    optionLabel.numberOfLines = 0;
                    [optionLabel sizeToFit];
                    self.heightCell += CGRectGetHeight(optionLabel.frame);
                    [self.contentView addSubview:optionLabel];
                }
            }
        }
        if (tierPrices.count > 0 && GLOBALVAR.isLogin) {
            for (int i = 0; i < tierPrices.count; i++) {
                NSDictionary *tierPrice = [tierPrices objectAtIndex:i];
                NSString *title = [NSString stringWithFormat:@"%@",[tierPrice.allKeys objectAtIndex:0]];
                NSString *value = [NSString stringWithFormat:@"%@",[tierPrice.allValues objectAtIndex:0]];
                value = [[SimiFormatter sharedInstance]priceWithPrice:value];
                SimiLabel *optionLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(padding, self.heightCell, cellWidth, 25)];
                [optionLabel setTextWithTitle:title value:value fontSize:FONT_SIZE_LARGE];
                optionLabel.numberOfLines = 0;
                [optionLabel sizeToFit];
                self.heightCell += CGRectGetHeight(optionLabel.frame);
                [self.contentView addSubview:optionLabel];
            }
        }else if (!GLOBALVAR.isLogin){
            if ([[groupOptionModel valueForKey:@"Price"] isKindOfClass:[NSString class]]) {
                NSString *priceTitle = [NSString stringWithFormat:@"%@",[groupOptionModel valueForKey:@"Price"]];
                SimiLabel *priceTitleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, self.heightCell, cellWidth - padding*2, 25) andFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_LARGE];
                [priceTitleLabel setText:priceTitle];
                [priceTitleLabel resizLabelToFit];
                [self.contentView addSubview:priceTitleLabel];
                self.heightCell += CGRectGetHeight(priceTitleLabel.frame);
            }
        }
        NSString *stockType = [NSString stringWithFormat:@"%@",[groupOptionModel valueForKey:@"stock_type"]];
        if ([stockType isEqualToString:@"1"] || [stockType isEqualToString:@"3"]) {
            UIButton *plusButton = [[UIButton alloc] initWithFrame:CGRectMake(cellWidth - 40, 5, 38, 38)];
            [plusButton setImage:[UIImage imageNamed:@"ic_plus"] forState:UIControlStateNormal];
            plusButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
            [plusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [plusButton.layer setCornerRadius:14.0f];
            [plusButton.layer setMasksToBounds:YES];
            [plusButton setAdjustsImageWhenHighlighted:YES];
            [plusButton setAdjustsImageWhenDisabled:YES];
            [plusButton addTarget:self action:@selector(didSelectPlusButtonOption:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:plusButton];
            
            UIButton *minusButton = [[UIButton alloc] initWithFrame:CGRectMake(cellWidth - 100, 5, 38, 38)];
            [minusButton setImage:[UIImage imageNamed:@"ic_minus"] forState:UIControlStateNormal];
            minusButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
            [minusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            minusButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            [minusButton.layer setCornerRadius:14.0f];
            [minusButton.layer setMasksToBounds:YES];
            [minusButton setAdjustsImageWhenHighlighted:YES];
            [minusButton setAdjustsImageWhenDisabled:YES];
            [minusButton addTarget:self action:@selector(didSelectMinusButtonOptionQty:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:minusButton];
            
            if ([stockType isEqualToString:@"3"]) {
                SimiLabel *onBackOrderLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(cellWidth - 110, 45, 110, 25) andFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_MEDIUM];
                [onBackOrderLabel setText:@"On Backorder"];
                onBackOrderLabel.adjustsFontSizeToFitWidth = YES;
                [onBackOrderLabel setTextColor:COLOR_WITH_HEX(@"#36C839")];
                [onBackOrderLabel setTextAlignment:NSTextAlignmentCenter];
                [self.contentView addSubview:onBackOrderLabel];
            }
        }else if([stockType isEqualToString:@"3"]){
            SimiLabel *outOfStockLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(cellWidth - 130, 5, 110, 25) andFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_LARGE];
            [outOfStockLabel setText:@"Out of stock"];
            outOfStockLabel.adjustsFontSizeToFitWidth = YES;
            [outOfStockLabel setTextColor:[UIColor redColor]];
            [outOfStockLabel setTextAlignment:NSTextAlignmentCenter];
            [self.contentView addSubview:outOfStockLabel];
        }
    }
    return self;
}

- (void)didSelectPlusButtonOption:(UIButton*)sender{
    [self.delegate plusGroupOption:self.groupOptionModel];
}

- (void)didSelectMinusButtonOptionQty:(UIButton*)sender{
    [self.delegate minusGroupOption:self.groupOptionModel];
}
@end
