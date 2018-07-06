//
//  SCProductReviewWorker.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 9/12/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCProductReviewWorker.h"
#import <SimiCartBundle/SCProductMoreViewController.h>
#import "SCAddProductReviewViewController.h"
#import "SCProductReviewShortCell.h"
#import "SimiReviewModel.h"
#import "ASStarRatingView.h"

@implementation SCProductReviewWorker {
    MoreActionView* moreActionView;
    SimiProductModel *product;
    SCProductMoreViewController *productMoreVC;
    SCProductSecondDesignViewController *productVC;
    UIButton *reviewButton;
    SimiTable *cells;
    NSDictionary *appReviews;
    UITableView *productTableView;
    BOOL hadReviews;
    float paddingEdge, heightHeader, tableWidth;
}
- (id)init {
    if(self == [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initViewMoreAction:) name:SCProductMoreViewControllerInitViewMoreAction object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beforeTouchMoreAction:) name:SCProductMoreViewControllerBeforeTouchMoreAction object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initViewMoreAction:) name:SCProductViewControllerInitViewMoreAction object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beforeTouchMoreAction:) name:SCProductViewControllerBeforeTouchMoreAction object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initProductCellsAfter:) name:[NSString stringWithFormat:@"%@%@",SCProductSecondDesignViewController_RootEventName,SimiTableViewController_SubKey_InitCells_End] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializedProductCellBegin:) name:[NSString stringWithFormat:@"%@%@",SCProductSecondDesignViewController_RootEventName,SimiTableViewController_SubKey_InitializedCell_Begin] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productSecondDesignViewControllerViewForHeader:) name:[NSString stringWithFormat:@"%@%@",SCProductSecondDesignViewController_RootEventName,SimiTableViewController_SubKey_InitializedHeader_Begin] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productSecondDesignViewControllerDidSelectRow:) name:[NSString stringWithFormat:@"%@%@",SCProductSecondDesignViewController_RootEventName,SimiTableViewController_SubKey_DidSelectCell] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productMoreViewControllerInitTab:) name:SCProductMoreViewControllerInitTab object:nil];
        paddingEdge = SCALEVALUE(15);
        heightHeader = 44;
        // Update for Perry Theme
        [self addObserverOnPerryTheme];
    }
    return self;
}
- (void)initViewMoreAction: (NSNotification *)noti {
    moreActionView = noti.object;
    float sizeButton = 50;
    reviewButton = [UIButton new];
    [reviewButton setImage:[[UIImage imageNamed:@"ic_review"] imageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
    reviewButton.simiObjectName = SCLocalizedString(@"Comment");
    [reviewButton setImageEdgeInsets:UIEdgeInsetsMake(9, 9, 9, 9)];
    [reviewButton.layer setCornerRadius:sizeButton/2.0f];
    [reviewButton.layer setShadowOffset:CGSizeMake(1, 1)];
    [reviewButton.layer setShadowRadius:2];
    reviewButton.layer.shadowOpacity = 0.5;
    [reviewButton setBackgroundColor:[UIColor whiteColor]];
    [reviewButton addTarget:self action:@selector(didTouchReviewButton:) forControlEvents:UIControlEventTouchUpInside];
    reviewButton.tag = 1000;
    moreActionView.numberIcon += 1;
    [moreActionView.arrayIcon addObject:reviewButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterInitViewMoreOnProductMoreViewController:) name:SCProductMoreViewControllerAfterInitViewMore object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterInitViewMoreOnProductViewController:) name:SCProductViewControllerAfterInitViewMore object:nil];
}

- (void)productMoreViewControllerInitTab: (NSNotification *)noti {
    NSMutableArray *_horizontalTitleList = [noti.userInfo objectForKey:@"titles"];
    NSMutableArray *_contentViewArray = [noti.userInfo objectForKey:@"contents"];
    productMoreVC = noti.object;
    product = [noti.userInfo objectForKey:@"product"];
    //  Product Review
    if ([[product valueForKey:@"app_reviews"] isKindOfClass:[NSDictionary class]]) {
        appReviews = [product valueForKey:@"app_reviews"];
        if ([[appReviews valueForKey:@"number"]floatValue]) {
            SCProductReviewController *reviewDetailController = [SCProductReviewController new];
            [productMoreVC addChildViewController:reviewDetailController];
            reviewDetailController.product = product;
            [_horizontalTitleList addObject:SCLocalizedString(@"Reviews")];
            [_contentViewArray addObject:reviewDetailController.view];
        }
    }
}

