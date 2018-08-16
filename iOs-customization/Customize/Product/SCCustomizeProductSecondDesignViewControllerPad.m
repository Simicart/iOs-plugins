//
//  SCCustomizeProductSecondDesignViewControllerPad.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 2/8/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCCustomizeProductSecondDesignViewControllerPad.h"
#import "SCMyFavouriteModelCollection.h"
#import "SCCustomizeProductCollectionViewCell.h"
#import "SCCustomizeProductOptionViewController.h"
#import "SCCustomizeProductSecondDesignViewController.h"

@interface SCCustomizeProductSecondDesignViewControllerPad ()

@end

@implementation SCCustomizeProductSecondDesignViewControllerPad{
    UIButton *favouriteButton;
    BOOL isOpenOptionFromAddToFavourite;
    BOOL descriptionExpanded;
    UIButton *expandButton;
}

- (void)viewDidLoadBefore{
    [super viewDidLoadBefore];
    descriptionExpanded = YES;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.contentTableView.estimatedRowHeight = 0;
}

- (void)createCells{
    SimiSection *mainSection = [[SimiSection alloc]initWithIdentifier:product_main_section];
    [self.cells addObject:mainSection];
    [mainSection addRowWithIdentifier:product_nameandprice_row height:200];
    if (optionController.hasOption || [self.product objectForKey:@"exgst_option"]) {
        [mainSection addRowWithIdentifier:product_option_row height:50];
    }
    if([self.product objectForKey:@"description"]){
        [mainSection addRowWithIdentifier:product_description_row height:50];
        if(descriptionExpanded){
            [mainSection addRowWithIdentifier:PRODUCT_DESCRIPTION_DETAIL];
        }
    }
    if ([[self.product valueForKeyPath:@"additional"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *additional = [self.product valueForKeyPath:@"additional"];
        if (additional.count > 0) {
            [mainSection addRowWithIdentifier:product_techspecs_row height:50];
        }
    }
    if(relatedProducts.count){
        itemHeight = 0;
        for(SimiProductModel *product in relatedProducts.collectionData){
            float callHeight = 0;
            if([[product objectForKey:@"final_price"] floatValue] == 0 && product.productType != ProductTypeGrouped && GLOBALVAR.isLogin){
                callHeight = 44;
            }
            if(itemHeight < [product heightPriceOnGrid] + 150 + callHeight){
                itemHeight = [product heightPriceOnGrid] + 150 + callHeight;
            }
        }
        SimiSection *relatedSection = [self.cells addSectionWithIdentifier:product_related_section headerTitle:SCLocalizedString(@"Related Products")];
        [relatedSection addRowWithIdentifier:product_related_row height:itemHeight + 30];
        [self.contentTableView reloadData];
    }
}
- (UITableViewCell *)contentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if([row.identifier isEqualToString:PRODUCT_DESCRIPTION_DETAIL]){
        SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:PRODUCT_DESCRIPTION_DETAIL];
        if(!cell){
            cell = [[SimiTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PRODUCT_DESCRIPTION_DETAIL];
            cell.heightCell = 10;
            float cellWidth = CGRectGetWidth(self.contentTableView.frame) - 2*paddingEdge;
            SimiLabel *label = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingEdge, cell.heightCell, cellWidth, 25)];
            [label setHTMLContent:[NSString stringWithFormat:@"%@",[self.product objectForKey:@"description"]]];
            label.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
            label.textColor = THEME_CONTENT_COLOR;
            label.numberOfLines = 0;
            [label sizeToFit];
            [cell.contentView addSubview:label];
            cell.heightCell += CGRectGetHeight(label.frame) + 10;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        row.height = cell.heightCell;
        return cell;
    }else if([row.identifier isEqualToString:product_description_row]){
        SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:product_description_row];
        if(!cell){
            cell = [[SimiTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:product_description_row];
            SimiLabel *label = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingEdge, 0, CGRectGetWidth(self.contentTableView.frame) - 2*paddingEdge - 40, row.height) andFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:FONT_SIZE_LARGE]];
            label.text = @"Description";
            expandButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.contentTableView.frame) - 40, 5, 40, 40)];
            expandButton.contentEdgeInsets = UIEdgeInsetsMake(12.5, 12.5, 12.5, 12.5);
            [expandButton setImage:[UIImage imageNamed:@"ic_narrow_up"] forState:UIControlStateNormal];
            expandButton.userInteractionEnabled = NO;
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:expandButton];
        }
        if(descriptionExpanded){
            [expandButton setImage:[UIImage imageNamed:@"ic_narrow_up"] forState:UIControlStateNormal];
        }else{
            [expandButton setImage:[UIImage imageNamed:@"ic_narrow_down"] forState:UIControlStateNormal];
        }
        return cell;
    }else{
        return [super contentTableViewCellForRowAtIndexPath:indexPath];
    }
}

