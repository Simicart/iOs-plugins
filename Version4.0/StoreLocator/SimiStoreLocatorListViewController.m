//
//  SimiStoreLocatorListViewController.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/1/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiStoreLocatorListViewController.h"

@interface SimiStoreLocatorListViewController ()
{
    NSInteger offset;
    BOOL isFirstRun;
}
@end

@implementation SimiStoreLocatorListViewController
@synthesize currentLongitube, currentLatitube, sLModelCollection, delegate;
@synthesize sLModel,listViewOption, dictSearch;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark Cycle View

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setContentInset:UIEdgeInsetsZero];
    if (self.listViewOption != ListViewOptionSearched) {
        self.listViewOption = ListViewOptionNoneSearch;
    }
    
    __block __weak id weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf getStoreLocatorList];
    }];
    cLController = [[SimiCLController alloc]init];
    cLController.delegate = self;
    if (SIMI_SYSTEM_IOS >= 8.0) {
        [cLController.locationManager requestWhenInUseAuthorization];
    }
    [cLController.locationManager startUpdatingLocation];
    isFirstRun = YES;
    offset = 0;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    switch (listViewOption) {
        case ListViewOptionNoneSearch:
            break;
        case ListViewOptionSearched:
            isFirstRun = YES;
            offset = sLModelCollection.count;
            [self.tableView reloadData];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [sLModelCollection count];
}

- (SCStoreListTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimiStoreLocatorModel *locatorModel = [sLModelCollection objectAtIndex:indexPath.row];
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%@",@"CellIdentifier",locatorModel.simistorelocatorId];
    SCStoreListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[SCStoreListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier andStoreData:locatorModel];
        cell.delegate = self;
    }
    return cell;
}


#pragma mark Table View Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimiStoreLocatorModel *storeLocatorModel = [sLModelCollection objectAtIndex:indexPath.row];
    NSString *stringAddress = @"";
    if (![storeLocatorModel.address isEqualToString:@""]) {
        stringAddress = [NSString stringWithFormat:@"%@",storeLocatorModel.address];
    }
    if (![storeLocatorModel.city isEqualToString:@""]) {
        stringAddress = [NSString stringWithFormat:@"%@, %@",stringAddress, storeLocatorModel.city];
    }
    if (![storeLocatorModel.state isEqualToString:@""]) {
        stringAddress = [NSString stringWithFormat:@"%@, %@", stringAddress, storeLocatorModel.state];
    }
    if (![storeLocatorModel.zipcode isEqualToString:@""]) {
        stringAddress = [NSString stringWithFormat:@"%@, %@", stringAddress, storeLocatorModel.zipcode];
    }
    if (![storeLocatorModel.countryName isEqualToString:@""]) {
        stringAddress = [NSString stringWithFormat:@"%@, %@", stringAddress, storeLocatorModel.countryName];
    }
    float cellWidth = SCREEN_WIDTH;
    if (PADDEVICE) {
        cellWidth = 320;
    }
    float labelWidth = cellWidth - 100;
    float heightLabelAddress = [stringAddress boundingRectWithSize:CGSizeMake(labelWidth, 999) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 3]} context:nil].size.height;
    float heightCell = heightLabelAddress + 70;
    if (heightCell < 120) {
        heightCell = 120;
    }
    return heightCell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCStoreListTableViewCell *cell = (SCStoreListTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    [self.delegate showViewDetailControllerFromList:cell.storeLocatorModel];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:TRACKINGEVENT object:@"store_locator_action" userInfo:@{@"action":@"selected_store",@"store_name":cell.storeLocatorModel.name}];
}


#pragma mark Simi CL Delegate
- (void)locationUpdate:(CLLocation *)location {
    [cLController.locationManager stopUpdatingLocation];
    if (isFirstRun) {
        [self didGetCurrentLocationWithLatitube:location.coordinate.latitude andLongitube:location.coordinate.longitude];
    }
}

- (void)locationError:(NSError *)error {
    if (isFirstRun) {
        [self didGetCurrentLocationWithLatitube:0 andLongitube:0];
    }
}

- (void) didGetCurrentLocationWithLatitube:(float)la andLongitube:(float)lng
{
    currentLatitube = la;
    currentLongitube = lng;
    [self getStoreLocatorList];
}


