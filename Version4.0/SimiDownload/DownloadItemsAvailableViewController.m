//
//  DownloadManageViewController.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 9/10/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "DownloadItemsAvailableViewController.h"

#define fileDownloaded @"order_link_isDownloaded"
#define fileDownloading @"order_link_isDownloading"
#define SectionControlAvailable @"SectionControlAvailable"

@interface DownloadItemsAvailableViewController ()

@end
//static NSString *rowDownloadAvailabel = @"rowDownloadAvailabel";
//static NSString *downloadNotAvailable = @"downloadNotAvailable";

@implementation DownloadItemsAvailableViewController
-(void)viewDidLoadBefore
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    _tableDownloadItems = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableDownloadItems.dataSource = self;
    _tableDownloadItems.delegate = self;
    [self.view addSubview:_tableDownloadItems];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    [self getListDownloadItems];
}
- (void)viewDidAppearBefore:(BOOL)animated
{
    [_tableDownloadItems setFrame:self.view.bounds];
}

#pragma mark Get List Download Items
- (void)getListDownloadItems
{
    if (_downloadModelCollection == nil) {
        _downloadModelCollection = [DownloadModelCollection new];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetDownloadItems:) name:DidGetDownloadItems object:nil];
    [_downloadModelCollection getDownloadItemsWithParams:@{}];
    [self startLoadingData];
}

- (void)didGetDownloadItems:(NSNotification*)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([[responder.status uppercaseString]isEqualToString:@"SUCCESS"]) {
        [self setCells:nil];
    }else {
        [self showToastMessage:responder.responseMessage];
    }
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    
//    if ([[responder.status uppercaseString]isEqualToString:@"SUCCESS"]) {
//        if (_downloadModelCollection.count > 0) {
//
//            _countSuccess = 0;
//            for (int i = 0; i < _downloadModelCollection.count; i++) {
//                SimiModel *model = [_downloadModelCollection objectAtIndex:i];
//                NSURL *url = [NSURL URLWithString:[model valueForKey:@"order_link"]];
//                NSMutableURLRequest *request = [NSMutableURLRequest
//                                                requestWithURL:url
//                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
//                                                timeoutInterval:30.0];
//
//                [request setHTTPMethod:@"HEAD"];
//                NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//                [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
//                    [model setValue:response.suggestedFilename forKey:@"filename"];
//                    if (response == nil || ![httpResponse.allHeaderFields valueForKey:@"Content-Disposition"] || [[NSString stringWithFormat:@"%@",[model valueForKey:@"order_status"]] isEqualToString:@"expired"]) {
//                        [model setValue:@"YES" forKey:downloadNotAvailable];
//                    }
//                    _countSuccess += 1;
//                    if (_countSuccess == _downloadModelCollection.count) {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [self stopLoadingData];
//                            [self setCells:nil];
//                            return;
//                        });
//                    }
//                }];
//            }
//        }else
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self stopLoadingData];
//            });
//    }else
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self stopLoadingData];
//        });
//    [self removeObserverForNotification:noti];
}

