//
//  SCPPadThankYouPageViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 6/19/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCPPadThankYouPageViewController.h"

@interface SCPPadThankYouPageViewController ()

@end

@implementation SCPPadThankYouPageViewController

- (void)viewDidLoadBefore{
    [super viewDidLoadBefore];
    paddingX = 100;
    buttonHeight = 44;
}
- (void)viewWillAppearBefore:(BOOL)animated{
    if(!self.isPresented){
        [self configureNavigationBarOnViewWillAppear];
    }
}
- (void)createCells{
    self.cells = [SimiTable new];
    SimiSection *mainSection = [self.cells addSectionWithIdentifier:THANK_YOU_PAGE_SECTION];
    [mainSection addRowWithIdentifier:THANK_YOU_PAGE_TITLE_ROW];
    [mainSection addRowWithIdentifier:THANK_YOU_PAGE_DESCRIBLE_ROW];
    [mainSection addRowWithIdentifier:THANK_YOU_PAGE_BUTTON_ROW];
}
- (UITableViewCell *)contentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    SimiTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:row.identifier];
    if(!cell){
        float contentWidth = CGRectGetWidth(self.contentTableView.frame) - 2*paddingX;
        cell = [[SimiTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        if([row.identifier isEqualToString:THANK_YOU_PAGE_TITLE_ROW]){
            cell.heightCell = 44;
            SimiLabel *titleLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX, cell.heightCell, contentWidth, 44) andFontName:SCP_FONT_SEMIBOLD andFontSize:FONT_SIZE_HEADER andTextColor:SCP_ICON_HIGHLIGHT_COLOR text:[NSString stringWithFormat:@"%@!",SCLocalizedString(@"Thank you for your order")]];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:titleLabel];
            [titleLabel resizLabelToFit];
            cell.heightCell += CGRectGetHeight(titleLabel.frame);
        }else if([row.identifier isEqualToString:THANK_YOU_PAGE_DESCRIBLE_ROW]){
            cell.heightCell = 30;
            SimiLabel *statusLabel = [[SimiLabel alloc] initWithFrame:CGRectMake(paddingX, cell.heightCell, contentWidth, 44) andFontName:SCP_FONT_REGULAR andFontSize:FONT_SIZE_MEDIUM andTextColor:[UIColor blackColor] text:@"You have successfully placed an order"];
            statusLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:statusLabel];
            [statusLabel resizLabelToFit];
            cell.heightCell += CGRectGetHeight(statusLabel.frame);
        }else if([row.identifier isEqualToString:THANK_YOU_PAGE_BUTTON_ROW]){
            cell.heightCell = 30;
            float buttonPadding = 20;
            float buttonWidth = (contentWidth - buttonPadding)/2;
            SCPButton *viewDetailButton = [[SCPButton alloc] initWithFrame:CGRectMake(paddingX, cell.heightCell, buttonWidth, buttonHeight) title:@"" titleFont:nil cornerRadius:buttonHeight/2 borderWidth:2 borderColor:[UIColor blackColor]];
            [viewDetailButton setImage:[[UIImage imageNamed:@"scp_ic_next"] imageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
            [viewDetailButton setImageEdgeInsets:UIEdgeInsetsMake(12, buttonWidth - 30, 12, 10)];
            [viewDetailButton addTarget:self action:@selector(viewOrderDetail:) forControlEvents:UIControlEventTouchUpInside];
            viewDetailButton.backgroundColor = [UIColor clearColor];
            [viewDetailButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            NSString *htmlString = [NSString stringWithFormat:@"<span style='font-family:%@;font-size:%f'>%@: </span><span style='font-family:%@;font-size:%f'>%@</span>",SCP_FONT_LIGHT,FONT_SIZE_MEDIUM,SCLocalizedString(@"View detail of your order"),SCP_FONT_REGULAR,FONT_SIZE_MEDIUM,[NSString stringWithFormat:@"#%@", @"1203231"]];
            NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            [viewDetailButton setAttributedTitle:attrStr forState:UIControlStateNormal];
            [cell.contentView addSubview:viewDetailButton];
            
            SCPButton *continueButton = [[SCPButton alloc] initWithFrame:CGRectMake(paddingX + buttonWidth + buttonPadding, cell.heightCell, buttonWidth, buttonHeight) title:@"CONTINUE SHOPPING" titleFont:[UIFont fontWithName:SCP_FONT_SEMIBOLD size:FONT_SIZE_LARGE] cornerRadius:buttonHeight/2 borderWidth:0 borderColor:[UIColor blackColor]];
            [continueButton addTarget:self action:@selector(continueShopping:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:continueButton];
            cell.heightCell += CGRectGetHeight(continueButton.frame);
        }
    }
    row.height = cell.heightCell;
    return cell;
}
- (void)continueShopping:(UIButton *)sender{
    [super continueShopping:sender];
}
- (void)viewOrderDetail:(UIButton *)sender{
    [super viewOrderDetail:sender];
}
@end
