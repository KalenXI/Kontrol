//
//  SettingsViewControllerPhone.m
//  Kontrol
//
//  Created by Kevin Vinck on 23/04/2011.
//  Copyright 2011 None. All rights reserved.
//

#import "SettingsViewControllerPhone.h"

NSString * const MediaListNeedsReloadingNotificationPhone = @"ReloadMedia";

@implementation SettingsViewControllerPhone

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (searching == NO) {
        //NSLog(@"ViewDidLoad with status %i",searching);
    }
}

- (void) awakeFromNib {
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
    //[m_boxee.boxeeServerList removeAllObjects];
    //NSLog(@"Removing old servers.");
    //[m_boxee discoverBoxeeServers];
    searching = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (searching == NO) {
        [m_boxee.boxeeServerList removeAllObjects];
        //NSLog(@"Removing old servers.");
        [serverListView reloadData];
        [m_boxee discoverBoxeeServers];
        searching = YES;
        [super viewDidAppear:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

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
    // Return the number of sections.
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
        NSString *footer = @"Searching for servers...";
        return footer;
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

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

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
			[nc postNotificationName:MediaListNeedsReloadingNotificationPhone object:self];
		}
    }
	
}

#pragma mark - Table view delegate

-(void) doneButtonPressed:(NSArray *) values {
    [self dismissModalViewControllerAnimated:YES];
    NSLog(@"Stuff: %@",values);
    
    if ([values count] == 0) {
        return;
    }
    
    if ([values count] < 2) {
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
        [nc postNotificationName:MediaListNeedsReloadingNotificationPhone object:self];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [m_boxee.boxeeServerList count]) {
        CustomServerController_Phone *cust = [[CustomServerController_Phone alloc] initWithStyle:UITableViewStyleGrouped];
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
            // Ask for Username and password.
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
            [nc postNotificationName:MediaListNeedsReloadingNotificationPhone object:self];
        }
    }
    //NSLog(@"Sending reload notification.");
}

@end
