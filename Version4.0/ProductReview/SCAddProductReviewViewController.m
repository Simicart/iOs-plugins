//
//  SCAddProductReviewViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 10/14/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SCAddProductReviewViewController.h"
#import "SimiReviewModel.h"
#import "ASStarRatingView.h"
#import <SimiCartBundle/SimiTextView.h>


@interface SCAddProductReviewViewController ()

@end

@implementation SCAddProductReviewViewController{
    UIScrollView *reviewScrollView;
    UIView *reviewContentView;
    NSArray *rateFields, *formKeys;
    SimiReviewModel* reviewModel;
    NSMutableArray *ratingViews, *reviewTextViews;
    CGSize keyboardSize;
    SimiButton *submitButton;
}

- (void)viewDidLoadBefore {
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    self.navigationItem.title  = SCLocalizedString(@"Add Review");
    if(PHONEDEVICE) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
}
- (void)viewWillDisappearBefore:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewDidAppearBefore:(BOOL)animated
{
    
    if([[[_productModel objectForKey:@"app_reviews"] objectForKey:@"form_add_reviews"] isKindOfClass:[NSArray class]]){
        NSArray* formAddReviews = [[_productModel objectForKey:@"app_reviews"] objectForKey:@"form_add_reviews"];
        if(formAddReviews.count > 0){
            float viewWidth = CGRectGetWidth(self.view.bounds);
            float viewHeight = CGRectGetHeight(self.view.bounds);
            reviewScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
            reviewScrollView.delegate = self;
            reviewContentView = [UIView new];
            [reviewScrollView addSubview:reviewContentView];
            [self.view addSubview:reviewScrollView];
            
            float paddingWidth = 15;
            float viewY = 10;
            if([[[formAddReviews objectAtIndex:0] objectForKey:@"rates"] isKindOfClass:[NSArray class]]){
                SimiLabel *titleLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingWidth, viewY, viewWidth - 2*paddingWidth, 40) andFontName:THEME_FONT_NAME_REGULAR andFontSize:THEME_FONT_SIZE andTextColor:THEME_CONTENT_COLOR text:[NSString stringWithFormat:@"%@?",SCLocalizedString(@"HOW DO YOU RATE THIS PRODUCT")]];
                [reviewContentView addSubview:titleLabel];
                viewY += titleLabel.frame.size.height;
                rateFields = [[formAddReviews objectAtIndex:0] objectForKey:@"rates"];
                ratingViews = [[NSMutableArray alloc] initWithCapacity:0];
                for(int i = 0;i<rateFields.count;i++) {
                    NSDictionary* rateField = [rateFields objectAtIndex:i];
                    UIView* ratingView = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, viewWidth, 30)];
                    [reviewContentView addSubview:ratingView];
                    SimiLabel* ratingLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingWidth, 0, viewWidth/2 - paddingWidth, 30) andFontName:THEME_FONT_NAME andFontSize:THEME_FONT_SIZE andTextColor:THEME_CONTENT_COLOR text:[rateField objectForKey:@"rate_code"]];
                    ASStarRatingView* ratingStarView = [[ASStarRatingView alloc] initWithFrame:CGRectMake(viewWidth/2, 0, viewWidth/2 - paddingWidth, 30)];
                    ratingStarView.simiRateData = [rateField objectForKey:@"rate_options"];
                    [ratingViews addObject:ratingStarView];
                    ratingStarView.rating = 1;
                    ratingStarView.minAllowedRating = 1;
                    ratingStarView.maxAllowedRating = 5;
                    [ratingView addSubview:ratingLabel];
                    [ratingView addSubview:ratingStarView];
                    viewY += ratingStarView.frame.size.height;
                }
            }
            if([[[formAddReviews objectAtIndex:0] objectForKey:@"form_review"] isKindOfClass:[NSDictionary class]]){
                NSDictionary *formReview = [[formAddReviews objectAtIndex:0] objectForKey:@"form_review"];
                formKeys = [formReview objectForKey:@"form_key"];
                if(formKeys.count > 0) {
                    reviewTextViews = [[NSMutableArray alloc] init];
                    for(NSDictionary *formKey in formKeys) {
                        SimiLabel *titleLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingWidth, viewY, viewWidth - 2*paddingWidth, 30) andFontName:THEME_FONT_NAME_REGULAR andFontSize:THEME_FONT_SIZE andTextColor:THEME_CONTENT_COLOR text:[NSString stringWithFormat:@"%@ (*)",[formKey objectForKey:@"value"]]];
                        [reviewContentView addSubview:titleLabel];
                        viewY += titleLabel.frame.size.height;
                        SimiTextView *contentTextView = [[SimiTextView alloc] initWithFrame:CGRectMake(paddingWidth, viewY, viewWidth - 2*paddingWidth, 40) font:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE] borderWidth:1 borderColor:COLOR_WITH_HEX(@"#cacaca") paddingLeft:5];
                        [reviewContentView addSubview:contentTextView];
                        viewY += contentTextView.frame.size.height;
                        contentTextView.simiObjectIdentifier = formKey;
                        contentTextView.delegate = self;
                        [reviewTextViews addObject:contentTextView];
                    }
                }
            }
            viewY += 20;
            submitButton = [[SimiButton alloc] initWithFrame:CGRectMake(paddingWidth, viewY, viewWidth - 2*paddingWidth, 50)];
            [submitButton setTitle:SCLocalizedString(@"Submit Review") forState:UIControlStateNormal];
            [submitButton addTarget:self action:@selector(submitReview:) forControlEvents:UIControlEventTouchUpInside];
            [reviewContentView addSubview:submitButton];
            viewY += submitButton.frame.size.height;
            
            reviewContentView.frame = CGRectMake(0, 0, viewWidth, viewY + 10);
            reviewScrollView.contentSize = CGSizeMake(viewWidth, viewY + 10);
            [SimiGlobalVar sortViewForRTL:reviewScrollView andWidth:viewWidth];
        }
    }
}

