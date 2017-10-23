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
    NSMutableArray *cells;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.zoPimConfig = [[SimiGlobalVar sharedInstance].allConfig valueForKeyPath:@"zopim_config"];
        NSString *enable = [self.zoPimConfig valueForKey:@"enable"];
        if ([enable isEqualToString:@"1"]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCLeftMenu_InitCellsAfter" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCLeftMenu_DidSelectRow" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initRightItemsEnd:) name:@"SCNavigationBarPhone-InitRightItems-End" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initLeftItemsEnd:) name:@"SCNavigationBarPad-InitLeftItems-End" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:DidLogin object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogout:) name:DidLogout object:nil];
//            [[ZDCTextEntryView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceRightToLeft];
//            [[ZDCChatView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceRightToLeft];
            // loading the chat
            [[ZDCLoadingView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
            [[ZDCLoadingErrorView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
            
            // pre-chat form
            [[ZDCPreChatFormView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
            [[ZDCFormCell appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
            
            // offline message view
            [[ZDCOfflineMessageView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
            
            // chat view
            [[ZDCChatView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
            [[ZDCTextEntryView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
            [[ZDCJoinLeaveCell appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
            [[ZDCSystemTriggerCell appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
            [[ZDCVisitorChatCell appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
            [[ZDCAgentChatCell appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
            [[ZDCChatTimedOutCell appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
            [[ZDCRatingCell appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
            [[ZDCAgentAttachmentCell appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
            [[ZDCVisitorAttachmentCell appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
            
            // chat UI and nav buttons
            [[ZDCChatUI appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
            
            // chat overlay icon
            [[ZDCChatOverlay appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
            
            // agent chat avatar
            [[ZDCChatAvatar appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
        }
    }
    return self;
}

- (void)didLogin:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo objectForKey:@"responder"];
    if([responder.status isEqualToString:@"SUCCESS"]){
        SimiCustomerModel *customer = noti.object;
        [ZDCChat updateVisitor:^(ZDCVisitorInfo *visitor) {
            visitor.name = [NSString stringWithFormat:@"%@ %@", [customer objectForKey:@"firstname"],[customer objectForKey:@"lastname"]];
            visitor.email = [customer objectForKey:@"email"];
        }];
    }
}

- (void)didLogout:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo objectForKey:@"responder"];
    if([responder.status isEqualToString:@"SUCCESS"]){
        [ZDCChat updateVisitor:^(ZDCVisitorInfo *visitor) {
            visitor.name = @"";
            visitor.email = @"";
        }];
    }
}

- (void)didReceiveNotification:(NSNotification *)noti{
    if([noti.name isEqualToString:@"SCLeftMenu_InitCellsAfter"]){
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
    }else if([noti.name isEqualToString:@"SCLeftMenu_DidSelectRow"]){
        SimiRow *row = [noti.userInfo valueForKey:@"simirow"];
        if ([row.identifier isEqualToString:LEFTMENU_ROW_CHAT]) {
            SCNavigationBarPhone *navi = noti.object;
            navi.isDiscontinue = YES;
            [self didSelectChatBarItem:nil];
        }
    }
}

- (void)initRightItemsEnd:(NSNotification*)noti{
    UIButton *chatButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [chatButton setImage:[[UIImage imageNamed:@"ic_livechat"] imageWithColor:THEME_NAVIGATION_ICON_COLOR] forState:UIControlStateNormal];
    [chatButton addTarget:self action:@selector(didSelectChatBarItem:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *chatItem = [[UIBarButtonItem alloc] initWithCustomView:chatButton];
    NSMutableArray *rightButtonItems = noti.object;
    [rightButtonItems addObject:chatItem];
}

- (void)initLeftItemsEnd:(NSNotification*)noti{
    UIBarButtonItem *itemSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    itemSpace.width = 20;
    UIButton *chatButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [chatButton setImage:[[UIImage imageNamed:@"ic_livechat"] imageWithColor:THEME_NAVIGATION_ICON_COLOR] forState:UIControlStateNormal];
    [chatButton addTarget:self action:@selector(didSelectChatBarItem:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *chatItem = [[UIBarButtonItem alloc] initWithCustomView:chatButton];
    NSMutableArray *rightButtonItems = noti.object;
    [rightButtonItems addObjectsFromArray:@[itemSpace,chatItem]];
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

//- (void)move:(UIPanGestureRecognizer *)sender {
//    if (sender.state == UIGestureRecognizerStateChanged) {
//        self.messageButton.center = [sender locationInView:[[[UIApplication sharedApplication] delegate] window]];
//    }
//}

- (void)startZopimChat:(NSString *)accountKey showProfile:(NSString *)showProfile name:(NSString *)name email:(NSString *)email phone:(NSString *)phone{
    [ZDCChat initializeWithAccountKey:accountKey];
    [ZDCChat startChat:^(ZDCConfig *config) {
        config.preChatDataRequirements.name = [name integerValue];;
        config.preChatDataRequirements.email = [email integerValue];
        config.preChatDataRequirements.phone = [phone integerValue];
        config.preChatDataRequirements.department = [showProfile integerValue];
        config.preChatDataRequirements.message = ZDCPreChatDataRequired;
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
