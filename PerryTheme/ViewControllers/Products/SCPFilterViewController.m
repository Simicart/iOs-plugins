//
//  SCPFilterViewController.m
//  SimiCartPluginFW
//
//  Created by Liam on 5/16/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPFilterViewController.h"
#import "SCPGlobalVars.h"
#import "UICollectionViewLeftAlignedLayout.h"
static NSString* FILTER_ATTRIBUTE_SECTION = @"FILTER_ATTRIBUTE_SECTION";
static NSString* FILTER_ATTRIBUTE_VALUE_ROW = @"FILTER_ATTRIBUTE_VALUE_ROW";
@interface SCPFilterViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    UICollectionView *activeFilterCollectionView;
}

@end

@implementation SCPFilterViewController
- (void)viewDidLoadBefore{
    [self configureNavigationBarOnViewDidLoad];
    [[UINavigationBar appearance] setBarTintColor:SCP_BUTTON_BACKGROUND_COLOR];
    self.navigationItem.title = SCLocalizedString(@"Filters");
    UIButton *closeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [closeButton setImage:[[UIImage imageNamed:@"scp_ic_close"]imageWithColor:SCP_TITLE_COLOR] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(cancelFilter:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 20)];
    UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    self.navigationItem.leftBarButtonItem = closeButtonItem;
    
    UIButton *doneButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [doneButton setImage:[[UIImage imageNamed:@"scp_ic_checked"]imageWithColor:SCP_TITLE_COLOR] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(applyFilter:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setImageEdgeInsets:UIEdgeInsetsMake(10, 20, 10, 0)];
    UIBarButtonItem *dontButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    self.navigationItem.rightBarButtonItem =  dontButtonItem;
    [self initCells];
    
    self.contentTableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.contentTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.contentTableView setContentInset:UIEdgeInsetsMake(0, 0, 50, 0)];
    if (SIMI_SYSTEM_IOS >= 9) {
        self.contentTableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    self.contentTableView.delegate = self;
    self.contentTableView.dataSource = self;
    [self.view addSubview:self.contentTableView];
    [self.contentTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)viewDidAppearBefore:(BOOL)animated{
    
}

- (void)createCells{
    self.activedFilterOptions = [NSMutableArray new];
    self.selectFilterOptions = [NSMutableArray new];
    self.paramFilter = [NSMutableDictionary new];
    if ([self.filterContent valueForKey:@"layer_state"]) {
        self.activedFilterOptions = [[NSMutableArray alloc]initWithArray:[self.filterContent valueForKey:@"layer_state"]];
    }
    if([self.filterContent valueForKey:@"layer_filter"]){
        self.selectFilterOptions = [self.filterContent valueForKey:@"layer_filter"];
    }
    if (self.activedFilterOptions.count > 0) {
        SimiSection *activeSection = [[SimiSection alloc]initWithIdentifier:FILTER_SECTION_ACTIVED];
        activeSection.simiObjectIdentifier = [NSNumber numberWithBool:YES];
        activeSection.header = [[SimiSectionHeader alloc]initWithTitle:SCLocalizedString(@"Activated") height:60];
        [activeSection addRowWithIdentifier:FILTER_SECTION_ACTIVED height:200];
        for (int i = 0; i < self.activedFilterOptions.count; i++) {
            NSDictionary *dictActiveUnit = [self.activedFilterOptions objectAtIndex:i];
            [self.paramFilter setObject:[dictActiveUnit valueForKey:@"value"] forKey:[dictActiveUnit valueForKey:@"attribute"]];
        }
        [self.cells addObject:activeSection];
    }
    
    if (self.selectFilterOptions.count > 0) {
        SimiSection *section02 = [[SimiSection alloc]initWithIdentifier:FILTER_SECTION_SELECTED];
        section02.header = [[SimiSectionHeader alloc]initWithTitle:SCLocalizedString(@"Select a filter") height:60];
        section02.simiObjectIdentifier = [NSNumber numberWithBool:YES];
        [self.cells addObject:section02];
        for (int i = 0; i < self.selectFilterOptions.count; i++) {
            NSDictionary *filterOption = [self.selectFilterOptions objectAtIndex:i];
            SimiSection *attributeSection = [[SimiSection alloc]initWithIdentifier:FILTER_ATTRIBUTE_SECTION];
            attributeSection.simiObjectIdentifier = [NSNumber numberWithBool:NO];
            attributeSection.header = [[SimiSectionHeader alloc]initWithTitle:[filterOption valueForKey:@"title"] height:40];
            [self.cells addObject:attributeSection];
            if ([[filterOption valueForKey:@"filter"] isKindOfClass:[NSArray class]]) {
                NSArray *filters = [filterOption valueForKey:@"filter"];
                for (int i = 0; i < filters.count; i++) {
                    SimiRow *row = [[SimiRow alloc]initWithIdentifier:FILTER_ATTRIBUTE_VALUE_ROW height:44];
                    row.data = [[NSMutableDictionary alloc]initWithDictionary:[filters objectAtIndex:i]];
                    [row.data setValue:[filterOption valueForKey:@"attribute"] forKey:@"attribute"];
                    [attributeSection addRow:row];
                }
            }
        }
    }
}

- (void)applyFilter:(UIButton*)sender{
    self.paramFilter = [NSMutableDictionary new];
    if (self.activedFilterOptions.count > 0) {
        for (NSDictionary *activedFilterInfo in self.activedFilterOptions) {
            [self.paramFilter setObject:[activedFilterInfo valueForKey:@"value"] forKey:[activedFilterInfo valueForKey:@"attribute"]];
        }
    }
    for (SimiSection *section in self.cells) {
        if ([section.identifier isEqualToString:FILTER_ATTRIBUTE_SECTION]) {
            for (SimiRow *row in section.rows) {
                NSNumber *isSelected = (NSNumber*)row.simiObjectIdentifier;
                if ([isSelected boolValue]) {
                    [self.paramFilter setObject:[row.data valueForKey:@"value"] forKey:[row.data valueForKey:@"attribute"]];
                }
            }
        }
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate filterWithParam:self.paramFilter];
    }];
}