- (void)afterInitViewMoreOnProductMoreViewController: (NSNotification *)noti {
    [self removeObserverForNotification:noti];
    product = [noti.userInfo valueForKey:@"productModel"];
    productMoreVC = [noti.userInfo valueForKey:@"controller"];
}

- (void)afterInitViewMoreOnProductViewController: (NSNotification *)noti {
    [self removeObserverForNotification:noti];
    product = [noti.userInfo valueForKey:@"productModel"];
    productVC = [noti.userInfo valueForKey:@"controller"];
}

- (void)didTouchReviewButton: (id)sender {
    if ([SimiGlobalVar sharedInstance].isLogin || (![SimiGlobalVar sharedInstance].isLogin && [SimiGlobalVar sharedInstance].isReviewAllowGuest)) {
        if(PHONEDEVICE) {
            if([[product valueForKey:@"app_reviews"] isKindOfClass:[NSDictionary class]]){
                SCAddProductReviewViewController* reviewController = [SCAddProductReviewViewController new];
                reviewController.productModel = product;
                if(productVC)
                    [productVC.navigationController pushViewController:reviewController animated:YES];
                else if(productMoreVC) {
                    [productMoreVC.navigationController pushViewController:reviewController animated:YES];
                }
            }
        }else if(PADDEVICE) {
            SCAddProductReviewViewController* reviewController = [SCAddProductReviewViewController new];
            reviewController.productModel = product;
            if(productMoreVC) {
                [productMoreVC.navigationController pushViewController:reviewController animated:YES];
            }else if(productVC) {
                [productVC presentWithRootViewController:reviewController];
            }
        }
    }else{
        [((SimiViewController *)GLOBALVAR.currentViewController) showAlertWithTitle:@"" message:@"Please login first"];
    }
}


- (void)getReviews{
    SimiReviewModelCollection *reviewCollection = [[SimiReviewModelCollection alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetReviewCollection:) name:@"DidGetReviewCollection" object:reviewCollection];
    [reviewCollection getReviewCollectionWithProductId:product.entityId offset:0 limit:6];
}

- (void)didGetReviewCollection:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    if (responder.status == SUCCESS) {
        NSInteger mainSectionIndex = [cells getSectionIndexByIdentifier:product_main_section];
        SimiSection *reviewSection = [cells addSectionWithIdentifier:product_reviews_section atIndex:mainSectionIndex+1];
        reviewSection.header = [[SimiSectionHeader alloc]initWithTitle:SCLocalizedString(@"Review") height:heightHeader]; ;
        SimiReviewModelCollection *reviewCollection = noti.object;
        if ([[appReviews valueForKey:@"number"]floatValue] > 3) {
            for (int i = 0; i < 3; i++) {
                SimiRow *row = [[SimiRow alloc]initWithIdentifier:product_reviews_normal_row height:SCALEVALUE(120)];
                row.model = [reviewCollection objectAtIndex:i];
                [reviewSection addRow:row];
            }
            [reviewSection addRowWithIdentifier:product_reviews_viewall_row height:50];
        }else
        {
            for (int i = 0; i < [[appReviews valueForKey:@"number"]floatValue]; i++) {
                SimiRow *row = [[SimiRow alloc]initWithIdentifier:product_reviews_normal_row height:SCALEVALUE(120)];
                row.model = [reviewCollection objectAtIndex:i];
                [reviewSection addRow:row];
            }
            [reviewSection addRowWithIdentifier:product_reviews_add_row height:50];
        }
        [productTableView reloadData];
    }
    [self removeObserverForNotification:noti];
}

- (void)initProductCellsAfter: (NSNotification *)noti {
    cells = noti.object;
    productVC = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.viewcontroller];
    productTableView = productVC.contentTableView;
    product = productVC.product;
    appReviews = [product valueForKey:@"app_reviews"];
    hadReviews = NO;
    if ([[appReviews valueForKey:@"number"] floatValue]) {
        hadReviews = YES;
    }
    if(!hadReviews){
        SimiSection *reviewSection = [cells addSectionWithIdentifier:product_reviews_section headerTitle:SCLocalizedString(@"Review")];
        reviewSection.header.height = heightHeader;
        [reviewSection addRowWithIdentifier:product_reviews_firstpeople_row height:50];
    }
    if(hadReviews) {
        [self getReviews];
    }
}

