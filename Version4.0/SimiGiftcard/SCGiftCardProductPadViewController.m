//
//  SCGiftCardProductPadViewController.m
//  SimiCartPluginFW
//
//  Created by Liam on 8/17/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCGiftCardProductPadViewController.h"

@interface SCGiftCardProductPadViewController ()

@end

@implementation SCGiftCardProductPadViewController
@synthesize cells = _cells;
- (void)viewDidLoadBefore
{
    self.rootEventName = SCProductSecondDesignViewController_RootEventName;
    [self configureLogo];
    [self configureNavigationBarOnViewDidLoad];
    
    tableWidth = SCREEN_WIDTH/2;
    paddingEdge = SCALEVALUE(15);
    heightHeader = 44;
}

- (void)viewDidAppearBefore:(BOOL)animated
{
    if (self.contentTableView == nil) {
        CGRect frame = self.view.bounds;
        frame.size.width = SCREEN_WIDTH/2;
        frame.origin.x = SCREEN_WIDTH/2;
        self.contentTableView = [[UITableView alloc]initWithFrame:frame style:UITableViewStyleGrouped];
        self.contentTableView.delegate = self;
        self.contentTableView.dataSource = self;
        [self.view addSubview:self.contentTableView];
        [self.contentTableView setContentInset:UIEdgeInsetsMake(0, 0, 100, 0)];
        [self.contentTableView setHidden:YES];
        
        [self getProductDetail];
        [self startLoadingData];
    }
}

- (void)didGetProduct:(NSNotification *)noti{
    [self stopLoadingData];
    [self.contentTableView setHidden:NO];
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    if ([noti.name isEqualToString:DidGetGiftCardDetail]) {
        if (responder.status == SUCCESS) {
            if ([[self.product valueForKey:@"simigift_template_ids"] isKindOfClass:[NSArray class]]) {
                NSArray *simiGiftTemplateIds = [self.product valueForKey:@"simigift_template_ids"];
                if (simiGiftTemplateIds.count > 0) {
                    NSDictionary *giftTemplate = [simiGiftTemplateIds objectAtIndex:0];
                    giftCardTemplateID = [NSString stringWithFormat:@"%@",[giftTemplate valueForKey:@"giftcard_template_id"]];
                    if ([[giftTemplate valueForKey:@"images"] isKindOfClass:[NSArray class]]) {
                        giftCardTemplateImages = [giftTemplate valueForKey:@"images"];
                    }
                }
            }
            if ([[self.product valueForKey:@"is_salable"]boolValue]) {
                [self initViewAction];
            }
            [self setCells:nil];
            [self initGiftCardImageView];
        }
        [[NSNotificationCenter defaultCenter]removeObserverForNotification:noti];
    }
}

- (void)initCells{
    _cells = [SimiTable new];
    SimiSection *mainSection = [[SimiSection alloc]initWithIdentifier:product_main_section];
    [_cells addObject:mainSection];
    [mainSection addRowWithIdentifier:product_nameandprice_row height:100];
    [mainSection addRowWithIdentifier:giftcard_sendpostoffice_checkbox_row height:44];
    [mainSection addRowWithIdentifier:giftcard_sendfriend_checkbox_row height:44];
    [mainSection addRowWithIdentifier:product_description_row height:200];
    if ([[self.product valueForKeyPath:@"additional"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *additional = [self.product valueForKeyPath:@"additional"];
        if (additional.count > 0) {
            [mainSection addRowWithIdentifier:product_techspecs_row height:50];
        }
    }
    [self endInitCellsWithInfo:@{}];
    [mainSection sortItems];
    [self.contentTableView reloadData];
}

- (void)initGiftCardImageView{
    float imageWidth = tableWidth - paddingEdge*2;
    float imageHeight = imageWidth/1.88;
    giftCardImageView = [[UIImageView alloc]initWithFrame:CGRectMake(paddingEdge, paddingEdge, imageWidth, imageHeight)];
    [giftCardImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:giftCardImageView];
    
    if (giftCardTemplateImages.count > 0) {
        [giftCardImageView sd_setImageWithURL:[NSURL URLWithString:[[giftCardTemplateImages objectAtIndex:0] valueForKey:@"url"]] placeholderImage:[UIImage imageNamed:@"logo"]];
    }
    
    float heightCell = imageHeight + paddingEdge*2;
    SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - paddingEdge*2, 20) andFontName:THEME_FONT_NAME_REGULAR andFontSize:18 andTextColor:THEME_CONTENT_COLOR text:@"Choose an images"];
    [self.view addSubview:titleLabel];
    heightCell += 20;
    
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.minimumLineSpacing = 10;
    templatesCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - paddingEdge*2, 80) collectionViewLayout:flowLayout];
    [templatesCollectionView setBackgroundColor:[UIColor whiteColor]];
    templatesCollectionView.delegate = self;
    templatesCollectionView.dataSource = self;
    [self.view addSubview:templatesCollectionView];
    heightCell += 90;
    
    SimiLabel *uploadImageLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - paddingEdge*2, 20) andFontName:THEME_FONT_NAME_REGULAR andFontSize:18 andTextColor:THEME_CONTENT_COLOR text:@"Or upload your photo"];
    [self.view addSubview:uploadImageLabel];
    heightCell += 30;
    
    SimiButton *uploadImageButton = [[SimiButton alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, 140, 30) title:@"Upload image" titleFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:16] cornerRadius:4 borderWidth:0 borderColor:0];
    [uploadImageButton addTarget:self action:@selector(uploadImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:uploadImageButton];
    
    uploadImageView = [[UIImageView alloc]initWithFrame:CGRectMake(paddingEdge + 160, heightCell, 80, 80)];
    uploadImageView.contentMode = UIViewContentModeScaleAspectFit;
    uploadImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectUploadImage:)];
    [uploadImageView addGestureRecognizer:gesture];
    heightCell += 90;
    [self.view addSubview:uploadImageView];
    
}

- (void)uploadImage:(UIButton*)sender{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}


@end