- (void)removeAllActiveAttribute:(UIButton*)sender{
    [self.activedFilterOptions removeAllObjects];
    self.paramFilter = [NSMutableDictionary new];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate filterWithParam:self.paramFilter];
    }];
}

- (UIView *)contentTableViewViewForHeaderInSection:(NSInteger)section{
    SimiSection *simiSection = [self.cells objectAtIndex:section];
    UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:simiSection.identifier];
    float headerLabelWidth = [[simiSection.header.title uppercaseString] sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:FONT_SIZE_HEADER]}].width + 10;
    SimiLabel *headerLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(SCP_GLOBALVARS.padding, 0, headerLabelWidth, simiSection.header.height) andFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_HEADER];
    [headerLabel setText:[simiSection.header.title uppercaseString]];
    [headerView.contentView addSubview:headerLabel];
    [headerView.contentView setBackgroundColor:[UIColor whiteColor]];
    if ([simiSection.identifier isEqualToString:FILTER_ATTRIBUTE_SECTION]) {
        [headerLabel setFrame:CGRectMake(SCP_GLOBALVARS.padding*2, 0, headerLabelWidth, simiSection.header.height)];
        [headerLabel setText:simiSection.header.title];
        UIButton *actionButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentTableView.frame), simiSection.header.height)];
        [actionButton addTarget:self action:@selector(updateAttributeSectionState:) forControlEvents:UIControlEventTouchUpInside];
        actionButton.simiObjectIdentifier = simiSection;
        [headerView.contentView addSubview:actionButton];
    }else if([simiSection.identifier isEqualToString:FILTER_SECTION_ACTIVED]){
        NSString *title = SCLocalizedString(@"Clear all");
        UIFont *titleFont = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:FONT_SIZE_LARGE];
        float buttonWidth = [title sizeWithAttributes:@{NSFontAttributeName:titleFont}].width + 4;
        SimiButton *clearAllButton = [[SimiButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.contentTableView.frame) - SCP_GLOBALVARS.padding - buttonWidth, 10, buttonWidth, 40) title:title titleFont:titleFont cornerRadius:0 borderWidth:0 borderColor:nil];
        [clearAllButton setTitleColor:SCP_BUTTON_BACKGROUND_COLOR forState:UIControlStateNormal];
        [clearAllButton setBackgroundColor:[UIColor clearColor]];
        [clearAllButton addTarget:self action:@selector(removeAllActiveAttribute:) forControlEvents:UIControlEventTouchUpInside];
        [headerView.contentView addSubview:clearAllButton];
    }
    return headerView;
}

