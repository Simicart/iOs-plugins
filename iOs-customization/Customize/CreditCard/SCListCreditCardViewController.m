//
//  SCListCreditCardViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 2/5/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import "SCListCreditCardViewController.h"
#import "CreditCardModelCollection.h"
#import "SimiCustomizeTableViewCell.h"

#define LIST_CREDIT_CARDS @"LIST_CREDIT_CARDS"
#define EMPTY @"EMPTY"
#define CREDIT_CARD @"CREDIT_CARD"

@interface SCListCreditCardViewController ()

@end

@implementation SCListCreditCardViewController{
    CreditCardModelCollection *cardCollection;
}
- (void)viewDidLoadBefore{
    [super viewDidLoadBefore];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewCard:)];
    self.navigationItem.title = @"My Credit Cards";
    [self getListCreditCards];
}
- (void)getListCreditCards{
    if(!cardCollection){
        cardCollection = [CreditCardModelCollection new];
    }
    [cardCollection getListCreditCards];
    [self startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetListCreditCards:) name:DidGetListCreditCards object:nil];
}
- (void)didGetListCreditCards:(NSNotification *)noti{
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    if(responder.status == SUCCESS){
        [self initCells];
    }else{
        [self showAlertWithTitle:@"" message:responder.message];
    }
}
- (void)addNewCard:(id)sender{
    SCCreditCardDetailViewController *cardDetailVC = [SCCreditCardDetailViewController new];
    [self.navigationController pushViewController:cardDetailVC animated:YES];
}
- (void)createCells{
    self.cells = [SimiTable new];
    SimiSection *section = [self.cells addSectionWithIdentifier:LIST_CREDIT_CARDS];
    section.header = [[SimiSectionHeader alloc] initWithTitle:@"MY CREDIT CARDS" height:44];
    if(cardCollection.count){
        for(SimiModel *card in cardCollection.collectionData){
            SimiRow *row = [section addRowWithIdentifier:CREDIT_CARD];
            row.model = card;
        }
    }else{
        [section addRowWithIdentifier:EMPTY height:100];
    }
}

- (UITableViewCell *)contentTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if([row.identifier isEqualToString:CREDIT_CARD]){
        SimiModel *creditCard = row.model;
        NSString *identifier = [NSString stringWithFormat:@"%@%@",CREDIT_CARD,[creditCard objectForKey:@"token_id"]];
        SimiCustomizeTableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:identifier];
        if(!cell){
            cell = [[SimiCustomizeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            [cell addLabelWithTitle:@"Type" value:[creditCard objectForKey:@"type_name"]];
            [cell addLabelWithTitle:@"Number" value:[creditCard objectForKey:@"card"]];
            [cell addLabelWithTitle:@"Expiration Date" value:[NSString stringWithFormat:@"%@/%@",[creditCard objectForKey:@"cc_exp_month"],[creditCard objectForKey:@"cc_exp_year"]]];
            SimiButton *button = [cell addButtonWithTitle:@"Set as default"];
            button.simiObjectIdentifier = creditCard;
            [button addTarget:self action:@selector(setCardDefault:) forControlEvents:UIControlEventTouchUpInside];
            cell.simiObjectIdentifier = button;
            button.backgroundColor = [UIColor whiteColor];
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.contentTableView.frame) - 50, 0, 50, 50)];
            [deleteButton setContentEdgeInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
            [deleteButton setImage:[UIImage imageNamed:@"ic_delete"] forState:UIControlStateNormal];
            deleteButton.simiObjectIdentifier = creditCard;
            [cell addSubview:deleteButton];
            [deleteButton addTarget:self action:@selector(deleteCard:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if(![[creditCard objectForKey:@"can_edit"] boolValue]){
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }else{
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
        SimiButton *defaultButton = (SimiButton *)cell.simiObjectIdentifier;
        if([[creditCard objectForKey:@"is_default"] boolValue]){
            defaultButton.hidden = YES;
            row.height = cell.heightCell - 40;
        }else{
            defaultButton.hidden = NO;
            row.height = cell.heightCell;
        }
        return cell;
    }else if([row.identifier isEqualToString:EMPTY]){
        UITableViewCell *cell = [self.contentTableView dequeueReusableCellWithIdentifier:EMPTY];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EMPTY];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            SimiLabel *label = [[SimiLabel alloc] initWithFrame:CGRectMake(15, 0, CGRectGetWidth(self.contentTableView.frame), row.height)];
            label.text = @"There are no items match your selection";
            [cell.contentView addSubview:label];
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 0;
        }
        return cell;
    }
    return nil;
}
- (void)didSelectCellAtIndex:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    [self.contentTableView deselectRowAtIndexPath:indexPath animated:YES];
    if([row.identifier isEqualToString:CREDIT_CARD]){
        [self.contentTableView deselectRowAtIndexPath:indexPath animated:YES];
        SimiModel *creditCard = row.model;
        SCCreditCardDetailViewController *detailVC = [SCCreditCardDetailViewController new];
        detailVC.delegate = self;
        detailVC.creditCard = creditCard;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}
- (void)didSaveCreditCard{
    [self getListCreditCards];
}
- (void)deleteCard:(UIButton *)sender{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@?",SCLocalizedString(@"Are you sure to delete this Credit Card")] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        SimiModel *creditCard = (SimiModel *)sender.simiObjectIdentifier;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDeleteCard:) name:DidDeleteCard object:nil];
        [self startLoadingData];
        [cardCollection deleteCardWithId:[creditCard objectForKey:@"token_id"]];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didDeleteCard:(NSNotification *)noti{
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    [self showAlertWithTitle:@"" message:responder.message];
    if(responder.status == SUCCESS){
        if([[[cardCollection.data objectForKey:@"ewaycard"] objectForKey:@"status"] boolValue]){
            [self showAlertWithTitle:@"" message:[[cardCollection.data objectForKey:@"ewaycard"] objectForKey:@"message"] completionHandler:^{
                [self getListCreditCards];
            }];
        }else{
            [self showAlertWithTitle:@"" message:[[cardCollection.data objectForKey:@"ewaycard"] objectForKey:@"message"] completionHandler:^{
            }];
        }
    }
}
- (void)setCardDefault:(UIButton *)sender{
    SimiModel *creditCard = (SimiModel *)sender.simiObjectIdentifier;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSetDefaultCard:) name:DidSetCardDefault object:nil];
    [self startLoadingData];
    [cardCollection setCardDefaultWithId:[creditCard objectForKey:@"token_id"]];
}
- (void)didSetDefaultCard:(NSNotification *)noti{
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    SimiResponder *responder = [noti.userInfo objectForKey:responderKey];
    [self showAlertWithTitle:@"" message:responder.message];
    if(responder.status == SUCCESS){
        if([[[cardCollection.data objectForKey:@"ewaycard"] objectForKey:@"status"] boolValue]){
            [self showAlertWithTitle:@"" message:[[cardCollection.data objectForKey:@"ewaycard"] objectForKey:@"message"] completionHandler:^{
                [self getListCreditCards];
            }];
        }else{
            [self showAlertWithTitle:@"" message:[[cardCollection.data objectForKey:@"ewaycard"] objectForKey:@"message"] completionHandler:^{
            }];
        }
    }
}
@end
