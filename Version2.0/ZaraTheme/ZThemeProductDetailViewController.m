//
//  ZThemeProductDetailViewController.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 6/5/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeProductDetailViewController.h"
#import "ZThemeProductViewController.h"
#import "ZThemeProductViewControllerPad.h"

@interface ZThemeProductDetailViewController ()

@end
static NSString *BASIC_INFO = @"Basic Info";
static NSString *DESCRIPTION = @"Description";
static NSString *TECH_SPECS = @"Tech Specs";
static NSString *REVIEWS = @"Reviews";

@implementation ZThemeProductDetailViewController
@synthesize product, tabItems;
- (void)viewDidLoadBefore
{
    self.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = SCLocalizedString(@"Product Detail");
    self.dataSource = self;
    self.delegate = self;
    if (tabItems == nil) {
        tabItems = [[NSMutableArray alloc] init];
    }
    [self setData];
}

- (void)setData{
    [tabItems addObject:BASIC_INFO];
    if ([[product valueForKeyPath:@"product_description"] length] > 0) {
        [tabItems addObject:DESCRIPTION];
    }
    if ([[product valueForKeyPath:@"product_attributes"] count] > 0) {
        [tabItems addObject:TECH_SPECS];
    }
    [tabItems addObject:REVIEWS];
}

- (NSString *)convertToHTMLString:(NSArray *)arr{
    NSString *str = @"";
    for (NSDictionary *dict in arr) {
        str = [NSString stringWithFormat:@"%@<b>%@</b></br>", str, [dict valueForKeyPath:@"title"]];
        str = [NSString stringWithFormat:@"%@%@</br></br>", str, [dict valueForKeyPath:@"value"]];
        str = [NSString stringWithFormat:@"<span style=\"font-family: %@; font-size: %i\">%@</span>",
               @"Helvetica",
               14,
               str];
    }
    return str;
}

#pragma mark Simi Tab View Data Source
- (NSUInteger)numberOfTabsForSimiTabView:(SimiTabViewController *)simiTabView{
    return tabItems.count;
}
- (UIColor *)simiTabView:(SimiTabViewController *)simiTabView colorForComponent:(SimiTabViewComponent)component withDefault:(UIColor *)color{
    switch (component) {
        case SimiTabViewIndicator:
            return THEME_COLOR;
            break;
            
        default:
            return color;
            break;
    }
}
- (CGFloat)simiTabView:(SimiTabViewController *)simiTabView valueForOption:(SimiTabViewOption)option withDefault:(CGFloat)value{
    switch (option) {
        case SimiTabViewOptionTabWidth:
            return self.view.frame.size.width/tabItems.count;
            break;
            
        default:
            return value;
            break;
    }
}
- (UIView *)simiTabView:(SimiTabViewController *)simiTabView viewForTabAtIndex:(NSUInteger)index{
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14.0];
    label.text = SCLocalizedString([tabItems objectAtIndex:index]);
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    [label sizeToFit];
    return label;
}

- (UIViewController *)simiTabView:(SimiTabViewController *)simiTabView contentViewControllerForTabAtIndex:(NSUInteger)index{
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.view.frame = self.view.frame;
    if ([[tabItems objectAtIndex:index] isEqualToString:BASIC_INFO]) {
        UIScrollView *scrollView = [[UIScrollView alloc]init];
        ZThemeProductInfoView *productInfoView = [[ZThemeProductInfoView alloc]init];
        productInfoView.delegate = self;
        productInfoView.isDetailInfo = YES;
        [productInfoView cusSetProduct:product];
        productInfoView.shortDescriptionLabel.numberOfLines = 0;
        [productInfoView.shortDescriptionLabel sizeToFit];
        productInfoView.userInteractionEnabled = YES;
        productInfoView.frame = CGRectMake(0, 0, self.view.frame.size.width, productInfoView.heightCell + 450);
        scrollView.frame = self.view.frame;
        scrollView.contentSize = CGSizeMake(self.view.frame.size.width, productInfoView.heightCell+450);
        [scrollView addSubview:productInfoView];
        [viewController.view addSubview:scrollView];
        return viewController;
    }
    
    if ([[tabItems objectAtIndex:index] isEqualToString:DESCRIPTION]) {
        CGRect frame = self.view.frame;
        UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
        [webView loadHTMLString:[NSString stringWithFormat:@"<span style=\"font-family: %@; font-size: %i\">%@</span>",
                                 @"Helvetica",14,[product valueForKeyPath:@"product_description"]] baseURL:nil];
        webView.contentMode = UIViewContentModeScaleAspectFit;
        webView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [viewController.view addSubview:webView];
        return viewController;
    }
    
    if ([[tabItems objectAtIndex:index] isEqualToString:TECH_SPECS]) {
        CGRect frame = self.view.frame;
        UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
        [webView loadHTMLString:[self convertToHTMLString:[product valueForKeyPath:@"product_attributes"]] baseURL:nil];
        
        webView.contentMode = UIViewContentModeScaleAspectFit;
        webView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [viewController.view addSubview:webView];
        return viewController;
    }
    
    if ([[tabItems objectAtIndex:index] isEqualToString:REVIEWS]) {
        SCReviewDetailController *reviewDetailController = [[SCReviewDetailController alloc] init];
        [reviewDetailController setProduct:product];
        return reviewDetailController;
    }
    
    return viewController;
}

#pragma mark ZThemeInfo Product Delagate
- (void)didSelectRelatedProductWithProductID:(NSString *)selectProductID andListRelatedProduct:(NSMutableArray *)arrayRelatedProduct
{
    ZThemeProductViewController *zThemeProductViewController = [ZThemeProductViewController new];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        zThemeProductViewController = [ZThemeProductViewControllerPad new];
    }
    
    zThemeProductViewController.arrayProductsID = arrayRelatedProduct;
    zThemeProductViewController.firstProductID = selectProductID;
    [self.navigationController pushViewController:zThemeProductViewController animated:YES];
}
@end