- (void)initializedProductCellBegin:(NSNotification *)noti{
    SimiTable *cells = noti.object;
    NSIndexPath *indexPath = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.indexpath];
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    productVC = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.viewcontroller];
    productTableView = productVC.contentTableView;
    tableWidth = productTableView.frame.size.width;
    if ([section.identifier isEqualToString:product_reviews_section]) {
        productVC.isDiscontinue = YES;
        if ([row.identifier isEqualToString:product_reviews_normal_row]) {
            row.tableCell = [self createCherryReviewNormalCellForRow:row];
        }else if([row.identifier isEqualToString:product_reviews_add_row]){
            row.tableCell = [self createCherryReviewAddCellForRow:row];
        }else if ([row.identifier isEqualToString:product_reviews_firstpeople_row]){
            row.tableCell = [self createCherryReviewFirstPeopleCellForRow: row];
        }else if ([row.identifier isEqualToString:product_reviews_viewall_row]) {
            row.tableCell = [self createCherryReviewViewAllCellForRow: row];
        }
    }
}

- (void)productSecondDesignViewControllerViewForHeader: (NSNotification *)noti {
    productVC = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.viewcontroller];
    NSNumber *sectionNumber = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.section];
    SimiSection *section = [productVC.cells objectAtIndex:[sectionNumber intValue]];
    UITableViewHeaderFooterView *headerView = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.header];
    UITableView *tableView = productVC.contentTableView;
    tableWidth = tableView.frame.size.width;
    if([section.identifier isEqualToString:product_reviews_section]) {
        productVC.isDiscontinue = YES;
        [self createCherryReviewViewForHeader:headerView inSection:section];
    }
}

- (void)createCherryReviewViewForHeader: (UITableViewHeaderFooterView *)headerView inSection:(SimiSection *)section{
    [headerView.contentView setBackgroundColor:THEME_SECTION_COLOR];
    if (!hadReviews) {
        SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, 10, tableWidth - paddingEdge*3, 30) andFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_HEADER];
        [titleLabel setText:section.header.title];
        [headerView addSubview:titleLabel];
    }else
    {
        NSString *title = [NSString stringWithFormat:@"%@ (%@)",section.header.title, [appReviews valueForKey:@"number"]];
        float titleWidth = [title sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:FONT_SIZE_HEADER]}].width;
        SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, 6, titleWidth, 30) andFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_HEADER];
        [titleLabel setText:title];
        [headerView addSubview:titleLabel];
        
        NSMutableArray *starReview = [[NSMutableArray alloc]init];
        float sizeStar = 20;
        for(int i = 0; i< 5; i++){
            UIImageView *imgStar = [[UIImageView alloc] initWithFrame:CGRectMake(0, (heightHeader - sizeStar)/2, sizeStar, sizeStar)];
            [imgStar setImage:[UIImage imageNamed:@"rate0"]];
            CGRect frameStar = [imgStar frame];
            frameStar.origin.x = (tableWidth - paddingEdge - 5*sizeStar) + i*sizeStar;
            [imgStar setFrame:frameStar];
            [headerView addSubview:imgStar];
            [starReview addObject:imgStar];
        }
        float _ratePoint = [[appReviews valueForKey:@"rate"]floatValue];
        int temp = (int)_ratePoint;
        
        if (_ratePoint == 0) {
            for (int i = 0; i < [starReview count]; i++) {
                [[starReview objectAtIndex:i] setImage:[UIImage imageNamed:@"ic_star2"]];
            }
        }else{
            for (int i = 0; i < temp; i++) {
                [[starReview objectAtIndex:i] setImage:[UIImage imageNamed:@"ic_star"]];
            }
            if (_ratePoint - temp > 0) {
                [[starReview objectAtIndex:temp] setImage:[UIImage imageNamed:@"ic_star_50"]];
                for (int i = temp+1; i < [starReview count]; i++) {
                    [[starReview objectAtIndex:i] setImage:[UIImage imageNamed:@"ic_star2"]];
                }
            }else{
                for (int i = temp; i < [starReview count]; i++) {
                    [[starReview objectAtIndex:i] setImage:[UIImage imageNamed:@"ic_star2"]];
                }
            }
        }
        
        NSString *rateNumberString = [NSString stringWithFormat:@"(%0.2f)",[[appReviews valueForKey:@"rate"]floatValue]];
        SimiLabel *rateNumberLabel = [[SimiLabel alloc]initWithFrame:CGRectMake((tableWidth - paddingEdge - 5*sizeStar) - 40, 6, 40, 30) andFontSize:FONT_SIZE_MEDIUM];
        [rateNumberLabel setText:rateNumberString];
        [headerView addSubview:rateNumberLabel];
    }
    [SimiGlobalFunction sortViewForRTL:headerView andWidth:tableWidth];
}

