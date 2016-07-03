//
//  IAConverter.m
//  FunBoxTask
//
//  Created by user on 02.07.16.
//  Copyright © 2016 I&N. All rights reserved.
//

#import "IAConverter.h"
#import "IAProduct.h"
#import "IASVCParser.h"
@implementation IAConverter
-(NSString*)convertJSONXMLToCVS:(NSDictionary*)dict{
    
    NSArray* itmes = dict[@"items"];
    
    NSMutableString* result = [NSMutableString string];
    
    for (IAProduct* item in itmes ) {
        NSString* productLine = [NSString stringWithFormat:@"\n\"%@\", \"%@\", \"%@\"", item.name, item.price, [NSString stringWithFormat:@"%ld", (long)item.count]];
        [result appendString:productLine];
    }
    
    return result;
    
}
-(NSDictionary*)convertCVSToJSONXML:(NSString*)cvs{
    
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    
    IASVCParser* parser = [[IASVCParser alloc] init];
    NSArray* items = [parser parseSVCString:cvs forFrontStore:YES];
    
    [result setObject:items forKey:@"items"];
    
    return result;
    
}

@end
