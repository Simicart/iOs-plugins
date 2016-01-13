//
//  SimiStoreLocatorDetailViewController.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/3/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiViewController.h>
#import "SimiStoreLocatorModel.h"
#import <MessageUI/MessageUI.h>

#define SIZE_SCROLL_VIEW_DETAIL ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 320 : 680)
@protocol SimiStoreLocatorDetailViewControllerDelegate <NSObject>
@optional
- (void)returnMapViewController:(SimiStoreLocatorModel*)sLModelParam;
@end

@interface SimiStoreLocatorDetailViewController : SimiViewController<MFMailComposeViewControllerDelegate>


@property (nonatomic, strong) SimiStoreLocatorModel *sLModel;
@property (nonatomic) float currentLatitude;
@property (nonatomic) float currentLongitude;

/*
@property (nonatomic, strong) IBOutlet UIScrollView *scrView;
@property (nonatomic, strong) IBOutlet UILabel *lblStoreName;
@property (nonatomic, strong) IBOutlet UILabel *lblStoreAddress;

@property (nonatomic, strong) IBOutlet UIView *viewStorePhone;
@property (nonatomic, strong) IBOutlet UILabel *lblStorePhone;

@property (nonatomic, strong) IBOutlet UIView *viewStoreEmail;
@property (nonatomic, strong) IBOutlet UILabel *lblStoreEmail;

@property (nonatomic, strong) IBOutlet UIView *viewStoreWebSite;
@property (nonatomic, strong) IBOutlet UILabel *lblStoreWebSite;

@property (nonatomic, strong) IBOutlet UIImageView *imgStore;
@property (nonatomic, strong) IBOutlet UILabel *lblGetdirection;
@property (nonatomic, strong) IBOutlet UIButton *btnGetdirection;

@property (nonatomic, strong) IBOutlet UIView *viewInfomation;
@property (nonatomic, strong) IBOutlet UILabel *lblInfomationContents;
@property (nonatomic, strong) IBOutlet UIButton *btnShowMoreLess;

@property (nonatomic, strong) IBOutlet UIView *viewOpenHours;
@property (nonatomic, strong) IBOutlet UILabel *lblOpenHours;
@property (nonatomic, strong) IBOutlet UILabel *lblMonday;
@property (nonatomic, strong) IBOutlet UILabel *lblTuesday;
@property (nonatomic, strong) IBOutlet UILabel *lblWednesday;
@property (nonatomic, strong) IBOutlet UILabel *lblThursday;
@property (nonatomic, strong) IBOutlet UILabel *lblFriday;
@property (nonatomic, strong) IBOutlet UILabel *lblSaturday;
@property (nonatomic, strong) IBOutlet UILabel *lblSunday;
@property (nonatomic, strong) IBOutlet UILabel *lblMondayContent;
@property (nonatomic, strong) IBOutlet UILabel *lblTuesdayContent;
@property (nonatomic, strong) IBOutlet UILabel *lblWednesdayContent;
@property (nonatomic, strong) IBOutlet UILabel *lblThursdayContent;
@property (nonatomic, strong) IBOutlet UILabel *lblFridayContent;
@property (nonatomic, strong) IBOutlet UILabel *lblSaturdayContent;
@property (nonatomic, strong) IBOutlet UILabel *lblSundayContent;

@property (nonatomic, weak) id<SimiStoreLocatorDetailViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet UILabel *lblSpecialsDay;
@property (nonatomic, strong) IBOutlet UIView *viewSpecialsDay;
@property (nonatomic, strong) IBOutlet UILabel *lblSpecialsDayContent;

@property (nonatomic, strong) IBOutlet UILabel *lblHolidays;
@property (nonatomic, strong) IBOutlet UIView *viewHolidays;
@property (nonatomic, strong) IBOutlet UILabel *lblHolidaysContent;


- (IBAction)btnStorePhone_Click:(id)sender;
- (IBAction)btnStoreEmail_Click:(id)sender;
- (IBAction)btnStoreWebSite_Click:(id)sender;
- (IBAction)btnShowMoreLess_Click:(id)sender;
- (IBAction)btnGetDirections_Click:(id)sender;
- (IBAction)btnViewMap_Click:(id)sender;
*/

