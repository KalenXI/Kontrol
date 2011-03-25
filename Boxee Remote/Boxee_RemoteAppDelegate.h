//
//  Boxee_RemoteAppDelegate.h
//  Boxee Remote
//
//  Created by Kevin Vinck on 25/03/2011.
//  Copyright 2011 None. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@class DetailViewController;

@interface Boxee_RemoteAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;

@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

@end
