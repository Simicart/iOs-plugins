//
//  YoutubeWorker.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/20/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimizopimWorker.h"
#import "ChatStyling.h"
#import <SimiCartBundle/SCThemeWorker.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiRow.h>
#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SCLeftMenuViewController.h>
#import <SimiCartBundle/SCNavigationBarPhone.h>
#import <SimiCartBundle/SCNavigationBarPad.h>

@implementation SimizopimWorker
{
    NSMutableArray * cells;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didTapChatButton) name:@"tapToChatButton" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCLeftMenu_InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCLeftMenu_DidSelectRow" object:nil];
        self.zoPimConfig = [[SimiGlobalVar sharedInstance].allConfig valueForKeyPath:@"zopim_config"];
        NSString *enable = [self.zoPimConfig valueForKey:@"enable"];
        if ([enable isEqualToString:@"1"]) {
            [SimiGlobalVar sharedInstance].isZopimChat = YES;
        } else {
            [SimiGlobalVar sharedInstance].isZopimChat = NO;
        }
    }
    return self;
}

-(void)didReceiveNotification:(NSNotification *)noti
{
    if([noti.name isEqualToString:@"SCLeftMenu_InitCellsAfter"])
    {
        cells = noti.object;
        for (int i = 0; i < cells.count; i++) {
            SimiSection *section = [cells objectAtIndex:i];
            if ([section.identifier isEqualToString:LEFTMENU_SECTION_MORE]) {
                SimiRow *row = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_CHAT height:50 sortOrder:80];
                row.image = [UIImage imageNamed:@"ic_livechat"];
                row.title = SCLocalizedString(@"Live Chat");
                row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [section addObject:row];
                [section sortItems];
            }
        }
    }else if([noti.name isEqualToString:@"SCLeftMenu_DidSelectRow"])
    {
        SimiRow *row = [noti.userInfo valueForKey:@"simirow"];
        if ([row.identifier isEqualToString:LEFTMENU_ROW_CHAT]) {
            SCNavigationBarPhone *navi = noti.object;
            navi.isDiscontinue = YES;
            [self didTapChatButton];
        }
    }
}

-(void)didTapChatButton
{
    NSString *accountKey = [self.zoPimConfig valueForKey:@"account_key"];
    NSString *showProfile = [self.zoPimConfig valueForKey:@"show_profile"];
    if ([showProfile isEqualToString:@"0"]) {
        [self startZopimChat:accountKey showProfile:showProfile name:nil email:nil phone:nil];
    } else {
        NSString *name = [self.zoPimConfig valueForKey:@"name"];
        NSString *email = [self.zoPimConfig valueForKey:@"email"];
        NSString *phone = [self.zoPimConfig valueForKey:@"phone"];
        [self startZopimChat:accountKey showProfile:showProfile name:name email:email phone:phone];
    }
}

-(void)move:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateChanged) {
        self.messageButton.center = [sender locationInView:[[[UIApplication sharedApplication] delegate] window]];
    }
}

- (void)startZopimChat:(NSString *)accountKey showProfile:(NSString *)showProfile name:(NSString *)name email:(NSString *)email phone:(NSString *)phone
{
    [ZDCChat initializeWithAccountKey:accountKey];
    [ZDCChat startChat:^(ZDCConfig *config) {
        config.preChatDataRequirements.name = [name integerValue];;
        config.preChatDataRequirements.email = [email integerValue];
        config.preChatDataRequirements.phone = [phone integerValue];
        config.preChatDataRequirements.department = [showProfile integerValue];
        config.preChatDataRequirements.message = ZDCPreChatDataOptionalEditable;
    }];
    [self styleApp];
    [ZDCLog enable:YES];
    [ZDCLog setLogLevel:ZDCLogLevelWarn];
}

- (void) styleApp
{
    [[ZDCChatOverlay appearance] setOverlayTintColor:[UIColor colorWithRed:0.9 green:0.45 blue:0 alpha:1]];
    [[ZDCChatOverlay appearance] setMessageCountColor:THEME_BUTTON_TEXT_COLOR];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
