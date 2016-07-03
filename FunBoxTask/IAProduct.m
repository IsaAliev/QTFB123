//
//  IAProduct.m
//  FunBoxTask
//
//  Created by user on 01.07.16.
//  Copyright © 2016 I&N. All rights reserved.
//

#import "IAProduct.h"

@implementation IAProduct

-(instancetype)initWithName:(NSString*)name price:(NSString*)price countString:(NSString*)countString{
    self = [super init];
    
    if (self) {
        self.name = name;
        self.price = price;
        self.count = [countString integerValue];
    }
    
    return self;
}

@end
