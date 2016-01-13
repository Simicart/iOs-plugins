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
    //  Liam ADD 150416
    NSMutableArray *arrayMessageNumber;
    NSMutableArray *arrayMessageNumberAfterCheck;
    //  End 150416
    NSMutableArray *arrayEmail;
    NSMutableArray *arrayEmailCheck;
    NSString *stringWebsite;
    NSString *stringStyle;
    NSString *stringColor;
    UIActivityIndicatorView *indicatorView;
    BOOL isFirstLoad;
    int numberItemPhone;
    int numberItemPad;
}

- (void)viewDidLoad {
    isFirstLoad = YES;
    [super viewDidLoad];
    self.navigationItem.title = SCLocalizedString(@"Contact Us");
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    if (isFirstLoad) {
        isFirstLoad = NO;
        indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [indicatorView setFrame:self.view.bounds];
        [self.view addSubview:indicatorView];
        indicatorView.hidesWhenStopped = YES;
        [indicatorView startAnimating];
        
        _contactModel = [[SCEmailContactModel alloc]init];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetEmailContact:) name:@"DidGetEmailContactConfig" object:_contactModel];
        [_contactModel getEmailContactWithParams:@{}];
    }
}

#pragma mark Action
- (void)btnCallClick
{
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
        UIAlertView* calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:SCLocalizedString(@"Call facility is not available!!!") delegate:nil cancelButtonTitle:SCLocalizedString(@"Ok") otherButtonTitles:nil, nil];
        [calert show];
    }
}

- (void)btnEmailClick
{
    NSString *emailContent = SCLocalizedString(@"");
    [self sendEmailToStoreWithEmail:arrayEmailCheck andEmailContent:emailContent];
}

- (void)btnWebsiteClick
{
    if (!([stringWebsite containsString:@"http://"]||[stringWebsite containsString:@"https://"])) {
        stringWebsite = [NSString stringWithFormat:@"%@%@",@"http://",stringWebsite];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringWebsite]];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"You haven’t setup email account") message:SCLocalizedString(@"You must go to Settings/ Mail, Contact, Calendars and choose Add Account.")
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
    {  UIAlertView *sent=[[UIAlertView alloc]initWithTitle:SCLocalizedString(@"Your Email was sent succesfully.") message:nil delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil];
        [sent show];
        [controller dismissViewControllerAnimated:YES completion:NULL];
    }
    if(result==MFMailComposeResultFailed)
    {UIAlertView *sent=[[UIAlertView alloc]initWithTitle:SCLocalizedString(@"Failed") message:SCLocalizedString(@"Your mail was not sent") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil];
        [sent show];
        
        [controller dismissViewControllerAnimated:YES completion:NULL];
        
    }
}

