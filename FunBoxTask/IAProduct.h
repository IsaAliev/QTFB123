//
//  IAProduct.h
//  FunBoxTask
//
//  Created by user on 01.07.16.
//  Copyright © 2016 I&N. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAProduct : NSObject
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* price;
@property (assign, nonatomic) NSInteger count;
@property (assign, nonatomic) NSInteger updatedCount;
-(instancetype)initWithName:(NSString*)name price:(NSString*)price countString:(NSString*)countString;
@end
