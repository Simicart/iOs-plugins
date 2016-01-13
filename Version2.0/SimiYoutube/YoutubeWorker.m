//
//  YoutubeWorker.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/20/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "YoutubeWorker.h"
#import "SimiSection.h"
#import "SimiRow.h"
#import "SimiProductModel.h"
#import "SCProductViewController.h"
#import "YKYouTubeVideo.h"
#import "SCProductInfoView.h"
static NSString *PRODUCT_ROW_YOUTUBE = @"PRODUCT_ROW_YOUTUBE";
@implementation YoutubeWorker
{
    NSMutableArray *cells;
    SimiProductModel *product;
    SCProductViewController *productViewController;
    NSMutableArray *youtubeArray;
    NSMutableArray *youtubeVideoArray;
    SCProductInfoView *infoView;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveNotification:) name:@"SCProductViewController-InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveNotification:) name:@"InitializedProductCell-After" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(videoPlayBackDidFinish:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ZThemeProductInfoView-DidSetBasicInfoView" object:nil];
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"SCProductViewController-InitCellsAfter"]) {
        cells = (NSMutableArray*)noti.object;
        SimiSection *section = [cells objectAtIndex:0];
        productViewController = [noti.userInfo valueForKey:@"controller"];
        NSMutableArray *arrayDemo = [[NSMutableArray alloc]initWithArray:@[@{@"title":@"Johnny",@"key":@"romRDMEidBw"},@{@"title":@"Cody",@"key":@"SuP1d4DjLZQ"},@{@"title":@"Johnny",@"key":@"romRDMEidBw"},@{@"title":@"Johnny",@"key":@"romRDMEidBw"},@{@"title":@"Johnny",@"key":@"romRDMEidBw"},@{@"title":@"Johnny",@"key":@"romRDMEidBw"}]];
        [productViewController.product setValue:arrayDemo forKey:@"youtube"];
        if ([productViewController.product valueForKey:@"youtube"]) {
            switch ([[SimiGlobalVar sharedInstance]themeUsing]) {
                case ThemeShowDefault:
                {
                    SimiRow *youtubeRow = [[SimiRow alloc]initWithIdentifier:PRODUCT_ROW_YOUTUBE height:230];
                    SimiRow *actionRow = [section getRowByIdentifier:@"ProductActionIdentifier"];
                    youtubeRow.sortOrder = actionRow.sortOrder + 10;
                    [section addRow:youtubeRow];
                    [section sortItems];
                }
                    break;
                case ThemeShowMatrixTheme:
                {
                    
                    SimiRow *youtubeRow = [[SimiRow alloc]initWithIdentifier:PRODUCT_ROW_YOUTUBE height:230];
                    SimiRow *actionRow = [section getRowByIdentifier:@"PRODUCT_OPTION_ADDTOCART_CELL_ID"];
                    youtubeRow.sortOrder = actionRow.sortOrder + 10;
                    [section addRow:youtubeRow];
                    [section sortItems];
                }
                    break;
                case ThemeShowZTheme:
                {
                    
                }
                    break;
                default:
                    break;
            }
        }
    }
    else if([noti.name isEqualToString:@"InitializedProductCell-After"])
    {
        NSIndexPath *indexPath = [noti.userInfo valueForKey:@"indexPath"];
        SimiSection *section = [cells objectAtIndex:0];
        SimiRow *row = [section objectAtIndex:indexPath.row];
        product = [noti.userInfo valueForKey:@"productmodel"];
        youtubeArray = (NSMutableArray*)[product valueForKey:@"youtube"];
        if ([row.identifier isEqualToString:PRODUCT_ROW_YOUTUBE]) {
            UITableViewCell *cell = (UITableViewCell *)noti.object;
            for (UIView *view in cell.subviews) {
                if ([view isKindOfClass:[LazyPageScrollView class]]) {
                    return;
                }
            }
            LazyPageScrollView *_pageView = nil;
            switch ([[SimiGlobalVar sharedInstance]themeUsing]) {
                case ThemeShowDefault:
                {
                    _pageView = [[LazyPageScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, row.height)];
                }
                    break;
                case ThemeShowMatrixTheme:
                {
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                        _pageView = [[LazyPageScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, row.height)];
                    }else
                    {
                        _pageView = [[LazyPageScrollView alloc]initWithFrame:CGRectMake(15, 0, 410, row.height)];
                    }
                }
                    break;
                case ThemeShowZTheme:
                    
                    break;
                default:
                    break;
            }
            
            [cell addSubview:_pageView];
            _pageView.delegate = self;
            if (youtubeArray.count > 3) {
                [_pageView initTab:NO Gap:50 TabHeight:40 VerticalDistance:5 BkColor:[UIColor whiteColor]];
            }else
            {
                [_pageView initTab:YES Gap:50 TabHeight:40 VerticalDistance:5 BkColor:[UIColor whiteColor]];
            }
            [_pageView enableTabBottomLine:YES LineHeight:3 LineColor:[UIColor redColor] LineBottomGap:5 ExtraWidth:10];
            [_pageView setTitleStyle:[UIFont systemFontOfSize:15] Color:[UIColor blackColor] SelColor:THEME_COLOR];
            [_pageView enableBreakLine:YES Width:1 TopMargin:0 BottomMargin:0 Color:[UIColor groupTableViewBackgroundColor]];
            _pageView.leftTopView = [[UIView alloc]initWithFrame:CGRectZero];
            _pageView.rightTopView = [[UIView alloc]initWithFrame:CGRectZero];
            
            for (int i = 0; i < youtubeArray.count; i++) {
                NSDictionary *youtubeUnit = [youtubeArray objectAtIndex:i];
                UIView *view = [UIView new];
                
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 180)];
                switch ([[SimiGlobalVar sharedInstance]themeUsing]) {
                    case ThemeShowDefault:
                        break;
                    case ThemeShowMatrixTheme:
                    {
                        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                            [imageView setFrame:CGRectMake(0, 0, 410, row.height)];
                        }
                    }
                        break;
                    case ThemeShowZTheme:
                        
                        break;
                    default:
                        break;
                }
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                [view addSubview:imageView];
                
                UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(135, 65, 50, 50)];
                switch ([[SimiGlobalVar sharedInstance]themeUsing]) {
                    case ThemeShowDefault:
                        break;
                    case ThemeShowMatrixTheme:
                    {
                        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                            [button setFrame:CGRectMake(180, 65, 50, 50)];
                        }
                    }
                        break;
                    case ThemeShowZTheme:
                        
                        break;
                    default:
                        break;
                }
                [button setImage:[UIImage imageNamed:@"play_youtube"] forState:UIControlStateNormal];
                button.tag = i;
                [button addTarget:self action:@selector(didTouchYoutubeVideo:) forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:button];
                
                NSString *youtubeLink = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@",[youtubeUnit valueForKey:@"key"]];
                YKYouTubeVideo *video = [[YKYouTubeVideo alloc]initWithContent:[NSURL URLWithString:youtubeLink]];
                [video parseWithCompletion:^(NSError *error)
                {
                    [video thumbImage:YKQualityHigh completion:^(UIImage *thumbImage, NSError *error) {
                        imageView.image = thumbImage;
                    }];
                }];
                if (youtubeVideoArray == nil) {
                    youtubeVideoArray = [NSMutableArray new];
                }
                [youtubeVideoArray addObject:video];
                
                [_pageView addTab:[youtubeUnit valueForKey:@"title"] View:view Info:nil];
            }
            
            [_pageView generate];
            UIView *topView = [_pageView getTopContentView];
            UILabel *lb=[[UILabel alloc] init];
            lb.translatesAutoresizingMaskIntoConstraints=NO;
            lb.backgroundColor=[UIColor darkTextColor];
            [topView addSubview:lb];
            [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[lb]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lb)]];
            [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lb(==1)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lb)]];
        }
    }
    else if([noti.name isEqualToString:@"ZThemeProductInfoView-DidSetBasicInfoView"])
    {
        infoView = (SCProductInfoView*)noti.object;
        product = [noti.userInfo valueForKey:@"productModel"];
        NSMutableArray *arrayDemo = [[NSMutableArray alloc]initWithArray:@[@{@"title":@"Johnny",@"key":@"romRDMEidBw"},@{@"title":@"Cody",@"key":@"SuP1d4DjLZQ"},@{@"title":@"Johnny",@"key":@"romRDMEidBw"},@{@"title":@"Johnny",@"key":@"romRDMEidBw"},@{@"title":@"Johnny",@"key":@"romRDMEidBw"},@{@"title":@"Johnny",@"key":@"romRDMEidBw"}]];
        [product setValue:arrayDemo forKey:@"youtube"];
        youtubeArray = (NSMutableArray*)[product valueForKey:@"youtube"];
        if (youtubeArray.count > 0) {
            LazyPageScrollView *_pageView = [[LazyPageScrollView alloc]initWithFrame:CGRectMake(0, infoView.heightCell, 320, 230)];
            _pageView.delegate = self;
            [infoView addSubview:_pageView];
            infoView.heightCell += 230;
            if (youtubeArray.count > 3) {
                [_pageView initTab:NO Gap:50 TabHeight:40 VerticalDistance:5 BkColor:[UIColor whiteColor]];
            }else
            {
                [_pageView initTab:YES Gap:50 TabHeight:40 VerticalDistance:5 BkColor:[UIColor whiteColor]];
            }
            [_pageView enableTabBottomLine:YES LineHeight:3 LineColor:[UIColor redColor] LineBottomGap:5 ExtraWidth:10];
            [_pageView setTitleStyle:[UIFont systemFontOfSize:15] Color:[UIColor blackColor] SelColor:THEME_COLOR];
            [_pageView enableBreakLine:YES Width:1 TopMargin:0 BottomMargin:0 Color:[UIColor groupTableViewBackgroundColor]];
            _pageView.leftTopView = [[UIView alloc]initWithFrame:CGRectZero];
            _pageView.rightTopView = [[UIView alloc]initWithFrame:CGRectZero];
            
            for (int i = 0; i < youtubeArray.count; i++) {
                NSDictionary *youtubeUnit = [youtubeArray objectAtIndex:i];
                UIView *view = [UIView new];
                
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 180)];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                [view addSubview:imageView];
                
                UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(135, 65, 50, 50)];
                [button setImage:[UIImage imageNamed:@"play_youtube"] forState:UIControlStateNormal];
                button.tag = i;
                [button addTarget:self action:@selector(didTouchYoutubeVideo:) forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:button];
                
                NSString *youtubeLink = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@",[youtubeUnit valueForKey:@"key"]];
                YKYouTubeVideo *video = [[YKYouTubeVideo alloc]initWithContent:[NSURL URLWithString:youtubeLink]];
                [video parseWithCompletion:^(NSError *error)
                 {
                     [video thumbImage:YKQualityHigh completion:^(UIImage *thumbImage, NSError *error) {
                         imageView.image = thumbImage;
                     }];
                 }];
                if (youtubeVideoArray == nil) {
                    youtubeVideoArray = [NSMutableArray new];
                }
                [youtubeVideoArray addObject:video];
                
                [_pageView addTab:[youtubeUnit valueForKey:@"title"] View:view Info:nil];
            }
            
            [_pageView generate];
            UIView *topView = [_pageView getTopContentView];
            UILabel *lb=[[UILabel alloc] init];
            lb.translatesAutoresizingMaskIntoConstraints=NO;
            lb.backgroundColor=[UIColor darkTextColor];
            [topView addSubview:lb];
            [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[lb]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lb)]];
            [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lb(==1)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lb)]];
        }
    }
}

- (void)didTouchYoutubeVideo:(id)sender
{
    UIButton *buttonYoutube = (UIButton*)sender;
    YKYouTubeVideo *youtubeVideo = [youtubeVideoArray objectAtIndex:buttonYoutube.tag];
    [youtubeVideo play:YKQualityHigh];
}

- (void)videoPlayBackDidFinish:(id)sender
{
    for (int i = 0; i < youtubeVideoArray.count; i++) {
        YKYouTubeVideo *youtubeVideo = [youtubeVideoArray objectAtIndex:i];
        youtubeVideo.player = nil;
    }
}
@end
