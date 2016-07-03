//
//  IAProductsViewer.m
//  FunBoxTask
//
//  Created by user on 01.07.16.
//  Copyright © 2016 I&N. All rights reserved.
//

#import "IAProductsViewer.h"
#import "IAProduct.h"
#import "IAProductDetailController.h"

@interface IAProductsViewer() <UIPageViewControllerDataSource>
@property (strong, nonatomic) NSArray* products;
@property (strong, nonatomic) IAProduct* initialProduct;
@property (strong, nonatomic) UIViewController* viewController;
@property (strong, nonatomic) UIPageViewController* pageViewController;
@end


@implementation IAProductsViewer

-(instancetype)initWithInitialProfuct:(IAProduct*)initialProduct
                             products:(NSArray*)products
                    forViewController:(UIViewController*)viewController{
    self = [super init];
    if (self) {
        self.products = products;
        self.initialProduct = initialProduct;
        self.viewController = viewController;
    }
    
    return self;
    
}
-(void)show{
    IAProductDetailController* dc = [[IAProductDetailController alloc]
                                     initWithProduct:self.initialProduct];
    
    UIPageViewController* page = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    page.dataSource = self;
    
    [page setViewControllers:@[dc] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    [self.viewController addChildViewController:page];
    
    CGRect pageFrame = page.view.frame;
    pageFrame.origin.y = CGRectGetMaxY(self.viewController.view.frame);
    page.view.frame = pageFrame;
    
    UIButton* closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setTitle:@"Закрыть" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [closeButton addTarget:self
                    action:@selector(closePageVCAction)
          forControlEvents:UIControlEventTouchUpInside];
    [closeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [page.view addSubview:closeButton];
    
    
    [page.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(8)-[closeButton(20)]" options:NSLayoutFormatAlignAllLeft metrics:nil views:NSDictionaryOfVariableBindings(closeButton)]];
    [page.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(8)-[closeButton(80)]" options:NSLayoutFormatAlignAllLeft metrics:nil views:NSDictionaryOfVariableBindings(closeButton)]];
    
    [self.viewController.view addSubview:page.view];
    [self.viewController.view layoutIfNeeded];
    
    self.pageViewController = page;
    
    [page didMoveToParentViewController:self.viewController];
    
    [UIView animateWithDuration:0.3 animations:^{
        page.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.viewController.view.frame),
                                     CGRectGetHeight(self.viewController.view.frame));;
    }];

}




#pragma mark - UIPageViewControllerDataSource

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    
    NSInteger index = [self.products indexOfObject:[(IAProductDetailController*)viewController product]]-1;
    
    if (index<0) {
        return  nil;
    }
    
    return [[IAProductDetailController alloc]
            initWithProduct:[self.products objectAtIndex:index]];
}
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    
    NSInteger index = [self.products indexOfObject:[(IAProductDetailController*)viewController product]]+1;
    
    if (index==self.products.count) {
        return  nil;
    }
    
    return [[IAProductDetailController alloc]
            initWithProduct:[self.products objectAtIndex:index]];
}

#pragma mark - Actions

-(void)closePageVCAction{
    
    [UIView animateWithDuration:0.3 animations:^{
        self.pageViewController.view.frame = CGRectMake(0, CGRectGetMaxY(self.viewController.view.frame),
                                                        CGRectGetWidth(self.viewController.view.frame),
                                                        CGRectGetHeight(self.viewController.view.frame));
    } completion:^(BOOL finished) {
        [self.pageViewController.view removeFromSuperview];
        [self.pageViewController removeFromParentViewController];
        
    }];
    
    
    
}


@end
