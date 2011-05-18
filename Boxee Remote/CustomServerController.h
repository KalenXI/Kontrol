//
//  CustomServerController.h
//  Kontrol
//
//  Created by Kevin Vinck on 5/17/11.
//  Copyright 2011 None. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomServerControllerDelegate
-(void) doneButtonPressed:(NSArray *) values;
@end


@interface CustomServerController : UITableViewController <UITextFieldDelegate> {
    
    id<CustomServerControllerDelegate> delegate;
    
    NSString *serverIP;
    NSString *serverPort;
}

@property (nonatomic,assign) id<CustomServerControllerDelegate> delegate;

@end