#pragma mark - Get Store Locator
- (void) getStoreLocatorList
{
    switch (self.listViewOption) {
        case ListViewOptionNoneSearch:
            if (sLModelCollection == nil) {
                sLModelCollection = [[SimiStoreLocatorModelCollection alloc]init];
            }
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetStoreLocatorList) name:StoreLocator_DidGetStoreList object:sLModelCollection];
            if (isFirstRun || offset != [sLModelCollection count]) {
                isFirstRun = NO;
                offset = [sLModelCollection count];
                [sLModelCollection getStoreListWithLatitude:[NSString stringWithFormat:@"%f",currentLatitube] longitude:[NSString stringWithFormat:@"%f",currentLongitube] offset:[NSString stringWithFormat:@"%d",(int)offset] limit:@"20"];
                [self.tableView.infiniteScrollingView startAnimating];
            }else
            {
                [self.tableView.infiniteScrollingView stopAnimating];
            }
            break;
        case ListViewOptionSearched:
            if (sLModelCollection == nil) {
                sLModelCollection = [[SimiStoreLocatorModelCollection alloc]init];
            }
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetStoreLocatorList) name:StoreLocator_DidGetStoreList object:sLModelCollection];
            if (isFirstRun ||offset != [sLModelCollection count]) {
                isFirstRun = NO;
                offset = [sLModelCollection count];
                [sLModelCollection getStoreListWithLatitude:[NSString stringWithFormat:@"%f",currentLatitube] longitude:[NSString stringWithFormat:@"%f",currentLongitube] offset:[NSString stringWithFormat:@"%d",(int)offset] limit:@"20" country:[dictSearch valueForKey:@"countryCode"] city:[dictSearch valueForKey:@"city"] state:[dictSearch valueForKey:@"state"] zipcode:[dictSearch valueForKey:@"zipcode"] tag:[dictSearch valueForKey:@"tag"]];
                [self.tableView.infiniteScrollingView startAnimating];
            }else
            {
                [self.tableView.infiniteScrollingView stopAnimating];
            }
            break;
        default:
            break;
    }
}

- (void) didGetStoreLocatorList
{
    NSLog(@"%@",[sLModelCollection.collectionData valueForKey:@"sort"]);
    sLModelCollection.collectionData = [NSMutableArray arrayWithArray:[SimiGlobalFunction sortArray:sLModelCollection.collectionData byKey:@"sort"]];
    NSLog(@"%@",[sLModelCollection.collectionData valueForKey:@"sort"]);
    [self.tableView reloadData];
    [self.tableView.infiniteScrollingView stopAnimating];
}

#pragma mark Mail Delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    
	if(result==MFMailComposeResultCancelled)
	{
        [controller dismissViewControllerAnimated:YES completion:NULL];
	}
	if(result==MFMailComposeResultSent)
	{
        UIAlertView *sent=[[UIAlertView alloc]initWithTitle:@"Your email was sent succesfully" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[sent show];
		[controller dismissViewControllerAnimated:YES completion:NULL];
	}
	if(result==MFMailComposeResultFailed)
	{
        UIAlertView *sent=[[UIAlertView alloc]initWithTitle:@"Failed" message:@"Your mail was not sent" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[sent show];
		
		[controller dismissViewControllerAnimated:YES completion:NULL];
	}
}

#pragma mark Cell Delegate

- (void)sendEmailToStoreWithEmail:(NSString *)email andEmailContent:(NSString *)emailContent
{
    if([MFMailComposeViewController canSendMail])
	{
		MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
		[controller setToRecipients:[[NSArray alloc] initWithObjects:email, nil]];
		
		[controller setSubject:[NSString stringWithFormat:@""]];
		[controller setMessageBody:emailContent isHTML:NO];
		
		if(PADDEVICE)
		{
            [self presentViewController:controller animated:YES completion:NULL];
		}
		else {
            [self presentViewController:controller animated:YES completion:NULL];
		}
	}
	else{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"No Email Account") message:SCLocalizedString(@"Open Settings app to set up an email account")
													   delegate:self cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
		
		[alert show];
	}
}

- (void)choiceStoreLocatorWithStoreLocatorModel:(SimiStoreLocatorModel *)storeLM{
    if (storeLM !=nil) {
        self.sLModel = storeLM;
    }
    [self.delegate didChoiseStoreFromListToMap];
}
@end
