//
//  SCSearchTextField.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 3/14/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCSearchTextField.h"

@implementation SCSearchTextField

- (id)initWithFrame:(CGRect)frame{
    if(self == [super initWithFrame:frame]){
        self.textColor = THEME_SEARCH_TEXT_COLOR;
        self.placeholder = SCLocalizedString(@"Search");
        [self setFont:[UIFont fontWithName:THEME_FONT_NAME size:FONT_SIZE_LARGE]];
        self.returnKeyType = UIReturnKeySearch;
        float searchBarHeight = self.bounds.size.height;
        UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, searchBarHeight, searchBarHeight)];
        [searchButton setImage:[[UIImage imageNamed:@"ic_search"] imageWithColor:THEME_SEARCH_ICON_COLOR] forState:UIControlStateNormal];
        [searchButton setImageEdgeInsets:UIEdgeInsetsMake(searchBarHeight/8, searchBarHeight/8, searchBarHeight/4, searchBarHeight/4)];
        if ([GLOBALVAR isReverseLanguage]) {
            self.rightView = searchButton;
            self.rightViewMode = UITextFieldViewModeAlways;
            [self.rightView setBackgroundColor:THEME_SEARCH_ICON_COLOR];
            [self setTextAlignment:NSTextAlignmentRight];
            self.rightView.backgroundColor = [UIColor clearColor];
        }else{
            self.leftView = searchButton;
            self.leftViewMode = UITextFieldViewModeAlways;
            [self.leftView setBackgroundColor:THEME_SEARCH_ICON_COLOR];
            [self setTextAlignment:NSTextAlignmentLeft];
            self.leftView.backgroundColor = [UIColor clearColor];
            self.clearButtonMode = UITextFieldViewModeWhileEditing;
        }
    }
    return self;
}
- (void)setText:(NSString *)text{
    [super setText:text];
    [self.searchDelegate searchTextField:self didSetSearchText:text];
}
@end
