//
//  IAJSONXMLParserAdapter.m
//  FunBoxTask
//
//  Created by user on 02.07.16.
//  Copyright © 2016 I&N. All rights reserved.
//

#import "IAJSONXMLParserAdapter.h"
#import "IAConverter.h"
#import "IASVCParser.h"
#import "IADataStore.h"
@interface IAJSONXMLParserAdapter ()
@property (strong, nonatomic) NSDictionary* obj;
@end


@implementation IAJSONXMLParserAdapter

-(instancetype)initWithXMLJSONObject:(NSDictionary*)obj{
    self = [super init];
    
    if (self) {
        self.obj = obj;
    }
    
    return self;
}

-(NSArray*)parseForFrontStore:(BOOL)forFront{
    IAConverter* converter = [[IAConverter alloc] init];
    
    IASVCParser* parser = [[IASVCParser alloc] init];
    return [parser parseSVCString:[converter convertJSONXMLToCVS:self.obj] forFrontStore:forFront];
}

-(void)saveCVSString:(NSString *)string{
    IAConverter* converter = [[IAConverter alloc] init];
    NSDictionary* result = [converter convertCVSToJSONXML:string];
    
    NSString* path = [IADataStore pathForStore];
    
    [result writeToFile:path atomically:NO];
    
}

@end
