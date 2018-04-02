//
//  BarCodeModel.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 1/20/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiModel.h>
#import "ZBarSDK.h"

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

@interface SimiZbarResult : NSObject
@property (nonatomic, copy) NSString* strScanned;
@property (nonatomic, strong) UIImage* imgScanned;
@property (nonatomic, assign) zbar_symbol_type_t format;
@end

@interface SimiZBarWrapper : NSObject
- (instancetype)initWithPreView:(UIView*)preView barCodeType:(zbar_symbol_type_t)barCodeType block:(void(^)(NSArray<SimiZbarResult*> *result))block;
- (void)changeBarCode:(zbar_symbol_type_t)zbarFormat;
- (void)start;
- (void)stop;
- (void)openOrCloseFlash;
+ (void)recognizeImage:(UIImage*)image block:(void(^)(NSArray<SimiZbarResult*> *result))block;
+ (NSString*)convertFormat2String:(zbar_symbol_type_t)format;

@end
