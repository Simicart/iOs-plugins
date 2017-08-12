//
//  SCGiftCardProductViewController.h
//  SimiCartPluginFW
//
//  Created by Liam on 8/9/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//

#import "SCProductSecondDesignViewController.h"
#import "SimiGiftCardModel.h"
#import "SimiCheckbox.h"
#import "SimiTextField.h"
#import "ActionSheetPicker.h"
#import "SCGiftCardGlobalVar.h"

static NSString *giftcard_template_row = @"giftcard_template_row";
static NSString *giftcard_sendpostoffice_checkbox_row = @"giftcard_sendpostoffice_checkbox_row";
static NSString *giftcard_sendfriend_checkbox_row = @"giftcard_sendfriend_checkbox_row";
static NSString *giftcard_recommendinfo_row = @"giftcard_recommendinfo_row";
static NSString *giftcard_insertinfo_row = @"giftcard_insertinfo_row";

@interface SCGiftCardProductViewController : SCProductSecondDesignViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate>{
    UIImageView *giftCardImageView;
    NSArray *giftCardTemplateImages;
    NSInteger templateImageSelectedIndex;
    UICollectionView *templatesCollectionView;
    UIImageView *uploadImageView;
    SimiGiftCardModel *uploadImageModel;
    M13Checkbox *sendThroughPostOfficeCheckbox;
    M13Checkbox *sendGiftcardToFriendCheckbox;
    BOOL isSendThroughPostOffice;
    BOOL isSendGiftcardToFriend;
    
    SimiTextField *senderNameTextField;
    SimiTextField *recipientNameTextField;
    SimiTextField *recipientEmailTextField;
    UITextView *customMessageTextView;
    SimiCheckbox *getNotificationCheckbox;
    SimiTextField *dayToSendTextField;
    SimiTextField *selectTimeZoneTextField;
    NSDate *selectedDate;
    NSDictionary *giftCardPrices;
    SimiLabel *priceLabel;
    NSDictionary *priceValues;
    NSArray *giftCardValues;
    NSMutableArray *giftCardValueTitles;
    NSInteger valueSelectedIndex;
    SimiTextField *giftCardValueTextField;
    NSString *giftCardTemplateID;
    
    SimiGiftCardTimeZoneModelCollection *timeZoneModelCollection;
    NSMutableArray *timeZoneTitles;
    NSInteger timeZoneSelectedIndex;
    
    NSString *giftCardTypeValue;
}

@property (nonatomic) BOOL useUploadImage;
@end

@interface GiftCardTemplateCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSString *imagePath;
@end
