//
//  BoxeeServerParser.h
//  Boxee Remote
//
//  Created by Kevin Vinck on 27/03/2011.
//  Copyright 2011 None. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BoxeeServer.h"
@class BoxeeServer;


@interface BoxeeServerParser : NSObject <NSXMLParserDelegate> {
    NSString *cmd;
    NSString *application;
    NSString *version;
    NSString *name;
    NSString *response;
    NSString *httpPort;
    BOOL httpAuthRequired;
    NSString *signature;
    NSString *keyInProgress;
    NSMutableString *textInProgress;
    BOOL validServer;
}

- (BOOL)parseData:(NSData *)d;

@property (nonatomic, retain) NSString *cmd;
@property (nonatomic, retain) NSString *application;
@property (nonatomic, retain) NSString *version;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *response;
@property (nonatomic, retain) NSString *httpPort;
@property (nonatomic) BOOL httpAuthRequired;
@property (nonatomic, retain) NSString *signature;

@end
