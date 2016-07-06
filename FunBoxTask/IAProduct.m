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
        self.name = [self getWordWithinQuotes:name isNumber:NO];
        self.price = [self getWordWithinQuotes:price isNumber:YES];
        self.count = [[self getWordWithinQuotes:countString isNumber:YES] integerValue];
        self.updatedCount = self.count;
    }
    
    return self;
}


-(NSString*)getWordWithinQuotes:(NSString*)string isNumber:(BOOL)isNumber{
    NSString* pattern = nil;
    
    if (isNumber) {
        pattern = @"[0-9]+";
    }else{
        pattern = @"[^(\"|\\W)].[^\"]+";
    }
    
    NSError* error = nil;
    NSRegularExpressionOptions regexOptions =  NSRegularExpressionCaseInsensitive;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:&error];
    if (error)
    {
        NSLog(@"Couldn't create regex with given string and options");
    }
    
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length)];
    
    NSTextCheckingResult* match = [matches firstObject];
    
    NSRange matchRange = match.range;
    
    return [string substringWithRange:matchRange];
}

@end
