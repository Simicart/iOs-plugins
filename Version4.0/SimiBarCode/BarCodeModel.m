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
//barcode_id, barcode,qrcode,barcode_status,product_entity_id,product_name,product_sku,created_date
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

- (void)getProductIdWithBarCode:(NSString *)barCode type:(NSString *)type
{
    notificationName = BarCodeDidGetProductID;
    self.parseKey = @"simibarcode";
    actionType = ModelActionTypeGet;
    [[BarCodeAPI new] getProductIdWithBarCode:barCode type:type target:self selector:@selector(didGetResponseFromNetwork:)];
}
@end
