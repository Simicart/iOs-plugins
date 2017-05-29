//
//  SCBlueberryStoreLocationDetailViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 5/26/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCBlueberryStoreLocationDetailViewController.h"
#import "SimiTable.h"

#define STORELOCATION_DETAIL @"STORELOCATION_DETAIL"
#define STORELOCATION_DETAIL_MAP @"STORELOCATION_DETAIL_MAP"
#define STORELOCATION_DETAIL_INFO @"STORELOCATION_DETAIL_INFO"
#define STORELOCATION_DETAIL_DIRECTIONS @"STORELOCATION_DETAIL_DIRECTIONS"
#define STORELOCATION_DETAIL_PHONE @"STORELOCATION_DETAIL_PHONE"
#define STORELOCATION_DETAIL_EMAIL @"STORELOCATION_DETAIL_EMAIL"
#define STORELOCATION_HOURS @"STORELOCATION_HOURS"
#define STORELOCATION_ABOUT @"STORELOCATION_ABOUT"

@interface SCBlueberryStoreLocationDetailViewController ()

@end

@implementation SCBlueberryStoreLocationDetailViewController{
    UITableView* storeDetailTableView;
    SimiTable* cells;
}
- (void)viewDidLoadBefore {
    self.navigationItem.title = SCLocalizedString([_storeLocation objectForKey:@"name"]);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"Done") style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    storeDetailTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];
    storeDetailTableView.delegate = self;
    storeDetailTableView.dataSource = self;
    [self.view addSubview:storeDetailTableView];
    storeDetailTableView.tableFooterView = [UIView new];
    
    UIImageView* storeImageView = [[UIImageView alloc] initWithFrame:ScaleFrame(CGRectMake(15, 108, 64, 64))];
    [storeImageView sd_setImageWithURL:[NSURL URLWithString:[_storeLocation objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"image_placeholder"]];
    storeImageView.contentMode = UIViewContentModeScaleAspectFill;
    storeImageView.layer.cornerRadius = 10;
    [storeImageView.layer setMasksToBounds:YES];
    [storeDetailTableView addSubview:storeImageView];
    
    [self initCells];
}

- (void)viewWillAppearBefore:(BOOL)animated{
}

- (void)done:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initCells{
    cells = [SimiTable new];
    SimiSection* storeAddressSection = [cells addSectionWithIdentifier:STORELOCATION_DETAIL];
    [storeAddressSection addRowWithIdentifier:STORELOCATION_DETAIL_MAP height:ScaleValue(140)];
    [storeAddressSection addRowWithIdentifier:STORELOCATION_DETAIL_INFO height:ScaleValue(140)];
    [storeAddressSection addRowWithIdentifier:STORELOCATION_DETAIL_DIRECTIONS height:ScaleValue(44)];
    [storeAddressSection addRowWithIdentifier:STORELOCATION_DETAIL_PHONE height:ScaleValue(44)];
    [storeAddressSection addRowWithIdentifier:STORELOCATION_DETAIL_EMAIL height:ScaleValue(44)];
    SimiSection* hourSection = [cells addSectionWithIdentifier:STORELOCATION_HOURS];
    [hourSection addRowWithIdentifier:STORELOCATION_HOURS height:ScaleValue(150)];
    SimiSection* aboutSection = [cells addSectionWithIdentifier:STORELOCATION_ABOUT];
    [aboutSection addRowWithIdentifier:STORELOCATION_ABOUT height:ScaleValue(152)];
    [storeDetailTableView reloadData];
}