@property (nonatomic, strong)   UIScrollView *scrView;
@property (nonatomic, strong)   UILabel *lblStoreName;
@property (nonatomic, strong)   UILabel *lblStoreAddress;
@property (nonatomic, strong)   UIImageView *imgIconAddress;

@property (nonatomic, strong)   UIButton *btnStorePhone;
@property (nonatomic, strong)   UILabel *lblStorePhone;
@property (nonatomic, strong)   UIImageView *imgIconPhone;

@property (nonatomic, strong)   UIButton *btnStoreEmail;
@property (nonatomic, strong)   UILabel *lblStoreEmail;
@property (nonatomic, strong)   UIImageView *imgIconEmail;

@property (nonatomic, strong)   UIButton *btnStoreWebsite;
@property (nonatomic, strong)   UILabel *lblStoreWebSite;
@property (nonatomic, strong)   UIImageView *imgIconWebsite;


@property (nonatomic, strong)   UIImageView *imgStore;
@property (nonatomic, strong)   UILabel *lblGetdirection;
@property (nonatomic, strong)   UIButton *btnGetdirection;
@property (nonatomic, strong)   UIImageView *imgStoreBackground;
@property (nonatomic, strong)   UIButton *btnDirection;

@property (nonatomic, strong)   UIView *viewInfomation;
@property (nonatomic, strong)   UILabel *lblInfomationContents;
@property (nonatomic, strong)   UIButton *btnShowMoreLess;
@property (nonatomic, strong)   UIImageView *imgInformation;

@property (nonatomic, strong)   UIView *viewOpenHours;
@property (nonatomic, strong)   UIImageView *imgIconOpenHours;
@property (nonatomic, strong)  UILabel *lblOpenHours;
@property (nonatomic, strong)  UILabel *lblMonday;
@property (nonatomic, strong)  UILabel *lblTuesday;
@property (nonatomic, strong)  UILabel *lblWednesday;
@property (nonatomic, strong)  UILabel *lblThursday;
@property (nonatomic, strong)  UILabel *lblFriday;
@property (nonatomic, strong)  UILabel *lblSaturday;
@property (nonatomic, strong)  UILabel *lblSunday;
@property (nonatomic, strong)  UILabel *lblMondayContent;
@property (nonatomic, strong)  UILabel *lblTuesdayContent;
@property (nonatomic, strong)  UILabel *lblWednesdayContent;
@property (nonatomic, strong)  UILabel *lblThursdayContent;
@property (nonatomic, strong)  UILabel *lblFridayContent;
@property (nonatomic, strong)  UILabel *lblSaturdayContent;
@property (nonatomic, strong)  UILabel *lblSundayContent;

@property (nonatomic, weak) id<SimiStoreLocatorDetailViewControllerDelegate> delegate;

@property (nonatomic, strong)  UILabel *lblSpecialsDay;
@property (nonatomic, strong)  UIView *viewSpecialsDay;
@property (nonatomic, strong)  UILabel *lblSpecialsDayContent;
@property (nonatomic, strong)  UIImageView *imgIconSpecialDay;

@property (nonatomic, strong)  UILabel *lblHolidays;
@property (nonatomic, strong)  UIView *viewHolidays;
@property (nonatomic, strong)  UILabel *lblHolidaysContent;
@property (nonatomic, strong)  UIImageView *imgIconHolidays;


- (void)btnStorePhone_Click:(id)sender;
- (void)btnStoreEmail_Click:(id)sender;
- (void)btnStoreWebSite_Click:(id)sender;
- (void)btnShowMoreLess_Click:(id)sender;
- (void)btnGetDirections_Click:(id)sender;
- (void)btnViewMap_Click:(id)sender;

@end
