//
//  IAStoreFrontViewController.m
//  FunBoxTask
//
//  Created by user on 01.07.16.
//  Copyright © 2016 I&N. All rights reserved.
//

#import "IAStoreFrontViewController.h"
#import "IASVCParser.h"
#import "IAProduct.h"
#import "IAProductDetailController.h"
#import "IAProductsViewer.h"
#import "IAAdminProductDetailController.h"

@interface IAStoreFrontViewController()
@property (strong, nonatomic) NSArray* products;
@property (strong, nonatomic) IAProductsViewer* viewer;
@end

@implementation IAStoreFrontViewController

#pragma mark - LifeCycle

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self getProducts];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self getProducts];
    self.products = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getProducts) name:IABackEndProductAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getProducts) name:IABackEndInfoDidChangeNotification object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)getProducts{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"data.csv" ofType:nil];
    
    NSError* error;
    
    NSString* string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"Error in stringWithContentsOfFile %@", error);
    }
    
    IASVCParser* parser = [[IASVCParser alloc] init];
    self.products = [parser parseSVCString:string forFrontStore:YES];
    
    [self.tableView   reloadData];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    IAProduct* product = [self.products objectAtIndex:indexPath.row];

    IAProductsViewer* viewer = [[IAProductsViewer alloc] initWithInitialProfuct:product products:self.products forViewController:self];
    
    [viewer show];
    
    self.viewer = viewer;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.products.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifier = @"cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    IAProduct* product = [self.products objectAtIndex:indexPath.row];
    
    cell.textLabel.text = product.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ₽", product.price];
    
    return cell;
}



@end
