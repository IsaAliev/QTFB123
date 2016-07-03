//
//  IAAdminProductDetailController.m
//  FunBoxTask
//
//  Created by user on 01.07.16.
//  Copyright © 2016 I&N. All rights reserved.
//

#import "IAAdminProductDetailController.h"
#import "IAProduct.h"
#import "IASVCParser.h"
@interface IAAdminProductDetailController()
@property (strong, nonatomic) UIBarButtonItem* saveButton;
@end

NSString* const IABackEndInfoDidChangeNotification = @"IABackEndViewControllerBackEndInfoDidChangeNotification";

@implementation IAAdminProductDetailController

-(void)viewDidLoad{
    [super viewDidLoad];
    if (self.type==IAAdminProductDetailControllerTypeNew) {
        self.nameTextField.placeholder = @"Название";
        self.priceTextField.placeholder = @"Цена";
        self.countTextField.placeholder = @"Количество";
        self.navigationItem.title = @"Новый продукт";
    }else{
        self.nameTextField.text = self.product.name;
        self.priceTextField.text = self.product.price;
        self.countTextField.text = [NSString stringWithFormat:@"%ld", (long)self.product.count];
        self.navigationItem.title = @"Просмотр/Редактирование";
    }
    
    UIBarButtonItem* cancel = [[UIBarButtonItem alloc] initWithTitle:@"Отмена"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(cancelButtonAction:)];
    UIBarButtonItem* save = [[UIBarButtonItem alloc] initWithTitle:@"Сохранить"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(saveButtonAction:)];
    [save setEnabled:NO];
    self.saveButton = save;
    
    self.navigationItem.leftBarButtonItem = cancel;
    self.navigationItem.rightBarButtonItem = save;
    
    
    
}

#pragma mark - Actions

-(void)cancelButtonAction:(UIBarButtonItem*)button{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)saveButtonAction:(UIBarButtonItem*)button{
    if (self.type==IAAdminProductDetailControllerTypeEdit) {
        IAProduct* editedProduct = [[IAProduct alloc] initWithName:self.nameTextField.text
                                                             price:self.priceTextField.text
                                                       countString:self.countTextField.text];
        [[[IASVCParser alloc] init]
         saveChangesFromState:self.product
         toState:editedProduct
         isBuyingOperation:NO
         onSucces:^{
             [[NSNotificationCenter defaultCenter]
              postNotificationName:IABackEndInfoDidChangeNotification object:nil];
        } onFailure:^(NSError *error) {
            [self showAlertForError:error];
        }];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        IAProduct* newProduct = [[IAProduct alloc] initWithName:self.nameTextField.text
                                                             price:self.priceTextField.text
                                                       countString:self.countTextField.text];
        [[[IASVCParser alloc] init] addProduct:newProduct onSucces:^{
            [[NSNotificationCenter defaultCenter]
             postNotificationName:IABackEndInfoDidChangeNotification object:nil];
        } onFailure:^(NSError *error) {
            [self showAlertForError:error];
        }];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)infoChangedAction:(UITextField *)sender {
    if ([self.nameTextField.text isEqualToString:self.product.name]&&
        [self.priceTextField.text isEqualToString:self.product.price]&&
        [self.countTextField.text isEqualToString:[NSString stringWithFormat:@"%ld", (long)self.product.count]]) {
        [self.saveButton setEnabled:NO];
    }else{
        [self.saveButton setEnabled:YES];
    }
    
}
-(void)showAlertForError:(NSError*)error{
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:@"Ошибка"
                                message:error.domain
                                preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ок" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