#pragma mark Message Delegate
- (void)sendMessageToStoreWithPhone:(NSString *)phone andMessageContent:(NSString *)messageContent
{
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
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
        {
//            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [warningAlert show];
        }
            break;
            
        case MessageComposeResultSent:
        {
//            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Send message success" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [warningAlert show];
        }
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Did Get Email Contact
- (void)didGetEmailContact:(NSNotification*)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([[responder.status uppercaseString]isEqualToString:@"SUCCESS"]) {
        [indicatorView stopAnimating];
        if ([_contactModel valueForKey:@"phone"]) {
            arrayPhoneNumber = (NSMutableArray *)[_contactModel valueForKey:@"phone"];
            arrayPhoneNumberAfterCheck = [[NSMutableArray alloc]init];
            for (int i = 0; i < arrayPhoneNumber.count; i++) {
                NSString *stringPhone = [NSString stringWithFormat:@"%@",[arrayPhoneNumber objectAtIndex:i]];
                stringPhone = [stringPhone stringByReplacingOccurrencesOfString:@" " withString:@""];
                if (![stringPhone isEqualToString:@""]) {
                    [arrayPhoneNumberAfterCheck addObject:stringPhone];
                }
            }
            if (arrayPhoneNumberAfterCheck.count > 0) {
                numberItemPhone += 1;
            }
        }
        
        // Liam ADD 150416
        if ([_contactModel valueForKey:@"message"]) {
            arrayMessageNumber = (NSMutableArray *)[_contactModel valueForKey:@"message"];
            arrayMessageNumberAfterCheck = [[NSMutableArray alloc]init];
            for (int i = 0; i < arrayMessageNumber.count; i++) {
                NSString *stringPhone = [NSString stringWithFormat:@"%@",[arrayMessageNumber objectAtIndex:i]];
                stringPhone = [stringPhone stringByReplacingOccurrencesOfString:@" " withString:@""];
                if (![stringPhone isEqualToString:@""]) {
                    [arrayMessageNumberAfterCheck addObject:stringPhone];
                }
            }
            if (arrayMessageNumberAfterCheck.count > 0) {
                numberItemPhone += 1;
                numberItemPad += 1;
            }
        }
        
        //End 150416
        
        if ([_contactModel valueForKey:@"email"]) {
            arrayEmail = (NSMutableArray*)[_contactModel valueForKey:@"email"];
            arrayEmailCheck = [[NSMutableArray alloc]init];
            for (int i = 0; i < arrayEmail.count; i++) {
                NSString *stringEmail = [NSString stringWithFormat:@"%@", [arrayEmail objectAtIndex:i]];
                stringEmail = [stringEmail stringByReplacingOccurrencesOfString:@" " withString:@""];
                if (![stringEmail isEqualToString:@""]) {
                    [arrayEmailCheck addObject:stringEmail];
                }
            }
            if (arrayEmailCheck.count > 0) {
                numberItemPhone += 1;
                numberItemPad += 1;
            }
        }
        
        if ([_contactModel valueForKey:@"website"]) {
            stringWebsite = [NSString stringWithFormat:@"%@",[_contactModel valueForKey:@"website"]];
            stringWebsite = [stringWebsite stringByReplacingOccurrencesOfString:@" " withString:@""];
            if (![stringWebsite isEqualToString:@""]) {
                numberItemPhone += 1;
                numberItemPad += 1;
            }
        }
        
        if ([_contactModel valueForKey:@"style"]) {
            stringStyle = [NSString stringWithFormat:@"%@",[_contactModel valueForKey:@"style"]];
        }else
        {
            stringStyle = @"1";
        }
        
        if ([_contactModel valueForKey:@"activecolor"]) {
            stringColor = [NSString stringWithFormat:@"%@",[_contactModel valueForKey:@"activecolor"]];
            stringColor = [stringColor stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
        
        if ([stringStyle isEqualToString:@"1"]) {
            _tblViewContent = [[UITableView alloc]initWithFrame:self.view.bounds];
            [_tblViewContent setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
            _tblViewContent.dataSource = self;
            _tblViewContent.delegate = self;
            [self.view addSubview:_tblViewContent];
            [self setCells:nil];
            [_tblViewContent reloadData];
            
        }else
        {
            _btnCall = [[UIButton alloc]init];
            [_btnCall addTarget:self action:@selector(btnCallClick) forControlEvents:UIControlEventTouchUpInside];
            [_btnCall setImage:[[UIImage imageNamed:@"contactus_call"]imageWithColor:[self colorWithHexString:stringColor]] forState:UIControlStateNormal];
            
            _lblCall = [[UILabel alloc]init];
            [_lblCall setFont:[UIFont fontWithName:THEME_FONT_NAME size:16]];
            [_lblCall setText:SCLocalizedString(@"Call")];
            [_lblCall setTextAlignment:NSTextAlignmentCenter];
            
            _btnEmail = [[UIButton alloc]init];
            [_btnEmail addTarget:self action:@selector(btnEmailClick) forControlEvents:UIControlEventTouchUpInside];
            [_btnEmail setImage:[[UIImage imageNamed:@"contactus_email"]imageWithColor:[self colorWithHexString:stringColor]] forState:UIControlStateNormal];
            
            _lblEmail = [[UILabel alloc]init];
            [_lblEmail setFont:[UIFont fontWithName:THEME_FONT_NAME size:16]];
            [_lblEmail setText:SCLocalizedString(@"Email")];
            [_lblEmail setTextAlignment:NSTextAlignmentCenter];
            
            _btnWebsite = [[UIButton alloc]init];
            [_btnWebsite addTarget:self action:@selector(btnWebsiteClick) forControlEvents:UIControlEventTouchUpInside];
            [_btnWebsite setImage:[[UIImage imageNamed:@"contactus_web"]imageWithColor:[self colorWithHexString:stringColor]] forState:UIControlStateNormal];
            
            _lblWebsite = [[UILabel alloc]init];
            [_lblWebsite setFont:[UIFont fontWithName:THEME_FONT_NAME size:16]];
            [_lblWebsite setText:SCLocalizedString(@"Website")];
            [_lblWebsite setTextAlignment:NSTextAlignmentCenter];
            
            _btnMessage = [[UIButton alloc]init];
            [_btnMessage addTarget:self action:@selector(btnMessageClick) forControlEvents:UIControlEventTouchUpInside];
            [_btnMessage setImage:[[UIImage imageNamed:@"contactus_message"]imageWithColor:[self colorWithHexString:stringColor]] forState:UIControlStateNormal];
            
            _lblMessage = [[UILabel alloc]init];
            [_lblMessage setFont:[UIFont fontWithName:THEME_FONT_NAME size:16]];
            [_lblMessage setText:SCLocalizedString(@"Message")];
            [_lblMessage setTextAlignment:NSTextAlignmentCenter];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                int configLocationItem = 0;
                if (arrayEmailCheck.count > 0) {
                    configLocationItem += 1;
                    [_btnEmail setFrame:CGRectMake(40, 120, 68, 68)];
                    [_lblEmail setFrame:CGRectMake(10, 188, 128, 30)];
                    
                    [self.view addSubview:_btnEmail];
                    [self.view addSubview:_lblEmail];
                }
                
                if (arrayPhoneNumberAfterCheck.count > 0) {
                    configLocationItem += 1;
                    if (configLocationItem == 2) {
                        [_btnCall setFrame:CGRectMake(210, 120, 68, 68)];
                        [_lblCall setFrame:CGRectMake(180, 188, 128, 30)];
                    }else if(configLocationItem == 1)
                    {
                        [_btnCall setFrame:CGRectMake(40, 120, 68, 68)];
                        [_lblCall setFrame:CGRectMake(10, 188, 128, 30)];
                    }
                    
                    [self.view addSubview:_btnCall];
                    [self.view addSubview:_lblCall];
                }
                
                if (arrayMessageNumberAfterCheck.count > 0) {
                    configLocationItem += 1;
                    if (configLocationItem == 3) {
                        [_btnMessage setFrame:CGRectMake(40, 260, 68, 68)];
                        [_lblMessage setFrame:CGRectMake(10, 328, 128, 30)];
                    }else if(configLocationItem == 2)
                    {
                        [_btnMessage setFrame:CGRectMake(210, 120, 68, 68)];
                        [_lblMessage setFrame:CGRectMake(180, 188, 128, 30)];
                    }else if(configLocationItem == 1)
                    {
                        [_btnEmail setFrame:CGRectMake(40, 120, 68, 68)];
                        [_lblEmail setFrame:CGRectMake(10, 188, 128, 30)];
                    }
                    [self.view addSubview:_btnMessage];
                    [self.view addSubview:_lblMessage];
                }
                
                if (![stringWebsite isEqualToString:@""]) {
                    configLocationItem +=1;
                    switch (configLocationItem) {
                        case 1:
                            [_btnWebsite setFrame:CGRectMake(40, 120, 68, 68)];
                            [_lblWebsite setFrame:CGRectMake(10, 188, 128, 30)];
                            break;
                        case 2:
                            [_btnWebsite setFrame:CGRectMake(210, 120, 68, 68)];
                            [_lblWebsite setFrame:CGRectMake(180, 188, 128, 30)];
                            break;
                        case 3:
                            [_btnWebsite setFrame:CGRectMake(40, 260, 68, 68)];
                            [_lblWebsite setFrame:CGRectMake(10, 328, 128, 30)];
                            break;
                        case 4:
                            [_btnWebsite setFrame:CGRectMake(210, 260, 68, 68)];
                            [_lblWebsite setFrame:CGRectMake(180, 328, 128, 30)];
                            break;
                        default:
                            break;
                    }
                    [self.view addSubview:_btnWebsite];
                    [self.view addSubview:_lblWebsite];
                }
            }else
            {
                int configLocationItem = 0;
                if (arrayEmailCheck.count > 0) {
                    configLocationItem += 1;
                    [_btnEmail setFrame:CGRectMake(120, 120, 68, 68)];
                    [_lblEmail setFrame:CGRectMake(90, 188, 128, 30)];
                    
                    [self.view addSubview:_btnEmail];
                    [self.view addSubview:_lblEmail];
                }
                
                if (arrayMessageNumberAfterCheck.count > 0) {
                    configLocationItem +=1;
                    if (configLocationItem == 2) {
                        [_btnMessage setFrame:CGRectMake(450, 120, 68, 68)];
                        [_lblMessage setFrame:CGRectMake(420, 188, 128, 30)];
                    }else if(configLocationItem == 1)
                    {
                        [_btnMessage setFrame:CGRectMake(120, 120, 68, 68)];
                        [_lblMessage setFrame:CGRectMake(90, 188, 128, 30)];
                    }
                    [self.view addSubview:_btnMessage];
                    [self.view addSubview:_lblMessage];
                }
                
                if (![stringWebsite isEqualToString:@""])
                {
                    configLocationItem += 1;
                    switch (configLocationItem) {
                        case 1:
                            [_btnWebsite setFrame:CGRectMake(120, 120, 68, 68)];
                            [_lblWebsite setFrame:CGRectMake(90, 188, 128, 30)];
                            break;
                        case 2:
                            [_btnWebsite setFrame:CGRectMake(450, 120, 68, 68)];
                            [_lblWebsite setFrame:CGRectMake(420, 188, 128, 30)];
                            break;
                        case 3:
                            [_btnWebsite setFrame:CGRectMake(120, 260, 68, 68)];
                            [_lblWebsite setFrame:CGRectMake(90, 328, 128, 30)];
                            break;
                        default:
                            break;
                    }
                    [self.view addSubview:_btnWebsite];
                    [self.view addSubview:_lblWebsite];
                }
            }
        }
    }
}

#pragma mark Table View Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TableViewContact"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    if ([simiSection.identifier isEqualToString:EMAILCONTACT_SECTIONMAIN]) {
        SimiRow *row = [simiSection objectAtIndex:indexPath.row];
        if ([row.identifier isEqualToString:EMAILCONTACT_ROWEMAIL]) {
            UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
            [imageIcon setImage:[[UIImage imageNamed:@"contactusemail_tbl"]imageWithColor:[self colorWithHexString:stringColor]]];
            [cell addSubview:imageIcon];
            
            UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
            [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
            [lblName setText:SCLocalizedString(@"Email")];
            [cell addSubview:lblName];
        }
        
        if ([row.identifier isEqualToString:EMAILCONTACT_ROWCALL]) {
            UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 11, 28 , 28)];
            [imageIcon setImage:[[UIImage imageNamed:@"contactusphone_tbl"]imageWithColor:[self colorWithHexString:stringColor]]];
            [cell addSubview:imageIcon];
            
            UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
            [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
            [lblName setText:SCLocalizedString(@"Call")];
            [cell addSubview:lblName];
        }
        
        if ([row.identifier isEqualToString:EMAILCONTACT_ROWMESSAGE]) {
            UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
            [imageIcon setImage:[[UIImage imageNamed:@"contactusmessage_tbl"]imageWithColor:[self colorWithHexString:stringColor]]];
            [cell addSubview:imageIcon];
            
            UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
            [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
            [lblName setText:SCLocalizedString(@"Message")];
            [cell addSubview:lblName];
        }
        
        if ([row.identifier isEqualToString:EMAILCONTACT_ROWWEBSITE]) {
            UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
            [imageIcon setImage:[[UIImage imageNamed:@"contactusweb_tbl"]imageWithColor:[self colorWithHexString:stringColor]]];
            [cell addSubview:imageIcon];
            
            UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
            [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
            [lblName setText:SCLocalizedString(@"Website")];
            [cell addSubview:lblName];
        }
    }
    /*
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        switch (indexPath.row) {
            case 0:
            {
                if (arrayEmailCheck.count > 0) {
                    UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
                    [imageIcon setImage:[[UIImage imageNamed:@"contactusemail_tbl"]imageWithColor:[self colorWithHexString:stringColor]]];
                    [cell addSubview:imageIcon];
                    
                    UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
                    [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
                    [lblName setText:SCLocalizedString(@"Email")];
                    [cell addSubview:lblName];
                }else if(arrayPhoneNumberAfterCheck.count > 0)
                {
                    UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 11, 28 , 28)];
                    [imageIcon setImage:[[UIImage imageNamed:@"contactusphone_tbl"]imageWithColor:[self colorWithHexString:stringColor]]];
                    [cell addSubview:imageIcon];
                    
                    UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
                    [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
                    [lblName setText:SCLocalizedString(@"Call")];
                    [cell addSubview:lblName];
                }else if (arrayMessageNumberAfterCheck.count > 0)
                {
                    UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
                    [imageIcon setImage:[[UIImage imageNamed:@"contactusmessage_tbl"]imageWithColor:[self colorWithHexString:stringColor]]];
                    [cell addSubview:imageIcon];
                    
                    UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
                    [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
                    [lblName setText:SCLocalizedString(@"Message")];
                    [cell addSubview:lblName];
                }
                else if(![stringWebsite isEqualToString:@""])
                {
                    UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
                    [imageIcon setImage:[[UIImage imageNamed:@"contactusweb_tbl"]imageWithColor:[self colorWithHexString:stringColor]]];
                    [cell addSubview:imageIcon];
                    
                    UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
                    [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
                    [lblName setText:SCLocalizedString(@"Website")];
                    [cell addSubview:lblName];
                }
            }
                break;
            case 1:
            {
                if (arrayEmailCheck.count > 0) {
                    if (arrayPhoneNumberAfterCheck.count > 0) {
                        UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 11, 28 , 28)];
                        [imageIcon setImage:[[UIImage imageNamed:@"contactusphone_tbl"]imageWithColor:[self colorWithHexString:stringColor]]];
                        [cell addSubview:imageIcon];
                        
                        UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
                        [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
                        [lblName setText:SCLocalizedString(@"Call")];
                        [cell addSubview:lblName];
                    }else if (arrayMessageNumberAfterCheck.count > 0)
                    {
                        UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
                        [imageIcon setImage:[[UIImage imageNamed:@"contactusmessage_tbl"]imageWithColor:[self colorWithHexString:stringColor]]];
                        [cell addSubview:imageIcon];
                        
                        UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
                        [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
                        [lblName setText:SCLocalizedString(@"Message")];
                        [cell addSubview:lblName];
                    }else if(![stringWebsite isEqualToString:@""])
                    {
                        UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
                        [imageIcon setImage:[[UIImage imageNamed:@"contactusweb_tbl"]imageWithColor:[self colorWithHexString:stringColor]]];
                        [cell addSubview:imageIcon];
                        
                        UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
                        [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
                        [lblName setText:SCLocalizedString(@"Website")];
                        [cell addSubview:lblName];
                    }
                }else
                {
                    if (arrayPhoneNumberAfterCheck.count > 0) {
                        if (arrayMessageNumberAfterCheck.count > 0) {
                            UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
                            [imageIcon setImage:[[UIImage imageNamed:@"contactusmessage_tbl"]imageWithColor:[self colorWithHexString:stringColor]]];
                            [cell addSubview:imageIcon];
                            
                            UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
                            [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
                            [lblName setText:SCLocalizedString(@"Message")];
                            [cell addSubview:lblName];
                        }else if (![stringWebsite isEqualToString:@""])
                        {
                            UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
                            [imageIcon setImage:[[UIImage imageNamed:@"contactusweb_tbl"]imageWithColor:[self colorWithHexString:stringColor]]];
                            [cell addSubview:imageIcon];
                            
                            UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
                            [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
                            [lblName setText:SCLocalizedString(@"Website")];
                            [cell addSubview:lblName];
                        }
                    }else
                    {
                        if (![stringWebsite isEqualToString:@""])
                        {
                            UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
                            [imageIcon setImage:[[UIImage imageNamed:@"contactusweb_tbl"]imageWithColor:[self colorWithHexString:stringColor]]];
                            [cell addSubview:imageIcon];
                            
                            UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
                            [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
                            [lblName setText:SCLocalizedString(@"Website")];
                            [cell addSubview:lblName];
                        }
                    }
                }
            }
                break;
            case 2:
            {
                if (arrayEmailCheck.count > 0) {
                    if (arrayPhoneNumberAfterCheck.count > 0) {
                        if (arrayMessageNumberAfterCheck.count > 0) {
                            UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
                            [imageIcon setImage:[[UIImage imageNamed:@"contactusmessage_tbl"]imageWithColor:[self colorWithHexString:stringColor]]];
                            [cell addSubview:imageIcon];
                            
                            UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
                            [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
                            [lblName setText:SCLocalizedString(@"Message")];
                            [cell addSubview:lblName];
                        }else if (![stringWebsite isEqualToString:@""])
                        {
                            UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
                            [imageIcon setImage:[[UIImage imageNamed:@"contactusweb_tbl"]imageWithColor:[self colorWithHexString:stringColor]]];
                            [cell addSubview:imageIcon];
                            
                            UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
                            [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
                            [lblName setText:SCLocalizedString(@"Website")];
                            [cell addSubview:lblName];
                        }
                    }else if (![stringWebsite isEqualToString:@""])
                    {
                        UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
                        [imageIcon setImage:[[UIImage imageNamed:@"contactusweb_tbl"]imageWithColor:[self colorWithHexString:stringColor]]];
                        [cell addSubview:imageIcon];
                        
                        UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
                        [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
                        [lblName setText:SCLocalizedString(@"Website")];
                        [cell addSubview:lblName];
                    }
                }
            }
                break;
            case 3:
            {
                if (![stringWebsite isEqualToString:@""]) {
                    UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
                    [imageIcon setImage:[[UIImage imageNamed:@"contactusweb_tbl"]imageWithColor:[self colorWithHexString:stringColor]]];
                    [cell addSubview:imageIcon];
                    
                    UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
                    [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
                    [lblName setText:SCLocalizedString(@"Website")];
                    [cell addSubview:lblName];
                }
            }
                break;
            default:
                break;
        }
    }
    else{
        switch (indexPath.row) {
            case 0:
            {
                if (arrayEmailCheck.count > 0) {
                    UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
                    [imageIcon setImage:[[UIImage imageNamed:@"contactusemail_tbl"]imageWithColor:[self colorWithHexString:stringColor]]];
                    [cell addSubview:imageIcon];
                    
                    UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
                    [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
                    [lblName setText:SCLocalizedString(@"Email")];
                    [cell addSubview:lblName];
                }else if(arrayMessageNumberAfterCheck.count > 0)
                {
                    UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
                    [imageIcon setImage:[[UIImage imageNamed:@"contactusmessage_tbl"]imageWithColor:[self colorWithHexString:stringColor]]];
                    [cell addSubview:imageIcon];
                    
                    UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
                    [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
                    [lblName setText:SCLocalizedString(@"Message")];
                    [cell addSubview:lblName];
                }else if(![stringWebsite isEqualToString:@""])
                {
                    UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
                    [imageIcon setImage:[[UIImage imageNamed:@"contactusweb_tbl"]imageWithColor:[self colorWithHexString:stringColor]]];
                    [cell addSubview:imageIcon];
                    
                    UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
                    [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
                    [lblName setText:SCLocalizedString(@"Website")];
                    [cell addSubview:lblName];
                }
            }
                break;
            case 1:
            {
                if (arrayEmailCheck.count > 0) {
                    if (arrayMessageNumberAfterCheck.count > 0) {
                        UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
                        [imageIcon setImage:[[UIImage imageNamed:@"contactusmessage_tbl"]imageWithColor:[self colorWithHexString:stringColor]]];
                        [cell addSubview:imageIcon];
                        
                        UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
                        [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
                        [lblName setText:SCLocalizedString(@"Message")];
                        [cell addSubview:lblName];
                    }else if(![stringWebsite isEqualToString:@""])
                    {
                        UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
                        [imageIcon setImage:[[UIImage imageNamed:@"contactusweb_tbl"]imageWithColor:[self colorWithHexString:stringColor]]];
                        [cell addSubview:imageIcon];
                        
                        UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
                        [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
                        [lblName setText:SCLocalizedString(@"Website")];
                        [cell addSubview:lblName];
                    }
                }else
                {
                    if (arrayMessageNumberAfterCheck.count > 0) {
                        if (![stringWebsite isEqualToString:@""])
                        {
                            UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
                            [imageIcon setImage:[[UIImage imageNamed:@"contactusweb_tbl"]imageWithColor:[self colorWithHexString:stringColor]]];
                            [cell addSubview:imageIcon];
                            
                            UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
                            [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
                            [lblName setText:SCLocalizedString(@"Website")];
                            [cell addSubview:lblName];
                        }
                    }
                }
            }
                break;
            case 2:
            {
                if (![stringWebsite isEqualToString:@""]) {
                    UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
                    [imageIcon setImage:[[UIImage imageNamed:@"contactusweb_tbl"]imageWithColor:[self colorWithHexString:stringColor]]];
                    [cell addSubview:imageIcon];
                    
                    UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
                    [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
                    [lblName setText:SCLocalizedString(@"Website")];
                    [cell addSubview:lblName];
                }
            }
                break;
            default:
                break;
        }
    }
    */
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return numberItemPhone;
    }else
        return numberItemPad;
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
    /*
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        switch (indexPath.row) {
            case 0:
            {
                if (arrayEmailCheck.count > 0) {
                    [self btnEmailClick];
                }else if(arrayPhoneNumberAfterCheck.count > 0)
                {
                    [self btnCallClick];
                }else if(arrayMessageNumberAfterCheck.count > 0)
                {
                    [self btnMessageClick];
                }else if(![stringWebsite isEqualToString:@""])
                {
                    [self btnWebsiteClick];
                }
            }
                break;
            case 1:
            {
                if (arrayEmailCheck.count > 0) {
                    if (arrayPhoneNumberAfterCheck.count > 0) {
                        [self btnCallClick];
                    }else if (arrayMessageNumberAfterCheck.count > 0) {
                        [self btnMessageClick];
                    }else if(![stringWebsite isEqualToString:@""])
                    {
                        [self btnWebsiteClick];
                    }
                }else
                {
                    if (arrayMessageNumberAfterCheck.count > 0) {
                        [self btnMessageClick];
                    }else if (![stringWebsite isEqualToString:@""])
                    {
                        [self btnWebsiteClick];
                    }
                }
            }
                break;
            case 2:
            {
                
                if (arrayMessageNumberAfterCheck.count > 0) {
                    [self btnMessageClick];
                }else if (![stringWebsite isEqualToString:@""])
                {
                    [self btnWebsiteClick];
                }
            }
                break;
            case 3:
            {
                [self btnWebsiteClick];
            }
                break;
            default:
                break;
        }
    }else
    {
        switch (indexPath.row) {
            case 0:
            {
                if (arrayEmailCheck.count > 0) {
                    [self btnEmailClick];
                }else if(arrayMessageNumberAfterCheck.count > 0)
                {
                    [self btnMessageClick];
                }else if(![stringWebsite isEqualToString:@""])
                {
                    [self btnWebsiteClick];
                }
            }
                break;
            case 1:
            {
                if (arrayEmailCheck.count > 0) {
                    if (arrayMessageNumberAfterCheck.count > 0) {
                        [self btnMessageClick];
                    }else if(![stringWebsite isEqualToString:@""])
                    {
                        [self btnWebsiteClick];
                    }
                }else
                {
                    if (![stringWebsite isEqualToString:@""])
                    {
                        [self btnWebsiteClick];
                    }
                }
            }
                break;
            case 2:
            {
                
                [self btnWebsiteClick];
            }
                break;
            default:
                break;
        }
    }
    */
}

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
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

//  Liam ADD 150504
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
            [section addRow:rowEmail];
        }
        
        if (arrayPhoneNumberAfterCheck.count > 0 && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            SimiRow *rowCall = [SimiRow new];
            rowCall.identifier = EMAILCONTACT_ROWCALL;
            [section addRow:rowCall];
        }
        
        if (arrayMessageNumberAfterCheck.count > 0) {
            SimiRow *rowMessage = [SimiRow new];
            rowMessage.identifier = EMAILCONTACT_ROWMESSAGE;
            [section addRow:rowMessage];
        }
        
        if (![stringWebsite isEqualToString:@""]) {
            SimiRow *rowWebsite = [SimiRow new];
            rowWebsite.identifier = EMAILCONTACT_ROWWEBSITE;
            [section addRow:rowWebsite];
        }
        [_cells addObject:section];
    }
}
//  End 150504
@end
