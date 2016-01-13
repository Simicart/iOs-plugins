//
//  SCCategoryProductCell_Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/18/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCCategoryProductCell_Theme01.h"

@implementation SCCategoryProductCell_Theme01
@synthesize cateModel;

- (id)initWithFrame:(CGRect)frame isAllCate:(BOOL)isAllCate
{
    self = [super initWithFrame:frame];
    self.isAllCate = isAllCate;
    if (self) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            _slideShow = [[SCTheme01SlideShow alloc]initWithFrame:self.bounds];
            [_slideShow setImagesContentMode:UIViewContentModeScaleAspectFill];
            [_slideShow setDelay:3];
            [_slideShow setTransitionDuration:0.5];
            [_slideShow setTransitionType:SCTheme01SlideShowTransitionSlideUpDown];
            [self addSubview:_slideShow];
            if (!_isAllCate) {
                imgCateBackGround = [[UIImageView alloc]initWithFrame:CGRectMake(0, 35, self.frame.size.width, 40)];
                imgCateBackGround.alpha = 0.5;
                imgCateBackGround.backgroundColor = [UIColor whiteColor];
                [self addSubview:imgCateBackGround];
                
                lblCateName = [[UILabel alloc]initWithFrame:CGRectMake(0, 40, self.frame.size.width, 20)];
                [lblCateName setFont:[UIFont fontWithName:THEME01_FONT_NAME_BOLD size:18]];
                lblCateName.textAlignment = NSTextAlignmentCenter;
                [self addSubview:lblCateName];
                
                lblViewMore = [[UILabel alloc]initWithFrame:CGRectMake(0, 56, self.frame.size.width, 15)];
                [lblViewMore setFont:[UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:12]];
                lblViewMore.textAlignment = NSTextAlignmentCenter;
                [lblViewMore setText:SCLocalizedString(@"View more")];
                [self addSubview:lblViewMore];
                if (self.frame.size.width == 210) {
                    imgChoice = [[UIImageView alloc]initWithFrame:CGRectMake(133, 63, 7, 5)];
                }else
                {
                    imgChoice = [[UIImageView alloc]initWithFrame:CGRectMake(80, 63, 7, 5)];
                }
                [imgChoice setImage:[UIImage imageNamed:@"theme1_viewmore"]];
                [self addSubview:imgChoice];
            }else
            {
                imgCateBackGround = [[UIImageView alloc]initWithFrame:self.bounds];
                imgCateBackGround.alpha = 1;
                [imgCateBackGround setImage:[UIImage imageNamed:@"theme1_images_transpa_view_now"]];
                [self addSubview:imgCateBackGround];
                
                lblCateName = [[UILabel alloc]initWithFrame:CGRectMake(0, 40, self.frame.size.width, 20)];
                [lblCateName setFont:[UIFont fontWithName:THEME01_FONT_NAME_BOLD size:10]];
                [lblCateName setTextColor:[UIColor whiteColor]];
                lblCateName.textAlignment = NSTextAlignmentCenter;
                [self addSubview:lblCateName];
                
                // Liam UPDATE 20150502
                /*
                imgChoice = [[UIImageView alloc]initWithFrame:CGRectMake(22, 60, 60, 17)];
                [imgChoice setImage:[UIImage imageNamed:@"theme1_bt_view_now"]];
                [self addSubview:imgChoice];
                 */
                lblChoice = [[UILabel alloc]initWithFrame:CGRectMake(22, 60, 60, 17)];
                [lblChoice setBackgroundColor:[UIColor whiteColor]];
                [lblChoice.layer setCornerRadius:4];
                [lblChoice.layer setMasksToBounds:YES];
                [lblChoice setTextAlignment:NSTextAlignmentCenter];
                [lblChoice setFont:[UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:12]];
                [lblChoice setText:SCLocalizedString(@"View now")];
                [self addSubview:lblChoice];
                
                // End
            }
            btnCate = [[UIButton alloc]initWithFrame:self.bounds];
            [btnCate addTarget:self action:@selector(didSelectCategory) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btnCate];
        }else
        {
            _slideShow = [[SCTheme01SlideShow alloc]initWithFrame:self.bounds];
            _slideShow.layer.borderWidth = 1.0;
            _slideShow.layer.borderColor = [UIColor colorWithRed:213.0/255.0 green:213.0/255.0 blue:215.0/255.0 alpha:1.0].CGColor;
            [_slideShow setImagesContentMode:UIViewContentModeScaleAspectFill];
            [_slideShow setDelay:3];
            [_slideShow setTransitionDuration:0.5];
            [_slideShow setTransitionType:SCTheme01SlideShowTransitionSlideUpDown];
            [self addSubview:_slideShow];
            if (!_isAllCate) {
                imgCateBackGround = [[UIImageView alloc]initWithFrame:CGRectMake(0, 50, self.frame.size.width, 60)];
                imgCateBackGround.alpha = 0.5;
                imgCateBackGround.backgroundColor = [UIColor whiteColor];
                [self addSubview:imgCateBackGround];
                
                lblCateName = [[UILabel alloc]initWithFrame:CGRectMake(0, 55, self.frame.size.width, 30)];
                [lblCateName setFont:[UIFont fontWithName:THEME01_FONT_NAME_BOLD size:22]];
                lblCateName.textAlignment = NSTextAlignmentCenter;
                [self addSubview:lblCateName];
                
                lblViewMore = [[UILabel alloc]initWithFrame:CGRectMake(0, 81, self.frame.size.width, 15)];
                [lblViewMore setFont:[UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:16]];
                lblViewMore.textAlignment = NSTextAlignmentCenter;
                [lblViewMore setText:SCLocalizedString(@"View more")];
                [self addSubview:lblViewMore];
                if (self.frame.size.width == 332) {
                    imgChoice = [[UIImageView alloc]initWithFrame:CGRectMake(202, 89, 7, 5)];
                }else
                {
                    imgChoice = [[UIImageView alloc]initWithFrame:CGRectMake(120, 89, 7, 5)];
                }
                [imgChoice setImage:[UIImage imageNamed:@"theme1_viewmore"]];
                [self addSubview:imgChoice];
            }else
            {
                imgCateBackGround = [[UIImageView alloc]initWithFrame:self.bounds];
                imgCateBackGround.alpha = 1;
                [imgCateBackGround setImage:[UIImage imageNamed:@"theme1_images_transpa_view_now"]];
                [self addSubview:imgCateBackGround];
                
                lblCateName = [[UILabel alloc]initWithFrame:CGRectMake(0, 60, self.frame.size.width, 20)];
                [lblCateName setFont:[UIFont fontWithName:THEME01_FONT_NAME_BOLD size:16]];
                [lblCateName setTextColor:[UIColor whiteColor]];
                lblCateName.textAlignment = NSTextAlignmentCenter;
                [self addSubview:lblCateName];
                
                // Liam UPDATE 150502
                /*
                imgChoice = [[UIImageView alloc]initWithFrame:CGRectMake(33, 85, 100, 28)];
                [imgChoice setImage:[UIImage imageNamed:@"theme1_bt_view_now"]];
                [self addSubview:imgChoice];
                */
                lblChoice = [[UILabel alloc]initWithFrame:CGRectMake(33, 85, 100, 28)];
                [lblChoice setBackgroundColor:[UIColor whiteColor]];
                [lblChoice.layer setCornerRadius:4];
                [lblChoice.layer setMasksToBounds:YES];
                [lblChoice setTextAlignment:NSTextAlignmentCenter];
                [lblChoice setFont:[UIFont fontWithName:THEME01_FONT_NAME_LIGHT size:16]];
                [lblChoice setText:SCLocalizedString(@"View now")];
                [self addSubview:lblChoice];
                //  End
            }
            btnCate = [[UIButton alloc]initWithFrame:self.bounds];
            [btnCate addTarget:self action:@selector(didSelectCategory) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btnCate];
        }
    }
    return self;
}

- (void)cusSetCateModel:(SimiCategoryModel *)cateModel_
{
    self.cateModel = cateModel_;
    [lblCateName setText:SCLocalizedString([[self.cateModel valueForKey:@"category_name"]uppercaseString])];
    NSMutableArray * array = [self.cateModel valueForKey:@"images"];
    if (array.count > 0) {
        for (int i = 0; i < array.count; i++) {
            [self.slideShow addImagePath:[array objectAtIndex:i]];
        }
    }
}

- (void)didSelectCategory
{
    [self.delegate didSelectCateGoryWithCateModel:cateModel];
}

@end
