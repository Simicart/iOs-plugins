//
//  SCMyFavouriteDetailViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 10/26/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCMyFavouriteDetailViewController.h"
#import "SCMyFavouriteModel.h"
#import <SimiCartBundle/SimiTextField.h>
#import <SimiCartBundle/ActionSheetStringPicker.h>


@interface SCMyFavouriteDetailViewController ()

@end

@implementation SCMyFavouriteDetailViewController{
    UITableView *detailTableView;
    SCMyFavouriteModel *detailModel;
    UIRefreshControl *refreshControl;
    NSArray *items;
    SimiLabel *emptyLabel;
    SimiButton *addToCartButton;
    UIView *headerView;
    SimiLabel *titleLabel;
    UIButton *editButton;
}


- (void)viewDidAppearBefore:(BOOL)animated{
    emptyLabel.frame = self.view.bounds;
    detailTableView.frame = CGRectMake(0, 44, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 50 - 44);
    headerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44);
    addToCartButton.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - 50, CGRectGetWidth(self.view.bounds), 50);
    
    if(self.favouriteId)
        [self getFavouriteDetail];
}

- (void)viewDidLoadBefore{
    [super viewDidLoadBefore];
    emptyLabel = [[SimiLabel alloc] init];
    emptyLabel.text = @"This folder has no item";
    emptyLabel.numberOfLines = 0;
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:emptyLabel];
    if(!self.favouriteId){
        return;
    }
    headerView = [[UIView alloc] init];
    titleLabel = [[SimiLabel alloc] init];
    [headerView addSubview:titleLabel];
    editButton = [[UIButton alloc] init];
    editButton.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12);
    [editButton setImage:[[UIImage imageNamed:@"ic_custom_edit"] imageWithColor:THEME_CONTENT_COLOR] forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editTitle:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:editButton];
    [SimiGlobalFunction sortViewForRTL:headerView andWidth:headerView.frame.size.width];
    [self.view addSubview:headerView];
    headerView.hidden = YES;
    
    detailTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    detailTableView.tableFooterView = [UIView new];
    detailTableView.delegate = self;
    detailTableView.dataSource = self;
    [self.view addSubview:detailTableView];
    refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(getFavouriteDetail) forControlEvents:UIControlEventValueChanged];
    [detailTableView addSubview:refreshControl];
    detailModel = [SCMyFavouriteModel new];
    addToCartButton = [[SimiButton alloc] initWithFrame:CGRectZero title:@"Add All Item To Cart" titleFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE] cornerRadius:0 borderWidth:0 borderColor:[UIColor clearColor]];
    [addToCartButton addTarget:self action:@selector(addAllToCart:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addToCartButton];
    
    emptyLabel.hidden = YES;
    detailTableView.hidden = YES;
    addToCartButton.hidden = YES;
}

- (void)addAllToCart:(id)sender{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddAllItemToCart:) name:DidAddAllItemToCart object:nil];
    [self startLoadingData];
    SCMyFavouriteModel *model = [SCMyFavouriteModel new];
    [model addAllItemToCart:_favouriteId];
}

- (void)didAddAllItemToCart:(NSNotification *)noti{
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    if(responder.status == SUCCESS){
        [self showAlertWithTitle:@"" message:@"Your folder has been added to cart"];
        [self getFavouriteDetail];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetQuoteItems:) name:Simi_DidGetCart object:nil];
        [GLOBALVAR.cart getQuoteItems];
    }else{
        [self showAlertWithTitle:@"" message:responder.message];
    }
}
- (void)getFavouriteDetail{
    [detailModel getFavouriteDetailWithId:self.favouriteId];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetFavouriteDetail:) name:DidGetFavouriteDetail object:nil];
    [self startLoadingData];
}

