//
//  SCCustomizeWebViewController.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 7/20/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

@interface SCCustomizeWebViewController : UIViewController<UIGestureRecognizerDelegate,UIWebViewDelegate>
@property (strong, nonatomic) NSString *urlPath;
@property (strong, nonatomic) UITapGestureRecognizer *tapOutsideRecognizer;
@end
