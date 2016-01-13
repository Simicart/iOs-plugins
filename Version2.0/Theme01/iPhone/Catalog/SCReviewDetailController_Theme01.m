//
//  SCReviewDetailController_Theme01.m
//  SimiCart
//
//  Created by Tan on 7/2/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SCReviewView.h>
#import <SimiCartBundle/SimiResponder.h>
#import <SimiCartBundle/UIScrollView+SVInfiniteScrolling.h>
#import "SCReviewDetailController_Theme01.h"
#import "ShortReviewCell_Theme01.h"
#import "SimiThemeWorker.h"

@interface SCReviewDetailController_Theme01 (){
    UIBarButtonItem *filterButton;
    NSInteger selectedStar;
    BOOL isFirstGet;
}

@end

@implementation SCReviewDetailController_Theme01

@synthesize tableViewReviewCollection, reviewCollection, reviewCount, product, productRate;

- (void)viewDidLoadBefore
{
    [self setNavigationBarOnViewDidLoadForTheme01];
    [self setToSimiView];
    selectedStar = 0;
    self.navigationItem.title = [[NSString stringWithFormat:@"%@", SCLocalizedString(@"Review")] uppercaseString];
    filterButton = [[UIBarButtonItem alloc]initWithTitle:SCLocalizedString(@"Filter") style:UIBarButtonItemStyleBordered target:self action:@selector(filter)];
    if (tableViewReviewCollection == nil) {
        tableViewReviewCollection = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        tableViewReviewCollection.dataSource = self;
        tableViewReviewCollection.delegate = self;
        tableViewReviewCollection.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:tableViewReviewCollection];
    }
    __weak UITableView *tableView = tableViewReviewCollection;
    [tableView addInfiniteScrollingWithActionHandler:^{
        [self getReviews];
    }];
    isFirstGet = YES;
    [self getReviews];
}

- (void)viewWillAppearAfter:(BOOL)animated{
    [tableViewReviewCollection deselectRowAtIndexPath:[tableViewReviewCollection indexPathForSelectedRow] animated:YES];
    [self setNavigationBarOnViewWillAppearForTheme01];
}

- (void)viewDidUnload {
    [self setTableViewReviewCollection:nil];
    [super viewDidUnload];
}