- (void)updateAttributeSectionState:(UIButton*)sender{
    SimiSection *section = (SimiSection*)sender.simiObjectIdentifier;
    NSNumber *isShow = (NSNumber*)section.simiObjectIdentifier;
    if ([isShow boolValue]) {
        section.simiObjectIdentifier = [NSNumber numberWithBool:NO];
    }else{
        section.simiObjectIdentifier = [NSNumber numberWithBool:YES];
    }
    [self.contentTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SimiSection *simiSection = [self.cells objectAtIndex:section];
    NSNumber *isShow = (NSNumber*)simiSection.simiObjectIdentifier;
    return [isShow boolValue]?simiSection.count:0;
}

- (UITableViewCell *)contentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [simiSection objectAtIndex:indexPath.row];
    SimiTableViewCell *cell = nil;
    if ([simiSection.identifier isEqualToString:FILTER_ATTRIBUTE_SECTION]) {
        cell = [self createSelectFilterValueWithRow:row];
    }else if([simiSection.identifier isEqualToString:FILTER_SECTION_ACTIVED]){
        if ([row.identifier isEqualToString:FILTER_SECTION_ACTIVED]) {
            cell = [self createActivedCellWithRow:row];
        }
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (SimiTableViewCell*)createActivedCellWithRow:(SimiRow*)row{
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if (cell == nil) {
        cell = [[SimiTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        UICollectionViewFlowLayout *flowLayout = [UICollectionViewLeftAlignedLayout new];
        flowLayout.minimumLineSpacing = SCP_GLOBALVARS.lineSpacing;
        flowLayout.minimumInteritemSpacing = SCP_GLOBALVARS.interitemSpacing;
        activeFilterCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(SCP_GLOBALVARS.padding, 0, CGRectGetWidth(self.contentTableView.frame) - SCP_GLOBALVARS.padding*2, row.height) collectionViewLayout:flowLayout];
        activeFilterCollectionView.delegate = self;
        activeFilterCollectionView.dataSource = self;
        [activeFilterCollectionView setBackgroundColor:[UIColor whiteColor]];
        [activeFilterCollectionView registerClass:[ActiveFilterCollectionViewCell class]
                       forCellWithReuseIdentifier:@"active_cell"];
        activeFilterCollectionView.autoresizingMask = UIViewAutoresizingNone;
        [activeFilterCollectionView setScrollEnabled:NO];
        [cell.contentView addSubview:activeFilterCollectionView];
        
        UIImageView *crossLineView = [[UIImageView alloc]initWithFrame:CGRectMake(0, row.height - 1, CGRectGetWidth(self.contentTableView.frame), 1)];
        crossLineView.tag = 123123;
        [crossLineView setBackgroundColor:[UIColor darkGrayColor]];
        [cell.contentView addSubview:crossLineView];
    }
    row.height = [self activeHeightCalculate];
    CGRect frame = activeFilterCollectionView.frame;
    frame.size.height = row.height;
    UIImageView *crossLineView = [cell.contentView viewWithTag:123123];
    [crossLineView setFrame:CGRectMake(0, row.height - 1, CGRectGetWidth(self.contentTableView.frame), 1)];
    [activeFilterCollectionView setFrame:frame];
    [activeFilterCollectionView reloadData];
    return cell;
}

- (SimiTableViewCell*)createSelectFilterValueWithRow:(SimiRow*)row{
    NSString *identifier = [NSString stringWithFormat:@"%@_%@",row.identifier,[row.data valueForKey:@"value"]];
    SelectFilterTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SelectFilterTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier row:row];
    }
    [cell updateCellStateWithRow:row];
    return cell;
}

- (float)activeHeightCalculate{
    float height = 0;
    float collectionWidth = CGRectGetWidth(activeFilterCollectionView.frame);
    NSMutableArray *itemWidthArray = [NSMutableArray new];
    for (NSDictionary *activeFilterInfo in self.activedFilterOptions) {
        NSString *filterValue = [[NSString stringWithFormat:@"%@",[activeFilterInfo valueForKey:@"label"]]uppercaseString];
        float itemWidth = [filterValue sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:THEME_FONT_NAME size:FONT_SIZE_MEDIUM]}].width + SCP_GLOBALVARS.textPadding + 45 ;
        [itemWidthArray addObject:[NSNumber numberWithFloat:itemWidth]];
    }
    float numberItemRow = 0;
    float totalWidthInRow = 0;
    for (int i = 0; i < itemWidthArray.count; i++) {
        float itemWidth = [itemWidthArray[i] floatValue];
        totalWidthInRow += itemWidth + SCP_GLOBALVARS.interitemSpacing;
        if (totalWidthInRow < collectionWidth) {
            continue;
        }else{
            numberItemRow += 1;
            totalWidthInRow = itemWidth + SCP_GLOBALVARS.interitemSpacing;
        }
    }
    numberItemRow += 1;
    height = numberItemRow * (40 + SCP_GLOBALVARS.lineSpacing);
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [simiSection objectAtIndex:indexPath.row];
    return row.height;
}

