//
//  SCSearchView.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 3/13/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCSearchView.h"

@implementation SCSearchView{
    UIBarButtonItem *searchBarButtonItem;
    UIBarButtonItem *cancelBarButtonItem;
}
- (id)initWithFrame:(CGRect)frame{
    if(self == [super initWithFrame:frame]){
        self.searchTextField = [[SCSearchTextField alloc] initWithFrame:self.bounds];
        self.searchTextField.delegate = self;
        self.searchTextField.searchDelegate = self;
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        searchBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"Search") style:UIBarButtonItemStyleDone target:self action:@selector(doneSearching:)];
        cancelBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelSearching:)];
        UIBarButtonItem *flexedButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        if(GLOBALVAR.isReverseLanguage){
            toolbar.items = @[searchBarButtonItem,flexedButtonItem,cancelBarButtonItem];
        }else{
            toolbar.items = @[cancelBarButtonItem,flexedButtonItem,searchBarButtonItem];
        }
        self.searchTextField.inputAccessoryView = toolbar;
        self.searchBackgroundView = [[UIView alloc]initWithFrame:self.searchTextField.frame];
        [self.searchBackgroundView setBackgroundColor:THEME_SEARCH_BOX_BACKGROUND_COLOR];
        [self.searchBackgroundView setAlpha:0.9f];
        
        [self addSubview:self.searchBackgroundView];
        [self addSubview:self.searchTextField];
    }
    return self;
}
- (void)doneSearching:(id)sender{
    [self.delegate searchWithText:self.searchTextField.text];
    [self.searchTextField endEditing:YES];
    [self.searchTextField resignFirstResponder];
}
- (void)cancelSearching:(id)sender{
    [self.searchTextField endEditing:YES];
    [self.searchTextField resignFirstResponder];
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if(textField.returnKeyType == UIReturnKeySearch){
        if([textField.text isEqualToString:@""]){
            [SimiGlobalFunction showToastMessage:@"Please enter text to search"];
            return NO;
        }
        [self.delegate searchWithText:textField.text];
        [self.searchTextField endEditing:YES];
        [self.searchTextField resignFirstResponder];
    }
    return YES;
}
- (void)clearTextField:(id)sender{
    self.searchTextField.text = @"";
    searchBarButtonItem.enabled = NO;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    searchBarButtonItem.enabled = NO;
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *nextString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(![nextString isEqualToString:@""]){
        if(GLOBALVAR.isReverseLanguage){
            float height = self.bounds.size.height;
            UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, height, height)];
            [clearButton setImage:[[UIImage imageNamed:@"ic_search_clear"] imageWithColor:THEME_SEARCH_ICON_COLOR] forState:UIControlStateNormal];
            [clearButton setImageEdgeInsets:UIEdgeInsetsMake(height/4, height/4, height/4, height/4)];
            clearButton.userInteractionEnabled = YES;
            [clearButton addTarget:self action:@selector(clearTextField:) forControlEvents:UIControlEventTouchUpInside];
            self.searchTextField.leftView = clearButton;
            self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
        }
        searchBarButtonItem.enabled = YES;
    }else{
        if(GLOBALVAR.isReverseLanguage){
            self.searchTextField.leftView = nil;
        }
        searchBarButtonItem.enabled = NO;
    }
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(![textField.text isEqualToString:@""]){
        if(GLOBALVAR.isReverseLanguage){
            float height = self.bounds.size.height;
            UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, height, height)];
            [clearButton setImage:[[UIImage imageNamed:@"ic_search_clear"] imageWithColor:THEME_SEARCH_ICON_COLOR] forState:UIControlStateNormal];
            [clearButton setImageEdgeInsets:UIEdgeInsetsMake(height/4, height/4, height/4, height/4)];
            clearButton.userInteractionEnabled = YES;
            [clearButton addTarget:self action:@selector(clearTextField:) forControlEvents:UIControlEventTouchUpInside];
            self.searchTextField.leftView = clearButton;
            self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
        }
        searchBarButtonItem.enabled = YES;
    }else{
        if(GLOBALVAR.isReverseLanguage){
            self.searchTextField.leftView = nil;
        }
        searchBarButtonItem.enabled = NO;
    }
    return YES;
}
- (void)searchTextField:(SCSearchTextField *)searchTextField didSetSearchText:(NSString *)searchText{
    if([searchText isEqualToString:@""]){
        if(GLOBALVAR.isReverseLanguage){
            searchTextField.leftView = nil;
        }
    }
}
@end
