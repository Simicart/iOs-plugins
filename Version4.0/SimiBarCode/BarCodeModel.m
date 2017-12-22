//
//  BarCodeModel.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 1/20/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "BarCodeModel.h"
#import "BarCodeAPI.h"

@implementation BarCodeModel
- (void)parseData {
    [super parseData];
    self.barcodeId = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"barcode_id"]];
    self.barcode = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"barcode"]];
    self.qrcode = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"qrcode"]];
    self.barcodeStatus = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"barcode_status"]];
    self.productEntityId = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"product_entity_id"]];
    self.productName = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"product_name"]];
    self.productSku = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"product_sku"]];
    self.createdDate = [NSString stringWithFormat:@"%@",[self.modelData objectForKey:@"created_date"]];
}

- (void)getProductIdWithBarCode:(NSString *)barCode type:(NSString *)type{
    notificationName = BarCodeDidGetProductID;
    actionType = ModelActionTypeGet;
    self.parseKey = @"simibarcode";
    self.resource = @"simibarcodes";
    [self addParamsWithKey:@"type" value:type];
    [self addExtendsUrlWithKey:barCode];
    self.method = MethodGet;
    [self request];
}
@end
