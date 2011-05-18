//
//  SettingsViewController.m
//  Boxee Remote
//
//  Created by Kevin Vinck on 25/03/2011.
//  Copyright 2011 None. All rights reserved.
//

#import "SettingsViewController.h"

NSString * const MediaListNeedsReloadingNotification = @"ReloadMedia";
NSString * const hideServerPopupNotification = @"hideServerPopup";

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        m_boxee = [BoxeeHTTPInterface sharedInstance];
        //NSLog(@"Initilizing view");
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(doneFindingServers:) 
                   name:DoneFindingServersNotification
                 object:nil];
        [nc addObserver:self
               selector:@selector(foundServer:) 
                   name:FoundServerNotification
                 object:nil];
        //NSLog(@"Registered with notification center.");
        //NSLog(@"Searching for servers...");
        [m_boxee.boxeeServerList removeAllObjects];
        //NSLog(@"Removing old servers.");
        [m_boxee discoverBoxeeServers];
        searching = YES;
    }
    return self;
}

- (void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    [serverListView release];
    [super dealloc];
}

- (void)doneFindingServers:(NSNotification *)note {
    //NSLog(@"Received notification %@",note);
    searching = NO;
    [serverListView reloadData];
}

- (void)foundServer:(NSNotification *)note {
    //NSLog(@"Received notification %@",note);
    [serverListView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([m_boxee.boxeeServerList count] > 0) {
        return [m_boxee.boxeeServerList count] + 1;
    } else {
        return 1;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"Select a Boxee Server";
    return title;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (searching == YES) {
        return @"Searching for servers...";
    } else {
        return nil;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (indexPath.row == [m_boxee.boxeeServerList count]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"Other";
        return cell;
    }
    
    if ([m_boxee.boxeeServerList count] > 0) {
        BoxeeServer *server = [m_boxee.boxeeServerList objectAtIndex:indexPath.row];
        cell.textLabel.text = server.hostName;
        cell.userInteractionEnabled = YES;
        if ([server.hostIP isEqualToString:m_boxee.serverIP]) {
			if (m_boxee.isConnected == YES) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
				cell.textLabel.textColor = [UIColor blueColor];
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
				cell.textLabel.textColor = [UIColor blackColor];
			}
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.textColor = [UIColor blackColor];
        }
    } else {
        if (searching == YES) {
            cell.textLabel.text = @"Searching for servers...";
            cell.userInteractionEnabled = NO;
        } else {
            cell.textLabel.text = @"No servers found.";
            cell.userInteractionEnabled = NO;
        }
    }
    
    return cell;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ((alertView == passwordAlert) && (buttonIndex == 1)) {
		m_boxee.serverPassword = passwordField.text;
		if ([m_boxee isPasswordProtected]) {
			[m_boxee showAlert:@"Authentication failed."];
			m_boxee.isConnected = NO;
			[serverListView reloadData];
		} else {
			NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
			m_boxee.isConnected = YES;
			[serverListView reloadData];
			[nc postNotificationName:MediaListNeedsReloadingNotification object:self];
			[nc postNotificationName:hideServerPopupNotification object:self];
		}
    }
}

-(void) doneButtonPressed:(NSArray *) values {
    [self dismissModalViewControllerAnimated:YES];
    NSLog(@"Stuff: %@",values);
    
    if ([values count] < 1) {
        return;
    }
    
    m_boxee.serverIP = [values objectAtIndex:0];
    m_boxee.serverPort = [values objectAtIndex:1];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setValue:[values objectAtIndex:0] forKey:@"lastServerIP"];
    [defaults setValue:[values objectAtIndex:1] forKey:@"lastServerPort"];
    //NSLog(@"lastServerIP: %@",[defaults stringForKey:@"lastServerIP"]);
    //NSLog(@"lastServerPort: %@",[defaults stringForKey:@"lastServerPort"]);
    [serverListView reloadData];
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
    } else {
        m_boxee.isConnected = YES;
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:MediaListNeedsReloadingNotification object:self];
        [nc postNotificationName:hideServerPopupNotification object:self];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == [m_boxee.boxeeServerList count]) {
        CustomServerController *cust = [[CustomServerController alloc] initWithStyle:UITableViewStyleGrouped];
        cust.delegate = self;
        
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:cust];
        
        nc.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self presentModalViewController:nc animated:YES];
        
        [nc release];
        [cust release];
    } else {
        
        [tableView deselectRowAtIndexPath:indexPath	animated:YES];
        BoxeeServer *server = [m_boxee.boxeeServerList objectAtIndex:indexPath.row];
        m_boxee.serverIP = server.hostIP;
        m_boxee.serverPort = server.hostPort;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setValue:server.hostIP forKey:@"lastServerIP"];
        [defaults setValue:server.hostPort forKey:@"lastServerPort"];
        //NSLog(@"lastServerIP: %@",[defaults stringForKey:@"lastServerIP"]);
        //NSLog(@"lastServerPort: %@",[defaults stringForKey:@"lastServerPort"]);
        [serverListView reloadData];
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
        } else {
            m_boxee.isConnected = YES;
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:MediaListNeedsReloadingNotification object:self];
            [nc postNotificationName:hideServerPopupNotification object:self];
        }
    }
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [serverListView release];
    serverListView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


- (IBAction)findServerButtonClicked:(id)sender {
    [m_boxee discoverBoxeeServers];
}
@end
