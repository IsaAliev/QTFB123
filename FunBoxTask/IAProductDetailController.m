//
//  IAProductDetailController.m
//  FunBoxTask
//
//  Created by user on 01.07.16.
//  Copyright © 2016 I&N. All rights reserved.
//

#import "IAProductDetailController.h"
#import "IAProduct.h"
#import "IASVCParser.h"
@interface IAProductDetailController()

@end


@implementation IAProductDetailController

-(instancetype)initWithProduct:(IAProduct*)product{
    self = [super init];
    
    if (self) {
        self.product = product;

    }
    
    return self;
}

#pragma mark - LifeCycle

-(void)viewDidLoad{
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row==3) {
        IASVCParser* parser = [[IASVCParser alloc] init];
        [parser buyProduct:self.product onSucces:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
            } onFailure:^(NSError *error) {
                [self showAlertForError:error];
        }];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifier = @"cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    switch (indexPath.row) {
        case 0:{
            UILabel *myLabel;
            cell.textLabel.text = nil;
            myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 28, self.view.frame.size.width, 44)];
            myLabel.tag = 111;
            myLabel.textAlignment= NSTextAlignmentCenter;
            [cell.contentView addSubview:myLabel];
            myLabel = (UILabel*)[cell.contentView viewWithTag:111];
            myLabel.text = self.product.name;
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        }
            break;
        case 1:
            cell.textLabel.text = @"Цена";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ₽", self.product.price];
            break;
        case 2:
            cell.textLabel.text = @"Количество";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld шт", (long)self.product.count];
            break;
        case 3:{
            UILabel *myLabel;
            cell.textLabel.text = nil;
            myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 28, self.view.frame.size.width, 44)];
            myLabel.tag = 111;
            myLabel.textAlignment= NSTextAlignmentCenter;
            [cell.contentView addSubview:myLabel];
            myLabel = (UILabel*)[cell.contentView viewWithTag:111];
            myLabel.text = @"Купить";
        }

            break;
        default:
            break;
    }

    
    return cell;
}

#pragma mark - Private Methods

-(void)showAlertForError:(NSError*)error{
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:@"Ошибка"
                                message:error.domain
                                preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ок" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
