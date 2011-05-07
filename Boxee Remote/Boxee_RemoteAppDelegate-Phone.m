//
//  Boxee_RemoteAppDelegate.m
//  Boxee Remote
//
//  Created by Kevin Vinck on 25/03/2011.
//  Copyright 2011 None. All rights reserved.
//

#import "Boxee_RemoteAppDelegate-Phone.h"
#import "SplashScreenViewController.h"

@implementation Boxee_RemoteAppDelegatePhone



@synthesize window=_window;

//@synthesize splitViewController=_splitViewController;

//@synthesize rootViewController=_rootViewController;

//@synthesize detailViewController=_detailViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    m_boxee = [BoxeeHTTPInterface sharedInstance];
	[nc addObserver:self
           selector:@selector(connectedToServer) 
               name:MediaListNeedsReloadingNotificationPhone
             object:nil];
	//NSLog(@"lastServerIP: %@",[defaults stringForKey:@"lastServerIP"]);
	//NSLog(@"lastServerPort: %@",[defaults stringForKey:@"lastServerPort"]);
    if ([defaults stringForKey:@"lastServerIP"] != nil) {
        //NSLog(@"Last server saved.");
        m_boxee.serverIP = [defaults stringForKey:@"lastServerIP"];
        m_boxee.serverPort = [defaults stringForKey:@"lastServerPort"];
        if ([m_boxee ping]) {
			if ([m_boxee isPasswordProtected]) {
				passwordAlert = [[UIAlertView alloc] initWithTitle:@"Boxee Authentication" message:@"\n \n \n \n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
			
				UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 40.0, 260.0, 50.0)];
				messageLabel.text = @"This server requires authentication.";
				messageLabel.lineBreakMode = UILineBreakModeWordWrap;
				messageLabel.numberOfLines = 0;
				messageLabel.textAlignment = UITextAlignmentCenter;
				messageLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
				messageLabel.textColor = [UIColor colorWithWhite:100 alpha:1];
				[passwordAlert addSubview:messageLabel];
			
				// Adds a password Field
				passwordField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 100.0, 260.0, 25.0)]; passwordField.placeholder = @"Password";
				[passwordField setSecureTextEntry:YES];
				[passwordField setBackgroundColor:[UIColor whiteColor]]; [passwordAlert addSubview:passwordField];
			
			
				// Show alert on screen.
				[passwordAlert show];
				[passwordField becomeFirstResponder];
				[passwordAlert release];
				
				[messageLabel release];
				[passwordField release];
				m_boxee.isConnected = NO;
			} else {
				[nc postNotificationName:MediaListNeedsReloadingNotificationPhone object:self];
				m_boxee.isConnected = YES;
				tabBarController.selectedIndex = 0;
			}
        } else {
            //NSLog(@"Last server not found.");
            tabBarController.selectedIndex = 3;
        }
    } else {
        //NSLog(@"No last server saved.");
        tabBarController.selectedIndex = 3;
    }
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ((alertView == passwordAlert) && (buttonIndex == 1)) {
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        NSLog(@"Password: %@",passwordField.text);
		m_boxee.serverPassword = passwordField.text;
		if ([m_boxee isPasswordProtected]) {
			[m_boxee showAlert:@"Authentication failed."];
			m_boxee.isConnected = NO;
		} else {
			[nc postNotificationName:MediaListNeedsReloadingNotificationPhone object:self];
			m_boxee.isConnected = YES;
			tabBarController.selectedIndex = 0;
		}
    }
	
    if ((alertView == databaseAlert) && (buttonIndex == 1)) {
        [m_boxee setupRemoteDatabaseMac];
    } else if ((alertView == databaseAlert) && (buttonIndex == 2)) {
        [m_boxee setupRemoteDatabaseWin];
    } else if ((alertView == databaseAlert) && (buttonIndex == 3)) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setInteger:1 forKey:[NSString stringWithFormat:@"ask%@ForDatabase",m_boxee.serverIP]];
        
    }
}

- (void) connectedToServer {
    if (![m_boxee isBoxeeBox]) {
        if ([m_boxee isDatabaseEnabled]) {
            //NSLog(@"Database is enabled!");
        } else {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if ([defaults integerForKey:[NSString stringWithFormat:@"ask%@ForDatabase",m_boxee.serverIP]] != 1) {
                //NSLog(@"Database isn't enabled :(");
                databaseAlert = [[UIAlertView alloc] initWithTitle:@"Library Access" message:@"Remote library access is not setup on this server, would you like to enable?" delegate:self cancelButtonTitle:@"Ignore" otherButtonTitles:@"Enable for Mac/Linux",@"Enable for Windows",@"No, do not ask again.", nil];
                [databaseAlert show];
            }
        }
    } else {
        [m_boxee showAlert:@"You appear to be connecting to a Boxee Box. Since the Boxee Box does not allow remote access to media shares, functionality will be impared. Remote and playback controls should continue to work."];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)awakeFromNib {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

-(void) displayView:(int)intNewView {
    //NSLog(@"Telling controller to load new view.");
    //[_detailViewController view];
    //[_detailViewController displayView:intNewView];
}

- (void)dealloc
{
    [_window release];
    //[_splitViewController release];
    //[_rootViewController release];
    //[_detailViewController release];
    [super dealloc];
}

@end
