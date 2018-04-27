//
//  SCPSearchViewController.m
//  SimiCartPluginFW
//
//  Created by Axe on 4/27/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPSearchViewController.h"
#import "SCPGlobalVars.h"
#import "SCPLabel.h"
#import "SCPTextField.h"
#import "SCPProductListViewController.h"

@interface SCPSearchViewController ()

@end

@implementation SCPSearchViewController{
    UIScrollView *mainScrollView;
    UIView *popularSearchView;
    float paddingX, contentWidth, contentY;
}
- (void)viewDidLoadBefore{
    mainScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    mainScrollView.backgroundColor = COLOR_WITH_HEX(@"#F2F2F2");
    [self.view addSubview:mainScrollView];
    paddingX = 15;
    contentY = 15;
    contentWidth = CGRectGetWidth(self.view.bounds) - 2*paddingX;
    SCPLabel *titleLabel = [[SCPLabel alloc] initWithFrame:CGRectMake(paddingX, contentY, contentWidth, 30) andFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_HEADER];
    titleLabel.text = @"Search";
    [mainScrollView addSubview:titleLabel];
    contentY += CGRectGetHeight(titleLabel.frame) + 15;
    SCPTextField *searchTextField = [[SCPTextField alloc] initWithFrame:CGRectMake(paddingX, contentY, contentWidth, 40)];
    searchTextField.backgroundColor = [UIColor whiteColor];
    searchTextField.placeholder = SCLocalizedString(@"Search our products");
    searchTextField.returnKeyType = UIReturnKeySearch;
    searchTextField.delegate = self;
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    searchButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [searchButton setImage:[[UIImage imageNamed:@"scp_ic_search_tabbar"] imageWithColor:SCP_ICON_COLOR] forState:UIControlStateNormal];
    searchButton.userInteractionEnabled = NO;
    searchTextField.leftView = searchButton;
    searchTextField.leftViewMode = UITextFieldViewModeAlways;
    [mainScrollView addSubview:searchTextField];
    contentY += CGRectGetHeight(searchTextField.frame) + 15;
    SCPLabel *popularlabel = [[SCPLabel alloc] initWithFrame:CGRectMake(paddingX, contentY, contentWidth, 30) andFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_LARGE];
    popularlabel.text = @"Popular Searches";
    [mainScrollView addSubview:popularlabel];
    contentY += CGRectGetHeight(popularlabel.frame);
    popularSearchView = [[UIView alloc] initWithFrame:CGRectMake(paddingX, contentY, contentWidth, 75)];
    [mainScrollView addSubview:popularSearchView];
    contentY += CGRectGetHeight(popularSearchView.frame);
}
- (void)viewDidAppearBefore:(BOOL)animated{
    mainScrollView.frame = self.view.bounds;
    [self loadSearchHistory];
}
- (void)loadSearchHistory{
    [popularSearchView removeAllSubViews];
    if(SCP_SEARCH_DATA.searchHistory.count){
        float popularY = 0;
        for(int i = 0;i<SCP_SEARCH_DATA.searchHistory.count;i++){
            if(i >= 3){
                break;
            }
            NSString *value = [SCP_SEARCH_DATA.searchHistory objectAtIndex:i];
            SimiLabel *valueLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(0, popularY, contentWidth, 25) andFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_SMALL andTextColor:COLOR_WITH_HEX(@"#747474") text:value];
            [valueLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSearchHistory:)]];
             valueLabel.userInteractionEnabled = YES;
            [popularSearchView addSubview:valueLabel];
            popularY += CGRectGetHeight(valueLabel.frame);
        }
    }
}
- (void)tapSearchHistory:(UITapGestureRecognizer *)sender{
    SCPLabel *historyLabel = (SCPLabel *)sender.view;
     [SCP_SEARCH_DATA addValueToSearchHistory:historyLabel.text];
    [[SCAppController sharedInstance]openProductListWithNavigationController:self.navigationController productsId:@"" productsName:@"" getProductsFrom:ProductListGetProductTypeFromSearch moreParams:@{KEYEVENT.PRODUCTLISTVIEWCONTROLLER.search_text:historyLabel.text}];
}
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(![[textField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]){
        [SCP_SEARCH_DATA addValueToSearchHistory:textField.text];
        textField.text = @"";
        [textField resignFirstResponder];
        [[SCAppController sharedInstance]openProductListWithNavigationController:self.navigationController productsId:@"" productsName:@"" getProductsFrom:ProductListGetProductTypeFromSearch moreParams:@{KEYEVENT.PRODUCTLISTVIEWCONTROLLER.search_text:textField.text}];
    }
    return YES;
}
@end
