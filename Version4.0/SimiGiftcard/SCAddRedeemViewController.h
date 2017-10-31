//
//  SCAddRedeemViewController.h
//  SimiCartPluginFW
//
//  Created by Liam on 8/12/17.
//  Copyright © 2017 Trueplus. All rights reserved.
//
#import <SimiCartBundle/SimiTextField.h>
#import "SimiGiftCardCreditModel.h"

@interface SCAddRedeemViewController : SimiViewController{
    SimiTextField *giftCodeTextField;
    SimiGiftCardCreditModel *giftCardCreditModel;
    SimiButton *redeemGiftCardButton;
    SimiButton *addToListButton;
}
@end
