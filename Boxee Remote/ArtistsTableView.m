//
//  ArtistsTableView.m
//  Kontrol
//
//  Created by Kevin Vinck on 5/7/11.
//  Copyright 2011 None. All rights reserved.
//

#import "ArtistsTableView.h"


@implementation ArtistsTableView

@synthesize searchDC,searchBar;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithArtists {
    self = [super init];
    if (self) {
        //NSLog(@"initWithPath");
        viewTitle = @"Artists";
        m_boxee = [BoxeeHTTPInterface sharedInstance];
        NSSortDescriptor *sortByTitle = [[NSSortDescriptor alloc] initWithKey:@"strTitle" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        dataSource = [[m_boxee getArtists] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByTitle]];
        [sortByTitle release];
        [dataSource retain];
        tableData = [NSMutableArray arrayWithArray:dataSource];
        [tableData retain];
        isRootDirectory = NO;
        isLibraryDirectory = YES;
        libraryType = 6;
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

    myQueue = dispatch_queue_create("com.lastdit.kontrol", NULL);
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    self.title = viewTitle;
    
    self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)] autorelease];
	self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.searchBar.keyboardType = UIKeyboardTypeAlphabet;
	self.searchBar.delegate = self;
	self.tableView.tableHeaderView = self.searchBar;
	
	// Create the search display controller
	self.searchDC = [[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self] autorelease];
	self.searchDC.searchResultsDataSource = self;
	self.searchDC.searchResultsDelegate = self;
	self.searchDC.delegate = self;
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
	return YES;
}

#pragma mark - Search delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)sb {
	[tableData removeAllObjects];
	
	for (NSDictionary* item in dataSource) {
		NSString *title;
		title = [item valueForKey:@"strName"];
		
		if ([title rangeOfString:sb.text options:NSCaseInsensitiveSearch].location != NSNotFound) {
			//NSLog(@"Found title: %@",title);
			[tableData addObject:item];
		}
	}
	[tableData retain];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
	tableData = [NSMutableArray arrayWithArray:dataSource];
	[tableData retain];
}

- (void)searchBar:(UISearchBar *)sb textDidChange:(NSString *)searchText {
	[tableData removeAllObjects];
	
	for (NSDictionary* item in dataSource) {
		NSString *title;
		title = [item valueForKey:@"strName"];
		
		if ([title rangeOfString:sb.text options:NSCaseInsensitiveSearch].location != NSNotFound) {
			[tableData addObject:item];
		}
	}
	[tableData retain];
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
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ArtistCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [[tableData objectAtIndex:indexPath.row] valueForKey:@"strName"];
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
    //NSLog(@"Clicked on artist.");
	NSDictionary *currentObject = [tableData objectAtIndex:indexPath.row];
	NSString *artist = [currentObject valueForKey:@"idArtist"];
	//NSLog(@"Clicked on artist id: %@",artist);
	UITableViewController *targetViewController = [[ArtistTableView alloc] initWithArtist:artist Name:[currentObject valueForKey:@"strName"]];
	[self.navigationController pushViewController:targetViewController animated:YES];
	[targetViewController release];
}

@end
