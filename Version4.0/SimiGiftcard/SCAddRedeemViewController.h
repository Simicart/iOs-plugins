//
//  SCAddRedeemViewController.h
//  SimiCartPluginFW
//
//  Created by Liam on 8/12/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//
#import "SimiTextField.h"
#import "SimiGiftCardCreditModel.h"

@protocol  SCAddRedeemViewControllerDelegate<NSObject>
- (void)didRedeemOrAddGiftCode:(SimiGiftCardCreditModel*)creditModel;
@end

@interface SCAddRedeemViewController : SimiViewController{
    SimiTextField *giftCodeTextField;
    SimiGiftCardCreditModel *giftCardCreditModel;
    SimiButton *redeemGiftCardButton;
    SimiButton *addToListButton;
}
@property (weak, nonatomic) id<SCAddRedeemViewControllerDelegate> delegate;

@end
