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
            [self initializedGiftCardInfo];
            if ([[self.product valueForKey:@"is_salable"]boolValue]) {
                [self initViewAction];
            }
            [self initCells];
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
    if ([[giftCardSettings valueForKey:@"simigift_postoffice"]boolValue]) {
        [mainSection addRowWithIdentifier:giftcard_sendpostoffice_checkbox_row height:44];
    }
    [mainSection addRowWithIdentifier:giftcard_sendfriend_checkbox_row height:44];
    [mainSection addRowWithIdentifier:product_description_row height:200];
    if (self.product.additional) {
        NSDictionary *additional = self.product.additional;
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
    float heightCell = imageHeight + paddingEdge*2;
    if (simiGiftTemplates.count > 0) {
        if(simiGiftTemplates.count > 1){
            SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - paddingEdge*2, 20) andFontName:THEME_FONT_NAME_REGULAR andFontSize:18 andTextColor:THEME_CONTENT_COLOR text:@"Select a template"];
            [self.view addSubview:titleLabel];
            heightCell += 20;
            
            UIImageView *dropdownImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 40)];
            [dropdownImageView setContentMode:UIViewContentModeScaleAspectFit];
            [dropdownImageView setImage:[UIImage imageNamed:@"ic_dropdown"]];
            selectTemplateTextField = [[SimiTextField alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - paddingEdge*2, 40) placeHolder:@"" font:[UIFont fontWithName:THEME_FONT_NAME size:16] textColor:THEME_CONTENT_COLOR borderWidth:1 borderColor:[UIColor lightGrayColor] cornerRadius:4 leftView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 40)] rightView:dropdownImageView];
            selectTemplateTextField.delegate = self;
            [selectTemplateTextField setText:[selectedTemplate valueForKey:@"template_name"]];
            [self.view addSubview:selectTemplateTextField];
            heightCell += 50;
        }else{
            SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - paddingEdge*2, 20) andFontName:THEME_FONT_NAME_REGULAR andFontSize:18 andTextColor:THEME_CONTENT_COLOR text:@"Choose an images"];
            [self.view addSubview:titleLabel];
            heightCell += 20;
        }
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
    }
    if (giftCardTemplateImages.count > 0) {
        [giftCardImageView sd_setImageWithURL:[NSURL URLWithString:[[giftCardTemplateImages objectAtIndex:0] valueForKey:@"url"]] placeholderImage:[UIImage imageNamed:@"logo"]];
    }
    
    if ([giftCardSettings valueForKey:@"simigift_template_upload"]) {
        SimiLabel *uploadImageLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - paddingEdge*2, 20) andFontName:THEME_FONT_NAME_REGULAR andFontSize:18 andTextColor:THEME_CONTENT_COLOR text:@"Or upload your photo"];
        [self.view addSubview:uploadImageLabel];
        heightCell += 30;
        
        SimiButton *uploadImageButton = [[SimiButton alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, 140, 30) title:@"Upload" titleFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:16] cornerRadius:4 borderWidth:0 borderColor:0];
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
}

- (void)uploadImage:(UIButton*)sender{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}


@end
