//
//  SCBlueberryStoreLocatorViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 5/26/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCBlueberryStoreLocatorViewController.h"
#import "SimiTable.h"

#define STORELOCATION_MAPVIEW @"STORELOCATION_MAPVIEW"
#define STORELOCATION_STORE_LOCATION @"STORELOCATION_STORE_LOCATION"

@interface SCBlueberryStoreLocatorViewController ()

@end

@implementation SCBlueberryStoreLocatorViewController{
    GMSMapView* mapView;
    UITableView* storeLocationTableView;
    SimiStoreLocatorModelCollection* storeLocationCollection;
    SimiCLController *cLController;
    BOOL isFirstRun;
    float currentLatitube,currentLongitube;
    SimiTable* cells;
}

- (void)viewDidLoadBefore {
    [[NSNotificationCenter defaultCenter]postNotificationName:TRACKINGEVENT object:@"page_view_action" userInfo:@{@"action":@"viewed_store_locator_screen"}];
    self.navigationItem.title = SCLocalizedString(@"Stores Near You");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"Done") style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    cLController = [[SimiCLController alloc]init];
    cLController.delegate = self;
    if (SIMI_SYSTEM_IOS >= 8.0) {
        [cLController.locationManager requestWhenInUseAuthorization];
    }
    [cLController.locationManager startUpdatingLocation];
    isFirstRun = YES;
    storeLocationTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    storeLocationTableView.delegate = self;
    storeLocationTableView.dataSource = self;
    [self.view addSubview:storeLocationTableView];
    storeLocationTableView.hidden = YES;
}

- (void)done:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initCells{
    cells = [SimiTable new];
    SimiSection* mapSection = [cells addSectionWithIdentifier:STORELOCATION_MAPVIEW];
    [mapSection addRowWithIdentifier:STORELOCATION_MAPVIEW height:ScaleValue(220)];
    if(storeLocationCollection.count > 0){
        SimiSection* storeLocationSection = [cells addSectionWithIdentifier:STORELOCATION_STORE_LOCATION];
        for(NSDictionary* storeLocation in storeLocationCollection){
            [storeLocationSection addRowWithIdentifier:[NSString stringWithFormat:@"%@%@",STORELOCATION_STORE_LOCATION,[storeLocation objectForKey:@"simistorelocator_id"]] height:ScaleValue(142)];
        }
    }
    [storeLocationTableView reloadData];
}

- (void)getStoreLocations{
    if(!storeLocationCollection){
        storeLocationCollection = [SimiStoreLocatorModelCollection new];
    }
    [storeLocationCollection getStoreListWithLatitude:[NSString stringWithFormat:@"%f",currentLatitube] longitude:[NSString stringWithFormat:@"%f",currentLongitube] offset:[NSString stringWithFormat:@"%ld",storeLocationCollection.count] limit:@"24"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetStoreLocations:) name:@"StoreLocator_DidGetStoreList" object:nil];
    [self startLoadingData];
}