- (void)productSecondDesignViewControllerDidSelectRow: (NSNotification *)noti {
    NSIndexPath *indexPath = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.indexpath];
    SimiTable *cells = noti.object;
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    productVC = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.viewcontroller];
    UITableView *tableView = productVC.contentTableView;
    
    if([section.identifier isEqualToString:product_reviews_section]) {
        if([row.identifier isEqualToString:product_reviews_normal_row]) {
            UIViewController *nextController = [[UIViewController alloc]init];
            SimiModel *reviewModel = row.model;
            UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:nextController.view.bounds];
            nextController.title = [reviewModel valueForKey:@"title"];
            
            SCProductReviewShortCell *reviewCell = [[SCProductReviewShortCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil reviewData:reviewModel numberTitleLine:0 numberBodyLine:0];
            [reviewCell setFrame:scrollView.bounds];
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, reviewCell.cellHeight);
            [scrollView addSubview:reviewCell];
            scrollView.backgroundColor = THEME_APP_BACKGROUND_COLOR;
            [nextController.view addSubview:scrollView];
            if(PHONEDEVICE) {
                [productVC.navigationController pushViewController:nextController animated:YES];
            }else {
                [productVC presentWithRootViewController:nextController];
            }
        }else if([row.identifier isEqualToString:product_reviews_add_row] || [row.identifier isEqualToString:product_reviews_firstpeople_row]) {
            if ([SimiGlobalVar sharedInstance].isLogin || (![SimiGlobalVar sharedInstance].isLogin && [SimiGlobalVar sharedInstance].isReviewAllowGuest)) {
                SCAddProductReviewViewController* reviewController = [SCAddProductReviewViewController new];
                reviewController.productModel = product;
                if(PHONEDEVICE)
                    [productVC.navigationController pushViewController:reviewController animated:YES];
                else
                    [productVC presentWithRootViewController:reviewController];
            }else{
                [productVC showAlertWithTitle:@"" message:@"Please login first"];
            }
        }else if([row.identifier isEqualToString:product_reviews_viewall_row])
        {
            SCProductReviewController *reviewDetailController = [SCProductReviewController new];
            reviewDetailController.product = product;
            if(PHONEDEVICE)
                [productVC.navigationController pushViewController:reviewDetailController animated:YES];
            else
                [productVC presentWithRootViewController:reviewDetailController];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)beforeTouchMoreAction: (NSNotification *)noti {
    
}

//For cherry theme
- (UITableViewCell *)createCherryReviewNormalCellForRow:(SimiRow *)row{
    SimiModel *reviewModel = row.model;
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%@",row.identifier,[reviewModel valueForKey:@"review_id"]];
    SCProductReviewShortCell *cell = [productTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        cell = [[SCProductReviewShortCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier reviewData:reviewModel numberTitleLine:1 numberBodyLine:2];
        row.height = cell.cellHeight;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}
- (UITableViewCell *)createCherryReviewAddCellForRow:(SimiRow *)row{
    UITableViewCell *cell = [productTableView dequeueReusableCellWithIdentifier:row.identifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, 10, tableWidth - paddingEdge*3, 30) andFontName:THEME_FONT_NAME_REGULAR];
        [titleLabel setText:SCLocalizedString(@"Add your review")];
        [cell.contentView addSubview:titleLabel];
        [SimiGlobalFunction sortViewForRTL:cell.contentView andWidth:tableWidth - paddingEdge];
    }
    return cell;
}
- (UITableViewCell *)createCherryReviewFirstPeopleCellForRow:(SimiRow *)row{
    UITableViewCell *cell = [productTableView dequeueReusableCellWithIdentifier:row.identifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, 10, tableWidth - paddingEdge*3, 30) andFontName:THEME_FONT_NAME_REGULAR];
        [titleLabel setText:SCLocalizedString(@"Be the first to review this product")];
        [cell.contentView addSubview:titleLabel];
        [SimiGlobalFunction sortViewForRTL:cell.contentView andWidth:tableWidth - paddingEdge];
    }
    return cell;
}
- (UITableViewCell *)createCherryReviewViewAllCellForRow:(SimiRow *)row{
    UITableViewCell *cell = [productTableView dequeueReusableCellWithIdentifier:row.identifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, 10, tableWidth - paddingEdge*3, 30) andFontName:THEME_FONT_NAME_REGULAR];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setText:SCLocalizedString(@"View all")];
        [cell.contentView addSubview:titleLabel];
        [SimiGlobalFunction sortViewForRTL:cell.contentView andWidth:tableWidth-paddingEdge];
    }
    return cell;
}