#pragma mark Table View Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.reviewCollection count] + 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = [indexPath row];
    switch (row) {
        case 0:{
            return 135;
        }
            break;
        default:
            return 100;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = [indexPath row];
    switch (row) {
        case 0:{
            //Init cell
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ProductInfoCell"];
            int originXstar = (CGRectGetWidth(self.view.frame) - 23*5)/2 - 5;
            self.productRate = [[product valueForKey:@"product_rate"]floatValue];
            int temp = (int)productRate;
            
            UILabel *rateTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(90, 25, 150, 30)];
            NSString *reviewTitle = @"reviews";
            if([[product valueForKey:@"product_review_number"] integerValue] <= 1){
                reviewTitle = @"review";
            }
                
            [rateTitleLabel setText:[NSString stringWithFormat:@"%@ %@",[product valueForKey:@"product_review_number"], [SCLocalizedString(reviewTitle) uppercaseString]]];
            CGFloat rateTitleWidth = [rateTitleLabel.text sizeWithFont:rateTitleLabel.font].width;
            CGRect frame = rateTitleLabel.frame;
            frame.origin.x = (CGRectGetWidth(self.view.frame) - rateTitleWidth)/2 - 5;
            rateTitleLabel.frame = frame;
            [rateTitleLabel setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:22]];
            [rateTitleLabel setTextColor:[UIColor blackColor]];
            [cell addSubview:rateTitleLabel];
            
            _heightCell = 60;
            if (productRate == 0) {
                for (int i = 0; i < 5; i++) {
                    UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + i*27, _heightCell, 23, 23)];
                    [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar_big2.png"]];
                    UILabel *numberRateLabel = [[UILabel alloc]initWithFrame:CGRectMake(originXstar + 6 + i*27, _heightCell + 27, 23, 23)];
                    [numberRateLabel setText:@"0"];
                    [numberRateLabel setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:18]];
                    [numberRateLabel setTextColor:[UIColor darkGrayColor]];
                    [cell addSubview:imageStar];
                    [cell addSubview:numberRateLabel];
                }
            }else{
                for (int i = 0; i < temp; i++) {
                    UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + i*27, _heightCell, 23, 23)];
                    [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar_big1.png"]];
                    [cell addSubview:imageStar];
                    UILabel *numberRateLabel = [[UILabel alloc]initWithFrame:CGRectMake(originXstar + 6 + i*27, _heightCell + 27, 23, 23)];
                    [numberRateLabel setText:[NSString stringWithFormat:@"%@", [product valueForKey:[NSString stringWithFormat:@"%d_star_number",i+1]]]];
                    [numberRateLabel setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:18]];
                    [numberRateLabel setTextColor:[UIColor darkGrayColor]];
                    [cell addSubview:numberRateLabel];
                }
                if (productRate - temp > 0) {
                    UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + temp*27, _heightCell, 23, 23)];
                    [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar_big0.png"]];
                    [cell addSubview:imageStar];
                    UILabel *numberRateLabel = [[UILabel alloc]initWithFrame:CGRectMake(originXstar + 6 + temp*27, _heightCell + 27, 23, 23)];
                    [numberRateLabel setText:[NSString stringWithFormat:@"%@", [product valueForKey:[NSString stringWithFormat:@"%d_star_number",temp+1]]]];
                    [numberRateLabel setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:18]];
                    [numberRateLabel setTextColor:[UIColor darkGrayColor]];
                    [cell addSubview:numberRateLabel];
                    for (int i = temp + 1; i < 5; i++) {
                        UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + i*27, _heightCell, 23, 23)];
                        [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar_big2.png"]];
                        [cell addSubview:imageStar];
                        UILabel *numberRateLabel = [[UILabel alloc]initWithFrame:CGRectMake(originXstar + 6 + i*27, _heightCell + 27, 23, 23)];
                        [numberRateLabel setText:[NSString stringWithFormat:@"%@", [product valueForKey:[NSString stringWithFormat:@"%d_star_number",i+1]]]];
                        [numberRateLabel setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:18]];
                        [numberRateLabel setTextColor:[UIColor darkGrayColor]];
                        [cell addSubview:numberRateLabel];
                    }
                }else{
                    for (int i = temp; i < 5; i++) {
                        UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + i*27, _heightCell, 23, 23)];
                        [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar_big2.png"]];
                        [cell addSubview:imageStar];
                        UILabel *numberRateLabel = [[UILabel alloc]initWithFrame:CGRectMake(originXstar + 6 + i*27, _heightCell + 27, 23, 23)];
                        [numberRateLabel setText:[NSString stringWithFormat:@"%@", [product valueForKey:[NSString stringWithFormat:@"%d_star_number",i+1]]]];
                        [numberRateLabel setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:18]];
                        [numberRateLabel setTextColor:[UIColor darkGrayColor]];
                        [cell addSubview:numberRateLabel];
                    }
                }
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;
        default:{
            NSInteger row = [indexPath row] - 1;
            
            static NSString *ShortReviewIdentifier = @"ShortReviewCellIdentifier";
            UINib *nib = [UINib nibWithNibName:@"ShortReviewCell_Theme01" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:ShortReviewIdentifier];
            ShortReviewCell_Theme01 *cell = [tableView dequeueReusableCellWithIdentifier:ShortReviewIdentifier];
            
            [cell setRatePoint:[[[reviewCollection objectAtIndex:row] valueForKey:@"rate_point"] floatValue]];
            [cell setReviewTitle:[[reviewCollection objectAtIndex:row] valueForKey:@"review_title"]];
            [cell setReviewBody:[[reviewCollection objectAtIndex:row] valueForKey:@"review_body"]];
            [cell setReviewTime:[[reviewCollection objectAtIndex:row] valueForKey:@"review_time"]];
            [cell setCustomerName:[[reviewCollection objectAtIndex:row] valueForKey:@"customer_name"]];
            
            [cell reArrangeLabelWithTitleLine:1 BodyLine:2];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
            break;
    }
}

