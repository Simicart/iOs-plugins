//
//  SCPAdressTableViewCell.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 6/12/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPOrderAddressTableViewCell.h"
#import "SCPGlobalVars.h"

@implementation SCPOrderAddressTableViewCell{
    CGFloat cellWidth;
    SimiLabel *titleLabel, *nameLabel, *addressLabel, *phoneLabel, *mailLabel;
    float labelHeight;
    float contentPaddingY;
    float contentPaddingX,contentWidth;
    float imageInset;
    UIButton *nameButtonImageView, *addressButtonImageView, *phoneButtonImageView, *mailButtonImageView;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier width:(CGFloat)width type:(SCPAddressType)type{
    self.addressType = type;
    if(self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.simiContentView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, width - 30, 0)];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        self.simiContentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.simiContentView];
        cellWidth = width;
        contentPaddingX = SCALEVALUE(20);
        contentWidth = width - 2*contentPaddingX;
        labelHeight = 25;
        contentPaddingY = SCALEVALUE(15);
        imageInset = 5;
        
        nameButtonImageView = [[UIButton alloc] initWithFrame:CGRectMake(contentPaddingX, self.heightCell, labelHeight, labelHeight)];
        nameButtonImageView.contentEdgeInsets = UIEdgeInsetsMake(imageInset,imageInset,imageInset,imageInset);
        [self.simiContentView addSubview:nameButtonImageView];
        [nameButtonImageView setImage:[UIImage imageNamed:@"scp_ic_address_name"] forState:UIControlStateNormal];
        nameLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(contentPaddingX + labelHeight, self.heightCell, contentWidth - labelHeight, labelHeight) andFontName:SCP_FONT_LIGHT andFontSize:FONT_SIZE_MEDIUM andTextColor:[UIColor blackColor]];
        [self.simiContentView addSubview:nameLabel];
        self.heightCell += labelHeight;
        
        addressButtonImageView = [[UIButton alloc] initWithFrame:CGRectMake(contentPaddingX, self.heightCell, labelHeight, labelHeight)];
        addressButtonImageView.contentEdgeInsets = UIEdgeInsetsMake(imageInset,imageInset,imageInset,imageInset);
        [self.simiContentView addSubview:addressButtonImageView];
        [addressButtonImageView setImage:[UIImage imageNamed:@"scp_ic_address_location"] forState:UIControlStateNormal];
        addressLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(contentPaddingX + labelHeight, self.heightCell, contentWidth - labelHeight, labelHeight) andFontName:SCP_FONT_LIGHT andFontSize:FONT_SIZE_MEDIUM andTextColor:[UIColor blackColor]];
        [self.simiContentView addSubview:addressLabel];
        self.heightCell += labelHeight;
        
        phoneButtonImageView = [[UIButton alloc] initWithFrame:CGRectMake(contentPaddingX, self.heightCell, labelHeight, labelHeight)];
        phoneButtonImageView.contentEdgeInsets = UIEdgeInsetsMake(imageInset,imageInset,imageInset,imageInset);
        [self.simiContentView addSubview:phoneButtonImageView];
        [phoneButtonImageView setImage:[UIImage imageNamed:@"scp_ic_address_phone"] forState:UIControlStateNormal];
        phoneLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(contentPaddingX + labelHeight, self.heightCell, contentWidth - labelHeight, labelHeight) andFontName:SCP_FONT_LIGHT andFontSize:FONT_SIZE_MEDIUM andTextColor:[UIColor blackColor]];
        [self.simiContentView addSubview:phoneLabel];
        self.heightCell += labelHeight;
        
        mailButtonImageView = [[UIButton alloc] initWithFrame:CGRectMake(contentPaddingX, self.heightCell, labelHeight, labelHeight)];
        mailButtonImageView.contentEdgeInsets = UIEdgeInsetsMake(imageInset,imageInset,imageInset,imageInset);
        [self.simiContentView addSubview:mailButtonImageView];
        [mailButtonImageView setImage:[UIImage imageNamed:@"scp_ic_address_mail"] forState:UIControlStateNormal];
        mailLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(contentPaddingX + labelHeight, self.heightCell, contentWidth - labelHeight, labelHeight) andFontName:SCP_FONT_LIGHT andFontSize:FONT_SIZE_MEDIUM andTextColor:[UIColor blackColor]];
        [self.simiContentView addSubview:mailLabel];
        self.heightCell += labelHeight;
    
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void)setAddressModel:(SimiAddressModel *)addressModel{
    _addressModel = addressModel;
    self.heightCell = 0;
    nameButtonImageView.frame = CGRectMake(contentPaddingX, self.heightCell, labelHeight, labelHeight);
    nameLabel.frame = CGRectMake(contentPaddingX + labelHeight, self.heightCell, contentWidth - labelHeight, labelHeight);
    nameLabel.text = [NSString stringWithFormat:@"%@ %@",addressModel.firstName,addressModel.lastName];
    [nameLabel resizLabelToFit];
    self.heightCell += (nameLabel.labelHeight > labelHeight)?nameLabel.labelHeight:labelHeight;
    addressButtonImageView.frame = CGRectMake(contentPaddingX, self.heightCell, labelHeight, labelHeight);
    addressLabel.frame = CGRectMake(contentPaddingX + labelHeight, self.heightCell, contentWidth - labelHeight, labelHeight);
    NSMutableArray *result = [NSMutableArray new];
    if(addressModel.street){
        [result addObject:addressModel.street];
    }
    
    NSMutableArray *cityAndZip = [NSMutableArray new];
    if(addressModel.city){
        [cityAndZip addObject:addressModel.city];
    }
    
    if (addressModel.region) {
        [cityAndZip addObject:addressModel.region];
    }
    if (addressModel.postcode) {
        [cityAndZip addObject:addressModel.postcode];
    }
    if ([cityAndZip count]) {
        [result addObject:[cityAndZip componentsJoinedByString:@", "]];
    }
    
    if (addressModel.countryName) {
        [result addObject:addressModel.countryName];
    }
    
    addressLabel.text = [result componentsJoinedByString:@"\n"];
    [addressLabel resizLabelToFit];
    self.heightCell += (addressLabel.labelHeight > labelHeight)?addressLabel.labelHeight:labelHeight;
    phoneButtonImageView.frame = CGRectMake(contentPaddingX, self.heightCell, labelHeight, labelHeight);
    phoneLabel.frame = CGRectMake(contentPaddingX + labelHeight, self.heightCell, contentWidth - labelHeight, labelHeight);
    phoneLabel.text = addressModel.telephone;
    [phoneLabel resizLabelToFit];
    self.heightCell += (phoneLabel.labelHeight > labelHeight)?phoneLabel.labelHeight:labelHeight;
    mailButtonImageView.frame = CGRectMake(contentPaddingX, self.heightCell, labelHeight, labelHeight);
    mailLabel.frame = CGRectMake(contentPaddingX + labelHeight, self.heightCell, contentWidth - labelHeight, labelHeight);
    mailLabel.text = addressModel.email;
    [mailLabel resizLabelToFit];
    self.heightCell += (mailLabel.labelHeight > labelHeight)?mailLabel.labelHeight:labelHeight + SCALEVALUE(20);
    CGRect frame = self.simiContentView.frame;
    frame.size.height = self.heightCell;
    self.simiContentView.frame = frame;
}
@end
