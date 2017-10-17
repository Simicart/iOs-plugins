//
//  SCEmailContactViewController.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 10/15/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCEmailContactViewController.h"

@interface SCEmailContactViewController ()

@end

@implementation SCEmailContactViewController
{
    NSString *stringPhoneNumber;
    NSMutableArray *arrayPhoneNumber;
    NSMutableArray *arrayPhoneNumberAfterCheck;
    NSMutableArray *arrayMessageNumber;
    NSMutableArray *arrayMessageNumberAfterCheck;
    NSMutableArray *arrayEmail;
    NSMutableArray *arrayEmailCheck;
    NSString *stringWebsite;
    NSString *stringStyle;
    NSString *stringColor;
    
    float itemWidth;
    float itemHeight;
}

- (void)viewDidLoadBefore {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewDidLoadBefore];
    }
    self.navigationItem.title = SCLocalizedString(@"Contact Us");
    self.screenTrackingName = @"contact_us";
    self.eventTrackingName = @"contact_us_action";
    _contactModel = [[SimiModel alloc] initWithModelData:[GLOBALVAR.storeView valueForKey:@"instant_contact"]];
    if ([[_contactModel valueForKey:@"phone"] isKindOfClass:[NSArray class]]) {
        arrayPhoneNumber = [[NSMutableArray alloc]initWithArray:[_contactModel valueForKey:@"phone"]];
        arrayPhoneNumberAfterCheck = [[NSMutableArray alloc]init];
        for (int i = 0; i < arrayPhoneNumber.count; i++) {
            NSString *stringPhone = [NSString stringWithFormat:@"%@",[arrayPhoneNumber objectAtIndex:i]];
            stringPhone = [stringPhone stringByReplacingOccurrencesOfString:@" " withString:@""];
            if (![stringPhone isEqualToString:@""]) {
                [arrayPhoneNumberAfterCheck addObject:stringPhone];
            }
        }
    }
    
    if ([[_contactModel valueForKey:@"message"]isKindOfClass:[NSArray class]]) {
        arrayMessageNumber = [[NSMutableArray alloc]initWithArray:[_contactModel valueForKey:@"message"]];
        arrayMessageNumberAfterCheck = [[NSMutableArray alloc]init];
        for (int i = 0; i < arrayMessageNumber.count; i++) {
            NSString *stringPhone = [NSString stringWithFormat:@"%@",[arrayMessageNumber objectAtIndex:i]];
            stringPhone = [stringPhone stringByReplacingOccurrencesOfString:@" " withString:@""];
            if (![stringPhone isEqualToString:@""]) {
                [arrayMessageNumberAfterCheck addObject:stringPhone];
            }
        }
    }
    
    
    if ([_contactModel valueForKey:@"email"]) {
        arrayEmail = [[NSMutableArray alloc]initWithArray:[_contactModel valueForKey:@"email"]];
        arrayEmailCheck = [[NSMutableArray alloc]init];
        for (int i = 0; i < arrayEmail.count; i++) {
            NSString *stringEmail = [NSString stringWithFormat:@"%@", [arrayEmail objectAtIndex:i]];
            stringEmail = [stringEmail stringByReplacingOccurrencesOfString:@" " withString:@""];
            if (![stringEmail isEqualToString:@""]) {
                [arrayEmailCheck addObject:stringEmail];
            }
        }
    }
    
    if ([_contactModel valueForKey:@"website"]) {
        stringWebsite = [NSString stringWithFormat:@"%@",[_contactModel valueForKey:@"website"]];
        stringWebsite = [stringWebsite stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    if ([_contactModel valueForKey:@"style"]) {
        stringStyle = [NSString stringWithFormat:@"%@",[_contactModel valueForKey:@"style"]];
    }else
    {
        stringStyle = @"0";
    }
    
    if ([_contactModel valueForKey:@"activecolor"]) {
        if([stringColor containsString:@"#"])
            stringColor = [NSString stringWithFormat:@"%@",[_contactModel valueForKey:@"activecolor"]];
        else
            stringColor = [NSString stringWithFormat:@"#%@",[_contactModel valueForKey:@"activecolor"]];
        stringColor = [stringColor stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    [self setCells:nil];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewWillAppearBefore:YES];
    }
    itemWidth = SCALEVALUE(120);
    itemHeight = SCALEVALUE(100);
}

- (void)viewDidAppearBefore:(BOOL)animated
{
    if (_tblViewContent == nil && _contactCollectionView == nil) {        
        if ([stringStyle isEqualToString:@"0"]) {
            _tblViewContent = [[UITableView alloc]initWithFrame:self.view.bounds];
            [_tblViewContent setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
            _tblViewContent.dataSource = self;
            _tblViewContent.delegate = self;
            [self.view addSubview:_tblViewContent];
            [_tblViewContent reloadData];
        }else
        {
            UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
            flowLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
            flowLayout.minimumLineSpacing =  SCALEVALUE(20);
            flowLayout.minimumInteritemSpacing = SCALEVALUE(20);
            _contactCollectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
            [_contactCollectionView setBackgroundColor:[UIColor whiteColor]];
            _contactCollectionView.contentInset = UIEdgeInsetsMake(SCALEVALUE(40), SCALEVALUE(20), 0, SCALEVALUE(20));
            _contactCollectionView.delegate = self;
            _contactCollectionView.dataSource = self;
            [self.view addSubview:_contactCollectionView];
        }
    }
}

#pragma mark Action
- (void)btnCallClick
{
    [self trackingWithProperties:@{@"action":@"selected_contact_by_call"}];
    if (arrayPhoneNumberAfterCheck.count == 1) {
        stringPhoneNumber = [arrayPhoneNumberAfterCheck objectAtIndex:0];
        [self call];
    }else
    {
        _isCall = YES;
        SCListPhoneViewController *listPhoneViewController = [[SCListPhoneViewController alloc]init];
        listPhoneViewController.arrayPhone = [arrayPhoneNumberAfterCheck mutableCopy];
        listPhoneViewController.delegate = self;
        [self.navigationController pushViewController:listPhoneViewController animated:YES];
    }
}

- (void)call
{
    NSString *phNo = [NSString  stringWithFormat:@"telprompt:%@",stringPhoneNumber];
    NSURL *phoneUrl = [[NSURL alloc]initWithString:[phNo stringByReplacingOccurrencesOfString:@" " withString:@""]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        [self showAlertWithTitle:@"Error" message:@"Call facility is not available"];
    }
}

- (void)btnEmailClick
{
    NSString *emailContent = SCLocalizedString(@"");
    [self sendEmailToStoreWithEmail:arrayEmailCheck andEmailContent:emailContent];
    [self trackingWithProperties:@{@"action":@"selected_contact_by_email"}];
}

- (void)btnWebsiteClick
{
    if (!([stringWebsite containsString:@"http://"]||[stringWebsite containsString:@"https://"])) {
        stringWebsite = [NSString stringWithFormat:@"%@%@",@"http://",stringWebsite];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringWebsite]];
    [self trackingWithProperties:@{@"action":@"selected_contact_by_website"}];
}

- (void)btnMessageClick
{
    if (arrayMessageNumberAfterCheck.count == 1) {
        stringPhoneNumber = [arrayMessageNumberAfterCheck objectAtIndex:0];
        [self sendMessage];
    }else
    {
        _isCall = NO;
        SCListPhoneViewController *listPhoneViewController = [[SCListPhoneViewController alloc]init];
        listPhoneViewController.arrayPhone = [arrayMessageNumberAfterCheck mutableCopy];
        listPhoneViewController.delegate = self;
        [self.navigationController pushViewController:listPhoneViewController animated:YES];
    }
    [self trackingWithProperties:@{@"action":@"selected_contact_by_message"}];
}

- (void)sendMessage
{
    NSString *messageContent = @"";
    [self sendMessageToStoreWithPhone:stringPhoneNumber andMessageContent:messageContent];
}

#pragma mark Email Delegate
- (void)sendEmailToStoreWithEmail:(NSMutableArray *)email andEmailContent:(NSString *)emailContent
{
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setToRecipients:arrayEmailCheck];
        
        [controller setSubject:[NSString stringWithFormat:@""]];
        [controller setMessageBody:emailContent isHTML:NO];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [self presentViewController:controller animated:YES completion:NULL];
        }
        else {
            [self presentViewController:controller animated:YES completion:NULL];
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"You haven’t setup email account") message:SCLocalizedString(@"You must go to Settings/ Mail, Contact, Calendars and choose Add Account")
                                                       delegate:self cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    
    if(result==MFMailComposeResultCancelled)
    {
        [controller dismissViewControllerAnimated:YES completion:NULL];
    }
    if(result==MFMailComposeResultSent)
    {
        [self showAlertWithTitle:@"Success" message:@"Your email was sent succesfully"];
        [controller dismissViewControllerAnimated:YES completion:NULL];
    }
    if(result==MFMailComposeResultFailed)
    {
        [self showAlertWithTitle:@"Failed" message:@"Your mail was not sent"];
        [controller dismissViewControllerAnimated:YES completion:NULL];
        
    }
}