- (void)didGetStoreLocations:(NSNotification *)noti {
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    [self initCells];
    storeLocationTableView.hidden = NO;
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
    [self getStoreLocations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark UITableViewDelegate && UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SimiSection* section = [cells objectAtIndex:indexPath.section];
    if([section.identifier isEqualToString:STORELOCATION_STORE_LOCATION]){
        SimiModel* storeLocation = [storeLocationCollection objectAtIndex:indexPath.row];
        SCBlueberryStoreLocationDetailViewController* storeDetailVC = [SCBlueberryStoreLocationDetailViewController new];
        storeDetailVC.storeLocation = storeLocation;
        storeDetailVC.currentLatitude = currentLatitube;
        storeDetailVC.currentLongitude = currentLongitube;
        [self.navigationController pushViewController:storeDetailVC animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SimiSection* storeLocatorSection = [cells objectAtIndex:section];
    return storeLocatorSection.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return cells.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection* section = [cells objectAtIndex:indexPath.section];
    SimiRow* row = [section objectAtIndex:indexPath.row];
    return row.height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection* section = [cells objectAtIndex:indexPath.section];
    SimiRow* row = [section objectAtIndex:indexPath.row];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:row.identifier];
    if([section.identifier isEqualToString:STORELOCATION_STORE_LOCATION]){
        if(!cell){
            cell = [[SCBlueberryStoreLocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
            ((SCBlueberryStoreLocationCell *)cell).storeLocation = [storeLocationCollection objectAtIndex:indexPath.row];
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_disclosure_indicator"]];
        }
    }else if([section.identifier isEqualToString:STORELOCATION_MAPVIEW]){
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
            mapView = [[GMSMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, row.height)];
            [cell addSubview:mapView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        mapView.camera = [GMSCameraPosition cameraWithLatitude:currentLatitube longitude:currentLongitube zoom:15];
        mapView.delegate = self;
        mapView.myLocationEnabled = YES;
        for (SimiModel* storeLocation in storeLocationCollection) {
            SimiStoreLocatorMaker * storeLocatorMaker_ = [[SimiStoreLocatorMaker alloc]init];
            float lat = (float)[[NSString stringWithFormat:@"%@",[storeLocation valueForKey:@"latitude"]] floatValue];
            float lng = (float)[[NSString stringWithFormat:@"%@",[storeLocation valueForKey:@"longtitude"]] floatValue];
            storeLocatorMaker_.position = CLLocationCoordinate2DMake(lat,lng);
            storeLocatorMaker_.icon = [UIImage imageNamed:@"ic_store_marker"];
            storeLocatorMaker_.map = mapView;
        }
    }
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setPreservesSuperviewLayoutMargins:NO];
    [cell setLayoutMargins:UIEdgeInsetsZero];
    return cell;
}
@end
@implementation SCBlueberryStoreLocationCell{
    UIImageView* storeImageView;
    SCBlueberryLabel* distanceLabel;
    SCBlueberryLabel* storeNameLabel;
    SCBlueberryLabel* addressLabel;
    SCBlueberryLabel* openHourLabel;
    SCBlueberryButton* callButton;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        storeImageView = [[UIImageView alloc] initWithFrame:ScaleFrame(CGRectMake(15, 15, 64, 64))];
        storeImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:storeImageView];
        
        distanceLabel = [[SCBlueberryLabel alloc] initWithFrame:ScaleFrame(CGRectMake(15, 80, 64, 25)) andFont:RegularWithSize(14) opacity:0.48f andTextColor:[UIColor blackColor]];
        [self.contentView addSubview:distanceLabel];
        
        storeNameLabel = [[SCBlueberryLabel alloc] initWithFrame:ScaleFrame(CGRectMake(94, 15, 191, 30)) andFont:RegularWithSize(18) andTextColor:[UIColor blackColor]];
        [self.contentView addSubview:storeNameLabel];
        
        addressLabel = [[SCBlueberryLabel alloc] initWithFrame:ScaleFrame(CGRectMake(94, 30, 191, 50)) andFont:RegularWithSize(14) opacity:0.5f andTextColor:[UIColor blackColor]];
        [self.contentView addSubview:addressLabel];
        
        openHourLabel = [[SCBlueberryLabel alloc] initWithFrame:ScaleFrame(CGRectMake(94, 75, 191, 25)) andFont:RegularWithSize(14) opacity:0.5f andTextColor:[UIColor blackColor]];
        [self.contentView addSubview:openHourLabel];
        
        callButton = [[SCBlueberryButton alloc] initWithFrame:ScaleFrame(CGRectMake(94, 104, 90, 34)) title:SCLocalizedString(@"Call") titleFont:RegularWithSize(16) titleColor:[UIColor blackColor] backgroundColor:COLOR_WITH_HEX(@"#f8f8f8") cornerRadius:10.0f borderWidth:1 borderColor:COLOR_WITH_HEX(@"#ededed")];
        [callButton setImage:[UIImage imageNamed:@"ic_call"] forState:UIControlStateNormal];
        [callButton setTitle:SCLocalizedString(@"Call") forState:UIControlStateNormal];
        [callButton setImageEdgeInsets:UIEdgeInsetsMake(ScaleValue(4), ScaleValue(10), ScaleValue(4),ScaleValue(53))];
        [callButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        callButton.titleLabel.layer.opacity = 0.5f;
        [callButton addTarget:self action:@selector(callStore:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:callButton];
    }
    return self;
}

- (void)setStoreLocation:(SimiModel *)storeLocation{
    _storeLocation = storeLocation;
    [storeImageView sd_setImageWithURL:[storeLocation objectForKey:@"image"] placeholderImage:[UIImage imageNamed:@"image_placeholder"]];
    distanceLabel.text = [NSString stringWithFormat:@"%@ km",[[SimiFormatter sharedInstance] formatFloatNumber:[[storeLocation objectForKey:@"distance"] floatValue]/1000.0f maxDecimals:2 minDecimals:0]];
    [distanceLabel resizLabelToFit];
    storeNameLabel.text = [storeLocation objectForKey:@"name"];
    [storeNameLabel resizLabelToFit];
    CGRect frame = addressLabel.frame;
    frame.origin.y = storeNameLabel.frame.origin.y + storeNameLabel.frame.size.height;
    addressLabel.frame = frame;
    addressLabel.text = [storeLocation objectForKey:@"address"];
    [addressLabel resizLabelToFit];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSString* status = @"";
    switch (comps.weekday) {
        case 2://Mon
            if([[storeLocation objectForKey:@"monday_status"] boolValue]){
                status = [NSString stringWithFormat:@"%@ %@",SCLocalizedString(@"OPEN until"),[storeLocation objectForKey:@"monday_close"]];
            }else{
                status = SCLocalizedString(@"Not opening");
            }
            break;
        case 3:
            if([[storeLocation objectForKey:@"tuesday_status"] boolValue]){
                status = [NSString stringWithFormat:@"%@ %@",SCLocalizedString(@"OPEN until"),[storeLocation objectForKey:@"tuesday_close"]];
            }else{
                status = SCLocalizedString(@"Not opening");
            }
            break;
        case 4:
            if([[storeLocation objectForKey:@"wednesday_status"] boolValue]){
                status = [NSString stringWithFormat:@"%@ %@",SCLocalizedString(@"OPEN until"),[storeLocation objectForKey:@"wednesday_close"]];
            }else{
                status = SCLocalizedString(@"Not opening");
            }
            break;
        case 5:
            if([[storeLocation objectForKey:@"thursday_status"] boolValue]){
                status = [NSString stringWithFormat:@"%@ %@",SCLocalizedString(@"OPEN until"),[storeLocation objectForKey:@"thursday_close"]];
            }else{
                status = SCLocalizedString(@"Not opening");
            }
            break;
        case 6:
            if([[storeLocation objectForKey:@"friday_status"] boolValue]){
                status = [NSString stringWithFormat:@"%@ %@",SCLocalizedString(@"OPEN until"),[storeLocation objectForKey:@"friday_close"]];
            }else{
                status = SCLocalizedString(@"Not opening");
            }
            break;
        case 7:
            if([[storeLocation objectForKey:@"saturday_status"] boolValue]){
                status = [NSString stringWithFormat:@"%@ %@",SCLocalizedString(@"OPEN until"),[storeLocation objectForKey:@"saturday_close"]];
            }else{
                status = SCLocalizedString(@"Not opening");
            }
            break;
        default:
            if([[storeLocation objectForKey:@"sunday_status"] boolValue]){
                status = [NSString stringWithFormat:@"%@ %@",SCLocalizedString(@"OPEN until"),[storeLocation objectForKey:@"sunday_close"]];
            }else{
                status = SCLocalizedString(@"Not opening");
            }
            break;
    }
    frame = openHourLabel.frame;
    frame.origin.y = addressLabel.frame.origin.y + addressLabel.frame.size.height;
    openHourLabel.frame = frame;
    openHourLabel.text = status;
    frame = callButton.frame;
    frame.origin.y = openHourLabel.frame.origin.y + openHourLabel.frame.size.height + 5;
    callButton.frame = frame;
}

- (void)callStore:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:TRACKINGEVENT object:@"store_locator_action" userInfo:@{@"action":@"call_to_store",@"store_name":[self.storeLocation valueForKey:@"name"]}];
    NSString *phoneNumber = [[NSString stringWithFormat:@"%@",[_storeLocation objectForKey:@"phone"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phoneNumber]];
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    }
}

@end
