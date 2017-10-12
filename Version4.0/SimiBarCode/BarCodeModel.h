//
//  BarCodeModel.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 1/20/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiModel.h>

static NSString *const BarCodeDidGetProductID =  @"BarCode-DidGetProductID";

@interface BarCodeModel : SimiModel
@property (strong, nonatomic) NSString *barcodeId;
@property (strong, nonatomic) NSString *barcode;
@property (strong, nonatomic) NSString *qrcode;
@property (strong, nonatomic) NSString *barcodeStatus;
@property (strong, nonatomic) NSString *productEntityId;
@property (strong, nonatomic) NSString *productName;
@property (strong, nonatomic) NSString *productSku;
@property (strong, nonatomic) NSString *createdDate;

- (void)getProductIdWithBarCode:(NSString*)barCode type:(NSString*)type;
@end