#pragma mark Message Delegate
- (void)sendMessageToStoreWithPhone:(NSString *)phone andMessageContent:(NSString *)messageContent
{
    if(![MFMessageComposeViewController canSendText]) {
        [self showAlertWithTitle:@"Error" message:@"Your device doesn't support SMS"];
        return;
    }
    
    NSArray *recipents = @[phone];
    NSString *message = messageContent;
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed:
            break;
        case MessageComposeResultSent:
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Did Get Email Contact
- (void)didGetEmailContact:(NSNotification*)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    if (responder.status == SUCCESS) {
        
        if ([stringStyle isEqualToString:@"1"]) {
            _tblViewContent = [[UITableView alloc]initWithFrame:self.view.bounds];
            [_tblViewContent setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
            _tblViewContent.dataSource = self;
            _tblViewContent.delegate = self;
            [self.view addSubview:_tblViewContent];
            [_tblViewContent reloadData];
        }else
        {
            UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
            flowLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
            flowLayout.minimumLineSpacing =  SCALEVALUE(20);
            flowLayout.minimumInteritemSpacing = SCALEVALUE(20);
            _contactCollectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
            [_contactCollectionView setBackgroundColor:[UIColor whiteColor]];
            _contactCollectionView.contentInset = UIEdgeInsetsMake(SCALEVALUE(40), SCALEVALUE(20), 0, SCALEVALUE(20));
            _contactCollectionView.delegate = self;
            _contactCollectionView.dataSource = self;
            [self.view addSubview:_contactCollectionView];
        }
    }
}

#pragma mark Table View Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"TableViewContact_%ld",indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    if ([simiSection.identifier isEqualToString:EMAILCONTACT_SECTIONMAIN]) {
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"TableViewContact_%ld",indexPath.row]];
            SimiRow *row = [simiSection objectAtIndex:indexPath.row];
            UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
            [imageIcon setImage:[[UIImage imageNamed:[row.data valueForKey:@"image_tbl"]]imageWithColor:COLOR_WITH_HEX(stringColor)]];
            [imageIcon setContentMode:UIViewContentModeScaleAspectFit];
            [cell.contentView addSubview:imageIcon];
            
            UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
            [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
            [lblName setText:SCLocalizedString([row.data valueForKey:@"title"])];
            [cell.contentView addSubview:lblName];
            [SimiGlobalFunction sortViewForRTL:cell.contentView andWidth:CGRectGetWidth(tableView.frame)];
        }
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SimiSection *simiSection = [_cells objectAtIndex:section];
    return simiSection.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
