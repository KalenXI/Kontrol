//
//  BoxeeServer.h
//  Boxee Remote
//
//  Created by Kevin Vinck on 27/03/2011.
//  Copyright 2011 None. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BoxeeServer : NSObject {
    
    NSString *hostName;
    NSString *hostIP;
    NSString *hostPort;
    BOOL isBoxeeBox;
    BOOL httpAuthRequired;
    
}

@property (nonatomic, retain) NSString *hostName;
@property (nonatomic, retain) NSString *hostIP;
@property (nonatomic, retain) NSString *hostPort;
@property (nonatomic) BOOL httpAuthRequired;
@property (nonatomic) BOOL isBoxeeBox;

@end
