//
//  IAProductsViewer.h
//  FunBoxTask
//
//  Created by user on 01.07.16.
//  Copyright © 2016 I&N. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IAProduct;

@interface IAProductsViewer : NSObject
-(instancetype)initWithInitialProfuct:(IAProduct*)initialProduct
                             products:(NSArray*)products
                    forViewController:(UIViewController*)viewController;
-(void)show;
@end