#pragma mark Table View DataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    if ([simiSection.identifier isEqualToString:EMAILCONTACT_SECTIONMAIN]) {
        SimiRow *row = [simiSection objectAtIndex:indexPath.row];
        if ([row.identifier isEqualToString:EMAILCONTACT_ROWEMAIL]) {
            [self btnEmailClick];
        }
        
        if ([row.identifier isEqualToString:EMAILCONTACT_ROWCALL]) {
            [self btnCallClick];
        }
        
        if ([row.identifier isEqualToString:EMAILCONTACT_ROWMESSAGE]) {
            [self btnMessageClick];
        }
        
        if ([row.identifier isEqualToString:EMAILCONTACT_ROWWEBSITE]) {
            [self btnWebsiteClick];
        }
    }
}
#pragma mark CollectionView Delegate & DataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *row = [simiSection objectAtIndex:indexPath.row];
    [collectionView registerClass:[ContactCollectionViewCell class] forCellWithReuseIdentifier:row.identifier];
    ContactCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:row.identifier forIndexPath:indexPath];
    
    float imageSize = 70;
    cell.imageView = [[UIImageView alloc]initWithFrame:CGRectMake((itemWidth - imageSize)/2, 0, imageSize, imageSize)];
    [cell.imageView setImage:[[UIImage imageNamed:[row.data valueForKey:@"image_collectionview"]]imageWithColor:COLOR_WITH_HEX(stringColor)]];
    [cell addSubview:cell.imageView];
    
    cell.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, imageSize, itemWidth, itemHeight - imageSize)];
    [cell.titleLabel setText:SCLocalizedString([row.data valueForKey:@"title"])];
    [cell.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:16]];
    [cell.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [cell addSubview:cell.titleLabel];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    SimiSection *simiSection = [_cells objectAtIndex:section];
    return simiSection.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    if ([simiSection.identifier isEqualToString:EMAILCONTACT_SECTIONMAIN]) {
        SimiRow *row = [simiSection objectAtIndex:indexPath.row];
        if ([row.identifier isEqualToString:EMAILCONTACT_ROWEMAIL]) {
            [self btnEmailClick];
        }
        
        if ([row.identifier isEqualToString:EMAILCONTACT_ROWCALL]) {
            [self btnCallClick];
        }
        
        if ([row.identifier isEqualToString:EMAILCONTACT_ROWMESSAGE]) {
            [self btnMessageClick];
        }
        
        if ([row.identifier isEqualToString:EMAILCONTACT_ROWWEBSITE]) {
            [self btnWebsiteClick];
        }
    }
}

