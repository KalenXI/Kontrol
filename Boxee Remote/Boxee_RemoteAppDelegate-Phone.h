//
//  Boxee_RemoteAppDelegate.h
//  Boxee Remote
//
//  Created by Kevin Vinck on 25/03/2011.
//  Copyright 2011 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoxeeHTTPInterface.h"
#import "SettingsViewControllerPhone.h"

//@class RootViewController;
//@class DetailViewController;

@interface Boxee_RemoteAppDelegatePhone : NSObject <UIApplicationDelegate, UIAlertViewDelegate> {
    IBOutlet UITabBarController *tabBarController;
    BoxeeHTTPInterface *m_boxee;
    
    UIAlertView *databaseAlert;
	UIAlertView *passwordAlert;
	UITextField *passwordField;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
//@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
//@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;
//@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

-(void) displayView:(int)intNewView;
- (void) connectedToServer;

@end
