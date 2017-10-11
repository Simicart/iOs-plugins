//
//  SCReviewDetailController.m
//  SimiCart
//
//  Created by Tan on 7/2/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "SCProductReviewController.h"
#import <SimiCartBundle/SCProductInfoView.h>
#import "SCProductReviewView.h"
#import <SimiCartBundle/UIScrollView+SVInfiniteScrolling.h>
#import "SCProductReviewShortCell.h"
#import <SimiCartBundle/SimiSection.h>
#import "SCAddProductReviewViewController.h"

NSString *REVIEW_PRODUCT_CELL = @"REVIEW_PRODUCT_CELL";
NSString *REVIEW_REVIEWVIEW_CELL = @"REVIEW_REVIEWVIEW_CELL";
NSString *REVIEW_SHORT_REVIEW_CELL = @"REVIEW_SHORT_REVIEW_CELL";
@interface SCProductReviewController ()
@end

@implementation SCProductReviewController
{
    NSDictionary *appReviews;
}

@synthesize reviewTableView, reviewCollection, reviewCount, product;

- (void)viewDidLoadBefore
{
    [self setToSimiView];
    [self configureNavigationBarOnViewDidLoad];
    self.navigationItem.title = SCLocalizedString(@"Review");
    
    BOOL reviewAllowGuest = NO;
    if ([[GLOBALVAR.storeView.catalog valueForKey:@"review"] isKindOfClass:[NSDictionary class]]) {
        reviewAllowGuest = [[[GLOBALVAR.storeView.catalog valueForKey:@"review"] valueForKey:@"catalog_review_allow_guest"]boolValue];
    }
    if ([SimiGlobalVar sharedInstance].isLogin || reviewAllowGuest) {
        UIBarButtonItem *addNewReviewItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewReview)];
        self.navigationItem.rightBarButtonItem = addNewReviewItem;
    }
}

- (void)viewDidAppearBefore:(BOOL)animated{
    if (reviewTableView == nil) {
        reviewTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        reviewTableView.dataSource = self;
        reviewTableView.delegate = self;
        reviewTableView.tableFooterView = [UIView new];
        [reviewTableView setBackgroundColor:[UIColor clearColor]];
        [reviewTableView setContentInset:UIEdgeInsetsMake(0, 0, 60, 0)];
        if (SIMI_SYSTEM_IOS >= 9) {
            reviewTableView.cellLayoutMarginsFollowReadableWidth = NO;
        }
        [self.view addSubview:reviewTableView];
        appReviews = [product valueForKey:@"app_reviews"];
        
        __weak UITableView *tableView = reviewTableView;
        [tableView addInfiniteScrollingWithActionHandler:^{
            [self getReviews];
        }];
        [self setCells:nil];
        [self getReviews];
    }
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    
}

- (void)viewWillAppearAfter:(BOOL)animated{
    [reviewTableView deselectRowAtIndexPath:[reviewTableView indexPathForSelectedRow] animated:YES];
}

- (void)addNewReview
{
    SCAddProductReviewViewController* reviewController = [SCAddProductReviewViewController new];
    reviewController.productModel = self.product;
    [self.navigationController pushViewController:reviewController animated:YES];
}

- (void)setCells:(NSMutableArray *)cells{
    if (cells) {
        _cells = cells;
    }else{
        _cells = [[NSMutableArray alloc] init];
        SimiSection *section = [[SimiSection alloc] init];
        for (int i = 0; i < 2; i++) {
            SimiRow *row = [[SimiRow alloc] init];
            switch (i) {
                case 0:{
                    row.identifier = REVIEW_PRODUCT_CELL;
                    row.height = [SimiGlobalVar scaleValue:40];
                }
                    break;
                case 1:{
                    row.identifier = REVIEW_REVIEWVIEW_CELL;
                    row.height = [SimiGlobalVar scaleValue:185];
                }
                    break;
                            }
            [section addRow:row];
        }
        if (self.reviewCollection.count > 0) {
            for (int i = 0; i < self.reviewCollection.count; i++) {
                SimiRow *row = [[SimiRow alloc] init];
                row.identifier = REVIEW_SHORT_REVIEW_CELL;
                row.height = [SimiGlobalVar scaleValue:115];
                [section addRow:row];
            }
        
        }
        [_cells addObject:section];
    }
    [reviewTableView reloadData];
}

- (void)getReviews{
    if (self.reviewCollection == nil) {
        self.reviewCollection = [[SimiReviewModelCollection alloc] init];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetReviewCollection:) name:@"DidGetReviewCollection" object:self.reviewCollection];
    [self.reviewCollection getReviewCollectionWithProductId:self.product.entityId offset:self.reviewCollection.count limit:6];
}

