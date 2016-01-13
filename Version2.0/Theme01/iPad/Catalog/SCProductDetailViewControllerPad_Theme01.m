//
//  SCProductDetailViewControllerPad_Theme01.m
//  SimiCart
//
//  Created by Tan on 5/6/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "SCProductDetailViewControllerPad_Theme01.h"
#import "SCProductDetailView_Theme01.h"
#import "SimiThemeWorker.h"

@implementation SCProductDetailViewControllerPad_Theme01

@synthesize product, tabItems;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoadBefore
{
    self.view.frame = CGRectMake(0, 0, 320, 520);
    self.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = [SCLocalizedString(@"Details") uppercaseString];
    self.dataSource = self;
    self.delegate = self;
    if (tabItems == nil) {
        tabItems = [[NSMutableArray alloc] init];
    }
    [self setData];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    
}

#pragma mark Simi Tab View Data Source
- (NSUInteger)numberOfTabsForSimiTabView:(SimiTabViewController_Theme01 *)simiTabView{
    return self.tabItems.count;
}
- (UIColor *)simiTabView:(SimiTabViewController_Theme01 *)simiTabView colorForComponent:(SimiTabViewComponent)component withDefault:(UIColor *)color{
    switch (component) {
        case SimiTabViewIndicator:
            return THEME_COLOR;
            break;
            
        default:
            return color;
            break;
    }
}
- (CGFloat)simiTabView:(SimiTabViewController_Theme01 *)simiTabView valueForOption:(SimiTabViewOption)option withDefault:(CGFloat)value{
    switch (option) {
        case SimiTabViewOptionTabWidth:
            return (self.view.frame.size.width - 30)/self.tabItems.count;
            break;
            
        default:
            return value;
            break;
    }
}
- (UIView *)simiTabView:(SimiTabViewController_Theme01 *)simiTabView viewForTabAtIndex:(NSUInteger)index{
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME01_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR];
    label.text = [NSString stringWithFormat:@"%@", [self.tabItems objectAtIndex:index]];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    [label sizeToFit];
    return label;
}
- (UIViewController *)simiTabView:(SimiTabViewController_Theme01 *)simiTabView contentViewControllerForTabAtIndex:(NSUInteger)index{
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.view.frame = self.view.bounds;
    switch (index) {
        case 0:{
            SCProductDetailView_Theme01 *productDetailView = [[SCProductDetailView_Theme01 alloc]init];
            productDetailView.isDetailInfo = YES;
            [productDetailView cusSetProduct:product];
            productDetailView.shortDescriptionLabel.numberOfLines = 0;
            [productDetailView.shortDescriptionLabel sizeToFit];
            productDetailView.userInteractionEnabled = YES;
            productDetailView.frame = self.view.bounds;
            [productDetailView.scrollView setFrame:productDetailView.bounds];
            [productDetailView.scrollView setContentSize:CGSizeMake(productDetailView.bounds.size.width, productDetailView.bounds.size.height *2)];
            [viewController.view addSubview:productDetailView];
        }
            break;
        case 1:{
            CGRect frame = self.view.bounds;
            UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
            [webView loadHTMLString:[product valueForKeyPath:@"product_description"] baseURL:nil];
            webView.contentMode = UIViewContentModeScaleAspectFit;
            webView.scrollView.scrollEnabled = TRUE;
            webView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [viewController.view addSubview:webView];
        }
            break;
        case 2:{
            CGRect frame = self.view.bounds;
            UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
            [webView loadHTMLString:[self convertToHTMLString:[product valueForKeyPath:@"product_attributes"]] baseURL:nil];
            webView.contentMode = UIViewContentModeScaleAspectFit;
            webView.scrollView.scrollEnabled = TRUE;
            webView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [viewController.view addSubview:webView];
        }
            break;
        default:
            break;
    }
    return viewController;
}

- (UIColor *)tabsViewBackgroundColor
{
    return [UIColor whiteColor];
}

- (UIColor *)indicatorColor
{
    
    return [UIColor whiteColor];
}

- (UIColor *)contentViewBackgroundColor
{
    return [UIColor whiteColor];
}

- (NSNumber *)tabHeight
{
    return [NSNumber numberWithFloat:43];
}

- (CGRect)tabFrame{
    return CGRectMake(15, 27, self.view.frame.size.width - 30, 43);
}

- (CGRect)contentFrame{
    return CGRectMake(0, 87, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - self.navigationController.navigationBar.frame.size.height - 110);
}

- (NSString *)roundLeftImageName
{
    return @"theme01_description_round_left";
}

- (NSString *)roundRightImageName
{
    return @"theme01_description_round_right";
}

- (CGFloat)roundWith
{
    return 12;
}
- (CGFloat)roundHeight
{
    return 43;
}


@end
