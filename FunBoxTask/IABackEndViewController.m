//
//  IABackEndViewController.m
//  FunBoxTask
//
//  Created by user on 01.07.16.
//  Copyright © 2016 I&N. All rights reserved.
//

#import "IABackEndViewController.h"
#import "IASVCParser.h"
#import "IAProduct.h"
#import "IAProductDetailController.h"
#import "IAAdminProductDetailController.h"

@interface IABackEndViewController()
@property (strong, nonatomic) NSArray* products;
@end






@implementation IABackEndViewController



#pragma mark - LifeCycle

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self getProducts];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self getProducts];
    UIBarButtonItem* add = [[UIBarButtonItem alloc]
                            initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                            target:self
                            action:@selector(addButtonAction:)];
    self.navigationItem.rightBarButtonItem = add;
}

-(void)getProducts{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"data.csv" ofType:nil];
    
    NSError* error;
    
    NSString* string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"Error in stringWithContentsOfFile %@", error);
    }
    
    IASVCParser* parser = [[IASVCParser alloc] init];
    self.products = [parser parseSVCString:string forFrontStore:NO];
    [self.tableView   reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.products.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifier = @"cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    IAProduct* product = [self.products objectAtIndex:indexPath.row];
    
    cell.textLabel.text = product.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ₽", product.price];
    
    return cell;
}

#pragma mark - Actions

-(void)addButtonAction:(UIBarButtonItem*)button{
    IAAdminProductDetailController* ac = [self.storyboard  instantiateViewControllerWithIdentifier:@"adminDetailVC"];
    ac.type = IAAdminProductDetailControllerTypeNew;
    [self.navigationController pushViewController:ac animated:YES];
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController isKindOfClass:[IAAdminProductDetailController class]]) {
        IAAdminProductDetailController* ac = (IAAdminProductDetailController*)segue.destinationViewController;
        NSIndexPath* indexPath = [self.tableView indexPathForCell:(UITableViewCell*)sender];
        ac.product = [self.products objectAtIndex:indexPath.row];
        ac.type = IAAdminProductDetailControllerTypeEdit;
    }
}

@end
