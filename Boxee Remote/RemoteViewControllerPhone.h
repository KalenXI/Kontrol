//
//  RemoteViewControllerPhone.h
//  Kontrol
//
//  Created by Kevin Vinck on 23/04/2011.
//  Copyright 2011 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoxeeHTTPInterface.h"

@interface RemoteViewControllerPhone : UIViewController {
    
    BoxeeHTTPInterface *m_boxee;
    NSTimer *timer;
    NSTimer *holdTimer;
    
}

- (IBAction)selectButtonTouched:(id)sender;
- (IBAction)downButtonTouched:(id)sender;
- (IBAction)UpButtonTouched:(id)sender;
- (IBAction)rightButtonTouched:(id)sender;
- (IBAction)leftButtonTouched:(id)sender;
- (IBAction)backButtonTouched:(id)sender;
- (IBAction)downButtonTouchDown:(id)sender;
- (IBAction)rightButtonTouchDown:(id)sender;
- (IBAction)upButtonTouchDown:(id)sender;
- (IBAction)leftButtonTouchDown:(id)sender;

@end
