//
//  FilesTableView-Phone.m
//  Kontrol
//
//  Created by Kevin Vinck on 5/10/11.
//  Copyright 2011 None. All rights reserved.
//

#import "FilesTableView-Phone.h"


@implementation FilesTableView_Phone

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithFiles {
    self = [super init];
    if (self) {
        //NSLog(@"initWithPath");
        viewTitle = @"Files";
        
        m_boxee = [BoxeeHTTPInterface sharedInstance];
        mediaShares = [m_boxee getShares];
        [mediaShares retain];
        numOfShares = [mediaShares count];
        isRootDirectory = YES;
        isLibraryDirectory = NO;
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
    [super viewDidAppear:animated];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return numOfShares;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Return cells for root file directory.
	//NSLog(@"mediaShares: %@",[mediaShares objectAtIndex:0]);
	NSString *replyString = [[mediaShares objectAtIndex:0] objectAtIndex:0];
	if ([replyString isEqualToString:@"Error"]) {
		static NSString *CellIdentifier = @"ErrorCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		}
		//NSLog(@"mediaShares: %@",mediaShares);
		cell.textLabel.text = @"Error retreiving shares.";
		//cell.detailTextLabel.text = [[mediaShares objectAtIndex:indexPath.row] objectAtIndex:2];
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		return cell; 
	}
	//NSLog(@"Returning cells for root file directory.");
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	//NSLog(@"mediaShares: %@",mediaShares);
	cell.textLabel.text = [[mediaShares objectAtIndex:indexPath.row] objectAtIndex:1];
	cell.detailTextLabel.text = [[mediaShares objectAtIndex:indexPath.row] objectAtIndex:2];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath	animated:YES];
	NSString *path = [[mediaShares objectAtIndex:indexPath.row] objectAtIndex:2];
	UITableViewController *targetViewController = [[FolderTableView_Phone alloc] initWithPath:path title:[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text];
	[self.navigationController pushViewController:targetViewController animated:YES];
	[targetViewController release];
}

@end
