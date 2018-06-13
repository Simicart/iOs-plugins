//
//  SCPAdressTableViewCell.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 6/12/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPAddressTableViewCell.h"
#import "SCPGlobalVars.h"

@implementation SCPAddressTableViewCell{
    CGFloat cellWidth;
    SimiLabel *titleLabel, *nameLabel, *addressLabel, *phoneLabel, *mailLabel;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier width:(CGFloat)width type:(SCPAddressType)type{
    self.addressType = type;
    if(self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        cellWidth = width;
        float titlePadding = SCALEVALUE(15);
        float editButtonWidth = 44;
        float titleWidth = width - titlePadding - editButtonWidth;
        float contentPaddingX = SCALEVALUE(20);
        float contentWidth = width - 2*contentPaddingX;
        float contentPaddingY = SCALEVALUE(15);
        float labelHeight = 25;
        self.heightCell = SCALEVALUE(20);
        float imageInset = 5;
        titleLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(titlePadding, self.heightCell, titleWidth, 25) andFontName:SCP_FONT_SEMIBOLD andFontSize:FONT_SIZE_HEADER andTextColor:SCP_TITLE_COLOR text:@"Billing Address"];
        [titleLabel resizLabelToFit];
        [self.contentView addSubview:titleLabel];
        self.heightCell += CGRectGetHeight(titleLabel.frame) + contentPaddingY;
        UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(width - editButtonWidth, 0, editButtonWidth, editButtonWidth)];
        [editButton setImage:[UIImage imageNamed:@"scp_ic_address_edit"] forState:UIControlStateNormal];
        editButton.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
        [editButton addTarget:self action:@selector(didSelectEditButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:editButton];
        {
            UIButton *buttonImageView = [[UIButton alloc] initWithFrame:CGRectMake(contentPaddingX, self.heightCell, labelHeight, labelHeight)];
            buttonImageView.contentEdgeInsets = UIEdgeInsetsMake(imageInset,imageInset,imageInset,imageInset);
            [self.contentView addSubview:buttonImageView];
            [buttonImageView setImage:[UIImage imageNamed:@"scp_ic_address_name"] forState:UIControlStateNormal];
            nameLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(contentPaddingX + labelHeight, self.heightCell, contentWidth - labelHeight, labelHeight) andFontName:SCP_FONT_LIGHT andFontSize:FONT_SIZE_MEDIUM andTextColor:[UIColor blackColor]];
            [self.contentView addSubview:nameLabel];
            self.heightCell += labelHeight;
        }
        {
            UIButton *buttonImageView = [[UIButton alloc] initWithFrame:CGRectMake(contentPaddingX, self.heightCell, labelHeight, labelHeight)];
            buttonImageView.contentEdgeInsets = UIEdgeInsetsMake(imageInset,imageInset,imageInset,imageInset);
            [self.contentView addSubview:buttonImageView];
            [buttonImageView setImage:[UIImage imageNamed:@"scp_ic_address_location"] forState:UIControlStateNormal];
            addressLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(contentPaddingX + labelHeight, self.heightCell, contentWidth - labelHeight, labelHeight) andFontName:SCP_FONT_LIGHT andFontSize:FONT_SIZE_MEDIUM andTextColor:[UIColor blackColor]];
            [self.contentView addSubview:addressLabel];
            self.heightCell += labelHeight;
        }
        {
            UIButton *buttonImageView = [[UIButton alloc] initWithFrame:CGRectMake(contentPaddingX, self.heightCell, labelHeight, labelHeight)];
            buttonImageView.contentEdgeInsets = UIEdgeInsetsMake(imageInset,imageInset,imageInset,imageInset);
            [self.contentView addSubview:buttonImageView];
            [buttonImageView setImage:[UIImage imageNamed:@"scp_ic_address_phone"] forState:UIControlStateNormal];
            phoneLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(contentPaddingX + labelHeight, self.heightCell, contentWidth - labelHeight, labelHeight) andFontName:SCP_FONT_LIGHT andFontSize:FONT_SIZE_MEDIUM andTextColor:[UIColor blackColor]];
            [self.contentView addSubview:phoneLabel];
            self.heightCell += labelHeight;
        }
        {
            UIButton *buttonImageView = [[UIButton alloc] initWithFrame:CGRectMake(contentPaddingX, self.heightCell, labelHeight, labelHeight)];
            buttonImageView.contentEdgeInsets = UIEdgeInsetsMake(imageInset,imageInset,imageInset,imageInset);
            [self.contentView addSubview:buttonImageView];
            [buttonImageView setImage:[UIImage imageNamed:@"scp_ic_address_mail"] forState:UIControlStateNormal];
            mailLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(contentPaddingX + labelHeight, self.heightCell, contentWidth - labelHeight, labelHeight) andFontName:SCP_FONT_LIGHT andFontSize:FONT_SIZE_MEDIUM andTextColor:[UIColor blackColor]];
            [self.contentView addSubview:mailLabel];
            self.heightCell += labelHeight;
        }
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.heightCell += SCALEVALUE(20);
    }
    return self;
}
- (void)setAddressModel:(SimiAddressModel *)addressModel{
    _addressModel = addressModel;
    nameLabel.text = [NSString stringWithFormat:@"%@ %@",addressModel.firstName,addressModel.lastName];
    addressLabel.text = [NSString stringWithFormat:@"%@ %@ %@",addressModel.street,addressModel.city,addressModel.countryName];
    phoneLabel.text = addressModel.telephone;
    mailLabel.text = addressModel.email;
}
- (void)didSelectEditButton:(id)sender{
    
}
@end
