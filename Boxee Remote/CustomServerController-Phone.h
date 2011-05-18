//
//  CustomServerController-Phone.h
//  Kontrol
//
//  Created by Kevin Vinck on 17/05/2011.
//  Copyright 2011 None. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomServerControllerDelegate_Phone
-(void) doneButtonPressed:(NSArray *) values;
@end

@interface CustomServerController_Phone : UITableViewController <UITextFieldDelegate> {
 
    id<CustomServerControllerDelegate_Phone> delegate;
    
    NSString *serverIP;
    NSString *serverPort;
    
}

@property (nonatomic,assign) id<CustomServerControllerDelegate_Phone> delegate;

@end