#pragma mark Set Cells
- (void)setCells:(SimiTable *)cells
{
    if (cells) {
        _cells = cells;
    }else
    {
        _cells = [SimiTable new];
        SimiSection *section = [[SimiSection alloc]initWithIdentifier:SectionControlAvailable];
        _downloadedFilesArray = [[NSMutableArray alloc] init];
        _fileManger = [NSFileManager defaultManager];
        NSError *error;
        _downloadedFilesArray = [[_fileManger contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"] error:&error] mutableCopy];
        if([_downloadedFilesArray containsObject:@".DS_Store"])
            [_downloadedFilesArray removeObject:@".DS_Store"];
        for (int j = 0; j < _downloadModelCollection.count; j++) {
            SimiModel *model = [_downloadModelCollection objectAtIndex:j];
            [model setValue:@"NO" forKey:fileDownloaded];
            [model setValue:@"NO" forKey:fileDownloading];
        }

        for (int i = 0; i < _downloadedFilesArray.count; i++) {
            for (int j = 0; j < _downloadModelCollection.count; j++) {
                NSString *stringDownloadedFileName = [_downloadedFilesArray objectAtIndex:i];
                SimiModel *model = [_downloadModelCollection objectAtIndex:j];
                if ([(NSString*)[model valueForKey:@"item_id"] isEqualToString:stringDownloadedFileName]) {
                    [model setValue:@"YES" forKey:fileDownloaded];
                }
            }
        }
        for (int i = 0; i < self.downloadingArray.count; i++) {
            for (int j = 0; j < _downloadModelCollection.count; j++) {
                NSString *stringDownloadingFileName = [self.downloadingArray objectAtIndex:i];
                SimiModel *model = [_downloadModelCollection objectAtIndex:j];
                if ([(NSString*)[model valueForKey:@"item_id"] isEqualToString:stringDownloadingFileName]) {
                    [model setValue:@"YES" forKey:fileDownloading];
                }
            }
        }
        if (_downloadModelCollection.count > 0) {
            for (int i = 0; i < _downloadModelCollection.count; i++) {
                SimiModel *model = [_downloadModelCollection objectAtIndex:i];
                SimiRow *row = [[SimiRow alloc]initWithIdentifier:[NSString stringWithFormat:@"%@",[model objectForKey:@"item_id"]] height:50];
                row.data = model;
                row.height = 160;
                [section addRow:row];
            }
        }
        [_cells addObject:section];
    }
    [_tableDownloadItems reloadData];
}

#pragma mark TableView Delegate & DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SimiSection *simiSection = [_cells objectAtIndex:section];
    return simiSection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection objectAtIndex:indexPath.row];
    NSString *cellIdentifier = simiRow.identifier;
    DownloadItemsAvailableTableViewCell *cell = [[DownloadItemsAvailableTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withData:simiRow withIndex:indexPath.row];
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cell) {
        return cell;
    }
    return [UITableViewCell new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection objectAtIndex:indexPath.row];
    return simiRow.height;
}

- (void)downloadItem:(SimiRow *)row atIndex:(NSInteger)index
{
    NSString *stringPath = [row.data valueForKey:@"order_link"];
    NSString *stringFileName = [row.data valueForKey:@"order_file"];
    [self.delegate addDownloadTask:stringFileName fileURL:stringPath];
    [[_downloadModelCollection objectAtIndex:index]setValue:@"YES" forKey:fileDownloading];
}
@end

