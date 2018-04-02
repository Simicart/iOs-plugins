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

@implementation SimiZbarResult
@end

@interface SimiZBarWrapper()<ZBarReaderViewDelegate>
@property (nonatomic, strong) ZBarReaderView *readerView;
@property (nonatomic, copy) void (^success)(NSArray<SimiZbarResult*> *result);
@end

@implementation SimiZBarWrapper
- (instancetype)initWithPreView:(UIView*)preView barCodeType:(zbar_symbol_type_t)barCodeType block:(void(^)(NSArray<SimiZbarResult*> *result))block
{
    if (self = [super init])
    {
        self.success = block;
        
        self.readerView= [[ZBarReaderView alloc]init];
        _readerView.frame = CGRectMake(0,0, preView.frame.size.width, preView.frame.size.height);
        _readerView.tracksSymbols=NO;
        _readerView.readerDelegate =self;
        _readerView.torchMode = 0;
        [self changeBarCode:barCodeType];
        
        [preView addSubview:_readerView];
    }
    return self;
}

- (void)changeBarCode:(zbar_symbol_type_t)zbarFormat{
    ZBarImageScanner *scanner = _readerView.scanner;
    [scanner setSymbology: zbarFormat
                   config: ZBAR_CFG_ENABLE
                       to: 1];
}

- (void)start{
    [_readerView start];
}

-(void)stop{
    [_readerView stop];
}

- (void)openOrCloseFlash{
    _readerView.torchMode = 1 - _readerView.torchMode;
}

#pragma mark -- ZBarReaderViewDelegate

- (void) readerView: (ZBarReaderView*) readerView  didReadSymbols: (ZBarSymbolSet*) symbols  fromImage: (UIImage*) image{
    [self stop];
    
    ZBarSymbol *symbol = nil;
    
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:1];
    for (symbol in symbols) {
        NSLog(@"%@",NSStringFromCGRect(symbol.bounds));
        NSString* strCode = symbol.data;
        zbar_symbol_type_t format = symbol.type;
        
        SimiZbarResult *result = [SimiZbarResult new];
        result.strScanned = strCode;
        result.imgScanned = image;
        result.format = format;
        
        [array addObject:result];
    }
    
    if (_success) {
        _success(array);
    }
}

+ (void)recognizeImage:(UIImage*)image block:(void(^)(NSArray<SimiZbarResult*> *result))block
{
    UIImage * aImage = image;
    ZBarReaderController *read = [ZBarReaderController new];
    CGImageRef cgImageRef = aImage.CGImage;
    ZBarSymbol* symbol = nil;
    
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:1];
    
    for(symbol in [read scanImage:cgImageRef]){
        
        NSString* strCode = symbol.data;
        zbar_symbol_type_t format = symbol.type;
        
        SimiZbarResult *result = [SimiZbarResult new];
        result.strScanned = strCode;
        result.imgScanned = image;
        result.format = format;
        
        [array addObject:result];
    }
    
    if (block) {
        block(array);
    }
}

+ (NSString*)convertFormat2String:(zbar_symbol_type_t)format
{
    NSString* str = @"";
    switch (format) {
        case ZBAR_NONE:
            str = @"ZBAR_NONE";
            break;
        case ZBAR_PARTIAL:
            str = @"ZBAR_PARTIAL";
            break;
        case ZBAR_EAN2:
            str = @"ZBAR_EAN2";
            break;
        case ZBAR_EAN5:
            str = @"ZBAR_EAN5";
            break;
        case ZBAR_EAN8:
            str = @"ZBAR_EAN8";
            break;
        case ZBAR_ISBN10:
            str = @"ZBAR_ISBN10";
            break;
        case ZBAR_UPCA:
            str = @"ZBAR_UPCA";
            break;
        case ZBAR_EAN13:
            str = @"ZBAR_EAN13";
            break;
        case ZBAR_ISBN13:
            str = @"ZBAR_ISBN13";
            break;
        case ZBAR_COMPOSITE:
            str = @"ZBAR_COMPOSITE";
            break;
        case ZBAR_I25:
            str = @"ZBAR_I25";
            break;
        case ZBAR_DATABAR:
            str = @"ZBAR_DATABAR";
            break;
        case ZBAR_DATABAR_EXP:
            str = @"ZBAR_DATABAR_EXP";
            break;
        case ZBAR_CODE39:
            str = @"ZBAR_CODE39";
            break;
        case ZBAR_QRCODE:
            str = @"ZBAR_QRCODE";
            break;
        case ZBAR_PDF417:
            str = @"ZBAR_PDF417";
            break;
        case ZBAR_CODE93:
            str = @"ZBAR_CODE93";
            break;
        case ZBAR_CODE128:
            str = @"ZBAR_CODE128";
            break;
        case ZBAR_SYMBOL:
            str = @"ZBAR_SYMBOL";
            break;
        case ZBAR_ADDON2:
            str = @"ZBAR_ADDON2";
            break;
        case ZBAR_ADDON5:
            str = @"ZBAR_ADDON5";
            break;
        case ZBAR_ADDON:
            str = @"ZBAR_ADDON";
            break;
        default:
            break;
    }
    return str;
}
@end