- (void)didGetReviewCollection:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    if (responder.status == SUCCESS) {
        if ([noti.name isEqualToString:@"DidGetReviewCollection"]) {
            [self setCells:nil];
        }
        [self.reviewTableView reloadData];
    }
    [self.reviewTableView.infiniteScrollingView stopAnimating];
    [self removeObserverForNotification:noti];
}

#pragma mark Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _cells.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SimiSection *simiSection = [_cells objectAtIndex:section];
    return simiSection.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    return simiRow.height;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection objectAtIndex:indexPath.row];
    UITableViewCell *cell;
    if([simiRow.identifier isEqualToString:REVIEW_PRODUCT_CELL])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:simiRow.identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
            SimiLabel *nameProduct = [[SimiLabel alloc]initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(15, 0, 250, 40)] andFontName:THEME_FONT_NAME_REGULAR andFontSize:[SimiGlobalVar scaleValue:18] andTextColor:THEME_CONTENT_COLOR];
            nameProduct.text = self.product.name;
            if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
                [nameProduct setFrame:[SimiGlobalVar scaleFrame:CGRectMake(55, 0, 250, 40)]];
                if (PADDEVICE) {
                   [nameProduct setFrame:[SimiGlobalVar scaleFrame:CGRectMake(418, 0, 250, 40)]];
                }
                [nameProduct setTextAlignment:NSTextAlignmentRight];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell addSubview:nameProduct];
        }
    }else if([simiRow.identifier isEqualToString:REVIEW_REVIEWVIEW_CELL]){
        
        cell = [tableView dequeueReusableCellWithIdentifier:simiRow.identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
            SCProductReviewView *reviewView = [[SCProductReviewView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, simiRow.height)];
            if (PADDEVICE) {
                [reviewView setFrame:CGRectMake(0, 0, SCREEN_WIDTH *2/3, simiRow.height)];
            }
            reviewView.backgroundColor = THEME_APP_BACKGROUND_COLOR;
            [reviewView setReviewType:SCLocalizedString(@"Customer Reviews")];
            [reviewView setRatePoint: [[appReviews valueForKey:@"rate"] floatValue]];
            [reviewView setReviewNumber:[[appReviews valueForKey:@"number"] integerValue]];
            NSString *fiveStar = [appReviews valueForKey:@"5_star_number"];
            NSString *fourStar = [appReviews valueForKey:@"4_star_number"];
            NSString *threeStar = [appReviews valueForKey:@"3_star_number"];
            NSString *twoStar = [appReviews valueForKey:@"2_star_number"];
            NSString *oneStar = [appReviews valueForKey:@"1_star_number"];
            [reviewView setStarCollectionWithFiveStar:fiveStar fourStar:fourStar threeStar:threeStar twoStar:twoStar oneStar:oneStar];
            reviewView.userInteractionEnabled = NO;
            [cell addSubview:reviewView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }else if ([simiRow.identifier isEqualToString:REVIEW_SHORT_REVIEW_CELL]){
        NSInteger row = [indexPath row] - 2;
        SimiModel *reviewModel = [self.reviewCollection objectAtIndex:row];
        NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%@",simiRow.identifier,[reviewModel valueForKey:@"review_id"]];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            SCProductReviewShortCell *cellShort = [[SCProductReviewShortCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier reviewData:reviewModel numberTitleLine:1 numberBodyLine:2];
            cellShort.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell = cellShort;
            simiRow.height = cellShort.cellHeight;
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


#pragma mark Table View Delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{    
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    NSInteger row = [indexPath row] - 2;
    if ([simiRow.identifier isEqualToString:REVIEW_SHORT_REVIEW_CELL]) {
        UIViewController *nextController = [[UIViewController alloc]init];
        SimiModel *reviewModel = [self.reviewCollection objectAtIndex:row];
        UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:nextController.view.bounds];
        nextController.title = [reviewModel valueForKey:@"title"];
        
        SCProductReviewShortCell *reviewCell = [[SCProductReviewShortCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil reviewData:reviewModel numberTitleLine:0 numberBodyLine:0];
        [reviewCell setFrame:scrollView.bounds];
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, reviewCell.cellHeight);
        [scrollView addSubview:reviewCell];
        scrollView.backgroundColor = THEME_APP_BACKGROUND_COLOR;
        [nextController.view addSubview:scrollView];
        [self.navigationController pushViewController:nextController animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
