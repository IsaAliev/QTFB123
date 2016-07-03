//
//  IASVCParser.h
//  FunBoxTask
//
//  Created by user on 01.07.16.
//  Copyright © 2016 I&N. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IASVCParserDelegate
-(void)saveCVSString:(NSString*)string;
@end


@class IAProduct;
@interface IASVCParser : NSObject <IASVCParserDelegate>

@property (weak, nonatomic) id <IASVCParserDelegate> delegate;

-(NSArray*)parseSVCString:(NSString*)string  forFrontStore:(BOOL)forFront;
-(void)saveChangesFromState:(IAProduct*)fromProduct
                    toState:(IAProduct*)toProduct
          isBuyingOperation:(BOOL)isBuying
                   onSucces:(void(^)(void)) succes
                   onFailure:(void(^)(NSError* error)) failure;
-(void)addProduct:(IAProduct*)product
         onSucces:(void(^)(void)) succes
        onFailure:(void(^)(NSError* error)) failure;

-(void)buyProduct:(IAProduct*)product
         onSucces:(void(^)(void)) succes
        onFailure:(void(^)(NSError* error)) failure;


@end
