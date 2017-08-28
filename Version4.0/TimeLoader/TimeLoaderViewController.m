//
//  TimeLoaderViewController.m
//  SimiCartPluginFW
//
//  Created by Gin-Wishky on 10/14/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import "TimeLoaderViewController.h"
#import "SimiSection.h"
#import "TimeLoaderDetailViewController.h"

@interface TimeLoaderViewController (){
   
}

@end

@implementation TimeLoaderViewController
@synthesize dictdata,timeLoaderTable,array;

-(void)viewDidLoadBefore{
    [super viewDidLoadBefore];
    timeLoaderTable = [[SimiTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];
    timeLoaderTable.delegate = self;
    timeLoaderTable.dataSource = self;
    [self.view addSubview:timeLoaderTable];
    [self setCells:nil];
    UIButton *btnSend = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-110,SCREEN_WIDTH , 44)];
    [btnSend setTitle:@"Send" forState:UIControlStateNormal];
    [btnSend setBackgroundColor:[UIColor orangeColor]];
    [btnSend addTarget:self action:@selector(btnEmailClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSend];

}
-(void)viewDidLoadAfter{

}
#pragma mark Email Delegate
- (void)sendEmailToStoreWithEmail:(NSMutableDictionary *)email andEmailContent:(NSString *)emailContent
{
    if([MFMailComposeViewController canSendMail])
    {
        NSString *emailTitle = @"Export TimeLoader";
        NSString *messageBody = @"Email Body";
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:@[]];
        
        NSMutableString *csv = [NSMutableString stringWithString:@""];
        
        //add your content to the csv
//        for (int i = 0; i < dictdata.count; i++) {
//            NSString *stringKey = [[dictdata allKeys] objectAtIndex:i];
//            if(i == 0){
//                [csv appendFormat:@" %@,",stringKey];
//            }else{
//                [csv appendFormat:@"\n %@,",stringKey];
//            }
//            for (int j = 0; j<[[dictdata valueForKey:stringKey] count]; j++) {
//                NSString *stringCsv = [[dictdata valueForKey:stringKey] objectAtIndex:j];
//                [csv appendFormat:@",%@",stringCsv];
//            }
//        }
        
        NSMutableArray *arrayPrintCSV = [NSMutableArray new];
        for (int i = 0; i < 100; i++) {
            NSMutableArray *arrayPrintCSVRow = [NSMutableArray new];
            [arrayPrintCSV addObject:arrayPrintCSVRow];
        }
        for (int i = 0; i < dictdata.count; i++) {
            NSString *stringKey = [[dictdata allKeys] objectAtIndex:i];
            if(i == (dictdata.count -1)){
                [csv appendFormat:@"%@\n",stringKey];
            }else{
                [csv appendFormat:@"%@,",stringKey];
            }
            NSMutableArray *arrayForStringKey = [[NSMutableArray alloc]initWithArray:[dictdata valueForKey:stringKey]];
            for (int j = 0; j< 100; j++) {
                if (arrayForStringKey.count > j) {
                    [[arrayPrintCSV objectAtIndex:j]addObject:[arrayForStringKey objectAtIndex:j]];
                }else
                {
                    [[arrayPrintCSV objectAtIndex:j]addObject:@""];
                }
            }
        }
        for (int i = 0; i < arrayPrintCSV.count; i++) {
            NSMutableArray *arrayTemp = [arrayPrintCSV objectAtIndex:i];
            for (int j = 0; j < arrayTemp.count; j++) {
                NSString *stringKey = [arrayTemp objectAtIndex:j];
                if(j == (arrayTemp.count -1)){
                    [csv appendFormat:@"%@\n",stringKey];
                }else{
                    [csv appendFormat:@"%@,",stringKey];
                }
            }
        }
        NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* fileName = @"MyCSVFileName.csv";
        NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
            [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
        }
        
        BOOL res = [[csv dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO];
        
        if (!res) {
            [[[UIAlertView alloc] initWithTitle:@"Error Creating CSV" message:@"Check your permissions to make sure this app can create files so you may email the app data" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
        }else{
            NSLog(@"Data saved! File path = %@", fileName);
            [mc addAttachmentData:[NSData dataWithContentsOfFile:fileAtPath]
                         mimeType:@"text/csv"
                         fileName:@"MyCSVFileName.csv"];
            [self presentViewController:mc animated:YES completion:nil];
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
- (void)btnEmailClick
{
    NSString *emailContent = SCLocalizedString(@"");
    [self sendEmailToStoreWithEmail:dictdata andEmailContent:emailContent];
}
- (void)setCells:(NSMutableArray *)cells{
    if (cells) {
        _cells = cells;
    }else{
        _cells = [[NSMutableArray alloc] init];
        SimiSection *simiSection = [[SimiSection alloc] init];
        if([dictdata allKeys].count >0){
            for (int i = 0; i < [dictdata allKeys].count; i++) {
                SimiRow *row = [[SimiRow alloc] init];
                row.height = 44;
                row.identifier = [NSString stringWithFormat:@"%@",[[dictdata allKeys] objectAtIndex:i]];
                [simiSection addRow:row];
            }
        }
        [_cells addObject:simiSection];
    }
}

#pragma mark Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _cells.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SimiSection *simiSection = [_cells objectAtIndex:section];
    return simiSection.rows.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    return simiRow.height;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    UITableViewCell *cell;
    if ([simiRow.identifier isEqualToString:[NSString stringWithFormat:@"%@",[[dictdata allKeys] objectAtIndex:indexPath.row]]]){
        cell = [tableView dequeueReusableCellWithIdentifier:simiRow.identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *lbStt = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 50, 44)];
            lbStt.text = [NSString stringWithFormat:@"%li",(indexPath.row +1)];
            [cell addSubview:lbStt];
            
            UILabel *lbTime = [[UILabel alloc] initWithFrame:CGRectMake(50, 0,250 , 44)];
            lbTime.text = [[dictdata allKeys] objectAtIndex:indexPath.row];
            [cell addSubview:lbTime];
        }
    }

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    TimeLoaderDetailViewController *nextVC = [[TimeLoaderDetailViewController alloc] init];
    nextVC.arrayDetail = [dictdata objectForKey:simiRow.identifier];
    nextVC.stringHeader = simiRow.identifier;
    [self.navigationController pushViewController:nextVC animated:YES];
}
@end
