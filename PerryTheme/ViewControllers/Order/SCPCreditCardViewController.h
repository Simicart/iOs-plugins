//
//  SCPCreditCardViewController.h
//  SimiCartPluginFW
//
//  Created by Liam on 6/19/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SCCreditCardViewController.h>
#import "SCPGlobalVars.h"

typedef NS_ENUM(NSInteger, CreditCardBrand) {
    CreditCardBrandVisa,
    CreditCardBrandMasterCard,
    CreditCardBrandUnknown
};

static NSString *scpcreditcard_cardtype_section = @"scpcreditcard_cardtype_section";
static NSString *scpcreditcard_cardnumber_section = @"scpcreditcard_cardnumber_section";
static NSString *scpcreditcard_cardexpired_section = @"scpcreditcard_cardexpired_section";
static NSString *scpcreditcard_cardcvv_section = @"scpcreditcard_cardcvv_section";
static NSString *scpcreditcard_cardusername_section = @"scpcreditcard_cardusername_section";
@interface SCPCreditCardViewController : SCCreditCardViewController<UICollectionViewDelegate, UICollectionViewDataSource,SimiTextFieldDelegate, UITextFieldDelegate>{
    SimiTextField *numberTextField;
    SimiTextField *yearTextField;
    SimiTextField *monthTextField;
    SimiTextField *cvvTextField;
    SimiTextField *cartUserNameTextField;
    UIButton *saveButton;
}
@end

@interface SCPCreditCardTypeCollectionViewCell:UICollectionViewCell{
    UIImageView *iconSelectImageView;
    UIImageView *logoCardImageView;
    SimiLabel *cardTypeNameLabel;
    NSDictionary *imageNames;
}
@property (strong, nonatomic) NSDictionary *cardTypeInfo;
- (void)updateCellInfo:(NSDictionary *)info state:(BOOL)state;
@end