#pragma mark ListPhone Delegate

- (void)didSelectPhoneNumber:(NSString *)stringPhone
{
    stringPhoneNumber = stringPhone;
    if (_isCall) {
        [self call];
    }else
    {
        [self sendMessage];
    }
}

#pragma mark set Table

- (void)setCells:(SimiTable *)cells_
{
    if (cells_) {
        _cells = cells_;
    }else
    {
        _cells = [SimiTable new];
        SimiSection *section = [[SimiSection alloc]initWithIdentifier:EMAILCONTACT_SECTIONMAIN];
        
        if (arrayEmailCheck.count > 0) {
            SimiRow *rowEmail = [SimiRow new];
            rowEmail.identifier = EMAILCONTACT_ROWEMAIL;
            rowEmail.data = [[NSMutableDictionary alloc]initWithDictionary:@{@"title":@"Email",@"image_tbl":@"contactusemail_tbl",@"image_collectionview":@"contactus_email"}];
            [section addRow:rowEmail];
        }
        
        if (arrayPhoneNumberAfterCheck.count > 0 && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            SimiRow *rowCall = [SimiRow new];
            rowCall.identifier = EMAILCONTACT_ROWCALL;
            rowCall.data = [[NSMutableDictionary alloc]initWithDictionary:@{@"title":@"Call",@"image_tbl":@"contactusphone_tbl",@"image_collectionview":@"contactus_call"}];
            [section addRow:rowCall];
        }
        
        if (arrayMessageNumberAfterCheck.count > 0) {
            SimiRow *rowMessage = [SimiRow new];
            rowMessage.identifier = EMAILCONTACT_ROWMESSAGE;
            rowMessage.data = [[NSMutableDictionary alloc]initWithDictionary:@{@"title":@"Message",@"image_tbl":@"contactusmessage_tbl",@"image_collectionview":@"contactus_message"}];
            [section addRow:rowMessage];
        }
        
        if (![stringWebsite isEqualToString:@""]) {
            SimiRow *rowWebsite = [SimiRow new];
            rowWebsite.identifier = EMAILCONTACT_ROWWEBSITE;
            rowWebsite.data = [[NSMutableDictionary alloc]initWithDictionary:@{@"title":@"Website",@"image_tbl":@"contactusweb_tbl",@"image_collectionview":@"contactus_web"}];
            [section addRow:rowWebsite];
        }
        [_cells addObject:section];
    }
}
@end

@implementation ContactCollectionViewCell
@end
