//
//  SettingsViewControllerPhone.h
//  Kontrol
//
//  Created by Kevin Vinck on 23/04/2011.
//  Copyright 2011 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoxeeHTTPInterface.h"
#import "CustomServerController-Phone.h"


@interface SettingsViewControllerPhone : UIViewController <UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate, CustomServerControllerDelegate_Phone> {
    BoxeeHTTPInterface *m_boxee;
    BOOL searching;
    IBOutlet UITableView *serverListView;
	UIAlertView *passwordAlert;
	UITextField *passwordField;
}

extern NSString * const MediaListNeedsReloadingNotificationPhone;

@end
