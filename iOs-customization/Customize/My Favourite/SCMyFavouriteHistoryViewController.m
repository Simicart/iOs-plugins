//
//  SCMyFavouriteHistoryViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 10/27/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCMyFavouriteHistoryViewController.h"

@interface SCMyFavouriteHistoryViewController ()

@end

@implementation SCMyFavouriteHistoryViewController
{
    UITableView *historyTableView;
    SimiLabel *emptyLabel;
    SCMyFavouriteModel *detailModel;
    NSArray *histories;
}
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidLoadBefore{
    [super viewDidLoadBefore];
    emptyLabel = [[SimiLabel alloc] initWithFrame:CGRectZero];
    emptyLabel.text = @"This folder has no history";
    emptyLabel.numberOfLines = 0;
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:emptyLabel];
    if(!self.listId){
        return;
    }
    historyTableView = [[UITableView alloc] initWithFrame:CGRectZero];
    historyTableView.delegate = self;
    historyTableView.dataSource = self;
    historyTableView.tableFooterView = [UIView new];
    [self.view addSubview:historyTableView];
    detailModel = [SCMyFavouriteModel new];
    histories = [NSArray new];
    emptyLabel.hidden = YES;
    historyTableView.hidden = YES;
}
- (void)viewDidAppearBefore:(BOOL)animated{
    emptyLabel.frame = self.view.bounds;
    historyTableView.frame = self.view.bounds;
    if(self.listId)
        [self getFavouriteDetail];
}
- (void)getFavouriteDetail{
    [detailModel getFavouriteDetailWithId:self.listId];
    [self startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetFavouriteDetail:) name:DidGetFavouriteDetail object:nil];
}

- (void)didGetFavouriteDetail:(NSNotification *)noti{
    [self removeObserverForNotification:noti];
    [self stopLoadingData];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    if(responder.status == SUCCESS){
        if([[detailModel objectForKey:@"histories"] isKindOfClass:[NSArray class]]){
            histories = [detailModel objectForKey:@"histories"];
            if(histories.count > 0){
                emptyLabel.hidden = YES;
                historyTableView.hidden = NO;
                [historyTableView reloadData];
            }else{
                emptyLabel.hidden = NO;
                historyTableView.hidden = YES;
            }
            [self.delegate updateItem];
        }
    }else{
        [self showAlertWithTitle:@"" message:responder.message];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return histories.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *history = [histories objectAtIndex:indexPath.row];
    NSString *identifier = [NSString stringWithFormat:@"%@",[history objectForKey:@"item_id"]];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        NSString *content = [NSString stringWithFormat:@"<span style='font-family:%@;font-size:%ld'>%@</span></br><span style='font-family:%@;font-size:%ld'>%@</br>%@: %@</span>",THEME_FONT_NAME_REGULAR,(long)THEME_FONT_SIZE,[history objectForKey:@"product_name"],THEME_FONT_NAME,(long)THEME_FONT_SIZE,[history objectForKey:@"product_sku"],SCLocalizedString(@"Last Purchased"),[history objectForKey:@"last_purchased"]];
        NSError *err;
        NSAttributedString *html = [[NSAttributedString alloc]
                                    initWithData: [content dataUsingEncoding:NSUnicodeStringEncoding]
                                    options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                    documentAttributes: nil
                                    error: &err];
        cell.textLabel.attributedText = html;
        cell.textLabel.numberOfLines = 0;
        [cell.textLabel sizeToFit];
        UIButton *removeButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(tableView.frame) - 44, 0, 44, 44)];
        removeButton.imageEdgeInsets = UIEdgeInsetsMake(14, 14, 14, 14);
        [removeButton setImage:[[UIImage imageNamed:@"ic_custom_delete"] imageWithColor:THEME_CONTENT_COLOR] forState:UIControlStateNormal];
        [removeButton addTarget:self action:@selector(remove:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:removeButton];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        removeButton.simiObjectIdentifier = history;
    }
    return cell;
}

- (void)remove:(id)sender{
    NSDictionary *history = (NSDictionary *)((NSObject *)sender).simiObjectIdentifier;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@?",SCLocalizedString(@"Are you sure you want to delete this history")] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:SCLocalizedString(@"Delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [detailModel removeHistoryWithId:[history objectForKey:@"item_id"] listId:[detailModel objectForKey:@"list_id"]];
        [self startLoadingData];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetFavouriteDetail:) name:DidRemoveHistoryItem object:nil];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:SCLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