#pragma mark Table View Delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectReviewCellAtIndexPath" object:tableView userInfo:@{@"indexPath": indexPath}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    NSInteger row = [indexPath row];
    if (row >= 1) {
        row = row - 1;
        UIViewController *nextController = [[UIViewController alloc]init];
        nextController.title = [[[reviewCollection objectAtIndex:row] valueForKey:@"review_title"] uppercaseString];
        
        UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, nextController.view.frame.size.width, nextController.view.frame.size.height)];
        nextController.navigationItem.rightBarButtonItems = [[[SimiThemeWorker sharedInstance]navigationBar] rightButtonItems];
        CGFloat productCellHeight = 135;
        
        UIView *border = [[UIView alloc] init];
        CGRect frame = CGRectMake(15, 0, self.view.frame.size.width - 10, 135);
        frame.origin.y = frame.size.height;
        frame.size.height = 0.5;
        border.frame = frame;
        border.backgroundColor = [UIColor lightGrayColor];
        [scrollView addSubview:border];
        
        ShortReviewCell_Theme01 *reviewCell = [[ShortReviewCell_Theme01 alloc] initWithNibName:@"ShortReviewCell_Theme01"];

        [reviewCell setRatePoint:[[[reviewCollection objectAtIndex:row] valueForKey:@"rate_point"] floatValue]];
        [reviewCell setReviewTitle:[[reviewCollection objectAtIndex:row] valueForKey:@"review_title"]];
        [reviewCell setReviewBody:[[reviewCollection objectAtIndex:row] valueForKey:@"review_body"]];
        [reviewCell setReviewTime:[[reviewCollection objectAtIndex:row] valueForKey:@"review_time"]];
        [reviewCell setCustomerName:[[reviewCollection objectAtIndex:row] valueForKey:@"customer_name"]];

        frame.origin.x = 0;
        frame.origin.y += 10;
        frame.size.height = 480;
        reviewCell.frame = frame;
        [reviewCell reArrangeLabelWithTitleLine:0 BodyLine:0];
        reviewCell.selectionStyle = UITableViewCellSelectionStyleNone;

        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, productCellHeight + [reviewCell getActualCellHeight]);
        
        int originXstar = (CGRectGetWidth(self.view.frame) - 23*5)/2 - 5;
        int temp = (int)productRate;
        
        NSString *reviewTitle = @"reviews";
        if([[product valueForKey:@"product_review_number"] integerValue] <= 1){
            reviewTitle = @"review";
        }
    
        UILabel *rateTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(90, 25, 150, 30)];
        [rateTitleLabel setText:[NSString stringWithFormat:@"%@ %@",[product valueForKey:@"product_review_number"], [SCLocalizedString(@"reviews") uppercaseString]]];
        CGFloat rateTitleWidth = [rateTitleLabel.text sizeWithFont:rateTitleLabel.font].width;
        frame = rateTitleLabel.frame;
        frame.origin.x = (CGRectGetWidth(self.view.frame) - rateTitleWidth)/2 - 5;
        rateTitleLabel.frame = frame;
        [rateTitleLabel setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:22]];
        [rateTitleLabel setTextColor:[UIColor blackColor]];
        [scrollView addSubview:rateTitleLabel];
        _heightCell = 60;
        if (productRate == 0) {
            for (int i = 0; i < 5; i++) {
                UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + i*27, _heightCell, 23, 23)];
                [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar_big2.png"]];
                UILabel *numberRateLabel = [[UILabel alloc]initWithFrame:CGRectMake(originXstar + 6 + i*27, _heightCell + 27, 23, 23)];
                [numberRateLabel setText:@"0"];
                [numberRateLabel setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:18]];
                [numberRateLabel setTextColor:[UIColor darkGrayColor]];
                [scrollView addSubview:imageStar];
                [scrollView addSubview:numberRateLabel];
            }
        }else{
            for (int i = 0; i < temp; i++) {
                UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + i*27, _heightCell, 23, 23)];
                [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar_big1.png"]];
                [scrollView addSubview:imageStar];
                UILabel *numberRateLabel = [[UILabel alloc]initWithFrame:CGRectMake(originXstar + 6 + i*27, _heightCell + 27, 23, 23)];
                [numberRateLabel setText:[NSString stringWithFormat:@"%@", [product valueForKey:[NSString stringWithFormat:@"%d_star_number",i+1]]]];
                [numberRateLabel setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:18]];
                [numberRateLabel setTextColor:[UIColor darkGrayColor]];
                [scrollView addSubview:numberRateLabel];
            }
            if (productRate - temp > 0) {
                UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + temp*27, _heightCell, 23, 23)];
                [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar_big0.png"]];
                [scrollView addSubview:imageStar];
                UILabel *numberRateLabel = [[UILabel alloc]initWithFrame:CGRectMake(originXstar + 6 + temp*27, _heightCell + 27, 23, 23)];
                [numberRateLabel setText:[NSString stringWithFormat:@"%@", [product valueForKey:[NSString stringWithFormat:@"%d_star_number",temp+1]]]];
                [numberRateLabel setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:18]];
                [numberRateLabel setTextColor:[UIColor darkGrayColor]];
                [scrollView addSubview:numberRateLabel];
                for (int i = temp + 1; i < 5; i++) {
                    UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + i*27, _heightCell, 23, 23)];
                    [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar_big2.png"]];
                    [scrollView addSubview:imageStar];
                    UILabel *numberRateLabel = [[UILabel alloc]initWithFrame:CGRectMake(originXstar + 6 + i*27, _heightCell + 27, 23, 23)];
                    [numberRateLabel setText:[NSString stringWithFormat:@"%@", [product valueForKey:[NSString stringWithFormat:@"%d_star_number",i+1]]]];
                    [numberRateLabel setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:18]];
                    [numberRateLabel setTextColor:[UIColor darkGrayColor]];
                    [scrollView addSubview:numberRateLabel];
                }
            }else{
                for (int i = temp; i < 5; i++) {
                    UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + i*27, _heightCell, 23, 23)];
                    [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar_big2.png"]];
                    [scrollView addSubview:imageStar];
                    UILabel *numberRateLabel = [[UILabel alloc]initWithFrame:CGRectMake(originXstar + 6 + i*27, _heightCell + 27, 23, 23)];
                    [numberRateLabel setText:[NSString stringWithFormat:@"%@", [product valueForKey:[NSString stringWithFormat:@"%d_star_number",i+1]]]];
                    [numberRateLabel setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:18]];
                    [numberRateLabel setTextColor:[UIColor darkGrayColor]];
                    [scrollView addSubview:numberRateLabel];
                }
            }
        }
        [scrollView addSubview:reviewCell];
        scrollView.backgroundColor = [UIColor whiteColor];
        
        [nextController.view addSubview:scrollView];
        [self.navigationController pushViewController:nextController animated:YES];
    }
}

#pragma mark Review Filter Delegate
- (void)didSelectedStar:(NSInteger)star{
    if (star > 5 || star < 0) {
        star = 0;
    }
    if (selectedStar != star) {
        isFirstGet = YES;
        selectedStar = star;
        [reviewCollection removeAllObjects];
        [self getReviews];
    }
}

@end
