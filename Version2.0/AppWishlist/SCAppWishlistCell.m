//
//  SCProductListCell.m
//  SimiCart
//
//  Created by Tan on 4/30/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "SCAppWishlistCell.h"
#import <SimiCartBundle/SimiFormatter.h>
#import <SimiCartBundle/UILabelDynamicSize.h>
#import <SimiCartBundle/NSString+HTML.h>
#import "SimiGlobalVar+WishlistVar.h"
#import "SCAppWishlistModelCollection.h"
#import "SCAppWishlistModel.h"
#import <SimiCartBundle/SCProductViewController.h>
#import "SCAppWishlist.h"
#import <SimiCartBundle/UIImage+SimiCustom.h>



static NSInteger const WISHLIST_CELL_HEIGHT = 150 ;
static NSInteger const WISHLIST_DELETE_CONFIRMATION_ALERT_TAG = 2;
static NSInteger const WISHLIST_ITEM_NOT_SELECTED_REQUIRED_OPTIONS = 3;
static NSInteger const WISHLIST_MORE_OPTION_BUTTON_HEIGHT = 30;
static NSInteger const WISHLIST_MORE_OPTION_BUTTON_WIDTH = 220;
static NSInteger const WISHLIST_MORE_OPTION_FRAME_HEIGHT_FROM_TOP = 147;
static NSInteger const WISHLIST_MORE_OPTION_FRAME_HEIGHT =  85;
static NSInteger const WISHLIST_DISTANCE_FROM_MORE_OPTION_BUTTONS_TO_LEFT_SCREEN_BORDER = 50;
static NSInteger const WISHLIST_DISTANCE_FROM_MORE_OPTION_FRAME_TO_BUTTONS = 10;
static NSInteger const WISHLIST_DISTANCE_BETWEEN_BUTTONS = 5;



@interface SCAppWishlistCell()
    @property(nonatomic, strong) NSString *productName;
    @property(nonatomic, strong) NSString *stockStatus;
    @property(nonatomic, strong) NSString *productImagePath;
    @property(nonatomic, strong) NSArray *otherInfos;
    @property(nonatomic) NSInteger reviewNumber;
    @property(nonatomic) BOOL isInstock;



@end

@implementation SCAppWishlistCell


//@synthesize productName, stockStatus, price, productImagePath, productRate, reviewNumber;
@synthesize product, productImagePath, productImageView, productName, productNameLabel, productPrice, shareButton, deleteButton, sharingUrl, sharingMessage, moreOptionsFrame, triangle, imageBorder, moreOptionNarrow;

