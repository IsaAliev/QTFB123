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
#import "IAAdminProductDetailController.h"
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
        
        if ([name isEqualToString:fromProduct.name]) {
            NSString* newLine = [NSString stringWithFormat:@"\"%@\", \"%@\", \"%@\"", toProduct.name, toProduct.price,[NSString stringWithFormat:@"%ld", (long)toProduct.count] ];
            
            result = [string stringByReplacingOccurrencesOfString:line withString:newLine];
            break;
        }
    }
    

        NSTimeInterval time =  5;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.delegate saveCVSString:result];
            if (succes) {
                succes();
            }
        });
    

    
}

-(void)reduceCountForProduct:(IAProduct*)product
                   onSucces:(void(^)(NSInteger count)) succes
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
        NSString* countString = [self getWordWithinQuotes:[components objectAtIndex:2] isNumber:YES];
        
        if ([name isEqualToString:product.name]) {;
            NSString* newLine = [NSString stringWithFormat:@"\"%@\", \"%@\", \"%@\"", product.name, product.price,[NSString stringWithFormat:@"\"%ld\"", [countString integerValue]-1]];
            result = [string stringByReplacingOccurrencesOfString:line withString:newLine];
            break;
        }
    }
    
    product.count--;
    
    [self.delegate saveCVSString:result];
    if (succes) {
        succes(product.count);
    }
}



-(void)buyProduct:(IAProduct*)product
         onSucces:(void(^)(void)) succes
        onFailure:(void(^)(NSError* error)) failure{

    if (product.count<=0||product.updatedCount<=0) {
        NSError* error = [NSError errorWithDomain:@"The store is out of the product"
                                             code:104 userInfo:nil];
        if (failure) {
            failure(error);
        }
        
        return;
    }
        product.updatedCount--;
        NSTimeInterval time = product.updatedCount*2;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        
        [self reduceCountForProduct:product onSucces:^(NSInteger newCount){
            IAProduct* redProduct = [[IAProduct alloc] initWithName:product.name price:product.price countString:[NSString stringWithFormat:@"%ld", (long)newCount]];
            [[NSNotificationCenter defaultCenter] postNotificationName:IABackEndInfoDidChangeNotification object:@{kOldProductState:product,kNewProductState:redProduct}];
            if (succes) {
                succes();
            }
        } onFailure:^(NSError *error) {
            if (failure) {
            failure(error);
            }
        }];

    });

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
