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
#import "IAAdminProductDetailController.h"
@interface IAProductsViewer() <UIPageViewControllerDataSource>
@property (strong, nonatomic) NSMutableArray* products;
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
        self.products = [NSMutableArray arrayWithArray:products];
        self.initialProduct = initialProduct;
        self.viewController = viewController;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(infoDidChangeNotification:) name:IABackEndInfoDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productAddedNotification:) name:IABackEndProductAddedNotification object:nil];
    
    return self;
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark - Notifications

-(void)infoDidChangeNotification:(NSNotification*)note{
    IAProductDetailController* dc = (IAProductDetailController*)[self.pageViewController.viewControllers lastObject];
    IAProduct* oldStateProduct = (IAProduct*)note.object[kOldProductState];
    
    IAProduct* currentProduct = dc.product;
    IAProduct* newStateProduct = (IAProduct*)note.object[kNewProductState];
    if ([oldStateProduct.name isEqualToString:currentProduct.name]) {
 
        if (newStateProduct.count==0) {
            IAProductDetailController* newDC = (IAProductDetailController*)[self pageViewController:self.pageViewController viewControllerAfterViewController:dc];
            if (!newDC) {
                 newDC = (IAProductDetailController*)[self pageViewController:self.pageViewController viewControllerBeforeViewController:dc];
            }
            if (!newDC) {
                [self closePageVCAction];
                return;
            }
            [self.pageViewController
             setViewControllers:@[newDC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
            [self.products removeObject:dc.product];
        }
    }
    if (oldStateProduct.count==0&&newStateProduct.count>0) {
        [self.products addObject:newStateProduct];
    }
}

-(void)productAddedNotification:(NSNotification*)note{
    IAProduct* product = (IAProduct*)note.object;
    [self.products addObject:product];
    
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
