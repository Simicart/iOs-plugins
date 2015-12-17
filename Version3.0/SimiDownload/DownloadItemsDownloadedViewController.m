//
//  DownloadManageDownloadedViewController.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 9/10/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "DownloadItemsDownloadedViewController.h"

@interface DownloadItemsDownloadedViewController ()

@end

@implementation DownloadItemsDownloadedViewController

- (void)viewDidLoadBefore
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _tableItemsDownloaded = [[UITableView alloc]initWithFrame:self.view.bounds];
    _tableItemsDownloaded.delegate = self;
    _tableItemsDownloaded.dataSource = self;
    [self.view addSubview:_tableItemsDownloaded];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    [self reloadData];
}

- (void)reloadData
{
    _downloadedFilesArray = [[NSMutableArray alloc] init];
    _fileManger = [NSFileManager defaultManager];
    NSError *error;
    _downloadedFilesArray = [[_fileManger contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"] error:&error] mutableCopy];
    if([_downloadedFilesArray containsObject:@".DS_Store"])
        [_downloadedFilesArray removeObject:@".DS_Store"];
    [_tableItemsDownloaded reloadData];
}
#pragma mark UITableView Datasource & Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell.textLabel setText:[_downloadedFilesArray objectAtIndex:indexPath.row]];
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _downloadedFilesArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *fileName = [_downloadedFilesArray objectAtIndex:indexPath.row];
    [self.delegate openFileWithName:fileName];
}

@end
