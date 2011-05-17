//
//  AlbumTableView-Phone.m
//  Kontrol
//
//  Created by Kevin Vinck on 5/10/11.
//  Copyright 2011 None. All rights reserved.
//

#import "AlbumTableView-Phone.h"


@implementation AlbumTableView_Phone

@synthesize searchDC,searchBar;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithAlbum:(NSString *)album Name:(NSString *)name {
    self = [super init];
    if (self) {
        //NSLog(@"initWithPath");
        viewTitle = name;
        m_boxee = [BoxeeHTTPInterface sharedInstance];
        NSSortDescriptor *sortByTitle = [[NSSortDescriptor alloc] initWithKey:@"iTrackNumber" ascending:YES];
        dataSource = [[m_boxee getSongsForAlbum:album] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByTitle]];
        [sortByTitle release];
        [dataSource retain];
        tableData = [NSMutableArray arrayWithArray:dataSource];
        [tableData retain];
        isRootDirectory = NO;
        isLibraryDirectory = YES;
        libraryType = 7;
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
    
    self.title = viewTitle;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Search delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)sb {
	[tableData removeAllObjects];
	
	for (NSDictionary* item in dataSource) {
		NSString *title;
		title = [item valueForKey:@"strTitle"];
		
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
		title = [item valueForKey:@"strTitle"];
		
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
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [[tableData objectAtIndex:indexPath.row] valueForKey:@"strTitle"];
	//NSLog(@"AlbumSongCell = %@",[dataSource objectAtIndex:indexPath.row]);
	cell.detailTextLabel.text = [m_boxee getArtistWithID:[[tableData objectAtIndex:indexPath.row] valueForKey:@"idArtist"]];
    
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
    //NSLog(@"Clicked on album song.");
	NSDictionary *currentObject = [tableData objectAtIndex:indexPath.row];
	DetailViewPhone *targetViewController = [[DetailViewPhone alloc] init];
	
	MediaItem *media = [[MediaItem alloc] init];
	
	media.strShowName = [currentObject valueForKey:@"strTitle"];
	media.strPath = [currentObject valueForKey:@"strPath"];
	media.strTitle = [m_boxee getArtistWithID:[currentObject valueForKey:@"idArtist"]];                
	
	media.strDescription = @"";
	
	//NSData *thumbData = [m_boxee getFile:[m_boxee getArtworkForAlbum:[currentObject valueForKey:@"idAlbum"]]];
	//UIImage *thumbnail = [UIImage imageWithData:thumbData];
	
	//firstLevelViewController.detailViewController.thumbnailView.image = thumbnail;
	targetViewController.mediaItem = media;
	[self.navigationController pushViewController:targetViewController animated:YES];
	[targetViewController release];
}

@end
