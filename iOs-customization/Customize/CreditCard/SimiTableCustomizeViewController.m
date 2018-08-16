//
//  SimiTableCustomizeViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 1/20/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SimiTableCustomizeViewController.h"

@interface SimiTableCustomizeViewController ()

@end

@implementation SimiTableCustomizeViewController
- (void)viewDidLoadBefore{
    self.contentTableView = [[UITableView alloc] init];
    self.contentTableView.tableFooterView = [UIView new];
    self.contentTableView.delegate = self;
    self.contentTableView.dataSource = self;
    [self.view addSubview:self.contentTableView];
}
- (void)viewDidAppearBefore:(BOOL)animated{
    self.contentTableView.frame = self.view.bounds;
}
- (void)viewWillAppearBefore:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}
- (void)viewWillDisappearBefore:(BOOL)animated{
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.contentTableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.contentTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

@end