#pragma mark UITableViewDelegate && UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SimiSection* storeLocationSection = [cells objectAtIndex:indexPath.section];
    SimiRow* storeLocationRow = [storeLocationSection objectAtIndex:indexPath.row];
    if([storeLocationRow.identifier isEqualToString:STORELOCATION_DETAIL_DIRECTIONS]){
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
            [[UIApplication sharedApplication] openURL:
             [NSURL URLWithString: [NSString stringWithFormat: @"comgooglemaps://?saddr=%f,%f&daddr=%@,%@&center=%f,%f&zoom=15&views=traffic",_currentLatitude , _currentLongitude,[_storeLocation valueForKey:@"latitude"],[_storeLocation valueForKey:@"longtitude"],_currentLatitude, _currentLongitude]]];
        } else {
            [self showAlertWithTitle:@"" message:@"Please install Google Map for getting directions"];
        }
    }else if([storeLocationRow.identifier isEqualToString:STORELOCATION_DETAIL_PHONE]){
        NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",[_storeLocation objectForKey:@"phone"]]];
        if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
            [[UIApplication sharedApplication] openURL:phoneUrl];
        }else{
            [self showToastMessage:@"Phone number is not available"];
        }

    }else if([storeLocationRow.identifier isEqualToString:STORELOCATION_DETAIL_EMAIL]){
        NSURL *mailUrl = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@",[_storeLocation objectForKey:@"email"]]];
        if ([[UIApplication sharedApplication] canOpenURL:mailUrl]) {
            [[UIApplication sharedApplication] openURL:mailUrl];
        }else{
            [self showToastMessage:@"Email address is not available"];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SimiSection* storeDetailSection = [cells objectAtIndex:section];
    return storeDetailSection.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return cells.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection* storeDetailSection = [cells objectAtIndex:indexPath.section];
    SimiRow* storeDetailRow = [storeDetailSection objectAtIndex:indexPath.row];
    return storeDetailRow.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    SimiSection* storeLocationSection = [cells objectAtIndex:section];
    if([storeLocationSection.identifier isEqualToString:STORELOCATION_DETAIL]){
        return 0.0000001;
    }
    return ScaleValue(20);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* headerView = [[UIView alloc] initWithFrame:ScaleFrame(CGRectMake(0, 0, 320, 20))];
    headerView.backgroundColor = COLOR_WITH_HEX(@"#f8f8f8");
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection* section = [cells objectAtIndex:indexPath.section];
    SimiRow* row = [section objectAtIndex:indexPath.row];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:row.identifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if([row.identifier isEqualToString:STORELOCATION_DETAIL_MAP]){
            UIImageView* mapImageView = [[UIImageView alloc] initWithFrame:ScaleFrame(CGRectMake(0, 0, 320, 140))];
            mapImageView.contentMode = UIViewContentModeScaleToFill;
            NSString* mapImageURLString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?markers=icon:http://dev-magento19.jajahub.com/ic_pin.png|%@,%@&zoom=15&size=%dx%d&maptype=roadmap&sensor=false&key=AIzaSyDhu7FvcqOoX1OfzkauMhFNuKBM2aKI78k",[_storeLocation objectForKey:@"latitude"],[_storeLocation objectForKey:@"longtitude"],(int)ScaleValue(320),(int)ScaleValue(140)];
            NSURL* mapImageURL = [NSURL URLWithString:[mapImageURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            if(mapImageURL){
                [mapImageView sd_setImageWithURL:mapImageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if(error)
                        NSLog(@"%@",error);
                }];
            }
            [cell addSubview:mapImageView];

        }else if([row.identifier isEqualToString:STORELOCATION_DETAIL_INFO]){
            SCBlueberryLabel* distanceLabel = [[SCBlueberryLabel alloc] initWithFrame:ScaleFrame(CGRectMake(15, 32, 64, 30)) andFont:RegularWithSize(14) opacity:0.48f andTextColor:[UIColor blackColor]];
            distanceLabel.text = distanceLabel.text = [NSString stringWithFormat:@"%@ km",[[SimiFormatter sharedInstance] formatFloatNumber:[[_storeLocation objectForKey:@"distance"] floatValue]/1000.0f maxDecimals:2 minDecimals:0]];;
            [distanceLabel resizLabelToFit];
            [cell addSubview:distanceLabel];
            SCBlueberryLabel* storeNameLabel = [[SCBlueberryLabel alloc] initWithFrame:ScaleFrame(CGRectMake(94, 15, 320 - 94 - 15, 25)) andFont:RegularWithSize(20) opacity:1 andTextColor:[UIColor blackColor]];
            storeNameLabel.text = [_storeLocation objectForKey:@"name"];
            [cell addSubview:storeNameLabel];
            [storeNameLabel resizLabelToFit];
            SCBlueberryLabel* addressLabel = [[SCBlueberryLabel alloc] initWithFrame:CGRectMake(ScaleValue(94), storeNameLabel.frame.origin.y + storeNameLabel.frame.size.height, ScaleValue(211), 25) andFont:RegularWithSize(14) opacity:0.5f andTextColor:[UIColor blackColor]];
            addressLabel.text = [_storeLocation objectForKey:@"address"];
            [cell addSubview:addressLabel];
            [addressLabel resizLabelToFit];
            SCBlueberryLabel* hourLabel = [[SCBlueberryLabel alloc] initWithFrame:CGRectMake(ScaleValue(94), addressLabel.frame.origin.y + addressLabel.frame.size.height, ScaleValue(211), 25) andFont:RegularWithSize(14) opacity:0.5f andTextColor:[UIColor blackColor]];
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
            NSString* status = @"";
            switch (components.weekday) {
                case 2://Mon
                    if([[_storeLocation objectForKey:@"monday_status"] boolValue]){
                        status = [NSString stringWithFormat:@"%@ %@",SCLocalizedString(@"OPEN until"),[_storeLocation objectForKey:@"monday_close"]];
                    }else{
                        status = SCLocalizedString(@"Not opening");
                    }
                    break;
                case 3:
                    if([[_storeLocation objectForKey:@"tuesday_status"] boolValue]){
                        status = [NSString stringWithFormat:@"%@ %@",SCLocalizedString(@"OPEN until"),[_storeLocation objectForKey:@"tuesday_close"]];
                    }else{
                        status = SCLocalizedString(@"Not opening");
                    }
                    break;
                case 4:
                    if([[_storeLocation objectForKey:@"wednesday_status"] boolValue]){
                        status = [NSString stringWithFormat:@"%@ %@",SCLocalizedString(@"OPEN until"),[_storeLocation objectForKey:@"wednesday_close"]];
                    }else{
                        status = SCLocalizedString(@"Not opening");
                    }
                    break;
                case 5:
                    if([[_storeLocation objectForKey:@"thursday_status"] boolValue]){
                        status = [NSString stringWithFormat:@"%@ %@",SCLocalizedString(@"OPEN until"),[_storeLocation objectForKey:@"thursday_close"]];
                    }else{
                        status = SCLocalizedString(@"Not opening");
                    }
                    break;
                case 6:
                    if([[_storeLocation objectForKey:@"friday_status"] boolValue]){
                        status = [NSString stringWithFormat:@"%@ %@",SCLocalizedString(@"OPEN until"),[_storeLocation objectForKey:@"friday_close"]];
                    }else{
                        status = SCLocalizedString(@"Not opening");
                    }
                    break;
                case 7:
                    if([[_storeLocation objectForKey:@"saturday_status"] boolValue]){
                        status = [NSString stringWithFormat:@"%@ %@",SCLocalizedString(@"OPEN until"),[_storeLocation objectForKey:@"saturday_close"]];
                    }else{
                        status = SCLocalizedString(@"Not opening");
                    }
                    break;
                default:
                    if([[_storeLocation objectForKey:@"sunday_status"] boolValue]){
                        status = [NSString stringWithFormat:@"%@ %@",SCLocalizedString(@"OPEN until"),[_storeLocation objectForKey:@"sunday_close"]];
                    }else{
                        status = SCLocalizedString(@"Not opening");
                    }
                    break;
            }
            hourLabel.text = status;
            [hourLabel resizLabelToFit];
            [cell addSubview:hourLabel];
        }else if([row.identifier isEqualToString:STORELOCATION_DETAIL_PHONE]){
            cell.textLabel.text = [_storeLocation objectForKey:@"phone"];
            cell.textLabel.font = RegularWithSize(18);
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_call"]];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }else if([row.identifier isEqualToString:STORELOCATION_DETAIL_DIRECTIONS]){
            cell.textLabel.text = SCLocalizedString(@"Get directions");
            cell.textLabel.font = RegularWithSize(18);
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_direction"]];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }else if([row.identifier isEqualToString:STORELOCATION_DETAIL_EMAIL]){
            cell.textLabel.text = SCLocalizedString(@"Send email");
            cell.textLabel.font = RegularWithSize(18);
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_mail"]];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }else if([row.identifier isEqualToString:STORELOCATION_HOURS]){
            UIImageView* hourImageView = [[UIImageView alloc] initWithFrame:ScaleFrame(CGRectMake(15, 15, 32, 32))];
            hourImageView.image = [UIImage imageNamed:@"ic_hour"];
            [cell addSubview:hourImageView];
            SCBlueberryLabel* titleLabel = [[SCBlueberryLabel alloc] initWithFrame:ScaleFrame(CGRectMake(57, 15, 248, 32)) andFont:RegularWithSize(18) opacity:1 andTextColor:[UIColor blackColor]];
            titleLabel.text = SCLocalizedString(@"Store hours");
            [cell addSubview:titleLabel];
            
            SCBlueberryLabel* normalDayHoursTitleLabel = [[SCBlueberryLabel alloc] initWithFrame:ScaleFrame(CGRectMake(57, 50, 124, 25)) andFont:RegularWithSize(16) opacity:1 andTextColor:[UIColor blackColor]];
            normalDayHoursTitleLabel.text = @"Monday - Friday";
            [cell addSubview:normalDayHoursTitleLabel];
            SCBlueberryLabel* normalDayHoursLabel = [[SCBlueberryLabel alloc] initWithFrame:ScaleFrame(CGRectMake(181, 50, 124, 25)) andFont:RegularWithSize(16) opacity:1 andTextColor:[UIColor blackColor]];
            normalDayHoursLabel.text = [NSString stringWithFormat:@"%@ - %@",[_storeLocation objectForKey:@"monday_open"],[_storeLocation objectForKey:@"monday_close"]];
            [cell addSubview:normalDayHoursLabel];
            normalDayHoursLabel.textAlignment = NSTextAlignmentRight;
            
            SCBlueberryLabel* saturdayHoursTitleLabel = [[SCBlueberryLabel alloc] initWithFrame:ScaleFrame(CGRectMake(57, 75, 124, 25)) andFont:RegularWithSize(16) opacity:1 andTextColor:[UIColor blackColor]];
            saturdayHoursTitleLabel.text = @"Saturday";
            [cell addSubview:saturdayHoursTitleLabel];
            SCBlueberryLabel* saturdayHoursLabel = [[SCBlueberryLabel alloc] initWithFrame:ScaleFrame(CGRectMake(181, 75, 124, 25)) andFont:RegularWithSize(16) opacity:1 andTextColor:[UIColor blackColor]];
            saturdayHoursLabel.text = [NSString stringWithFormat:@"%@ - %@",[_storeLocation objectForKey:@"saturday_open"],[_storeLocation objectForKey:@"saturday_close"]];
            [cell addSubview:saturdayHoursLabel];
            saturdayHoursLabel.textAlignment = NSTextAlignmentRight;
            
            SCBlueberryLabel* sundayHoursTitleLabel = [[SCBlueberryLabel alloc] initWithFrame:ScaleFrame(CGRectMake(57, 100, 100, 25)) andFont:RegularWithSize(16) opacity:1 andTextColor:[UIColor blackColor]];
            sundayHoursTitleLabel.text = @"Sunday";
            [cell addSubview:sundayHoursTitleLabel];
            SCBlueberryLabel* sundayHoursLabel = [[SCBlueberryLabel alloc] initWithFrame:ScaleFrame(CGRectMake(181, 100, 124, 25)) andFont:RegularWithSize(16) opacity:1 andTextColor:[UIColor blackColor]];
            sundayHoursLabel.text = [NSString stringWithFormat:@"%@ - %@",[_storeLocation objectForKey:@"sunday_open"],[_storeLocation objectForKey:@"sunday_close"]];
            sundayHoursLabel.textAlignment = NSTextAlignmentRight;
            [cell addSubview:sundayHoursLabel];

        }else if([row.identifier isEqualToString:STORELOCATION_ABOUT]){
            UIImageView* aboutImageView = [[UIImageView alloc] initWithFrame:ScaleFrame(CGRectMake(15, 15, 32, 32))];
            aboutImageView.image = [UIImage imageNamed:@"ic_about"];
            [cell addSubview:aboutImageView];
            SCBlueberryLabel* titleLabel = [[SCBlueberryLabel alloc] initWithFrame:ScaleFrame(CGRectMake(57, 15, 248, 32)) andFont:RegularWithSize(18) opacity:1 andTextColor:[UIColor blackColor]];
            titleLabel.text = SCLocalizedString(@"About");
            [cell addSubview:titleLabel];
            UITextView* aboutTextView = [[UITextView alloc] initWithFrame:ScaleFrame(CGRectMake(57, 50, 248, 152 - 15 - 50))];
            aboutTextView.editable = NO;
            aboutTextView.font = RegularWithSize(16);
            aboutTextView.text = [_storeLocation objectForKey:@"description"];
            [cell addSubview:aboutTextView];
        }
        cell.preservesSuperviewLayoutMargins = NO;
        cell.separatorInset = UIEdgeInsetsZero;
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