@synthesize   stockStatus, isInstock
;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
       
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setProduct:(SimiProductModel *)pr{
    UIColor * colorBG =[UIColor colorWithRed:(240/255.0) green:(240/255.0) blue:(240/255.0) alpha:1.0];
    
    triangle.image  = [triangle.image imageWithColor:colorBG];
    triangle.hidden = YES;
    
    
    [self.option1Title setText:@""];
    [self.option1Value setText:@""];
    [self.option2Title setText:@""];
    [self.option2Value setText:@""];
    [self.haveMoreOptionLabel setText:@""];
    [self.priceLabel setText:@""];
    
    product = pr;
    self.productName = [product valueForKeyPath:@"product_name"];
    self.productImagePath = [product valueForKey:@"product_image"];
    self.reviewNumber = [[product valueForKey:@"product_review_number"] integerValue];
    self.isInstock= [[product valueForKeyPath:@"stock_status"] boolValue];
    NSMutableArray *a = [product valueForKey:@"options"];
    productPrice = (NSNumber *)[product valueForKey:@"product_price"];
    [self.moreOptionButton setTitle:[NSString stringWithFormat:@"%@         ", SCLocalizedString(@"More options")]  forState:UIControlStateNormal];
    [self.moreOptionButton addTarget:self action:@selector(showMoreOption:) forControlEvents:UIControlEventTouchUpInside];

    int optionCount = 3;
    
    if(a != nil)
        optionCount = [self updateOptionValue:a];
    
    switch (optionCount) {
        
        case 0:
            self.priceLabel.frame = CGRectMake(120, 25, 140, 21);
            break;
        case 1:
            self.priceLabel.frame = CGRectMake(120, 45, 140, 21);
            break;
        case 2:
            self.priceLabel.frame = CGRectMake(120, 61, 140, 21);
            break;
        case 3:
            self.priceLabel.frame = CGRectMake(120, 74, 140, 21);
            break;
            
        default:
            break;
    }
    self.priceLabel.text = [[SimiFormatter sharedInstance] priceByLocalizeNumber:productPrice];
    
    sharingMessage = [product valueForKeyPath:@"product_sharing_message"];
    sharingUrl = [product valueForKeyPath:@"product_sharing_url"];
    
    moreOptionsFrame = [[UIImageView alloc]init];
    moreOptionNarrow.clipsToBounds = YES;
    moreOptionsFrame.frame = CGRectMake(WISHLIST_DISTANCE_FROM_MORE_OPTION_BUTTONS_TO_LEFT_SCREEN_BORDER, WISHLIST_MORE_OPTION_FRAME_HEIGHT_FROM_TOP, SCREEN_WIDTH, WISHLIST_MORE_OPTION_FRAME_HEIGHT);

    [moreOptionsFrame setBackgroundColor:([UIColor colorWithRed:(240/255.0) green:(240/255.0) blue:(240/255.0) alpha:1.0])];
    //UIImage * moreOptionsFrameBg = [[UIImage imageNamed:@"pixel"] imageWithColor:colorBG];
   // UIImageView * moreOptionsFrameBgImgView = [[UIImageView alloc]initWithImage:moreOptionsFrameBg];
    //moreOptionsFrameBgImgView.frame = CGRectMake(0, 0, 400, 400);
    
    [moreOptionsFrame setImage:[[UIImage imageNamed:@"pixel"] imageWithColor:colorBG]];
    
    UIButton * doNothingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, WISHLIST_MORE_OPTION_FRAME_HEIGHT)];
    [doNothingButton setBackgroundColor:[UIColor clearColor]];
    [moreOptionsFrame addSubview:doNothingButton];
    
 
    
    shareButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    UIImage * shareButtonImage = [SCAppWishlist imageWithName:@"moreoptionshare" withColor:[UIColor blackColor]];
    [shareButton setImage:shareButtonImage forState:UIControlStateNormal];
    [shareButton setImageEdgeInsets:UIEdgeInsetsMake((WISHLIST_MORE_OPTION_BUTTON_HEIGHT - 22)/2, 70, (WISHLIST_MORE_OPTION_BUTTON_HEIGHT- 21)/2, WISHLIST_MORE_OPTION_BUTTON_WIDTH - 90)];
    [shareButton setBackgroundColor:[UIColor whiteColor]];
    [shareButton setBackgroundImage:[[UIImage imageNamed:@"pixel"]imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [shareButton setTitle:SCLocalizedString(@"Share") forState:UIControlStateNormal];
    [shareButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    shareButton.layer.cornerRadius = 2.0f;
    shareButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [shareButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 0)];
    [shareButton addTarget:self action:@selector(shareProduct) forControlEvents:UIControlEventTouchUpInside];
    
    
    deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    UIImage * deleteButtonImage = [SCAppWishlist imageWithName:@"moreoptiondelete" withColor:[UIColor redColor]];
    [deleteButton setImage:deleteButtonImage forState:UIControlStateNormal];
    [deleteButton setImageEdgeInsets:UIEdgeInsetsMake((WISHLIST_MORE_OPTION_BUTTON_HEIGHT - 20)/2, 70, (WISHLIST_MORE_OPTION_BUTTON_HEIGHT- 18)/2, WISHLIST_MORE_OPTION_BUTTON_WIDTH - 90)];
    [deleteButton setBackgroundColor:[UIColor whiteColor]];
    [deleteButton setBackgroundImage:[[UIImage imageNamed:@"pixel"]imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [deleteButton setTitle:SCLocalizedString(@"Remove") forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    deleteButton.layer.cornerRadius = 2.0f;
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
    
    [deleteButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [deleteButton addTarget:self action:@selector(deleteProduct) forControlEvents:UIControlEventTouchUpInside];
    moreOptionsFrame.userInteractionEnabled = YES;
    [moreOptionsFrame addSubview:deleteButton];
    [moreOptionsFrame addSubview:shareButton];
    
    moreOptionsFrame.hidden = YES;
    
    [self addSubview:moreOptionsFrame];
    
    [self bringSubviewToFront:self.moreOptionButton];
    
    
    //self.inclPrice =[product valueForKey:@"product_price"];
}

#pragma mark overide Set Property

- (void)setProductName:(NSString *)pn{
    if (![productName isEqualToString:pn]) {
        productName = [pn copy];
        productNameLabel.text = productName;
        //[productNameLabel resizLabelToFit];
        CGRect frame = productNameLabel.frame;
        if(frame.size.height > 40){
            frame.size.height = 40;
            productNameLabel.numberOfLines = 2;
        }
        productNameLabel.frame = frame;

    }
}

- (int)updateOptionValue: (NSMutableArray*)options {
    int i = 0;
    for (NSMutableDictionary * item in options) {
        NSString* optionTitle = [item valueForKey:@"option_title"];
        NSString* optionValue = [item valueForKey:@"option_value"];
        if(i==0)
        {
            [self.option1Title setText: [NSString stringWithFormat:@"%@:", optionTitle]];
            [self.option1Value setText: optionValue];
        }
        else if (i==1)
        {
            [self.option2Title setText: [NSString stringWithFormat:@"%@:",optionTitle]];
            [self.option2Value setText: optionValue];
        }
        else
        {
            [self.haveMoreOptionLabel setText:@"..."];
        }
        i ++;
    }
    return i;

}

- (void)setIsInstock:(BOOL)status{
    isInstock = status;
    self.addToCartButton.layer.masksToBounds = YES;
    [self.addToCartButton.layer setCornerRadius:2.0f];

    if (isInstock) {
        [self.addToCartButton setTitle:@"Add To Cart" forState:UIControlStateNormal];
        
        [self.addToCartButton setBackgroundImage:addToCartButtonBackgroundImage forState:UIControlStateNormal];
        
        [self.addToCartButton addTarget:self action:@selector(addProductToCart) forControlEvents:UIControlEventTouchUpInside];
    }else{
        
        [self.addToCartButton setTitle:@"Out Stock" forState:UIControlStateNormal];
        
        UIColor *disableColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0) blue:(200/255.0) alpha:1.0]  ;
        
        [self.addToCartButton setBackgroundImage:[addToCartButtonBackgroundImage imageWithColor:disableColor] forState:UIControlStateNormal];
        
        [self.addToCartButton setBackgroundColor: disableColor];
    }
}




- (void)setProductImagePath:(NSString *)imagePath{
    if (![productImagePath isEqualToString:imagePath]) {
        productImagePath = [imagePath copy];
        NSURL *url = [NSURL URLWithString:productImagePath];
        [productImageView sd_setImageWithURL:url];
    }
    
    [imageBorder.layer setBorderColor: [[UIColor colorWithRed:(222/255.0) green:(222/255.0) blue:(222/255.0) alpha:1.0] CGColor]];
    [imageBorder.layer setBorderWidth: 1.0];
}


#pragma mark Set Interface
- (void)setInterfaceCell
{
    //self.addToCartButton.layer.cornerRadius = 2.0f;
    
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *lblView = (UILabel*)subview;
            [lblView removeFromSuperview];
        }
    }

}



- (void)addProductToCart {


    
    if([[product valueForKeyPath:@"selected_all_required_options"] boolValue]){
        [globalAppWishlistViewController.tableViewProductCollection.infiniteScrollingView startAnimating];
        [globalAppWishlistViewController.productCollection removeAllObjects];
        [globalAppWishlistViewController.tableViewProductCollection reloadData];
    
        [[NSNotificationCenter defaultCenter] addObserver:globalAppWishlistViewController selector:@selector(didGetWishlistProducts:) name:@"DidAddWishlistProductToCart" object:nil];
        [globalAppWishlistViewController.productCollection addWishlistProductToCart:[product valueForKeyPath:@"wishlist_item_id"] otherParams:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Warning"
                          message:  @"You haven't selected all the required option, please go to the product detail to add it again"
                          delegate: self
                          cancelButtonTitle: @"Cancel"
                          otherButtonTitles: @"OK", nil];
        alert.tag = WISHLIST_ITEM_NOT_SELECTED_REQUIRED_OPTIONS;
        [alert show];
    }
}

#pragma mark -
#pragma mark More Options Behavior

- (void)showMoreOption:(id)sender {
    
    
    NSIndexPath * a = [globalAppWishlistViewController.tableViewProductCollection indexPathForCell:self];
    
    SCAppWishlistCell *cell = [[SCAppWishlistCell alloc] init];
    for (NSInteger j = 0; j < [globalAppWishlistViewController.tableViewProductCollection numberOfSections]; ++j)
    {
        for (NSInteger i = 0; i < [globalAppWishlistViewController.tableViewProductCollection numberOfRowsInSection:j]; ++i)
        {
            cell =  (SCAppWishlistCell*)[globalAppWishlistViewController.tableViewProductCollection cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
            if(globalAppWishlistViewController.currentExpandingOption == i)
            {
                if(globalAppWishlistViewController.currentExpandingOption == a.row)
                    [cell hideButtons];
                else
                    [cell hideButtonsNoEffect];
            }
        }
    }
    
    
    
    if(globalAppWishlistViewController.currentExpandingOption == a.row){
        [self hideButtons];
        globalAppWishlistViewController.currentExpandingOption = -1;
        [self setHeightCell:WISHLIST_CELL_HEIGHT];
    }
    else{
        [self showButtons];
        globalAppWishlistViewController.currentExpandingOption = a.row;
        [self setHeightCell:WISHLIST_CELL_HEIGHT + WISHLIST_MORE_OPTION_FRAME_HEIGHT];
    }
    
    
    [globalAppWishlistViewController reloadInputViews];
    [globalAppWishlistViewController.tableViewProductCollection beginUpdates];
    [globalAppWishlistViewController.tableViewProductCollection endUpdates];
}

- (void)showButtons {
    if(!moreOptionsFrame.hidden)
        return;
    
    triangle.hidden = NO;
    
    moreOptionsFrame.hidden = NO;
    
    moreOptionNarrow.transform = CGAffineTransformMakeRotation(M_PI);
    
    shareButton.frame = CGRectMake(WISHLIST_DISTANCE_FROM_MORE_OPTION_BUTTONS_TO_LEFT_SCREEN_BORDER, WISHLIST_DISTANCE_FROM_MORE_OPTION_FRAME_TO_BUTTONS, WISHLIST_MORE_OPTION_BUTTON_WIDTH, 0);
    deleteButton.frame = CGRectMake(WISHLIST_DISTANCE_FROM_MORE_OPTION_BUTTONS_TO_LEFT_SCREEN_BORDER, WISHLIST_DISTANCE_FROM_MORE_OPTION_FRAME_TO_BUTTONS + WISHLIST_DISTANCE_BETWEEN_BUTTONS + WISHLIST_MORE_OPTION_FRAME_HEIGHT/2, WISHLIST_MORE_OPTION_BUTTON_WIDTH, 0);
    moreOptionsFrame.frame = CGRectMake(0, WISHLIST_MORE_OPTION_FRAME_HEIGHT_FROM_TOP, SCREEN_WIDTH, 0);
    deleteButton.hidden = YES;
    [UIView animateWithDuration:0.2 animations:^{
            moreOptionsFrame.frame = CGRectMake(0, WISHLIST_MORE_OPTION_FRAME_HEIGHT_FROM_TOP, SCREEN_WIDTH, WISHLIST_MORE_OPTION_FRAME_HEIGHT);
        }
    ];

    [UIView animateWithDuration:0.1 animations:^{
        shareButton.frame = CGRectMake(WISHLIST_DISTANCE_FROM_MORE_OPTION_BUTTONS_TO_LEFT_SCREEN_BORDER, WISHLIST_DISTANCE_FROM_MORE_OPTION_FRAME_TO_BUTTONS, WISHLIST_MORE_OPTION_BUTTON_WIDTH, WISHLIST_MORE_OPTION_BUTTON_HEIGHT);
    }
    completion:^(BOOL finised){
        if(finised){
            deleteButton.hidden = NO;
            [UIView animateWithDuration:0.1
                             animations:^{
                                 deleteButton.frame = CGRectMake(WISHLIST_DISTANCE_FROM_MORE_OPTION_BUTTONS_TO_LEFT_SCREEN_BORDER, WISHLIST_DISTANCE_FROM_MORE_OPTION_FRAME_TO_BUTTONS + WISHLIST_DISTANCE_BETWEEN_BUTTONS +WISHLIST_MORE_OPTION_BUTTON_HEIGHT, WISHLIST_MORE_OPTION_BUTTON_WIDTH, WISHLIST_MORE_OPTION_BUTTON_HEIGHT);
                             }];
        }
    }
 ];
}

- (void)hideButtons{
    if(moreOptionsFrame.hidden)
        return;
    
    triangle.hidden = YES;
    moreOptionNarrow.transform = CGAffineTransformMakeRotation(0);
    
    shareButton.frame = CGRectMake(WISHLIST_DISTANCE_FROM_MORE_OPTION_BUTTONS_TO_LEFT_SCREEN_BORDER, WISHLIST_DISTANCE_FROM_MORE_OPTION_FRAME_TO_BUTTONS, WISHLIST_MORE_OPTION_BUTTON_WIDTH, WISHLIST_MORE_OPTION_BUTTON_HEIGHT);
    deleteButton.frame = CGRectMake(WISHLIST_DISTANCE_FROM_MORE_OPTION_BUTTONS_TO_LEFT_SCREEN_BORDER, WISHLIST_DISTANCE_FROM_MORE_OPTION_FRAME_TO_BUTTONS + WISHLIST_DISTANCE_BETWEEN_BUTTONS + WISHLIST_MORE_OPTION_BUTTON_HEIGHT, WISHLIST_MORE_OPTION_BUTTON_WIDTH, WISHLIST_MORE_OPTION_BUTTON_HEIGHT/2);
     moreOptionsFrame.frame = CGRectMake(0, WISHLIST_MORE_OPTION_FRAME_HEIGHT_FROM_TOP, SCREEN_WIDTH, WISHLIST_MORE_OPTION_FRAME_HEIGHT/2);
    
    [UIView animateWithDuration:0.2 animations:^{
            moreOptionsFrame.frame = CGRectMake(0, WISHLIST_MORE_OPTION_FRAME_HEIGHT_FROM_TOP, SCREEN_WIDTH, 0);
        }
    ];
    
    [UIView animateWithDuration:0.1 animations:^{
            deleteButton.frame = CGRectMake(WISHLIST_DISTANCE_FROM_MORE_OPTION_BUTTONS_TO_LEFT_SCREEN_BORDER, WISHLIST_DISTANCE_FROM_MORE_OPTION_FRAME_TO_BUTTONS + WISHLIST_DISTANCE_BETWEEN_BUTTONS + WISHLIST_MORE_OPTION_BUTTON_HEIGHT, WISHLIST_MORE_OPTION_BUTTON_WIDTH, 0);
        }
                     completion:^(BOOL finised2){
                         if(finised2){
                             [UIView animateWithDuration:0.1
                                              animations:^{
                                                  shareButton.frame = CGRectMake(WISHLIST_DISTANCE_FROM_MORE_OPTION_BUTTONS_TO_LEFT_SCREEN_BORDER, WISHLIST_DISTANCE_FROM_MORE_OPTION_FRAME_TO_BUTTONS, WISHLIST_MORE_OPTION_BUTTON_WIDTH, 0);
                                              }
                                               completion:^(BOOL finised1){
                                                   if(finised1){
                                                       moreOptionsFrame.hidden = YES;
                                                   }
                                               }
                              ];
                         }
                     }
     ];

}


- (void) hideButtonsNoEffect{
    
        if(moreOptionsFrame.hidden)
            return;
    moreOptionNarrow.transform = CGAffineTransformMakeRotation(0);
    
    triangle.hidden = YES;
    shareButton.hidden = YES;
    deleteButton.hidden = YES;
        moreOptionsFrame.frame = CGRectMake(0, WISHLIST_MORE_OPTION_FRAME_HEIGHT_FROM_TOP, SCREEN_WIDTH, WISHLIST_MORE_OPTION_FRAME_HEIGHT/2);
        
        [UIView animateWithDuration:0.2 animations:^{
            moreOptionsFrame.frame = CGRectMake(0, WISHLIST_MORE_OPTION_FRAME_HEIGHT_FROM_TOP, SCREEN_WIDTH, 0);
        }
         completion:^(BOOL finised1){
             if(finised1){
                 shareButton.hidden = NO;
                 deleteButton.hidden = NO;
                moreOptionsFrame.hidden = YES;
             }
         }
        ];
    
}

- (void) shareProduct {
    
    NSString *shareString = sharingMessage;
    NSURL *shareUrl = [NSURL URLWithString:sharingUrl];
    shareString = [shareString stringByReplacingOccurrencesOfString:[shareUrl absoluteString] withString:@""];
    NSArray *activityItems = [NSArray arrayWithObjects:shareString, shareUrl, nil];
    //NSArray *activityItems = [NSArray arrayWithObjects:shareString, nil];

    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    
    //for iPad view
    UITableViewCell *cell = [[globalAppWishlistViewController.tableViewProductCollection visibleCells] objectAtIndex:0];
    NSIndexPath *indexPath = [globalAppWishlistViewController.tableViewProductCollection indexPathForCell:cell];
    NSInteger distanceFromTop = (globalAppWishlistViewController.currentExpandingOption - indexPath.row) *WISHLIST_CELL_HEIGHT + 60;
    if(distanceFromTop < 60) distanceFromTop = 60;
    if(distanceFromTop > 260) distanceFromTop = 260;
    
    
    //UIView* tempView = [[UIView alloc]initWithFrame:CGRectMake(self.frame.origin.y, self.frame.origin.x, self.frame.size.width, self.frame.size.height)];
    //tempView.frame = CGRectMake(self.frame.origin.y, SCREEN_HEIGHT - 300, 10, 10);
    activityViewController.popoverPresentationController.sourceView = self.moreOptionAnchor;
        
    [globalAppWishlistViewController presentViewController:activityViewController animated:YES completion:nil];
    
    
}

- (void) deleteProduct {
    
    // confirm the deletion..
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Warning"
                          message: @"Are you sure want to remove?"
                          delegate: self
                          cancelButtonTitle: @"Cancel"
                          otherButtonTitles: @"Yes", nil];
    alert.tag = WISHLIST_DELETE_CONFIRMATION_ALERT_TAG;
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case WISHLIST_DELETE_CONFIRMATION_ALERT_TAG:
        {
            switch (buttonIndex) {
                case 0: // cancel
                {
                    NSLog(@"Delete was cancelled");
                }
                    break;
                case 1: // delete
                {
                    [globalAppWishlistViewController.tableViewProductCollection.infiniteScrollingView startAnimating];
                    
                    if (globalAppWishlistiPadViewController!=nil) {
                        [globalAppWishlistiPadViewController startLoadingData];
                    }
                    else if(globalAppWishlistViewController){
                        [globalAppWishlistViewController startLoadingData];
                    }
                    
                    [globalAppWishlistViewController.productCollection removeAllObjects];
                    
                    [[NSNotificationCenter defaultCenter] addObserver:globalAppWishlistViewController selector:@selector(didRemoveProductFromWishlist:) name:@"DidRemoveProductFromWishlist" object:nil];
                    [globalAppWishlistViewController.productCollection removeProductFromWishlist:[product valueForKeyPath:@"wishlist_item_id"] otherParams:nil];

                }
                break;
            }
            break;
        }
        case WISHLIST_ITEM_NOT_SELECTED_REQUIRED_OPTIONS:
        {

            switch (buttonIndex) {
                case 0: // cancel
                {
                    
                }
                    break;
                case 1: // come to product detail
                {
                    SimiTableView * tableView = globalAppWishlistViewController.tableViewProductCollection;
                    NSIndexPath *indexPath = [tableView indexPathForCell:self];
                    [globalAppWishlistViewController viewProductDetail:indexPath];
                }
                break;

            }
            break;
        }
        default:
            NSLog(@"");
        
    }	
}


@end

