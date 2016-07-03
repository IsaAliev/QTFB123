//
//  IAJSONXMLParserAdapter.h
//  FunBoxTask
//
//  Created by user on 02.07.16.
//  Copyright © 2016 I&N. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IASVCParser.h"
@class IAProduct;

@interface IAJSONXMLParserAdapter : NSObject <IASVCParserDelegate>

-(void)saveCVSString:(NSString *)string;
-(instancetype)initWithXMLJSONObject:(NSDictionary*)obj;
-(NSArray*)parseForFrontStore:(BOOL)forFront;

@end
