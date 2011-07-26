//
//  JSONInterface.h
//  Kontrol
//
//  Created by Kevin Vinck on 25-05-11.
//  Copyright 2011 None. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JSONInterface : NSObject {
    
}

-(void) sendCmd:(NSString *)cmd params:(NSArray *)params;
-(void) sendCmd:(NSString *)cmd;

@end
