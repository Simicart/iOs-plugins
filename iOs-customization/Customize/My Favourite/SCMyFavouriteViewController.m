//
//  SCMyFavouriteViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 10/26/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCMyFavouriteViewController.h"
#import "SCMyFavouriteModelCollection.h"
#import "SCMyFavouriteModel.h"
#import "SCMyFavouriteDetailViewController.h"
#import "Utilities.h"

@interface SCMyFavouriteViewController ()

@end

@implementation SCMyFavouriteViewController{
    UIRefreshControl *refreshControl;
    UITableView *favouriteTableView;
    SimiButton *addFolderButton;
    SimiLabel *emptyLabel;
    SCMyFavouriteModelCollection *favouriteCollection;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidLoadBefore{
    [super viewDidLoadBefore];
    favouriteTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    favouriteTableView.tableFooterView = [UIView new];
    favouriteTableView.delegate = self;
    favouriteTableView.dataSource = self;
    [self.view addSubview:favouriteTableView];
    refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(getMyFavouriteCollection) forControlEvents:UIControlEventValueChanged];
    [favouriteTableView addSubview: refreshControl];
    emptyLabel = [[SimiLabel alloc] initWithFrame:CGRectZero];
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.numberOfLines = 0;
    emptyLabel.text = [NSString stringWithFormat:@"%@!",SCLocalizedString(@"Fill in your favorites products to be able to purchase all of them with one click")];
    [self.view addSubview:emptyLabel];
    addFolderButton = [[SimiButton alloc] initWithFrame:CGRectZero title:@"Create New Folder"];
    [addFolderButton addTarget:self action:@selector(addNewFolder:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addFolderButton];
    
    emptyLabel.hidden = YES;
    favouriteTableView.hidden = YES;
    
}
- (void)viewDidAppearBefore:(BOOL)animated{
    favouriteTableView.frame = self.view.bounds;
    favouriteTableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    emptyLabel.frame = self.view.bounds;
    addFolderButton.frame = CGRectMake(0, self.view.bounds.size.height - 50, self.view.bounds.size.width, 50);
    [self getMyFavouriteCollection];
}
- (void)addNewFolder:(id)sender{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:SCLocalizedString(@"Folder Details") message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:SCLocalizedString(@"Save name") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = [alertController.textFields objectAtIndex:0];
        [self startLoadingData];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetFavouriteCollection:) name:DidAddNewFolder object:nil];
        [favouriteCollection addNewFolder:textField.text];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)updateItem{
    [self getMyFavouriteCollection];
}

- (void)getMyFavouriteCollection{
    if(!favouriteCollection){
        favouriteCollection = [SCMyFavouriteModelCollection new];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetFavouriteCollection:) name:DidGetMyFavouriteCollection object:nil];
    [favouriteCollection getMyFavouriteCollection];
    [self startLoadingData];
}

- (void)didGetFavouriteCollection:(NSNotification *)noti{
    [self stopLoadingData];
    [refreshControl endRefreshing];
    [self removeObserverForNotification:noti];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    if(responder.status == SUCCESS){
        if(favouriteCollection.count > 0){
            favouriteTableView.hidden = NO;
            emptyLabel.hidden = YES;
            [favouriteTableView reloadData];
        }else{
            favouriteTableView.hidden = YES;
            emptyLabel.hidden = NO;
        }
    }else{
    }
    [self showAlertWithTitle:@"" message:responder.message];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiModel *favouriteModel = [favouriteCollection objectAtIndex:indexPath.row];
    NSString *favouriteId = [favouriteModel objectForKey:@"list_id"];
    if(favouriteId){
        favouriteCollection = [SCMyFavouriteModelCollection new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didMakeFavouriteDefault:) name:DidMakeFavouriteDefault object:nil];
        [favouriteCollection setFavouriteDefaultWithId:favouriteId];
        [self startLoadingData];
    }
}
- (void)didMakeFavouriteDefault:(NSNotification *)noti{
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    [favouriteTableView reloadData];
    [self showAlertWithTitle:@"" message:responder.message];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiModel *favouriteModel = [favouriteCollection objectAtIndex:indexPath.row];
    NSString *identifier = [NSString stringWithFormat:@"%@",[favouriteModel objectForKey:@"list_id"]];
    SCMyFavouriteCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[SCMyFavouriteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier cellWidth:CGRectGetWidth(tableView.frame)];
        cell.delegate = self;
    }
    cell.favouriteModel = favouriteModel;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return favouriteCollection.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (void)editFavouriteWithId:(NSString *)favouriteId{
    SCMyFavouriteDetailViewController *detailVC = [SCMyFavouriteDetailViewController new];
    detailVC.favouriteId = favouriteId;
    [self.navigationController pushViewController:detailVC animated:YES];
}
- (void)addFolderToCart:(NSString *)listId{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddFolderToCart:) name:DidAddFolderToCart object:nil];
    [self startLoadingData];
    SCMyFavouriteModel *model = [SCMyFavouriteModel new];
    [model addFolderToCartWithId:listId];
}

- (void)didAddFolderToCart:(NSNotification *)noti{
    [self removeObserverForNotification:noti];
    [self stopLoadingData];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    if(responder.status == SUCCESS){
        [self showAlertWithTitle:@"" message:@"Your folder has been added to cart"];
        [[SimiGlobalVar sharedInstance].cart getQuoteItems];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetQuoteItems:) name:Simi_DidGetCart object:nil];
    }else{
        [self showAlertWithTitle:@"" message:responder.message];
    }
    [favouriteTableView reloadData];
}
- (void)didGetQuoteItems:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    [self removeObserverForNotification:noti];
    if(responder.status == SUCCESS){
        [[NSNotificationCenter defaultCenter] postNotificationName:SCCartController_DidChangeCart object:nil];
    }
}
- (void)historyFavouriteWithId:(NSString *)favouriteId{
    SCMyFavouriteHistoryViewController *historyVC = [SCMyFavouriteHistoryViewController new];
    historyVC.listId = favouriteId;
    historyVC.delegate = self;
    [self.navigationController pushViewController:historyVC animated:YES];
}

