//
//  IAConverter.h
//  FunBoxTask
//
//  Created by user on 02.07.16.
//  Copyright © 2016 I&N. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAConverter : NSObject
-(NSString*)convertJSONXMLToCVS:(NSDictionary*)dict;
-(NSDictionary*)convertCVSToJSONXML:(NSString*)cvs;

@end