- (void)didGetFavouriteDetail:(NSNotification *)noti{
    [self removeObserverForNotification:noti];
    [self stopLoadingData];
    [refreshControl endRefreshing];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    if(responder.status == SUCCESS){
        headerView.hidden = NO;
        titleLabel.frame = CGRectMake(15, 0, CGRectGetWidth(headerView.frame) - 30, 44);
        titleLabel.text = [NSString stringWithFormat:@"%@", [detailModel objectForKey:@"title"]];
        [titleLabel sizeToFit];
        CGRect frame = titleLabel.frame;
        if(frame.size.width > CGRectGetWidth(headerView.frame) - 30 - 44){
            frame.size.width = CGRectGetWidth(headerView.frame) - 30 - 44;
        }
        frame.size.height = 44;
        titleLabel.frame = frame;
        editButton.frame = CGRectMake(15 + CGRectGetWidth(titleLabel.frame), 0, 44, 44);
        if([[detailModel objectForKey:@"items"] isKindOfClass:[NSArray class]]){
            items = [detailModel objectForKey:@"items"];
            if(items.count > 0){
                emptyLabel.hidden = YES;
                detailTableView.hidden = NO;
                addToCartButton.hidden = NO;
                [detailTableView reloadData];
            }else{
                emptyLabel.hidden = NO;
                detailTableView.hidden = YES;
                addToCartButton.hidden = YES;
            }
        }
        [self.delegate updateItem];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 250;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return items.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *item = [items objectAtIndex:indexPath.row];
    NSString *identifer = [NSString stringWithFormat:@"%@",[item objectForKey:@"item_id"]];
    SCFavouriteDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if(!cell){
        cell = [[SCFavouriteDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer cellWidth:CGRectGetWidth(tableView.frame)];
        cell.delegate = self;
    }
    cell.item = item;
    return cell;
}
- (void)editTitle:(id)sender{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:SCLocalizedString(@"Change title") message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = [detailModel objectForKey:@"title"];
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:SCLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = [alertController.textFields objectAtIndex:0];
        [self startLoadingData];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetFavouriteDetail:) name:DidUpdateFavouriteTitle object:nil];
        [detailModel updateFavouriteTitle:textField.text listId:_favouriteId];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)updateSuggestedQty:(NSString *)qty forItem:(NSDictionary *)item{
    if([qty isEqualToString:@"0"]){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@?",SCLocalizedString(@"Are you sure you want to delete this item")] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:SCLocalizedString(@"Delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetFavouriteDetail:) name:DidUpdateSuggestedQty object:nil];
            [self startLoadingData];
            [detailModel updateSuggestedQty:qty forItem:item];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:SCLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertController animated:YES completion:^{
            
        }];
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetFavouriteDetail:) name:DidUpdateSuggestedQty object:nil];
    [self startLoadingData];
    [detailModel updateSuggestedQty:qty forItem:item];
}

- (void)updateQty:(NSString *)qty forItem:(NSDictionary *)item{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[item objectForKey:@"buy_request"]];
    [params addEntriesFromDictionary:@{@"qty":qty}];
    [self startLoadingData];
    [[NSNotificationCenter defaultCenter] postNotificationName:Simi_AddToCart object:nil userInfo:@{@"data":params}];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddToCart:) name:Simi_DidAddToCart object:nil];
}

- (void)didAddToCart:(NSNotification *)noti{
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    [self showAlertWithTitle:@"" message:responder.message];
    if(responder.status == SUCCESS){
        [self getFavouriteDetail];
        [GLOBALVAR.cart getQuoteItems];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetQuoteItems:) name:Simi_DidGetCart object:nil];
    }
}
- (void)didGetQuoteItems:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    [self removeObserverForNotification:noti];
    if(responder.status == SUCCESS){
        [[NSNotificationCenter defaultCenter] postNotificationName:SCCartController_DidChangeCart object:nil];
    }
}

