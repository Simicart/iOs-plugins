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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCLeftMenu_InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCLeftMenu_DidSelectRow" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didTapChatButton) name:@"tapToChatButton" object:nil];
        self.zoPimConfig = [[[[SimiGlobalVar sharedInstance] store] valueForKeyPath:@"store_config"] valueForKeyPath:@"zopim_config"];
        NSLog(@"zopim config : %@", self.zoPimConfig);
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
                SimiRow *row = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_CHAT height:50 sortOrder:70];
                row.image = [UIImage imageNamed:@"ic_livechat"];
                row.title = SCLocalizedString(@"Live Chat");
                row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [section addObject:row];
                [section sortItems];
            }
        }
    } else if([noti.name isEqualToString:@"SCLeftMenu_DidSelectRow"])
    {
        NSArray *zopimConfig = [[[[SimiGlobalVar sharedInstance] store] valueForKeyPath:@"store_config"] valueForKeyPath:@"zopim_config"];
        NSString *accountKey = [zopimConfig valueForKey:@"account_key"];
        NSString *showProfile = [zopimConfig valueForKey:@"show_profile"];
        NSString *name = [zopimConfig valueForKey:@"name"];
        NSString *email = [zopimConfig valueForKey:@"email"];
        NSString *phone = [zopimConfig valueForKey:@"phone"];
        SimiRow *row = [noti.userInfo valueForKey:@"simirow"];
        if([showProfile isEqualToString:@"0"])
            showProfile = @"3";
        if ([row.identifier isEqualToString:LEFTMENU_ROW_CHAT]) {
            SCNavigationBarPhone *navi = noti.object;
            navi.isDiscontinue = YES;
            [self startZopimChat:accountKey showProfile:showProfile name:name email:email phone:phone];
        }
    }
}

//- (NSUInteger) supportedInterfaceOrientations
//{
//    //Because your app is only landscape, your view controller for the view in your
//    // popover needs to support only landscape
//    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
//}

-(void)didTapChatButton
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"SCLeftMenu_DidSelectRow" object:nil];
    NSString *accountKey = [self.zoPimConfig valueForKey:@"account_key"];
    NSString *showProfile = [self.zoPimConfig valueForKey:@"show_profile"];
    if ([showProfile isEqualToString:@"0"]) {
        [self startZopimChat:accountKey showProfile:showProfile name:nil email:nil phone:nil];
    } else {
        NSString *name = [self.zoPimConfig valueForKey:@"name"];
        NSString *email = [self.zoPimConfig valueForKey:@"email"];
        NSString *phone = [self.zoPimConfig valueForKey:@"phone"];
        //    if(![showProfile isEqualToString:@"0"])
        //    showProfile = @"3";
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
    [self styleApp];
//    [ChatStyling applyStyling];
    [ZDCChat configure:^(ZDCConfig *defaults) {
        defaults.accountKey = accountKey;
        defaults.preChatDataRequirements.name = [name integerValue];
        defaults.preChatDataRequirements.email = [email integerValue];
        defaults.preChatDataRequirements.phone = [phone integerValue];
        defaults.preChatDataRequirements.department = [showProfile integerValue];
        defaults.preChatDataRequirements.message = ZDCPreChatDataOptional;
        defaults.emailTranscriptAction = ZDCEmailTranscriptActionNeverSend;

    }];
    [ZDCLog enable:YES];
    [ZDCLog setLogLevel:ZDCLogLevelWarn];
    
    // start a chat in a new modal
    // Lần click thứ 2 thì nó k call vào đây.
    [ZDCChat startChat:nil];
}

- (void) styleApp
{
    if ([ZDUUtil isVersionOrNewer:@(7)]) {
        // status bar
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        // nav bar
        NSDictionary *navbarAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor] ,UITextAttributeTextColor, nil];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTitleTextAttributes:navbarAttributes];
        [[UINavigationBar appearance] setBarTintColor:THEME_COLOR];
        UIButton *cartButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [cartButton setImage:[[UIImage imageNamed:@"ic_cart"] imageWithColor:THEME_NAVIGATION_ICON_COLOR] forState:UIControlStateNormal];
        [[ZDCChatOverlay appearance] setOverlayTintColor:THEME_BUTTON_BACKGROUND_COLOR];
        [[ZDCChatOverlay appearance] setMessageCountColor:THEME_BUTTON_TEXT_COLOR];
        if ([ZDUUtil isVersionOrNewer:@(8)]) {
            // For translucent nav bars set YES
            [[UINavigationBar appearance] setTranslucent:NO];
        }
    } else {
        [[UINavigationBar appearance] setTintColor:THEME_COLOR];
        [[ZDCChatOverlay appearance] setOverlayTintColor:THEME_BUTTON_BACKGROUND_COLOR];
        [[ZDCChatOverlay appearance] setMessageCountColor:THEME_BUTTON_TEXT_COLOR];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
