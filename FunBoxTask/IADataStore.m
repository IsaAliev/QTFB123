//
//  IADataStore.m
//  FunBoxTask
//
//  Created by user on 03.07.16.
//  Copyright © 2016 I&N. All rights reserved.
//

#import "IADataStore.h"

@implementation IADataStore
+(NSString*)pathForStore{
    return [[NSBundle mainBundle] pathForResource:@"data" ofType:@"csv"];
}
@end
