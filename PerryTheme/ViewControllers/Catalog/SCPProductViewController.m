//
//  SCPProductViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 5/3/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPProductViewController.h"
#import "SCPGlobalVars.h"
#import "SCPProductImagesViewController.h"

@interface SCPProductViewController ()

@end

@implementation SCPProductViewController

- (void)viewDidLoadBefore {
    [super viewDidLoadBefore];
}

- (void)viewDidAppearBefore:(BOOL)animated{
    [super viewDidAppearBefore:animated];
    self.contentTableView.backgroundColor = COLOR_WITH_HEX(@"#ededed");
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)createCells{
    SimiSection *mainSection = [[SimiSection alloc]initWithIdentifier:product_main_section];
    [self.cells addObject:mainSection];
    
    [mainSection addRowWithIdentifier:product_images_row height:tableWidth];
//    [mainSection addRowWithIdentifier:product_nameandprice_row height:200];
//    if (optionController.hasOption) {
//        [mainSection addRowWithIdentifier:product_option_row height:50];
//    }
    [mainSection addRowWithIdentifier:product_description_row height:200];
//    if (self.product.additional) {
//        NSDictionary *additional = self.product.additional;
//        if (additional.count > 0) {
//            [mainSection addRowWithIdentifier:product_techspecs_row height:50];
//        }
//    }
}

- (UITableViewCell *)createProductImageCell:(SimiRow *)row{
    UITableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = COLOR_WITH_HEX(@"#ededed");
        float imageWidth = tableWidth - paddingEdge*2;
        float imageHeight = row.height - 2*paddingEdge;
        UIView *imageView = [[UIView alloc] initWithFrame:CGRectMake(paddingEdge, paddingEdge, imageWidth, imageHeight)];
        imageView.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:imageView];
        if (imagesScrollView == nil) {
            imagesScrollView = [[UIScrollView alloc]initWithFrame:imageView.bounds];
            imagesScrollView.pagingEnabled = YES;
            imagesScrollView.showsHorizontalScrollIndicator = NO;
            imagesScrollView.delegate = self;
            [imageView addSubview:imagesScrollView];
            
            if (self.product.images) {
                productImages = [[NSMutableArray alloc]initWithArray:self.product.images];
            }
            for (int i = 0; i < productImages.count; i++) {
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i*imageWidth, 0,imageWidth, imageHeight)];
                NSDictionary *imageDict = [productImages objectAtIndex:i];
                if([imageDict valueForKey:@"url"])
                    [imageView sd_setImageWithURL:[imageDict valueForKey:@"url"] placeholderImage:[UIImage imageNamed:@"logo"] options:SDWebImageRetryFailed];
                [imageView setContentMode:UIViewContentModeScaleAspectFit];
                [imagesScrollView addSubview:imageView];
            }
            
            if (productImages.count == 0) {
                [imagesScrollView setContentSize:CGSizeMake(imageWidth, imageHeight)];
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:imagesScrollView.bounds];
                [imageView setImage:[UIImage imageNamed:@"logo"]];
                [imageView setContentMode:UIViewContentModeScaleAspectFit];
                [imagesScrollView addSubview:imageView];
            }else
                [imagesScrollView setContentSize:CGSizeMake(imageWidth *productImages.count, imageHeight)];
            UITapGestureRecognizer *imageTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToProductImage:)];
            [imagesScrollView addGestureRecognizer:imageTapGesture];
            
            imagesPageControll = [[UIPageControl alloc]initWithFrame:CGRectMake(0, imageHeight - 15, CGRectGetWidth(imageView.frame), 15)];
            imagesPageControll.autoresizingMask = UIViewAutoresizingNone;
            if (productImages.count > 0)
                imagesPageControll.numberOfPages = productImages.count;
            else
                imagesPageControll.numberOfPages = 1;
            imagesPageControll.currentPageIndicatorTintColor = SCP_ICON_HIGHLIGHT_COLOR;
            imagesPageControll.tintColor = SCP_ICON_HIGHLIGHT_COLOR;
            [imageView addSubview:imagesPageControll];
        }
    }
    return cell;
}

- (UITableViewCell *)createNameCell:(SimiRow *)row{
    return [super createNameCell:row];
}

- (UITableViewCell *)createRelatedCell:(SimiRow *)row{
    return [super createRelatedCell:row];
}

- (UITableViewCell *)createDescriptionCell:(SimiRow *)row{
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if (cell == nil) {
        cell = [[SimiTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.backgroundColor = [UIColor clearColor];
        float heightCell = 0;
        UIView *descriptionView = [[UIView alloc] initWithFrame:CGRectMake(paddingEdge, heightCell, tableWidth - 2*paddingEdge, 0)];
        [cell.contentView addSubview:descriptionView];
        descriptionView.backgroundColor = [UIColor whiteColor];
        UIImageView *nextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(descriptionView.frame) - paddingEdge - 30, paddingEdge, 20, 20)];
        nextImageView.image = [[UIImage imageNamed:@"scp_ic_next"] imageWithColor:SCP_ICON_COLOR];
        [descriptionView addSubview:nextImageView];
        SimiLabel *titleLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, paddingEdge, CGRectGetWidth(descriptionView.frame) - paddingEdge*2 - 40, 30) andFontName:THEME_FONT_NAME_REGULAR andFontSize:FONT_SIZE_LARGE];
        [titleLabel setText:[SCLocalizedString(@"Description") uppercaseString]];
        [descriptionView addSubview:titleLabel];
        heightCell += 40;
        
        if (self.product.shortDescription) {
            NSString *shortDescription = self.product.shortDescription;
            if (![shortDescription isEqualToString:@""]) {
                SimiLabel *shortDescriptionLabel = [[SimiLabel alloc]initWithFrame:CGRectMake(paddingEdge, heightCell, CGRectGetWidth(descriptionView.frame) - paddingEdge*2, 30) andFontSize:FONT_SIZE_MEDIUM];
                NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithData:[shortDescription dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                [attributeString addAttributes:@{NSFontAttributeName:[UIFont fontWithName:THEME_FONT_NAME size:FONT_SIZE_MEDIUM]} range:NSMakeRange(0, attributeString.length)];
                shortDescriptionLabel.attributedText = attributeString;
                [descriptionView addSubview:shortDescriptionLabel];
                heightCell = [shortDescriptionLabel resizLabelToFit] + paddingEdge;
            }
        }
        CGRect frame = descriptionView.frame;
        frame.size.height = heightCell;
        descriptionView.frame = frame;
        cell.heightCell = heightCell + paddingEdge;
        [SimiGlobalFunction sortViewForRTL:descriptionView andWidth:CGRectGetWidth(descriptionView.frame)];
    }
    row.height = cell.heightCell;
    return cell;
}

- (void)tapToProductImage:(id)sender{
    SCPProductImagesViewController *imagesViewController = [SCPProductImagesViewController new];
    imagesViewController.productImages = [productImages valueForKey:@"url"];
    imagesViewController.currentIndexImage = imagesPageControll.currentPage;
    [self presentViewController:imagesViewController animated:YES completion:nil];
}
@end
