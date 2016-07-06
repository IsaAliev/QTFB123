//
//  IAProductDetailController.h
//  FunBoxTask
//
//  Created by user on 01.07.16.
//  Copyright © 2016 I&N. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IAProduct;

extern NSString* const IAProductDetailControllerProductWasBoughtNotification;

@interface IAProductDetailController : UITableViewController

-(instancetype)initWithProduct:(IAProduct*)product;                   ;
@property (strong, nonatomic) IAProduct* product;
@end
