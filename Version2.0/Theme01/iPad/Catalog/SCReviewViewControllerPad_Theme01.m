//
//  SCReviewViewControllerPad_Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 9/24/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//
#import <SimiCartBundle/SCReviewView.h>
#import <SimiCartBundle/SimiResponder.h>
#import <SimiCartBundle/UIScrollView+SVInfiniteScrolling.h>

#import "SCReviewViewControllerPad_Theme01.h"


@interface SCReviewViewControllerPad_Theme01 ()
@end

@implementation SCReviewViewControllerPad_Theme01
@synthesize tableViewReviewCollection, reviewCollection, reviewCount, product, productRate;
@synthesize heightCell = _heightCell;

-(void)viewDidLoadBefore
{
    [self setToSimiView];
    selectedStar = 0;
    self.navigationItem.title = [[NSString stringWithFormat:@"%@ (%@)", SCLocalizedString(@"Review"), [product valueForKey:@"product_review_number"]]  uppercaseString];
    filterButton = [[UIBarButtonItem alloc]initWithTitle:SCLocalizedString(@"Filter") style:UIBarButtonItemStyleBordered target:self action:@selector(filter)];
    if (tableViewReviewCollection == nil) {
        tableViewReviewCollection = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
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

- (void)viewWillAppearAfter:(BOOL)animated
{
    [tableViewReviewCollection deselectRowAtIndexPath:[tableViewReviewCollection indexPathForSelectedRow] animated:YES];
}

#pragma mark Table View Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = [indexPath row];
    switch (row) {
        case 0:{
            return 135;
        }
            break;
        default:
        {
            SimiReviewModel *model = [reviewCollection objectAtIndex:(row -1)];
            if ([[model valueForKey:@"isSelect"] isEqualToString:@"yes"]) {
                return [[model valueForKey:@"Height"] floatValue];
            }else
            {
                return 200;
            }
        }
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = [indexPath row];
    switch (row) {
        case 0:{
            //Init cell
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ProductInfoCell"];
            int originXstar = (CGRectGetWidth(self.view.frame) - 33*5)/2 - 5;
            self.productRate = [[product valueForKey:@"product_rate"]floatValue];
            int temp = (int)productRate;
            
            float sizeBigStar = 33;
            float sizeBigStarWitdDistance = 38;
            
            UILabel *rateTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(70, 25, 150, 30)];
            [rateTitleLabel setText:[NSString stringWithFormat:@"%@ %@", [product valueForKey:@"product_review_number"],[SCLocalizedString(@"reviews") uppercaseString]]];
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
                    UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + i*sizeBigStarWitdDistance, _heightCell, sizeBigStar, sizeBigStar)];
                    [imageStar setImage:[UIImage imageNamed:@"theme01_stardetailbig2"]];
                    
                    frame = imageStar.frame;
                    frame.origin.y += sizeBigStar;
                    UILabel *numberRateLabel = [[UILabel alloc]initWithFrame:frame];
                    
                    [numberRateLabel setText:@"0"];
                    [numberRateLabel setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:18]];
                    [numberRateLabel setTextColor:[UIColor darkGrayColor]];
                    [numberRateLabel setTextAlignment:NSTextAlignmentCenter];
                    [cell addSubview:imageStar];
                    [cell addSubview:numberRateLabel];
                }
            }else{
                for (int i = 0; i < temp; i++) {
                    UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + i*sizeBigStarWitdDistance, _heightCell, sizeBigStar, sizeBigStar)];
                    [imageStar setImage:[UIImage imageNamed:@"theme01_stardetailbig0"]];
                    [cell addSubview:imageStar];
                    
                    frame = imageStar.frame;
                    frame.origin.y += sizeBigStar;
                    UILabel *numberRateLabel = [[UILabel alloc]initWithFrame:frame];
                    [numberRateLabel setTextAlignment:NSTextAlignmentCenter];
                    [numberRateLabel setText:[NSString stringWithFormat:@"%@", [product valueForKey:[NSString stringWithFormat:@"%d_star_number",i+1]]]];
                    [numberRateLabel setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:18]];
                    [numberRateLabel setTextColor:[UIColor darkGrayColor]];
                    [cell addSubview:numberRateLabel];
                }
                if (productRate - temp > 0) {
                    UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + temp*sizeBigStarWitdDistance, _heightCell, sizeBigStar, sizeBigStar)];
                    [imageStar setImage:[UIImage imageNamed:@"theme01_stardetailbig1"]];
                    [cell addSubview:imageStar];
                    
                    frame = imageStar.frame;
                    frame.origin.y += sizeBigStar;
                    UILabel *numberRateLabel = [[UILabel alloc]initWithFrame:frame];
                    [numberRateLabel setTextAlignment:NSTextAlignmentCenter];
                    [numberRateLabel setText:[NSString stringWithFormat:@"%@", [product valueForKey:[NSString stringWithFormat:@"%d_star_number",temp+1]]]];
                    [numberRateLabel setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:18]];
                    [numberRateLabel setTextColor:[UIColor darkGrayColor]];
                    [cell addSubview:numberRateLabel];
                    for (int i = temp + 1; i < 5; i++) {
                        UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + i*sizeBigStarWitdDistance, _heightCell, sizeBigStar, sizeBigStar)];
                        [imageStar setImage:[UIImage imageNamed:@"theme01_ratestar_big2"]];
                        [cell addSubview:imageStar];
                        frame = imageStar.frame;
                        frame.origin.y += sizeBigStar;
                        UILabel *numberRateLabel = [[UILabel alloc]initWithFrame:frame];
                        [numberRateLabel setTextAlignment:NSTextAlignmentCenter];
                        [numberRateLabel setText:[NSString stringWithFormat:@"%@", [product valueForKey:[NSString stringWithFormat:@"%d_star_number",i+1]]]];
                        [numberRateLabel setFont:[UIFont fontWithName:THEME01_FONT_NAME_REGULAR size:18]];
                        [numberRateLabel setTextColor:[UIColor darkGrayColor]];
                        [cell addSubview:numberRateLabel];
                    }
                }else{
                    for (int i = temp; i < 5; i++) {
                        UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(originXstar + i*sizeBigStarWitdDistance, _heightCell, sizeBigStar, sizeBigStar)];
                        [imageStar setImage:[UIImage imageNamed:@"theme01_stardetailbig2"]];
                        [cell addSubview:imageStar];
                        
                        frame = imageStar.frame;
                        frame.origin.y += sizeBigStar;
                        UILabel *numberRateLabel = [[UILabel alloc]initWithFrame:frame];
                        [numberRateLabel setTextAlignment:NSTextAlignmentCenter];
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
            ShortReviewCellPad_Theme01 *cell = [[ShortReviewCellPad_Theme01 alloc]initWithNibName:@"ShortReviewCellPad_Theme01"];
            [cell setReviewModel:[reviewCollection objectAtIndex:row]];
            [[reviewCollection objectAtIndex:row] setValue:[NSString stringWithFormat:@"%f",cell.heightReal] forKey:@"Height"];
            [[reviewCollection objectAtIndex:row] setValue:[NSString stringWithFormat:@"%d",(int)row] forKey:@"row"];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            return cell;
        }
            break;
    }
}

#pragma mark TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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

- (void)didClickShow:(int)row withSelected:(BOOL)isSelect
{
    if (isSelect) {
        [[reviewCollection objectAtIndex:row] setValue:@"no" forKey:@"isSelect"];
    }else
    {
        [[reviewCollection objectAtIndex:row] setValue:@"yes" forKey:@"isSelect"];
    }
    [tableViewReviewCollection reloadData];
}


@end