@end
@implementation SCFavouriteDetailCell{
    UIButton *qtyButton, *suggestedQtyButton;
    NSMutableArray *qtyArray, *suggestedQtyArray;
    SimiLabel *label, *suggestedLabel, *qtyLabel;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(float)cellWidth{
    if(self == [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]){
        _cellWidth = cellWidth;
        label = [[SimiLabel alloc] initWithFrame:CGRectMake(15, 5, cellWidth - 30, 100)];
        [self addSubview:label];
        
        suggestedLabel = [[SimiLabel alloc] init];
        suggestedLabel.text = [NSString stringWithFormat:@"%@: ",SCLocalizedString(@"Suggested Stock Qty")];
        suggestedLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE];
        [self addSubview:suggestedLabel];
        
        suggestedQtyButton = [[UIButton alloc] init];
        [suggestedQtyButton addTarget:self action:@selector(suggestedQty:) forControlEvents:UIControlEventTouchUpInside];
        [suggestedQtyButton setTitleColor:THEME_CONTENT_COLOR forState:UIControlStateNormal];
        suggestedQtyButton.layer.borderColor = THEME_CONTENT_COLOR.CGColor;
        suggestedQtyButton.layer.borderWidth = 1;
        suggestedQtyButton.layer.cornerRadius = 4;
        [self addSubview:suggestedQtyButton];
        
        qtyLabel = [[SimiLabel alloc] init];
        qtyLabel.text = [NSString stringWithFormat:@"%@: ",SCLocalizedString(@"Qty")];
        qtyLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE];
        [qtyLabel sizeToFit];
        
        [self addSubview:qtyLabel];
        
        
        qtyButton = [[UIButton alloc] init];
        [qtyButton setTitleColor:THEME_CONTENT_COLOR forState:UIControlStateNormal];
        qtyButton.layer.borderColor = THEME_CONTENT_COLOR.CGColor;
        qtyButton.layer.borderWidth = 1;
        qtyButton.layer.cornerRadius = 4;
        [qtyButton addTarget:self action:@selector(qty:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:qtyButton];
        
        UIButton *removeButton = [[UIButton alloc] initWithFrame:CGRectMake(cellWidth - 44, 0, 44, 44)];
        removeButton.imageEdgeInsets = UIEdgeInsetsMake(14, 14, 14, 14);
        [removeButton setImage:[[UIImage imageNamed:@"ic_custom_delete"] imageWithColor:THEME_CONTENT_COLOR] forState:UIControlStateNormal];
        [removeButton addTarget:self action:@selector(remove:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:removeButton];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setItem:(NSDictionary *)item{
    float cellHeight = 0;
    _item = item;
    NSDictionary *product = [item objectForKey:@"product"];
    NSMutableString *content = [[NSMutableString alloc] initWithString:@""];
    if([product objectForKey:@"sku"]){
        [content appendString:[NSString stringWithFormat:@"<span style='padding-top:2px;padding-bottom:2px'><span style='font-family: %@;font-size:%ld'>%@: </span><span style='font-family:%@;font-size:%ld'>%@</span></span></br>",THEME_FONT_NAME_REGULAR,(long)THEME_FONT_SIZE,SCLocalizedString(@"Code"),THEME_FONT_NAME,(long)THEME_FONT_SIZE,[product objectForKey:@"sku"]]];
    }
    if([product objectForKey:@"name"]){
        [content appendString:[NSString stringWithFormat:@"<span style='padding-top:2px;padding-bottom:2px'><span style='font-family: %@;font-size:%ld'>%@: </span><span style='font-family:%@;font-size:%ld'>%@</span></span></br>",THEME_FONT_NAME_REGULAR,(long)THEME_FONT_SIZE,SCLocalizedString(@"Description"),THEME_FONT_NAME,(long)THEME_FONT_SIZE,[product objectForKey:@"name"]]];
    }
    if([product objectForKey:@"length"]){
        [content appendString:[NSString stringWithFormat:@"<span style='padding-top:2px;padding-bottom:2px'><span style='font-family: %@;font-size:%ld'>%@: </span><span style='font-family:%@;font-size:%ld'>%@</span></span></br>",THEME_FONT_NAME_REGULAR,(long)THEME_FONT_SIZE,SCLocalizedString(@"Length"),THEME_FONT_NAME,(long)THEME_FONT_SIZE,[product objectForKey:@"length"]]];
    }
    if([item objectForKey:@"available"]){
        NSString *img = @"instock";
        if([[item objectForKey:@"available"] isEqualToString:@"0"]){
            img = @"outstock";
        }else if([[item objectForKey:@"available"] isEqualToString:@"1"]){
            img = @"low_stock";
        }
        [content appendString:[NSString stringWithFormat:@"<span style='padding-top:2px;padding-bottom:2px'><span style='font-family: %@;font-size:%ld'>%@: <img src=\"%@\" alt=\"image\" height=\"20\" width=\"20\"/></span></br>",THEME_FONT_NAME_REGULAR,(long)THEME_FONT_SIZE,SCLocalizedString(@"Available"),[[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:img ofType:@"png"]] absoluteString]]];
    }
    if([item objectForKey:@"total_price"]){
        [content appendString:[NSString stringWithFormat:@"<span style='padding-top:2px;padding-bottom:2px'><span style='font-family: %@;font-size:%ld'>%@: </span><span style='font-family:%@;font-size:%ld'>%@</span></span></br>",THEME_FONT_NAME_REGULAR,(long)THEME_FONT_SIZE,SCLocalizedString(@"Price"),THEME_FONT_NAME,(long)THEME_FONT_SIZE,[[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[item objectForKey:@"total_price"]]]]];
    }
    
    if([item objectForKey:@"in_cart"]){
        [content appendString:[NSString stringWithFormat:@"<span style='padding-top:2px;padding-bottom:2px'><span style='font-family: %@;font-size:%ld'>%@: </span><span style='font-family:%@;font-size:%ld'>%@</span></span></br>",THEME_FONT_NAME_REGULAR,(long)THEME_FONT_SIZE,SCLocalizedString(@"Qty in cart"),THEME_FONT_NAME, (long)THEME_FONT_SIZE,[NSString stringWithFormat:@"%@",[item objectForKey:@"in_cart"]]]];
    }
    
    NSError *err;
    NSAttributedString *html = [[NSAttributedString alloc]
                                initWithData: [content dataUsingEncoding:NSUnicodeStringEncoding]
                                options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                documentAttributes: nil
                                error: &err];
    label.attributedText = html;
    label.numberOfLines = 0;
    [label sizeToFit];
    cellHeight += label.frame.size.height;
    
    suggestedLabel.frame = CGRectMake(15, cellHeight, _cellWidth - 30, 30);
    [suggestedLabel sizeToFit];
    
    suggestedQtyButton.frame = CGRectMake(suggestedLabel.frame.origin.x + suggestedLabel.frame.size.width, cellHeight, 60, 30);
    [suggestedQtyButton setTitle:[NSString stringWithFormat:@"%@",[item objectForKey:@"qty"]] forState:UIControlStateNormal];
    CGRect frame = suggestedLabel.frame;
    frame.size.height = 30;
    suggestedLabel.frame = frame;
    cellHeight += suggestedLabel.frame.size.height;
    
    qtyLabel.frame = CGRectMake(15, cellHeight, _cellWidth - 30, 30);
    [qtyLabel sizeToFit];
    
    qtyButton.frame = CGRectMake(qtyLabel.frame.origin.x + qtyLabel.frame.size.width, cellHeight, 60, 30);
    [qtyButton setTitle:@"1" forState:UIControlStateNormal];
    
    frame = qtyLabel.frame;
    frame.size.height = 30;
    qtyLabel.frame = frame;
    cellHeight += qtyLabel.frame.size.height;
}

- (void)qty:(id)sender{
    UIButton *qtyButton = (UIButton *)sender;
    qtyArray = [[NSMutableArray alloc] init];
    for (int i = 0; i <= 999; i+=1) {
        [qtyArray addObject:[NSString stringWithFormat:@"%d",i + 1]];
    }
    int qty = [[qtyButton titleForState:UIControlStateNormal] intValue];
    ActionSheetStringPicker* qtyPicker = [[ActionSheetStringPicker alloc]initWithTitle:@"Add to cart with qty" rows:qtyArray initialSelection:qty - 1 target:self successAction:@selector(didSelectQtyValue:) cancelAction:@selector(cancelActionSheet:) origin:sender];
    [qtyPicker showActionSheetPicker];
}

- (void)suggestedQty:(id)sender{
    UIButton *suggestedQtyButton = (UIButton *)sender;
    suggestedQtyArray = [[NSMutableArray alloc] init];
    for (int i = 0; i <= 999; i+=1) {
        [suggestedQtyArray addObject:[NSString stringWithFormat:@"%d",i + 1]];
    }
    int qty = [[suggestedQtyButton titleForState:UIControlStateNormal] intValue];
    ActionSheetStringPicker* qtyPicker = [[ActionSheetStringPicker alloc]initWithTitle:@"Change suggested qty" rows:suggestedQtyArray initialSelection:qty - 1 target:self successAction:@selector(didSelectSuggestedQtyValue:) cancelAction:@selector(cancelActionSheet:) origin:sender];
    [qtyPicker showActionSheetPicker];
}

- (void)didSelectQtyValue:(NSNumber *)selectedIndex{
    NSString *qty = [qtyArray objectAtIndex: [selectedIndex intValue]];
    [qtyButton setTitle:qty forState:UIControlStateNormal];
    [self.delegate updateQty:qty forItem:_item];
}

- (void)didSelectSuggestedQtyValue:(NSNumber *)selectedIndex{
    NSString *qty = [suggestedQtyArray objectAtIndex: [selectedIndex intValue]];
    if(![[suggestedQtyButton titleForState:UIControlStateNormal] isEqual: qty]){
        [suggestedQtyButton setTitle:qty forState:UIControlStateNormal];
        [self.delegate updateSuggestedQty:qty forItem:_item];
    }
}

-(void) cancelActionSheet:(id)sender{
    
}

- (void)remove:(id)sender{
    [self.delegate updateSuggestedQty:@"0" forItem:self.item];
}
@end
