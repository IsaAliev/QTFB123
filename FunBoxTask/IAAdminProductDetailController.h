//
//  IAAdminProductDetailController.h
//  FunBoxTask
//
//  Created by user on 01.07.16.
//  Copyright © 2016 I&N. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IAProduct;

extern NSString* const IABackEndInfoDidChangeNotification;


typedef enum{
    IAAdminProductDetailControllerTypeNew,
    IAAdminProductDetailControllerTypeEdit
}IAAdminProductDetailControllerType;

@interface IAAdminProductDetailController : UITableViewController
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UITextField *countTextField;

- (IBAction)infoChangedAction:(UITextField *)sender;

@property (assign, nonatomic) IAAdminProductDetailControllerType type;
@property (strong, nonatomic) IAProduct* product;

@end
