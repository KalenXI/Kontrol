//
//  FolderTableView-Phone.m
//  Kontrol
//
//  Created by Kevin Vinck on 5/10/11.
//  Copyright 2011 None. All rights reserved.
//

#import "FolderTableView-Phone.h"


@implementation FolderTableView_Phone

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithPath:(NSString *)path title:(NSString*)title {
    //NSLog(@"Initilizing in alternate path");
    self = [super init];
    if (self) {
        //NSLog(@"initWithPath");
        viewTitle = title;
        m_boxee = [BoxeeHTTPInterface sharedInstance];
        dataSource = [m_boxee getDirectory:path];
        [dataSource retain];
        isRootDirectory = NO;
        numOfShares = [dataSource count];
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
    //Return cells for sub file directory.
	//NSLog(@"Returning cells for sub file directory.");
	static NSString *FolderCellIdentifier = @"Folder";
	static NSString *FileCellIdentifier = @"File";
	NSArray *cellObject = [dataSource objectAtIndex:indexPath.row];
	UITableViewCell *cell;
	UITableViewCellStyle style;
	
	if ([[cellObject objectAtIndex:2] isEqualToString:@"tFile"]) {
		cell = [tableView dequeueReusableCellWithIdentifier:FileCellIdentifier];
		style = UITableViewCellStyleSubtitle;
	} else {
		
		cell = [tableView dequeueReusableCellWithIdentifier:FolderCellIdentifier];
		style = UITableViewCellStyleDefault;
	}
	
	if (cell == nil) {
		if ([[cellObject objectAtIndex:2] isEqualToString:@"tFile"]) {
			style = UITableViewCellStyleSubtitle;
			cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:FileCellIdentifier] autorelease];
		} else {
			style = UITableViewCellStyleDefault;
			cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:FolderCellIdentifier] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
	}
	
    cell.textLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
	cell.textLabel.text = [cellObject objectAtIndex:1];
	cell.detailTextLabel.text = [cellObject objectAtIndex:0];
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
    NSString *type = [[dataSource objectAtIndex:indexPath.row] objectAtIndex:2];
	
	if ([type isEqualToString:@"tFolder"]) {
		
		[tableView deselectRowAtIndexPath:indexPath	animated:YES];
		
		NSString *path = [[dataSource objectAtIndex:indexPath.row] objectAtIndex:0];
		
		UITableViewController *targetViewController = [[FolderTableView_Phone alloc] initWithPath:path title:[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text];
		
		[self.navigationController pushViewController:targetViewController animated:YES];
		[targetViewController release];
		
	} else if ([type isEqualToString:@"tFile"]) {
		
		NSArray *currentObject = [dataSource objectAtIndex:indexPath.row];
		DetailViewPhone *targetViewController = [[DetailViewPhone alloc] init];
		
		MediaItem *media = [[MediaItem alloc] init];
		
		NSDictionary *fileInfo = [m_boxee getInfoForFile:[currentObject objectAtIndex:0]];
		
		if ([fileInfo valueForKey:@"strTitle"] != nil) {
			media.strShowName = [fileInfo valueForKey:@"strTitle"];
			media.strDescription = [fileInfo valueForKey:@"strDescription"];
			media.strCover = [fileInfo valueForKey:@"strCover"];
		} else {
			NSArray *filename = [[currentObject objectAtIndex:0] componentsSeparatedByString:@"/"];
			media.strShowName = [filename objectAtIndex:[filename count] - 1];
			//firstLevelViewController.detailViewController.thumbnailView.image = nil;
			media.strDescription = @"";
		}
		media.strPath = [currentObject objectAtIndex:0];
		media.strTitle = viewTitle;
		
		targetViewController.mediaItem = media;
		[self.navigationController pushViewController:targetViewController animated:YES];
		[targetViewController release];
	}
}

@end
