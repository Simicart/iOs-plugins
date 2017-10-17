//
//  SCSearchVoiceViewController.m
//  SimiCartPluginFW
//
//  Created by Lionel on 4/4/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//
// lionel added
#import <AVFoundation/AVFoundation.h>
#import "SCSearchVoicePadViewController.h"

@interface SCSearchVoicePadViewController ()
@end

@implementation SCSearchVoicePadViewController
- (void)setUpSearchVoiceView {
    // recording view
    // add backgroundView
    UIView *backGroundView = [[UIView alloc] initWithFrame:[SimiGlobalFunction scaleFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)]];
    backGroundView.backgroundColor = [UIColor blackColor];
    backGroundView.alpha = 0.9;
    [self.view addSubview:backGroundView];
    // recording image
    self.recordingButton = [[UIButton alloc] initWithFrame:[SimiGlobalFunction scaleFrame:CGRectMake((SCREEN_WIDTH - 100)/2, (SCREEN_HEIGHT - 100) / 2, 100, 100)]];
    [self.recordingButton addTarget:self action:@selector(stopRecord) forControlEvents:(UIControlEventTouchUpInside)];
    [self.recordingButton setImage:[UIImage imageNamed:@"recording"] forState:(UIControlStateNormal)];
    self.recordingButton.clipsToBounds = YES;
    self.recordingButton.layer.cornerRadius = self.recordingButton.frame.size.width / 2;
    // status label
    self.recordStatusLb = [[UILabel alloc] initWithFrame:[SimiGlobalFunction scaleFrame:CGRectMake(8, self.recordingButton.frame.origin.y - 8 - [SimiGlobalFunction scaleValue:50], SCREEN_WIDTH - 16, 50)]];
    self.recordStatusLb.text = SCLocalizedString(@"Say something to looking for...");
    self.recordStatusLb.textColor = [UIColor whiteColor];
    [self.recordStatusLb setTextAlignment:(NSTextAlignmentCenter)];
    // close button
    self.recordCloseBtn = [[UIButton alloc] initWithFrame:[SimiGlobalFunction scaleFrame:CGRectMake((SCREEN_WIDTH - 30)/2, SCREEN_HEIGHT - 8 - 30, 30, 30)]];
    // try record btn
    self.tryRecordBtn = [[UIButton alloc] initWithFrame:[SimiGlobalFunction scaleFrame:CGRectMake(((SCREEN_WIDTH / 2) - 50)/2, (SCREEN_HEIGHT - 50) / 2, 50, 50)]];
    [self.tryRecordBtn setImage:[UIImage imageNamed:@"ic_micro_inactive"] forState:(UIControlStateNormal)];
    self.tryRecordBtn.clipsToBounds = YES;
    self.tryRecordBtn.layer.cornerRadius = self.tryRecordBtn.frame.size.width / 2;
    [self.tryRecordBtn addTarget:self action:@selector(tryRecordBtnHandle) forControlEvents:(UIControlEventTouchUpInside)];
    self.tryRecordBtn.hidden = YES;
    
    self.tryRecordLb = [[UILabel alloc] initWithFrame:[SimiGlobalFunction scaleFrame:CGRectMake(8, self.tryRecordBtn.frame.origin.y + 50, (SCREEN_WIDTH / 2) - 16, 20)]];
    self.tryRecordLb.text = SCLocalizedString(@"Tap to try again");
    [self.tryRecordLb setFont:[UIFont systemFontOfSize:12]];
    self.tryRecordLb.textColor = [UIColor whiteColor];
    [self.tryRecordLb setTextAlignment:(NSTextAlignmentCenter)];
    self.tryRecordLb.hidden = YES;
    // search text btn
    self.searchTextBtn = [[UIButton alloc] initWithFrame:[SimiGlobalFunction scaleFrame:CGRectMake(((SCREEN_WIDTH / 2) - 50)/2 + (SCREEN_WIDTH/2), (SCREEN_HEIGHT - 50) / 2, 50, 50)]];
    [self.searchTextBtn setImage:[UIImage imageNamed:@"ic_search_inactive"] forState:(UIControlStateNormal)];
    self.searchTextBtn.clipsToBounds = YES;
    self.searchTextBtn.layer.cornerRadius = self.searchTextBtn.frame.size.width / 2;
    [self.searchTextBtn addTarget:self action:@selector(searchTextBtnHandle) forControlEvents:(UIControlEventTouchUpInside)];
    self.searchTextBtn.hidden = YES;
    
    self.searchTextLb = [[UILabel alloc] initWithFrame:[SimiGlobalFunction scaleFrame:CGRectMake((SCREEN_WIDTH /2) + 8, self.tryRecordBtn.frame.origin.y + 50, (SCREEN_WIDTH / 2) - 16, 20)]];
    self.searchTextLb.text = SCLocalizedString(@"type your search");
    [self.searchTextLb setFont:[UIFont systemFontOfSize:12]];
    self.searchTextLb.textColor = [UIColor whiteColor];
    [self.searchTextLb setTextAlignment:(NSTextAlignmentCenter)];
    self.searchTextLb.hidden = YES;
    
    [self.recordCloseBtn setImage:[UIImage imageNamed:@"ic_close"] forState:(UIControlStateNormal)];
    self.recordCloseBtn.imageView.clipsToBounds = YES;
    [self.recordCloseBtn setContentMode:(UIViewContentModeScaleAspectFit)];
    [self.recordCloseBtn addTarget:self action:@selector(closeBtnHandle) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:self.recordingButton];
    [self.view addSubview:self.recordStatusLb];
    [self.view addSubview:self.recordCloseBtn];
    [self.view addSubview:self.tryRecordBtn];
    [self.view addSubview:self.tryRecordLb];
    [self.view addSubview:self.searchTextLb];
    [self.view addSubview:self.searchTextBtn];
}
@end
