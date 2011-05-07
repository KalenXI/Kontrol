//
//  SettingsViewController.h
//  Boxee Remote
//
//  Created by Kevin Vinck on 25/03/2011.
//  Copyright 2011 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoxeeHTTPInterface.h"


@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIAlertViewDelegate> {
    BoxeeHTTPInterface *m_boxee;
    BOOL searching;
    IBOutlet UITableView *serverListVIew;
    UIActivityIndicatorView *activityIndicator;
	UIAlertView *passwordAlert;
	UITextField *passwordField;
}

extern NSString * const MediaListNeedsReloadingNotification;
extern NSString * const hideServerPopupNotification;

- (IBAction)findServerButtonClicked:(id)sender;

@end
