//
//  YoutubeWorker.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/20/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimizopimWorker.h"
#import "ChatStyling.h"
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiRow.h>
#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SCLeftMenuViewController.h>
#import <SimiCartBundle/SCNavigationBarPhone.h>
#import <SimiCartBundle/SCNavigationBarPad.h>

@implementation SimizopimWorker
{
    NSMutableArray *cells;
    UIBarButtonItem *chatItem;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.zoPimConfig = [[SimiGlobalVar sharedInstance].storeView valueForKeyPath:@"zopim_config"];
        NSString *enable = [self.zoPimConfig valueForKey:@"enable"];
        if ([enable isEqualToString:@"1"]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:[NSString stringWithFormat:@"%@%@",SCLeftMenuViewController_RootEventName, SimiTableViewController_SubKey_InitCells_End] object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:[NSString stringWithFormat:@"%@%@",SCLeftMenuViewController_RootEventName, SimiTableViewController_SubKey_DidSelectCell] object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initRightItemsEnd:) name:@"SCNavigationBarPhone-InitRightItems-End" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initLeftItemsEnd:) name:@"SCNavigationBarPad-InitLeftItems-End" object:nil];
        }
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti{
    if([noti.name isEqualToString:[NSString stringWithFormat:@"%@%@",SCLeftMenuViewController_RootEventName, SimiTableViewController_SubKey_InitCells_End]]){
        cells = noti.object;
        for (int i = 0; i < cells.count; i++) {
            SimiSection *section = [cells objectAtIndex:i];
            if ([section.identifier isEqualToString:LEFTMENU_SECTION_MORE]) {
                SimiRow *row = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_CHAT height:50 sortOrder:80];
                row.image = [UIImage imageNamed:@"ic_livechat"];
                row.title = SCLocalizedString(@"Live Chat");
                [section addObject:row];
                [section sortItems];
            }
        }
    }else if([noti.name isEqualToString:[NSString stringWithFormat:@"%@%@",SCLeftMenuViewController_RootEventName, SimiTableViewController_SubKey_DidSelectCell]]){
        NSIndexPath *indexPath = [noti.userInfo valueForKey:KEYEVENT.SIMITABLEVIEWCONTROLLER.indexpath];
        cells = noti.object;
        SimiSection *section = [cells objectAtIndex:indexPath.section];
        SimiRow *row = [section objectAtIndex:indexPath.row];
        if ([row.identifier isEqualToString:LEFTMENU_ROW_CHAT]) {
            SCNavigationBarPhone *navi = noti.object;
            navi.isDiscontinue = YES;
            [self didSelectChatBarItem:nil];
        }
    }
}

- (void)initRightItemsEnd:(NSNotification*)noti{
    NSMutableArray *rightButtonItems = noti.object;
    if(![rightButtonItems containsObject:chatItem]){
        UIButton *chatButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [chatButton setImage:[[UIImage imageNamed:@"ic_livechat"] imageWithColor:THEME_NAVIGATION_ICON_COLOR] forState:UIControlStateNormal];
        [chatButton addTarget:self action:@selector(didSelectChatBarItem:) forControlEvents:UIControlEventTouchUpInside];
        chatItem = [[UIBarButtonItem alloc] initWithCustomView:chatButton];
        chatItem.sortOrder = navigationbar_phone_chat_sort_order;
        [rightButtonItems addObject:chatItem];
    }
}

- (void)initLeftItemsEnd:(NSNotification*)noti{
    NSMutableArray *leftButtonItems = noti.object;
    if(![leftButtonItems containsObject:chatItem]){
        UIBarButtonItem *itemSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        itemSpace.width = 20;
        UIButton *chatButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [chatButton setImage:[[UIImage imageNamed:@"ic_livechat"] imageWithColor:THEME_NAVIGATION_ICON_COLOR] forState:UIControlStateNormal];
        [chatButton addTarget:self action:@selector(didSelectChatBarItem:) forControlEvents:UIControlEventTouchUpInside];
        chatItem = [[UIBarButtonItem alloc] initWithCustomView:chatButton];
        chatItem.sortOrder = navigationbar_pad_chat_sort_order;
        itemSpace.sortOrder = navigationbar_pad_chat_sort_order - 1;
        [leftButtonItems addObjectsFromArray:@[itemSpace,chatItem]];
    }
}

- (void)didSelectChatBarItem:(UIButton*)sender{
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

- (void)move:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateChanged) {
        self.messageButton.center = [sender locationInView:[[[UIApplication sharedApplication] delegate] window]];
    }
}

- (void)startZopimChat:(NSString *)accountKey showProfile:(NSString *)showProfile name:(NSString *)name email:(NSString *)email phone:(NSString *)phone{
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

- (void)styleApp{
    [[ZDCChatOverlay appearance] setOverlayTintColor:[UIColor colorWithRed:0.9 green:0.45 blue:0 alpha:1]];
    [[ZDCChatOverlay appearance] setMessageCountColor:THEME_BUTTON_TEXT_COLOR];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
