//
//  SCProductReviewWorker.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 9/12/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCProductReviewWorker.h"
#import <SimiCartBundle/SCProductMoreViewController.h>
#import <SimiCartBundle/SCProductSecondDesignViewController.h>
#import "SCAddProductReviewViewController.h"
#import "SCProductReviewShortCell.h"

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
    }
    return self;
}
- (void)initViewMoreAction: (NSNotification *)noti {
    if ([SimiGlobalVar sharedInstance].isLogin || (![SimiGlobalVar sharedInstance].isLogin && [SimiGlobalVar sharedInstance].isReviewAllowGuest)) {
        moreActionView = noti.object;
        float sizeButton = 50;
        reviewButton = [UIButton new];
        [reviewButton setImage:[[UIImage imageNamed:@"ic_review"] imageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
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
}


- (void)getReviews{
    SimiReviewModelCollection *reviewCollection = [[SimiReviewModelCollection alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetReviewCollection:) name:@"DidGetReviewCollection" object:reviewCollection];
    [reviewCollection getReviewCollectionWithProductId:[product valueForKey:@"entity_id"] offset:0 limit:6];
}

- (void)didGetReviewCollection:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    if (responder.status == SUCCESS) {
        NSInteger mainSectionIndex = [cells getSectionIndexByIdentifier:product_main_section];
        SimiSection *reviewSection = [cells addSectionWithIdentifier:product_reviews_section atIndex:mainSectionIndex+1];
        reviewSection.header = [[SimiSectionHeader alloc]initWithTitle:SCLocalizedString(@"Review") height:44]; ;
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
            if ([SimiGlobalVar sharedInstance].isLogin || [SimiGlobalVar sharedInstance].isReviewAllowGuest) {
                [reviewSection addRowWithIdentifier:product_reviews_add_row height:50];
            }
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
        if ([SimiGlobalVar sharedInstance].isLogin || (![SimiGlobalVar sharedInstance].isLogin && [SimiGlobalVar sharedInstance].isReviewAllowGuest)) {
            SimiSection *reviewSection = [cells addSectionWithIdentifier:product_reviews_section headerTitle:SCLocalizedString(@"Review")];
            [reviewSection addRowWithIdentifier:product_reviews_firstpeople_row height:50];
        }
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
    float paddingEdge = 15;
    float tableWidth = productTableView.frame.size.width;
    if ([section.identifier isEqualToString:product_reviews_section]) {
        productVC.isDiscontinue = YES;
        if ([row.identifier isEqualToString:product_reviews_normal_row]) {
            SimiModel *reviewModel = row.model;
            NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%@",row.identifier,[reviewModel valueForKey:@"review_id"]];
            SCProductReviewShortCell *cell = [productTableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if(!cell) {
                cell = [[SCProductReviewShortCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier reviewData:reviewModel numberTitleLine:1 numberBodyLine:2];
                row.height = cell.cellHeight;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            row.tableCell = cell;
        }else if([row.identifier isEqualToString:product_reviews_add_row]){
            UITableViewCell *cell = [productTableView dequeueReusableCellWithIdentifier:row.identifier];
            if(!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, 10, tableWidth - paddingEdge*3, 30) andFontName:THEME_FONT_NAME_REGULAR];
                [titleLabel setText:SCLocalizedString(@"Add Your Review")];
                [cell.contentView addSubview:titleLabel];
                [SimiGlobalFunction sortViewForRTL:cell.contentView andWidth:tableWidth - paddingEdge];
            }
            row.tableCell = cell;
        }
        else if ([row.identifier isEqualToString:product_reviews_firstpeople_row])
        {
            UITableViewCell *cell = [productTableView dequeueReusableCellWithIdentifier:row.identifier];
            if(!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, 10, tableWidth - paddingEdge*3, 30) andFontName:THEME_FONT_NAME_REGULAR];
                [titleLabel setText:SCLocalizedString(@"Be the first to review this product")];
                [cell.contentView addSubview:titleLabel];
                [SimiGlobalFunction sortViewForRTL:cell.contentView andWidth:tableWidth - paddingEdge];
            }
            row.tableCell = cell;
        }else if ([row.identifier isEqualToString:product_reviews_viewall_row]) {
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
            row.tableCell = cell;
        }
    }
}

- (void)productSecondDesignViewControllerViewForHeader: (NSNotification *)noti {
    productVC = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.viewcontroller];
    NSNumber *sectionNumber = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.section];
    SimiSection *section = [productVC.cells objectAtIndex:[sectionNumber intValue]];
    UITableViewHeaderFooterView *headerView = [noti.userInfo objectForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.header];
    UITableView *tableView = productVC.contentTableView;
    float paddingEdge = SCALEVALUE(15);
    float heightHeader = 44;
    float tableWidth = tableView.frame.size.width;
    if([section.identifier isEqualToString:product_reviews_section]) {
        productVC.isDiscontinue = YES;
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
            SCAddProductReviewViewController* reviewController = [SCAddProductReviewViewController new];
            reviewController.productModel = product;
            if(PHONEDEVICE)
                [productVC.navigationController pushViewController:reviewController animated:YES];
            else
                [productVC presentWithRootViewController:reviewController];
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

@end

