//
//  IASVCParser.m
//  FunBoxTask
//
//  Created by user on 01.07.16.
//  Copyright © 2016 I&N. All rights reserved.
//

#import "IASVCParser.h"
#import "IAProduct.h"
#import "IADataStore.h"
@implementation IASVCParser


-(instancetype)init{
    self = [super init];
    
    if (self) {
        self.delegate = self;
    }
    
    return self;
}

-(NSArray*)parseSVCString:(NSString*)string  forFrontStore:(BOOL)forFront{
    
    NSArray* lines = [string componentsSeparatedByString:@"\n"];
    
    NSMutableArray* resultArray = [NSMutableArray array];
    
    for (NSString* line in lines){
        NSArray* components = [line componentsSeparatedByString:@","];

        NSString* name = [self getWordWithinQuotes:[components objectAtIndex:0] isNumber:NO];
        NSString* price = [self getWordWithinQuotes:[components objectAtIndex:1] isNumber:YES];
        NSString* countString = [self getWordWithinQuotes:[components objectAtIndex:2] isNumber:YES];
        
        
        if ([countString isEqualToString:@"0"]&&forFront) {
            continue;
        }
        
        IAProduct* product = [[IAProduct alloc] initWithName:name price:price countString:countString];
        [resultArray addObject:product];
        
    }
    
    return resultArray;
}

-(void)addProduct:(IAProduct*)product
         onSucces:(void(^)(void)) succes
        onFailure:(void(^)(NSError* error)) failure{
    
    if ([self nameExists:product.name]) {
        NSError* error = [NSError errorWithDomain:@"The product is already exists" code:101 userInfo:nil];
        if (failure) {
            failure(error);
        }
        return;
    }
    NSString* path = [IADataStore pathForStore];
    
    NSError* error;
    
    NSString* string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    NSString* line = [NSString stringWithFormat:@"\n\"%@\", \"%@\", \"%@\"", product.name, product.price, [NSString stringWithFormat:@"%ld", (long)product.count]];
    
    NSString* result = [string stringByAppendingString:line];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.delegate saveCVSString:result];
            if (succes) {
                succes();
            }
        });
}

-(void)saveChangesFromState:(IAProduct*)fromProduct
                    toState:(IAProduct*)toProduct
          isBuyingOperation:(BOOL)isBuying
                   onSucces:(void(^)(void)) succes
                  onFailure:(void(^)(NSError* error)) failure{

    NSString* path = [IADataStore pathForStore];

    NSError* error;
    
    NSString* string = [NSString stringWithContentsOfFile:path
                                                 encoding:NSUTF8StringEncoding error:&error];

    if (error) {
        if (failure) {
            failure(error);
        }
        return;
    }
    
    NSArray* lines = [self lines];
    
    NSString* result = string;
    
    for (NSString* line in lines){
        NSArray* components = [line componentsSeparatedByString:@","];
        
        NSString* name = [self getWordWithinQuotes:[components objectAtIndex:0] isNumber:NO];
        NSString* price = [self getWordWithinQuotes:[components objectAtIndex:1] isNumber:YES];
        NSString* countString = [self getWordWithinQuotes:[components objectAtIndex:2] isNumber:YES];
        
        if ([name isEqualToString:fromProduct.name]) {
            NSString* s1 = [line stringByReplacingOccurrencesOfString:name withString:toProduct.name];
            NSString* s2 = [s1 stringByReplacingOccurrencesOfString:price withString:toProduct.price];
            NSString* s3 = [s2 stringByReplacingOccurrencesOfString:countString
                                                         withString:[NSString stringWithFormat:@"%ld", (long)toProduct.count]];
            result = [string stringByReplacingOccurrencesOfString:line withString:s3];
            break;
        }
    }
    
    
    NSTimeInterval time = isBuying? 3 : 5;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.delegate saveCVSString:result];
        if (succes) {
            succes();
        }
    });
    
}

-(void)buyProduct:(IAProduct*)product
         onSucces:(void(^)(void)) succes
        onFailure:(void(^)(NSError* error)) failure{
    if (product.count==0) {
        NSError* error = [NSError errorWithDomain:@"The store is out of the product"
                                             code:104 userInfo:nil];
        if (failure) {
            failure(error);
        }
        
        return;
    }
    
    
    IAProduct* reducedProduct = product;
    reducedProduct.count -=1;
    
    [self saveChangesFromState:product toState:reducedProduct isBuyingOperation:YES onSucces:^{
        if (succes) {
            succes();
        }
    } onFailure:^(NSError * error) {
        if (failure) {
            failure(error);
        }
    }];
}

-(void)saveCVSString:(NSString*)string{
    
    NSString* path = [IADataStore pathForStore];
    
    NSError* error;
    
    [string writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"error when saving changes %@", error);
    }
}

-(BOOL)nameExists:(NSString*)productName{
    
    NSArray* lines = [self lines];

    for (NSString* line in lines){
        NSArray* components = [line componentsSeparatedByString:@","];
        
        NSString* name = [self getWordWithinQuotes:[components objectAtIndex:0] isNumber:NO];
        
        if ([name isEqualToString:productName]) {
            return YES;
        }
    }
    return NO;
}

-(NSArray*)lines{
    
    NSString* path = [IADataStore pathForStore];
    
    NSError* error;
    
    NSString* string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Error in stringWithContentsOfFile %@", error);
    }
    
    return  [string componentsSeparatedByString:@"\n"];
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