- (void)contentTableViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if([row.identifier isEqualToString:product_description_row]){
        descriptionExpanded = !descriptionExpanded;
        [self initCells];
        [self.contentTableView deselectRowAtIndexPath:indexPath animated:YES];
    }else{
        [super contentTableViewDidSelectRowAtIndexPath:indexPath];
    }
}

- (void)initMoreViewAction
{
    float sizeButton = 50;
    float sizePlus = 18;
    float moreButtonOrgionX = CGRectGetWidth(self.view.frame) - sizeButton - paddingEdge/2;
    float moreButtonOrgionY = CGRectGetHeight(self.view.frame) - sizeButton - heightViewAction - paddingEdge;
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
    
    if(!favouriteButton){
        favouriteButton = [UIButton new];
        [favouriteButton setImage:[UIImage imageNamed:@"favourite_icon"] forState:UIControlStateNormal];
        [favouriteButton setImageEdgeInsets:UIEdgeInsetsMake(9, 9, 9, 9)];
        [favouriteButton.layer setCornerRadius:25.0f];
        [favouriteButton.layer setShadowOffset:CGSizeMake(1, 1)];
        [favouriteButton.layer setShadowRadius:2];
        favouriteButton.layer.shadowOpacity = 0.5;
        [favouriteButton setBackgroundColor:[UIColor whiteColor]];
        [favouriteButton addTarget:self action:@selector(addToFavourite:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.viewMoreAction.numberIcon += 1;
    [self.viewMoreAction.arrayIcon addObject:favouriteButton];
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

- (void)initOptionViewController{
    optionViewController = [SCCustomizeProductOptionViewController new];
    optionViewController.contentTableView.showsVerticalScrollIndicator = NO;
    optionViewController.delegate = self;
    optionViewController.product = self.product;
    optionViewController.optionController = optionController;
}

- (void)addToFavourite:(id)sender{
    if ([optionController enableAddProductToCart]) {
        NSDictionary* cartItem = [self cartItem];
        SCMyFavouriteModelCollection *favouriteCollection = [SCMyFavouriteModelCollection new];
        [favouriteCollection addProductToFavourite:cartItem];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddProductToFavourite:) name:DidAddProductToFavourite object:nil];
        [self startLoadingData];
        return;
    }else if(!isOpenOptionFromAddToFavourite){
        [self didSelectOption];
        isOpenOptionFromAddToFavourite = YES;
        isOpenOptionFromAddToCart = NO;
    }
}

- (void)addToCart{
    [super addToCart];
    isOpenOptionFromAddToFavourite = NO;
}
- (void)doneButtonTouch{
    [super doneButtonTouch];
    if (isOpenOptionFromAddToFavourite) {
        [self addToFavourite:favouriteButton];
    }
    isOpenOptionFromAddToFavourite = NO;
}

- (void)cancelButtonTouch{
    [super cancelButtonTouch];
    isOpenOptionFromAddToFavourite = NO;
}
- (void)didGetRelatedProducts:(NSNotification*)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    if (responder.status == SUCCESS) {
        if (relatedProducts.count > 0) {
            [self initCells];
        }
    }
    [self removeObserverForNotification:noti];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SimiProductModel *relateProduct = [relatedProducts objectAtIndex:indexPath.row];
    NSString *identifier = relateProduct.entityId;
    [collectionView registerClass:[SCCustomizeProductCollectionViewCell class] forCellWithReuseIdentifier:identifier];
    SCCustomizeProductCollectionViewCell *productViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    productViewCell.isShowNameOneLine = YES;
    [productViewCell setProductModelForCell:relateProduct];
    return productViewCell;
}
- (void)didAddProductToFavourite:(NSNotification *)noti{
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    [self showAlertWithTitle:@"" message:responder.message];
}
- (void)didGetProduct:(NSNotification*)noti{
    [self stopLoadingData];
    [self.contentTableView setHidden:NO];
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    if ([noti.name isEqualToString:Simi_DidGetProductModel]) {
        if (responder.status == SUCCESS) {
            if (self.product.isSalable || [[self.product objectForKey:@"final_price"] floatValue] == 0 || !GLOBALVAR.isLogin) {
                [self initViewAction];
            }
            [self initMoreViewAction];
            [self createScrollImage];
            if (GLOBALVAR.isMagento2) {
                optionController = [[SCMagentoTwoOptionController alloc]initWithProduct:self.product];
            }else
                optionController = [[SCOptionController alloc]initWithProduct:self.product];
            [self initCells];
            [self getRelatedProducts];
            if (self.product.name && self.product.entityId) {
                [[NSNotificationCenter defaultCenter]postNotificationName:TRACKINGEVENT object:@"page_view_action" userInfo:@{@"action":@"viewed_product_screen",@"product_name":self.product.name,@"product_id":self.product.entityId}];
            }
        }
        [[NSNotificationCenter defaultCenter]removeObserverForNotification:noti];
    }
}
- (void)initViewAction{
    [super initViewAction];
    [self.contentTableView setContentInset:UIEdgeInsetsMake(0, 0, 100, 0)];
    NSDictionary *exgstOption = [self.product objectForKey:@"exgst_option"];
    if(GLOBALVAR.isLogin){
        if(([[self.product objectForKey:@"final_price"] floatValue] == 0 && self.product.productType != ProductTypeGrouped) || (exgstOption && [[exgstOption objectForKey:@"qty_type"] isEqualToString:@"2"])){
            self.callForPriceButton = [[SimiButton alloc] initWithFrame:self.viewAction.frame title:@"Call For Price"];
            [self.view addSubview:self.callForPriceButton];
            [self.callForPriceButton addTarget:self action:@selector(callForPrice:) forControlEvents:UIControlEventTouchUpInside];
            [self.viewAction removeFromSuperview];
        }
    }else{
        if(!self.loginButton){
            self.loginButton = [[SimiButton alloc] initWithFrame:self.viewAction.frame title:@"Please login to checkout"];
            [self.view addSubview:self.loginButton];
            [self.loginButton addTarget:self action:@selector(loginToCheckout:) forControlEvents:UIControlEventTouchUpInside];
            [self.viewAction removeFromSuperview];
        }
    }
}
- (void)callForPrice:(UIButton *)button{
    NSURL *url = [NSURL URLWithString:@"tel:1300680638"];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
    }
}
- (void)loginToCheckout:(UIButton *)button{
    SCCustomizeLoginViewController *loginViewController = [SCCustomizeLoginViewController new];
    loginViewController.product = self.product;
    UINavigationController *loginNavi = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    loginNavi.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popover = loginNavi.popoverPresentationController;
    popover.sourceRect = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1);
    popover.sourceView = [UIApplication sharedApplication].delegate.window.rootViewController.view;
    popover.permittedArrowDirections = 0;
    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:loginNavi animated:YES completion:nil];
}
- (UITableViewCell *)createOptionCell:(SimiRow *)row{
    if(self.product.productType != ProductTypeGrouped && [[self.product objectForKey:@"exgst_option"] isKindOfClass:[NSDictionary class]]){
        SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:product_option_row];
        if(!cell){
            cell = [[SimiTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:product_option_row];
            float paddingX = SCALEVALUE(15);
            float cellWidth = CGRectGetWidth(self.contentTableView.frame) - 2*paddingX;
            float cellY = 10;
            SimiLabel *titleLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX, cellY, cellWidth, 25) andFontName:THEME_FONT_NAME_REGULAR andFontSize:THEME_FONT_SIZE andTextColor:THEME_CONTENT_COLOR text:@"Options"];
            [cell.contentView addSubview:titleLabel];
            cellY += CGRectGetHeight(titleLabel.frame) + 5;
            NSDictionary *exgstOption = [self.product objectForKey:@"exgst_option"];
            //Customize
            if(exgstOption){
                NSString *stockType = [exgstOption objectForKey:@"stock_type"];
                if([stockType isEqualToString:@"4"] || !stockType){
                    
                }else{
                    SimiLabel *stockStatusLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingX, cellY, tableWidth - paddingX*2, 25) andFontName:THEME_FONT_NAME];
                    stockStatusLabel.textColor = THEME_CONTENT_COLOR;
                    if([stockType isEqualToString:@"1"]){
                        [stockStatusLabel setText:SCLocalizedString(@"In Stock")];
                    }else if([stockType isEqualToString:@"2"]){
                        [stockStatusLabel setText:SCLocalizedString(@"Out Stock")];
                        stockStatusLabel.textColor = [UIColor redColor];
                    }else if([stockType isEqualToString:@"3"]){
                        [stockStatusLabel setText:SCLocalizedString(@"On Backorder")];
                        stockStatusLabel.textColor = COLOR_WITH_HEX(@"#36C839");
                    }
                    [cell.contentView addSubview:stockStatusLabel];
                    cellY += 25;
                }
            }
            NSArray *info = [exgstOption objectForKey:@"info"];
            NSArray *tierPrice = [exgstOption objectForKey:@"tier_price"];
            if(info.count){
                for(NSDictionary *option in info){
                    if(option.allKeys.count > 0){
                        for(NSString *key in option.allKeys){
                            SimiLabel *optionLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX, cellY, cellWidth, 25)];
                            [optionLabel setTextWithTitle:[NSString stringWithFormat:@"%@",key] value:[NSString stringWithFormat:@"%@",[option objectForKey:key]] fontSize:FONT_SIZE_LARGE];
                            optionLabel.numberOfLines = 0;
                            [optionLabel sizeToFit];
                            cellY += CGRectGetHeight(optionLabel.frame);
                            [cell.contentView addSubview:optionLabel];
                        }
                    }
                }
                for(NSDictionary *option in tierPrice){
                    if(option.allKeys.count > 0){
                        for(NSString *key in option.allKeys){
                            SimiLabel *optionLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX, cellY, cellWidth, 25)];
                            [optionLabel setTextWithTitle:[NSString stringWithFormat:@"%@",key] value:[[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[option objectForKey:key]]] fontSize:FONT_SIZE_LARGE];
                            optionLabel.numberOfLines = 0;
                            [optionLabel sizeToFit];
                            cellY += CGRectGetHeight(optionLabel.frame);
                            [cell.contentView addSubview:optionLabel];
                        }
                    }
                }
                if(exgstOption && [[exgstOption objectForKey:@"qty_type"] isEqualToString:@"3"]){
                    SimiLabel *label = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX, cellY, cellWidth, 25) andFontName:THEME_FONT_NAME andFontSize:THEME_FONT_SIZE - 1 andTextColor:THEME_CONTENT_COLOR text:@"Please Login or Signup to view table prices"];
                    [label resizLabelToFit];
                    cellY += label.labelHeight;
                    [cell.contentView addSubview:label];
                }
            }
            cell.heightCell = cellY + 10;
            [SimiGlobalFunction sortViewForRTL:cell.contentView andWidth:CGRectGetWidth(cell.contentView.frame)];
        }
        row.height = cell.heightCell;
        cell.userInteractionEnabled = NO;
        return cell;
    }else
        return [super createOptionCell:row];
}

- (UITableViewCell*)createNameCell:(SimiRow*)row{
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if (cell == nil) {
        float heightCell = 5;
        cell = [[SimiTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        SimiVerticalView *cellView = [[SimiVerticalView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, heightCell)];
        [cell.contentView addSubview:cellView withObjectName:@"cellView"];
        self.labelProductName = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - paddingEdge*2, 20) andFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_LARGE];
        [self.labelProductName setText:self.product.name];
        [cellView addSubview:self.labelProductName];
        heightCell = [self.labelProductName resizLabelToFit];
        self.priceView = [[SCPriceView alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - paddingEdge*2, 20)];
        [self.priceView showPriceWithProduct:self.product optionController:optionController widthView:CGRectGetWidth(self.priceView.frame) showTierPrice:YES];
        [cellView addSubview:self.priceView];
        heightCell += CGRectGetHeight(self.priceView.frame) + paddingEdge;
        CGRect frame = cellView.frame;
        frame.size.height = heightCell;
        cellView.frame = frame;
        cell.heightCell = cellView.frame.size.height;
        [SimiGlobalFunction sortViewForRTL:cellView andWidth:tableWidth];
    }
    row.height = cell.heightCell;
    return cell;
}
@end
