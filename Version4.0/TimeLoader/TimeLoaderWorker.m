//
//  TimeLoaderWorker.m
//  SimiCartPluginFW
//
//  Created by Gin-Wishky on 10/14/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import "TimeLoaderWorker.h"
#import <SimiCartBundle/SimiTableView.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SimiTable.h>
#import <SimiCartBundle/SCNavigationBarPhone.h>
#import <SimiCartBundle/SCNavigationBarPad.h>
#import "TimeLoaderViewController.h"
#import "CategoryTimeLoaderViewController.h"

@implementation TimeLoaderWorker
{
    SimiTable *cells;
    NSMutableDictionary *dictResult;
    NSMutableDictionary *dictStart;
    
    NSMutableDictionary *dictViewResult;
    NSMutableDictionary *dictViewStart;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        dictResult = [[NSMutableDictionary alloc]initWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:stringKeyTimeLoader]];
        if (dictResult == nil) {
            dictResult = [NSMutableDictionary new];
        }
        dictStart = [NSMutableDictionary new];
        
        dictViewResult = [[NSMutableDictionary alloc]initWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:VIEW_TIME_LOADER]];
        if(dictViewResult == nil) {
            dictViewResult = [NSMutableDictionary new];
        }
        dictViewStart = [NSMutableDictionary new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initCellsAfter:) name:@"SCLeftMenu_InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectRow:) name:@"SCLeftMenu_DidSelectRow" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStopTimeLoader:) name:@"TimeLoaderStop" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStartTimeLoader:) name:@"TimeLoaderStart" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startOpenView:) name:StartOpenView object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishLoadView:) name:FinishLoadView object:nil];
    }
    return self;
}

- (void)initCellsAfter:(NSNotification*)noti
{
    cells = noti.object;
    for (int i = 0; i < cells.count; i++) {
        SimiSection *section = [cells objectAtIndex:i];
        if ([section.identifier isEqualToString:LEFTMENU_SECTION_MORE]) {
            SimiRow *row = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_TIMELOADER height:50 sortOrder:70];
            row.image = [UIImage imageNamed:@"time"];
            row.title = SCLocalizedString(@"Time Loader");
            row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [section addObject:row];
            [section sortItems];
        }
    }
}

- (void)didSelectRow:(NSNotification*)noti
{
    SimiRow *row = [noti.userInfo valueForKey:@"simirow"];
    if ([row.identifier isEqualToString:LEFTMENU_ROW_TIMELOADER]) {
        UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
        CategoryTimeLoaderViewController *categoryTimeLoaderViewController = [[CategoryTimeLoaderViewController alloc]init];
        categoryTimeLoaderViewController.dictAPIDataTimeLoader = dictResult;
        categoryTimeLoaderViewController.dictAPIScreenDataTimeLoader = dictViewResult;
        [(UINavigationController *)currentVC pushViewController:categoryTimeLoaderViewController animated:YES];
        [[NSUserDefaults standardUserDefaults]setObject:dictResult forKey:stringKeyTimeLoader];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
   
}

-(void)didStartTimeLoader:(NSNotification *)noti{
    NSString *string = [noti object];
    double methodStart = [[NSDate date] timeIntervalSince1970];
    [dictStart setValue:[NSNumber numberWithDouble:methodStart] forKey:string];
}

-(void)didStopTimeLoader:(NSNotification *)noti{
    NSString *string = [noti object];
    NSMutableArray *arrayResultForAPI = nil;
    BOOL hasArrayForKey = NO;
    for(NSString* key in [dictResult allKeys]){
        if([key isEqualToString:string]){
            arrayResultForAPI = [[NSMutableArray alloc]initWithArray:[dictResult objectForKey:string]];
            hasArrayForKey = YES;
            break;
        }
    }
    if (!hasArrayForKey) {
        arrayResultForAPI = [NSMutableArray new];
    }
    double methodStop = [[NSDate date] timeIntervalSince1970];
    NSNumber *duration = [NSNumber numberWithDouble:(methodStop - [[dictStart valueForKey:string] doubleValue])];
    [arrayResultForAPI addObject:duration];
    [dictResult setObject:arrayResultForAPI forKey:string];
}

- (void)startOpenView: (NSNotification *)noti {
    NSString *string = [noti object];
    double methodStart = [[NSDate date] timeIntervalSince1970];
    [dictViewStart setValue:[NSNumber numberWithDouble:methodStart] forKey:string];
}

- (void)finishLoadView: (NSNotification *)noti {
    NSString *string = [noti object];
    NSMutableArray *arrayResultForAPI = nil;
    BOOL hasArrayForKey = NO;
    for(NSString* key in [dictViewResult allKeys]){
        if([key isEqualToString:string]){
            arrayResultForAPI = [[NSMutableArray alloc]initWithArray:[dictViewResult objectForKey:string]];
            hasArrayForKey = YES;
            break;
        }
    }
    if (!hasArrayForKey) {
        arrayResultForAPI = [NSMutableArray new];
    }
    double methodStop = [[NSDate date] timeIntervalSince1970];
    NSNumber *duration = [NSNumber numberWithDouble:(methodStop - [[dictViewStart valueForKey:string] doubleValue])];
    [arrayResultForAPI addObject:duration];
    [dictViewResult setObject:arrayResultForAPI forKey:string];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