#pragma mark DownloadItemsAvailableTableViewCell
@implementation DownloadItemsAvailableTableViewCell
{
    
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withData:(SimiRow *)row withIndex:(NSInteger)rowIndex
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.index = rowIndex;
    if (self) {
        float widthCell = SCREEN_WIDTH;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            widthCell = 2*SCREEN_WIDTH/3;
        }
        float padding = 15;
        float titlePaddingLeft = padding;
        float titleWidth = 90;
        float valuePaddingLeft =  titlePaddingLeft + titleWidth + padding;
        float valueWidth = widthCell - valuePaddingLeft - padding;
        float heightCell = 0;
        float heightLabel = 20;
        self.rowData = row;
        SimiModel *model = (SimiModel *)_rowData.data;
        NSString *titleObjectName = @"titleObjectName";
        NSString *valueObjectName = @"valueObjectName";
        
        UILabel *orderNameTitle = [[UILabel alloc]initWithFrame:CGRectMake(titlePaddingLeft, heightCell, titleWidth, heightLabel*2)];
        [orderNameTitle setText:[NSString stringWithFormat:@"%@",SCLocalizedString(@"Order Name")]];
        orderNameTitle.simiObjectName = titleObjectName;
        [self addSubview:orderNameTitle];
        
        UILabel *orderNameValue = [[UILabel alloc]initWithFrame:CGRectMake(valuePaddingLeft, heightCell,valueWidth, heightLabel*2)];
        [orderNameValue setText:[NSString stringWithFormat:@"%@",[model valueForKey:@"order_name"]]];
        orderNameValue.simiObjectName = valueObjectName;
        orderNameValue.numberOfLines = 2;
        orderNameValue.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:orderNameValue];
        heightCell += heightLabel*2;
        
        UILabel *orderDateTitle = [[UILabel alloc]initWithFrame:CGRectMake(titlePaddingLeft, heightCell, titleWidth, heightLabel)];
        [orderDateTitle setText:[NSString stringWithFormat:@"%@",SCLocalizedString(@"Order Date")]];
        orderDateTitle.simiObjectName = titleObjectName;
        [self addSubview:orderDateTitle];
        
        UILabel *orderDateValue = [[UILabel alloc]initWithFrame:CGRectMake(valuePaddingLeft, heightCell,valueWidth, heightLabel)];
        [orderDateValue setText:[NSString stringWithFormat:@"%@",[model valueForKey:@"order_date"]]];
        orderDateValue.simiObjectName = valueObjectName;
        [self addSubview:orderDateValue];
        heightCell += heightLabel;
        
        UILabel *orderStatusTitle = [[UILabel alloc]initWithFrame:CGRectMake(titlePaddingLeft, heightCell, titleWidth, heightLabel)];
        [orderStatusTitle setText:[NSString stringWithFormat:@"%@",SCLocalizedString(@"Order Status")]];
        orderStatusTitle.simiObjectName = titleObjectName;
        [self addSubview:orderStatusTitle];
        
        UILabel *orderStatusValue = [[UILabel alloc]initWithFrame:CGRectMake(valuePaddingLeft, heightCell,valueWidth, heightLabel)];
        [orderStatusValue setText:[NSString stringWithFormat:@"%@",[model valueForKey:@"order_status"]]];
        orderStatusValue.simiObjectName = valueObjectName;
        [self addSubview:orderStatusValue];
        heightCell += heightLabel;
        
        UILabel *orderRemainTitle = [[UILabel alloc]initWithFrame:CGRectMake(titlePaddingLeft, heightCell, titleWidth, heightLabel)];
        [orderRemainTitle setText:[NSString stringWithFormat:@"%@",SCLocalizedString(@"Order Remain")]];
        orderRemainTitle.simiObjectName = titleObjectName;
        [self addSubview:orderRemainTitle];
        
        UILabel *orderRemainValue = [[UILabel alloc]initWithFrame:CGRectMake(valuePaddingLeft, heightCell,valueWidth, heightLabel)];
        [orderRemainValue setText:[NSString stringWithFormat:@"%@",[model valueForKey:@"order_remain"]]];
        orderRemainValue.simiObjectName = valueObjectName;
        [self addSubview:orderRemainValue];
        heightCell += heightLabel + padding;
        
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel*)view;
                if ([label.simiObjectName isEqualToString:titleObjectName]) {
                    [label setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:14]];
                }else if ([label.simiObjectName isEqualToString:valueObjectName])
                {
                    [label setFont:[UIFont fontWithName:THEME_FONT_NAME size:14]];
                }
            }
        }
        
        UIButton *downloadButton = [[UIButton alloc]initWithFrame:CGRectMake(padding, heightCell, widthCell - padding*2, heightLabel*2)];
        downloadButton.simiObjectIdentifier = self.rowData;
        [downloadButton addTarget:self action:@selector(downloadItem:) forControlEvents:UIControlEventTouchUpInside];
        [downloadButton addTarget:self action:@selector(changeColor:) forControlEvents:UIControlEventTouchDown];
        [downloadButton setTitle:@"Download" forState:UIControlStateNormal];
        if ([[model valueForKey:fileDownloaded]boolValue]) {
            [downloadButton setTitle:@"Downloaded" forState:UIControlStateNormal];
            [downloadButton setEnabled:NO];
            [downloadButton setAlpha:0.5];
        }else if ([[model valueForKey:fileDownloading] boolValue])
        {
            [downloadButton setTitle:@"Downloading" forState:UIControlStateNormal];
            [downloadButton setEnabled:NO];
            [downloadButton setAlpha:0.5];
        }
        [downloadButton setBackgroundColor:[UIColor orangeColor]];
        [downloadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:downloadButton];
    }
    return self;
}

- (void)downloadItem:(id)sender
{
    UIButton *downloadButton = (UIButton*)sender;
    [downloadButton setBackgroundColor:[UIColor orangeColor]];
    SimiRow *rowData = (SimiRow *)downloadButton.simiObjectIdentifier;
    if ([[NSString stringWithFormat:@"%@",[rowData.data objectForKey:@"order_status"]] isEqualToString:@"expired"]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:SCLocalizedString(@"The link is not available") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil];
        [alert show];
        return;
    }
    [downloadButton setTitle:@"Downloading" forState:UIControlStateNormal];
    [downloadButton setEnabled:NO];
    [downloadButton setAlpha:0.5];
    [self.delegate downloadItem:rowData atIndex:self.index];
}

- (void)changeColor:(id)sender
{
     UIButton *downloadButton = (UIButton*)sender;
    [downloadButton setBackgroundColor:[UIColor redColor]];
}
@end