#pragma mark -
#pragma mark Implement Perry Theme
- (void)addObserverOnPerryTheme{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initPerryProductCellsAfter:) name:[NSString stringWithFormat:@"%@%@",@"SCPProductViewController",SimiTableViewController_SubKey_InitCells_End] object:nil];
}

- (void)initPerryProductCellsAfter:(NSNotification*)noti{
    cells = noti.object;
    productVC = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.viewcontroller];
    SCPProductDetailReviewWorker *unitWorker = [SCPProductDetailReviewWorker new];
    unitWorker.cells = cells;
    unitWorker.product = productVC.product;
    unitWorker.contentTableView = productVC.contentTableView;
    [unitWorker createReviewSection];
    productVC.reviewManageObject = unitWorker;
}
@end

@implementation SCPProductDetailReviewWorker{
    NSDictionary *appReviews;
    BOOL hadReviews;
    float paddingEdge, heightHeader, tableWidth;
    SCProductSecondDesignViewController *productViewController;
}

- (void)createReviewSection{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializedPerryProductCellBegin:) name:[NSString stringWithFormat:@"%@%@",@"SCPProductViewController",SimiTableViewController_SubKey_InitializedCell_Begin] object:self.cells];
    appReviews = self.product.appReviews;
    hadReviews = NO;
    if ([[appReviews valueForKey:@"number"] floatValue]) {
        hadReviews = YES;
    }
    if(!hadReviews){
        SimiSection *reviewSection = [self.cells addSectionWithIdentifier:product_reviews_section headerTitle:SCLocalizedString(@"Review")];
        reviewSection.header.height = SCALEVALUE(15);
        [reviewSection addRowWithIdentifier:product_reviews_normal_row height:52];
        [reviewSection addRowWithIdentifier:product_reviews_add_row height:49];
    }
    if(hadReviews) {
        [self getReviews];
    }
}

- (void)getReviews{
    SimiReviewModelCollection *reviewCollection = [[SimiReviewModelCollection alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(perryThemeDidGetReviewCollection:) name:@"DidGetReviewCollection" object:reviewCollection];
    [reviewCollection getReviewCollectionWithProductId:self.product.entityId offset:0 limit:6];
}

- (void)perryThemeDidGetReviewCollection:(NSNotification*)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    if (responder.status == SUCCESS) {
        NSInteger beforeIndex = 0;
        if ([self.cells getSectionIndexByIdentifier:@"scpproduct_description_section"] != NSNotFound) {
            beforeIndex = [self.cells getSectionIndexByIdentifier:@"scpproduct_description_section"];
        }
        if (beforeIndex == 0) {
            beforeIndex = [self.cells getSectionIndexByIdentifier:@"scpproduct_description_section"];
        }
        SimiSection *reviewSection = [self.cells addSectionWithIdentifier:product_reviews_section atIndex:beforeIndex+1];
        reviewSection.header = [[SimiSectionHeader alloc]initWithTitle:SCLocalizedString(@"Review") height:SCALEVALUE(15)];
        SimiReviewModelCollection *reviewCollection = noti.object;
        if (reviewCollection.count > 0) {
            SimiRow *row = [[SimiRow alloc]initWithIdentifier:product_reviews_normal_row height:140];
            row.model = [reviewCollection objectAtIndex:0];
            [reviewSection addRow:row];
        }
        [reviewSection addRowWithIdentifier:product_reviews_add_row height:49];
    }
    [self.contentTableView reloadData];
}