- (void)contentTableViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [self.cells objectAtIndex:indexPath.section];
    if ([simiSection.identifier isEqualToString:FILTER_ATTRIBUTE_SECTION]) {
        for (int i = 0; i < simiSection.rows.count; i++) {
            if (i == indexPath.row) {
                continue;
            }
            SimiRow *row = [simiSection.rows objectAtIndex:i];
            row.simiObjectIdentifier = [NSNumber numberWithBool:NO];
        }
        SimiRow *row = [simiSection objectAtIndex:indexPath.row];
        NSNumber *isSelected = (NSNumber*)row.simiObjectIdentifier;
        if ([isSelected boolValue]) {
            row.simiObjectIdentifier = [NSNumber numberWithBool:NO];
        }else{
            row.simiObjectIdentifier = [NSNumber numberWithBool:YES];
        }
    }
    [self.contentTableView reloadData];
}

#pragma mark Collection View Datasource& Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.activedFilterOptions.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *activeFilterInfo = [self.activedFilterOptions objectAtIndex:indexPath.row];
    ActiveFilterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"active_cell" forIndexPath:indexPath];
    cell.delegate = self;
    [cell updateCellData:activeFilterInfo];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *activeFilterInfo = [self.activedFilterOptions objectAtIndex:indexPath.row];
    NSString *filterValue = [NSString stringWithFormat:@"%@",[activeFilterInfo valueForKey:@"label"]];
    float filterValueWidth = [filterValue sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:THEME_FONT_NAME size:FONT_SIZE_MEDIUM]}].width + 5;
    float itemWidth = filterValueWidth + SCP_GLOBALVARS.textPadding + 40;
    return CGSizeMake(itemWidth, 40);
}

#pragma mark Cell Delegate
- (void)removeActivedFilterValue:(NSDictionary *)selectedFilter{
    [self.activedFilterOptions removeObject:selectedFilter];
    if (self.activedFilterOptions.count == 0) {
        [self.cells removeSectionsByIdentifier:FILTER_SECTION_ACTIVED];
        [self.contentTableView reloadData];
    }else{
        [activeFilterCollectionView reloadData];
    }
}
@end

@implementation ActiveFilterCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    selectedValueLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(SCP_GLOBALVARS.textPadding, 0, 40, 40) andFontName:THEME_FONT_NAME andFontSize:FONT_SIZE_MEDIUM];
    [self.contentView addSubview:selectedValueLabel];
    
    deleteButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [deleteButton setImage:[UIImage imageNamed:@"scp_ic_close"] forState:UIControlStateNormal];
    [deleteButton setImageEdgeInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    [deleteButton addTarget:self action:@selector(removeFilterValue:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:deleteButton];
    [self.contentView setBackgroundColor:COLOR_WITH_HEX(@"#f2f1f3")];
    return self;
}

- (void)updateCellData:(NSDictionary *)data{
    filterAttribute = data;
    NSString *filterValue = [NSString stringWithFormat:@"%@",[filterAttribute valueForKey:@"label"]];
    float filterValueWidth = [filterValue sizeWithAttributes:@{NSFontAttributeName:selectedValueLabel.font}].width + 5;
    CGRect frame = selectedValueLabel.frame;
    frame.size.width = filterValueWidth;
    [selectedValueLabel setFrame:frame];
    [selectedValueLabel setText:filterValue];
    
    frame = deleteButton.frame;
    frame.origin.x = SCP_GLOBALVARS.textPadding+filterValueWidth;
    [deleteButton setFrame:frame];
}

- (void)removeFilterValue:(UIButton*)sender{
    [self.delegate removeActivedFilterValue:filterAttribute];
}
@end

@implementation SelectFilterTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier row:(SimiRow *)row{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(SCP_GLOBALVARS.padding*3, 16, 12, 12)];
    [iconImageView setImage:[UIImage imageNamed:@"scp_ic_untick"]];
    [self.contentView addSubview:iconImageView];
    
    titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(SCP_GLOBALVARS.padding*3 + 16, 10, 150, 22) andFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_MEDIUM];
    [titleLabel setText:[NSString stringWithFormat:@"%@",[row.data valueForKey:@"label"]]];
    [self.contentView addSubview:titleLabel];
    return self;
}

- (void)updateCellStateWithRow:(SimiRow*)row{
    NSNumber *isSelected = (NSNumber*)row.simiObjectIdentifier;
    if([isSelected boolValue]){
        [iconImageView setImage:[[UIImage imageNamed:@"scp_ic_tick"]imageWithColor:SCP_BUTTON_BACKGROUND_COLOR]];
        [titleLabel setTextColor:SCP_BUTTON_BACKGROUND_COLOR];
    }else{
        [iconImageView setImage:[UIImage imageNamed:@"scp_ic_untick"]];
        [titleLabel setTextColor:[UIColor blackColor]];
    }
}
@end
