//
//  SimiAffiliatesCouponWorker.m
//  SimiCartPluginFW
//
//  Created by KingRetina on 5/19/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiAffiliatesCouponWorker.h"

#import <SimiCartBundle/SCCartViewController.h>
#import <SimiCartBundle/SCOrderViewController.h>
#import <SimiCartBundle/SimiGlobalVar.h>
#import <SimiCartBundle/SimiTable.h>
#import <SimiCartBundle/SCOrderFeeCell.h>
#import <SimiCartBundle/SimiFormatter.h>


@implementation SimiAffiliatesCouponWorker

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCOrderViewControllerViewDidLoad" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetOrderConfig" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:)
            name:@"DidSetCouponCode" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidSaveShippingMethod" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidSavePaymentMethod" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidSpendPointsOrder" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"InitializedOrderCell-After" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCOrderViewController-InitTableBefore" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCOrderViewController-InitTableAfter" object:nil];
        

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCOrderDetailViewControllerViewDidLoad" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"InitializedOrderDetailCell-After" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCCartViewController-ViewDidLoad" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"InitializedCartCell-After" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCOrderViewController_Theme01" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCCartViewController_Theme01" object:nil];
        
        //Order screen init order table on ipad
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCOrderViewController-InitRightTableAfter" object:nil];
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    NSLog(@"%@", noti.name);
    if (([noti.name isEqualToString:@"DidGetOrderConfig"] || [noti.name isEqualToString:@"DidSpendPointsOrder"] || [noti.name isEqualToString:@"DidSetCouponCode"] || [noti.name isEqualToString:@"DidSaveShippingMethod"] || [noti.name isEqualToString:@"SCOrderViewController-InitTableBefore"] || [noti.name isEqualToString:@"DidSavePaymentMethod"] || [noti.name isEqualToString:@"SCOrderViewController-InitTableAfter"] || [noti.name isEqualToString:@"SCOrderViewController-InitRightTableAfter"]) && self.orderViewController) {
        SimiOrderModel *order = [self.orderViewController order];
        
        NSDictionary *fee = [order objectForKey:@"fee"];
        NSMutableDictionary *v2 = [fee valueForKey:@"v2"];
        if (![v2 isKindOfClass:[NSMutableDictionary class]]) {
            v2 = [[NSMutableDictionary alloc] initWithDictionary:v2];
            [fee setValue:v2 forKey:@"v2"];
        }
        NSLog(@"%@", fee);
        if ([fee objectForKey:@"affiliates_discount"]) {
            [v2 setValue:[fee objectForKey:@"affiliates_discount"] forKey:@"affiliates_discount"];
        }
        if([fee objectForKey:@"coupon_code"]){
            [v2 setValue:[fee objectForKey:@"coupon_code"] forKey:@"coupon_code"];
        }
    }
    else if ([noti.name isEqualToString:@"SCOrderViewControllerViewDidLoad"] || [noti.name isEqualToString:@"SCOrderDetailViewControllerViewDidLoad"]) {
        self.orderViewController = noti.object;
    }else if ([noti.name isEqualToString:@"SCCartViewController-ViewDidLoad"] || [noti.name isEqualToString:@"SCCartViewController_Theme01"]) {
        self.tableViewCart = noti.object;
    }else if ([noti.name isEqualToString:@"InitializedOrderCell-After"]) {
        SCOrderFeeCell *cell = [noti.userInfo objectForKey:@"cell"];
        NSDictionary *fee    = [[[self.orderViewController order] objectForKey:@"fee"] objectForKey:@"v2"];
        if ([cell isKindOfClass:[SCOrderFeeCell class]] && fee) {
            // Label 22 + 3
//            CGFloat origionTitleX = cell.frame.size.width - 310;
//            CGFloat widthTitle    = 190;
//            CGFloat origionValueX = cell.frame.size.width - 170;
//            CGFloat widthValue    = 160;
//            CGFloat marginTop     = 0;
//            CGFloat subThreshold   = 0;
//            CGFloat subTotalMargin = marginTop;
            for (UIView *subView in cell.subviews) {
                [subView removeFromSuperview];
            }
            float heightCell = 5;
            float widthTitle = [SimiGlobalVar scaleValue:190];
            float widthValue = [SimiGlobalVar scaleValue:97];
            float origionTitleX = [SimiGlobalVar scaleValue:16];
            float origionValueX = [SimiGlobalVar scaleValue:206];
            float heightLabel = 22;
            float heightLabelWithDistance = 25;
            CGFloat marginTop = 0;
            CGFloat subThreshold = 0;
            CGFloat subTotalMargin = marginTop;
            UILabel *discount, *discountValue;
            
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                heightCell = 30;
                origionValueX = cell.frame.size.width - 120;
                widthValue = 100;
                origionTitleX = 10;
                widthTitle = cell.frame.size.width - 130;
                heightLabel = 22;
                heightLabelWithDistance = 25;
            }
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                origionTitleX = 115;
                widthTitle = 195;
                origionValueX = 15;
                widthValue = 120;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    origionTitleX = 460;
                    widthTitle = 195;
                    origionValueX = 320;
                    widthValue = 120;
                }
            }
            if ([fee objectForKey:@"affiliates_discount"]) {
                for (UIView *view in cell.subviews) {
                    if ([view isEqual:cell.subTotalExclLabel] || [view isEqual:cell.subTotalLabel] || [view isEqual:cell.subTotalInclLabel]) {
                        subThreshold = MAX(subThreshold, view.frame.origin.y);
                    }
                }
                marginTop += 25;
                subTotalMargin = marginTop + 25;
                discount = [[UILabel alloc] init];
                discount.frame = CGRectMake(origionTitleX, subThreshold + marginTop, widthTitle, 22);
                discount.text = [SCLocalizedString(@"Affiliates Discount") stringByAppendingString:@":"];
                discount.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
                discountValue = [[UILabel alloc] init];
                discountValue.frame = CGRectMake(origionValueX, subThreshold + marginTop, widthValue, 22);
                discountValue.font = discount.font;
                discountValue.textAlignment = NSTextAlignmentRight;
                discountValue.textColor = THEME_PRICE_COLOR;
                discountValue.text = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[fee objectForKey:@"affiliates_discount"]];
            }
            if (marginTop > 1) {
                for (UIView *view in cell.subviews) {
                    CGRect frame = view.frame;
                    if (frame.origin.y > subThreshold) {
                        frame.origin.y += marginTop;
                    }
                    view.frame = frame;
                }
            }
            if (discountValue) {
                [cell addSubview:discount];
                [cell addSubview:discountValue];
            }
        }
    }else if ([noti.name isEqualToString:@"InitializedOrderDetailCell-After"]) {
        SCOrderFeeCell *cell = [noti.userInfo objectForKey:@"cell"];
        NSDictionary *fee    = [[self.orderViewController order] objectForKey:@"total_v2"];
        if ([cell isKindOfClass:[SCOrderFeeCell class]] && fee && !self.isAddAffiliatesOrderLabel) {
            CGFloat origionTitleX = cell.frame.size.width - 310;
            CGFloat widthTitle    = 190;
            CGFloat origionValueX = cell.frame.size.width - 170;
            CGFloat widthValue    = 160;
            UILabel *discount, *discountValue;
            CGFloat marginTop     = 0;
            CGFloat subThreshold   = 0;
            CGFloat subTotalMargin = marginTop;
            if ([fee objectForKey:@"affiliates_discount"]) {
                for (UIView *view in cell.subviews) {
                    if ([view isEqual:cell.subTotalExclLabel] || [view isEqual:cell.subTotalLabel] || [view isEqual:cell.subTotalInclLabel]) {
                        subThreshold = MAX(subThreshold, view.frame.origin.y);
                    }
                }
                marginTop += 25;
                subTotalMargin = marginTop + 25;
                discount = [[UILabel alloc] init];
                discount.frame = CGRectMake(origionTitleX, subThreshold + marginTop, widthTitle, 22);
                discount.text = [SCLocalizedString(@"Affiliates Discount") stringByAppendingString:@":"];
                discount.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
                discountValue = [[UILabel alloc] init];
                discountValue.frame = CGRectMake(origionValueX, subThreshold + marginTop, widthValue, 22);
                discountValue.font = discount.font;
                discountValue.textAlignment = NSTextAlignmentRight;
                discountValue.textColor = THEME_PRICE_COLOR;
                discountValue.text = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[fee objectForKey:@"affiliates_discount"]];
            }
            if (marginTop > 1) {
                for (UIView *view in cell.subviews) {
                    CGRect frame = view.frame;
                    if (frame.origin.y > subThreshold) {
                        frame.origin.y += marginTop;
                    }
                    view.frame = frame;
                }
            }
            if (discountValue) {
                [cell addSubview:discount];
                [cell addSubview:discountValue];
            }
        }
    }else if ([noti.name isEqualToString:@"InitializedCartCell-After"]) {
        SCOrderFeeCell *cell = [noti.userInfo objectForKey:@"cell"];
        NSMutableArray *fee = [self.tableViewCart cartPrices];
        if ([cell isKindOfClass:[SCOrderFeeCell class]] && fee) {
            CGFloat origionTitleX = cell.frame.size.width - 310;
            CGFloat widthTitle    = 190;
            CGFloat origionValueX = cell.frame.size.width - 170;
            CGFloat widthValue    = 160;
            UILabel *discount, *discountValue;
            CGFloat marginTop     = 0;
            CGFloat subThreshold   = 0;
            CGFloat subTotalMargin = marginTop;
            if ([fee valueForKey:@"affiliates_discount"]) {
                for (UIView *view in cell.subviews) {
                    if ([view isEqual:cell.subTotalExclLabel] || [view isEqual:cell.subTotalLabel] || [view isEqual:cell.subTotalInclLabel]) {
                        subThreshold = MAX(subThreshold, view.frame.origin.y);
                    }
                }
                marginTop += 25;
                subTotalMargin = marginTop + 25;
                discount = [[UILabel alloc] init];
                discount.frame = CGRectMake(origionTitleX, subThreshold + marginTop, widthTitle, 22);
                discount.text = [SCLocalizedString(@"Affiliates Discount") stringByAppendingString:@":"];
                discount.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
                discountValue = [[UILabel alloc] init];
                discountValue.frame = CGRectMake(origionValueX, subThreshold + marginTop, widthValue, 22);
                discountValue.font = discount.font;
                discountValue.textAlignment = NSTextAlignmentRight;
                discountValue.textColor = THEME_PRICE_COLOR;
                discountValue.text = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[fee valueForKey:@"affiliates_discount"]];
            }
            if (marginTop > 1) {
                for (UIView *view in cell.subviews) {
                    CGRect frame = view.frame;
                    if (frame.origin.y > subThreshold) {
                        frame.origin.y += marginTop;
                    }
                    view.frame = frame;
                }
            }
            if (discountValue) {
                [cell addSubview:discount];
                [cell addSubview:discountValue];               
            }
        }
    }
}

- (SimiTable *)orderTableRight
{
    return nil;
}


@end