- (void)submitReview:(id) sender{
    if(!reviewModel)
        reviewModel = [SimiReviewModel new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSubmitReview:) name:DidSubmitProductReview object:nil];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithDictionary:@{@"product_id":_productModel.entityId}];
    NSMutableDictionary* ratingParams = [[NSMutableDictionary alloc] initWithCapacity:0];
    for(ASStarRatingView* ratingView in ratingViews){
        NSArray* rateOptions = ratingView.simiRateData;
        NSString* ratingKey = [[rateOptions objectAtIndex:ratingView.rating - 1] objectForKey:@"key"];
        NSString* ratingValue = [[rateOptions objectAtIndex:ratingView.rating - 1] objectForKey:@"value"];
        [ratingParams addEntriesFromDictionary:@{ratingKey:ratingValue}];
    }
    [params addEntriesFromDictionary:@{@"ratings":ratingParams}];
    for(SimiTextView *reviewTextView in reviewTextViews) {
        if([[reviewTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
            [self showToastMessage:@"Please fill in all required fields"];
            return;
        }
        NSDictionary *reviewKey = (NSDictionary *)reviewTextView.simiObjectIdentifier;
        [params addEntriesFromDictionary:@{[reviewKey objectForKey:@"key"]:reviewTextView.text}];
    }
    [reviewModel submitReviewForProductWithParams:params];
    [self startLoadingData];
}

- (void)didSubmitReview: (NSNotification*) noti{
    NSString *tempProductName = [NSString stringWithFormat:@"%@",self.productModel.name];
    NSString *tempProductId = [NSString stringWithFormat:@"%@",self.productModel.entityId];
    NSString *tempProductSku = [NSString stringWithFormat:@"%@",self.productModel.sku];
    [[NSNotificationCenter defaultCenter]postNotificationName:TRACKINGEVENT object:@"product_action" userInfo:@{@"action":@"rated_product",@"product_name":tempProductName,@"product_id":tempProductId,@"sku":tempProductSku,@"qty":@"1"}];
    
    SimiResponder* responder = [noti.userInfo objectForKey:responderKey];
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    if(responder.status == SUCCESS){
        [self showAlertWithTitle:@"" message:[reviewModel.data valueForKey:@"message"]];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self showAlertWithTitle:@"" message:responder.message];
    }
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification
{
    keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    reviewScrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    reviewScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}


#pragma mark UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    CGFloat oldHeight = textView.frame.size.height;
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
    if(newFrame.size.height != oldHeight) {
        [self resizeReviewSize];
    }
}

- (void)resizeReviewSize {
    float viewY = 10;
    for(UIView *subView in reviewContentView.subviews) {
        CGRect frame = subView.frame;
        if(subView == submitButton)
            viewY += 20;
        frame.origin.y = viewY;
        subView.frame = frame;
        viewY += subView.frame.size.height;
    }
    reviewContentView.frame = CGRectMake(0, 0, self.view.bounds.size.width, viewY + 10);
    reviewScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, viewY + 10);
}

@end