- (void)initializedPerryProductCellBegin:(NSNotification*)noti{
    SimiTable *cells = noti.object;
    NSIndexPath *indexPath = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.indexpath];
    productViewController = [noti.userInfo valueForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.viewcontroller];
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    tableWidth = CGRectGetWidth(self.contentTableView.frame);
    if ([section.identifier isEqualToString:product_reviews_section]) {
        productViewController.isDiscontinue = YES;
        if ([row.identifier isEqualToString:product_reviews_normal_row]) {
            row.tableCell = [self createPerryReviewNormalCellForRow:row];
        }else if([row.identifier isEqualToString:product_reviews_add_row]){
            row.tableCell = [self createPerryReviewAddCellForRow:row];
        }
    }
}

- (UITableViewCell *)createPerryReviewNormalCellForRow:(SimiRow *)row{
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if(cell == nil) {
        cell = [[SimiTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        float padding = SCALEVALUE(15);
        float widthCell = SCREEN_WIDTH - padding *2;
        if (PADDEVICE) {
            widthCell = SCALEVALUE(510) - padding *2;
        }
        cell.simiContentView = [[UIView alloc]initWithFrame:CGRectMake(padding, 0, widthCell, row.height)];
        [cell.simiContentView setBackgroundColor:[UIColor whiteColor]];
        [cell.contentView addSubview:cell.simiContentView];
        
        UIFont *headerFont = [UIFont fontWithName:@"Montserrat-SemiBold" size:FONT_SIZE_HEADER];
        float titleWidth = [[SCLocalizedString(@"Reviews") uppercaseString] sizeWithAttributes:@{NSFontAttributeName:headerFont}].width;
        SimiLabel *headerLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding,17,titleWidth,18) andFont:headerFont];
        [headerLabel setText:[SCLocalizedString(@"Reviews") uppercaseString]];
        [cell.simiContentView addSubview:headerLabel];
        
        if (row.model != nil) {
            float sizeStar = 12;
            float ratePoint = [[appReviews valueForKey:@"rate"]floatValue];
            ASStarRatingView *starView = [[ASStarRatingView alloc] initWithFrame:CGRectMake(widthCell - 5*(sizeStar+5)-padding, 20, 5*sizeStar, sizeStar)];
            starView.canEdit = NO;
            starView.minStarSize = CGSizeMake(sizeStar, sizeStar);
            starView.midMargin = 5;
            starView.leftMargin = 0;
            starView.rightMargin = 0;
            starView.rating = ratePoint;
            [cell.simiContentView addSubview:starView];
            
            UIFont *rateFont = [UIFont fontWithName:@"Montserrat-Regular" size:FONT_SIZE_HEADER];
            NSString *rateStr = [NSString stringWithFormat:@"%0.2f",ratePoint];
            float rateStrWidth = [rateStr sizeWithAttributes:@{NSFontAttributeName:rateFont}].width +2;
            SimiLabel *rateLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(widthCell - padding*1.5 - 5*(sizeStar+5) - rateStrWidth, 17, rateStrWidth, 18) andFont:rateFont];
            [rateLabel setText:rateStr];
            [cell.simiContentView addSubview:rateLabel];
            
            SimiLabel *numberReviewLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding*1.5+titleWidth, 17, 50, 18) andFont:rateFont];
            [numberReviewLabel setText:[NSString stringWithFormat:@"(%@)",[appReviews valueForKey:@"number"]]];
            [cell.simiContentView addSubview:numberReviewLabel];
            
            
            SimiReviewModel *reviewModel = (SimiReviewModel*)row.model;
            float heightContent = 52;
            padding += 5;
            sizeStar = 9;
            ASStarRatingView *firstReviewStarView = [[ASStarRatingView alloc] initWithFrame:CGRectMake(padding, heightContent, 5*sizeStar, sizeStar)];
            firstReviewStarView.canEdit = NO;
            firstReviewStarView.minStarSize = CGSizeMake(sizeStar, sizeStar);
            firstReviewStarView.midMargin = 4.5;
            firstReviewStarView.leftMargin = 0;
            firstReviewStarView.rightMargin = 0;
            firstReviewStarView.rating = [[reviewModel valueForKey:@"rate_points"] floatValue];
            [cell.simiContentView addSubview:firstReviewStarView];
            
            heightContent += 16;
            SimiLabel *firstReviewTitleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, heightContent, widthCell - padding*2, 16) andFont:[UIFont fontWithName:@"Montserrat-Regular" size:FONT_SIZE_MEDIUM]];
            [firstReviewTitleLabel setText:[NSString stringWithFormat:@"%@",[reviewModel valueForKey:@"title"]]];
            [cell.simiContentView addSubview:firstReviewTitleLabel];
            
            heightContent += CGRectGetHeight(firstReviewTitleLabel.frame) + 5;
            SimiLabel *firstReviewContentLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(padding, heightContent, widthCell - padding*2, 35) andFont:[UIFont fontWithName:@"Montserrat-Light" size:FONT_SIZE_MEDIUM]];
            firstReviewContentLabel.text = [NSString stringWithFormat:@"%@",[reviewModel valueForKey:@"detail"]];
            firstReviewContentLabel.numberOfLines = 2;
            [cell.simiContentView addSubview:firstReviewContentLabel];
            heightContent += CGRectGetHeight(firstReviewContentLabel.frame) + padding;
            row.height = heightContent;
        }
    }
    return cell;
}
- (SimiTableViewCell *)createPerryReviewAddCellForRow:(SimiRow *)row{
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if(cell == nil) {
        cell = [[SimiTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor clearColor]];
        float padding = SCALEVALUE(15);
        float widthCell = SCREEN_WIDTH - padding *2;
        if (PADDEVICE) {
            widthCell = SCALEVALUE(510) - padding *2;
        }
        cell.simiContentView = [[UIView alloc]initWithFrame:CGRectMake(padding, 1, widthCell, row.height-1)];
        [cell.simiContentView setBackgroundColor:[UIColor whiteColor]];
        [cell.contentView addSubview:cell.simiContentView];
        
        float buttonWidth = widthCell/2;
        UIButton *viewAllButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 2, buttonWidth, 44)];
        [viewAllButton setBackgroundColor:[UIColor clearColor]];
        viewAllButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [viewAllButton.titleLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:FONT_SIZE_LARGE]];
        [viewAllButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [viewAllButton setTitle:SCLocalizedString(@"View all reviews") forState:UIControlStateNormal];
        [viewAllButton addTarget:self action:@selector(viewAllReviews:) forControlEvents:UIControlEventTouchUpInside];
        [cell.simiContentView addSubview:viewAllButton];
        
        UIButton *addReviewButton = [[UIButton alloc]initWithFrame:CGRectMake(buttonWidth, 2, buttonWidth, 44)];
        [addReviewButton setBackgroundColor:[UIColor clearColor]];
        addReviewButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [addReviewButton.titleLabel setFont:[UIFont fontWithName:@"Montserrat-Semibold" size:FONT_SIZE_LARGE]];
        [addReviewButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [addReviewButton setTitle:SCLocalizedString(@"Add your review") forState:UIControlStateNormal];
        [addReviewButton addTarget:self action:@selector(addYourReviews:) forControlEvents:UIControlEventTouchUpInside];
        [cell.simiContentView addSubview:addReviewButton];
        if (!hadReviews) {
            [viewAllButton removeFromSuperview];
            [addReviewButton setFrame:CGRectMake(padding, 2, widthCell, 44)];
        }
    }
    return cell;
}

- (void)viewAllReviews:(UIButton*)sender{
    SCProductReviewController *reviewDetailController = [SCProductReviewController new];
    reviewDetailController.product = self.product;
    if(PHONEDEVICE)
        [productViewController.navigationController pushViewController:reviewDetailController animated:YES];
    else
        [productViewController presentWithRootViewController:reviewDetailController];
}

- (void)addYourReviews:(UIButton*)sender{
    if ([SimiGlobalVar sharedInstance].isLogin || (![SimiGlobalVar sharedInstance].isLogin && [SimiGlobalVar sharedInstance].isReviewAllowGuest)) {
        SCAddProductReviewViewController* reviewController = [SCAddProductReviewViewController new];
        reviewController.productModel = self.product;
        if(PHONEDEVICE)
            [productViewController.navigationController pushViewController:reviewController animated:YES];
        else
            [productViewController presentWithRootViewController:reviewController];
    }else{
        [productViewController showAlertWithTitle:@"" message:@"Please login first"];
    }
}
@end