- (void)removeFavouriteWithId:(NSString *)favouriteId{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@?",SCLocalizedString(@"Are you sure you want to delete this folder")] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:SCLocalizedString(@"Delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveFavourite:) name:DidRemoveFavourite object:nil];
        [self startLoadingData];
        [favouriteCollection removeFavouriteWithId:favouriteId];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:SCLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
    
}

- (void)didRemoveFavourite:(NSNotification *)noti{
    [self removeObserverForNotification:noti];
    [self stopLoadingData];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    [self showAlertWithTitle:@"" message:responder.message];
    [favouriteTableView reloadData];
}

@end

@implementation SCMyFavouriteCell{
    
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(float)cellWidth{
    if(self == [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]){
        self.textLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE];
        self.detailTextLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
        UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cellWidth/2, 100)];
        CGFloat fontSize = [[Utilities sharedInstance] fontSizeToWrapText:@"Add To Cart" forLabel:[[SimiLabel alloc] initWithFrame:CGRectMake(10, (100 - 30)/2 + 20, cellWidth/4 - 10, 30) andFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE]]];
        
        SimiButton *addToCartButton = [[SimiButton alloc] initWithFrame:CGRectMake(10, (100 - 30)/2 + 20, cellWidth/4 - 10, 30) title:@"Add To Cart" titleFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:fontSize - 0.75] cornerRadius:15 borderWidth:0 borderColor:[UIColor clearColor]];
        
        [addToCartButton addTarget:self action:@selector(addToCart:) forControlEvents:UIControlEventTouchUpInside];
        [accessoryView addSubview:addToCartButton];
        float otherWidth = cellWidth/4;
        float paddingX = 10;
        float buttonWidth = (otherWidth - 2*paddingX)/2;
        UIButton *historyButton = [[UIButton alloc]initWithFrame:CGRectMake(cellWidth/4 + paddingX, (100 - buttonWidth)/2 + 20, buttonWidth, buttonWidth)];
        [historyButton addTarget:self action:@selector(history:) forControlEvents:UIControlEventTouchUpInside];
        [historyButton setImage:[[UIImage imageNamed:@"ic_custom_history"] imageWithColor:THEME_CONTENT_COLOR] forState:UIControlStateNormal];
        [historyButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [accessoryView addSubview:historyButton];
        UIButton *editButton = [[UIButton alloc]initWithFrame:CGRectMake(cellWidth/4 + paddingX + buttonWidth + paddingX, (100 - buttonWidth)/2 + 20, buttonWidth, buttonWidth)];
        [editButton addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
        [editButton setImage:[[UIImage imageNamed:@"ic_custom_edit"] imageWithColor:THEME_CONTENT_COLOR] forState:UIControlStateNormal];
        [editButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [accessoryView addSubview:editButton];
        float inset = 0;
        if(buttonWidth > 24){
            inset = (buttonWidth - 24)/2;
        }
        [editButton setImageEdgeInsets:UIEdgeInsetsMake(inset, inset, inset, inset)];
        [historyButton setImageEdgeInsets:UIEdgeInsetsMake(inset, inset, inset, inset)];
        self.accessoryView = accessoryView;
        self.imageView.image = [[UIImage imageNamed:@"ic_pagecontrolnochoice"] imageWithColor:THEME_CONTENT_COLOR];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        UIButton *removeButton = [[UIButton alloc] initWithFrame:CGRectMake(cellWidth/2 - 24, 10, 24, 24)];
        removeButton.layer.borderColor = THEME_CONTENT_COLOR.CGColor;
        removeButton.layer.borderWidth = 0.75f;
        removeButton.layer.cornerRadius = CGRectGetHeight(removeButton.frame)/2;
        removeButton.imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
        [removeButton setImage:[[UIImage imageNamed:@"ic_custom_delete"] imageWithColor:THEME_CONTENT_COLOR] forState:UIControlStateNormal];
        [removeButton addTarget:self action:@selector(remove:) forControlEvents:UIControlEventTouchUpInside];
        [accessoryView addSubview:removeButton];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


- (void)history:(id)sender{
    [self.delegate historyFavouriteWithId:[_favouriteModel objectForKey:@"list_id"]];
}

- (void)edit:(id)sender{
    [self.delegate editFavouriteWithId:[_favouriteModel objectForKey:@"list_id"]];
}

- (void)addToCart:(id)sender{
    [self.delegate addFolderToCart:[_favouriteModel objectForKey:@"list_id"]];
}

- (void)remove:(id)sender{
    [self.delegate removeFavouriteWithId:[_favouriteModel objectForKey:@"list_id"]];
}

- (void)setFavouriteModel:(SimiModel *)favouriteModel{
    _favouriteModel = favouriteModel;
    self.textLabel.text = [favouriteModel objectForKey:@"title"];
    NSInteger numberItems = [[favouriteModel objectForKey:@"total_items"] integerValue];
    self.detailTextLabel.text = [NSString stringWithFormat:@"%ld %@",(long)numberItems,numberItems > 1?@"items":@"item"];
    if([[favouriteModel objectForKey:@"is_default"] boolValue]){
        self.imageView.image = [[UIImage imageNamed:@"ic_pagecontrolchoice"] imageWithColor:THEME_CONTENT_COLOR];
    }else{
        self.imageView.image = [[UIImage imageNamed:@"ic_pagecontrolnochoice"] imageWithColor:THEME_CONTENT_COLOR];
    }
}

@end

