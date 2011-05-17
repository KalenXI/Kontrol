//
//  TVShowTableView-Phone.m
//  Kontrol
//
//  Created by Kevin Vinck on 5/10/11.
//  Copyright 2011 None. All rights reserved.
//

#import "TVShowTableView-Phone.h"


@implementation TVShowTableView_Phone

@synthesize searchDC,searchBar;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithTVShow:(NSString *)show {
    self = [super init];
    if (self) {
        //NSLog(@"initWithPath");
        viewTitle = show;
        m_boxee = [BoxeeHTTPInterface sharedInstance];
        NSSortDescriptor *sortBySeason = [[NSSortDescriptor alloc] initWithKey:@"iSeason" ascending:YES];
        NSSortDescriptor *sortByEpisode = [[NSSortDescriptor alloc] initWithKey:@"iEpisode" ascending:YES];
        dataSource = [[m_boxee getEpisodesForTVShow:show] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortBySeason, sortByEpisode, nil]];
        tableData = [NSMutableArray arrayWithArray:dataSource];
        [sortBySeason release];
        [sortByEpisode release];
        [dataSource retain];
        [tableData retain];
        
        NSNumber *curSeason;
		NSNumber *lastSeason;
		seasons = [[NSMutableArray alloc] init];
		seasonEpNums = [[NSMutableArray alloc] init];
		int seasonEpNum = 0;
		
		for (int i = 0; i < [dataSource count]; i++) {			
			curSeason = [[dataSource objectAtIndex:i] valueForKey:@"iSeason"];
			//NSLog(@"curSeason: %@",curSeason);
			if (curSeason != lastSeason) {
				if (seasonEpNum > 0)
					[seasonEpNums addObject:[NSNumber numberWithInt:seasonEpNum]];
				seasonEpNum = 1;
				[seasons addObject:curSeason];
			} else {
				seasonEpNum++;
			}
			
			if (i == ([dataSource count] - 1)) {
				[seasonEpNums addObject:[NSNumber numberWithInt:seasonEpNum]];
			}
			
			lastSeason = curSeason;
		}
        
        isRootDirectory = NO;
        isLibraryDirectory = YES;
        libraryType = 4;
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

#pragma mark - Table view data source

- (void)searchBarSearchButtonClicked:(UISearchBar *)sb {
	//NSLog(@"Clicked Search: %@",sb.text);
	//[self.tableView setHidden:YES];
	isSearching = YES;
	//NSLog(@"Searching");
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

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	//NSLog(@"Done searching");
	isSearching = NO;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
	//NSLog(@"Done Searching.");
	tableData = [NSMutableArray arrayWithArray:dataSource];
	[tableData retain];
}

- (void)searchBar:(UISearchBar *)sb textDidChange:(NSString *)searchText {
	//NSLog(@"Search: %@",sb.text);
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
		return [seasons count];
	} else {
		return 1;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
		return [[seasonEpNums objectAtIndex:section] intValue];
	} else {
		//NSLog(@"%i results",[tableData count]);
		return [tableData count];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (tableView == self.tableView) {
		return [NSString stringWithFormat:@"Season %@",[seasons objectAtIndex:section]];
	} else {
		return nil;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EpisodeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    int fullRow = 0;
	
	for (int i = 0; i < indexPath.section; i++) {
		//NSLog(@"i: %i",i);
		//NSLog(@"Location: %i",[[seasonEpNums objectAtIndex:i] intValue]);
		fullRow = fullRow + [[seasonEpNums objectAtIndex:i] intValue];
	}
	
	if (tableView == self.tableView) {
		fullRow = fullRow + indexPath.row;
	} else {
		fullRow = indexPath.row;
		//NSLog(@"Did the right thing.");
	}
    
    NSDictionary *curObject = [tableData objectAtIndex:fullRow];
	cell.textLabel.text = [NSString stringWithFormat:@"%@-%@ %@",[curObject valueForKey:@"iSeason"],[curObject valueForKey:@"iEpisode"],[curObject valueForKey:@"strTitle"]];
	cell.detailTextLabel.text = [[tableData objectAtIndex:fullRow] valueForKey:@"strPath"];
	cell.detailTextLabel.lineBreakMode = UILineBreakModeHeadTruncation;
    
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
    
    int fullRow = 0;
	
	for (int i = 0; i < indexPath.section; i++) {
		//NSLog(@"i: %i",i);
		//NSLog(@"Location: %i",[[seasonEpNums objectAtIndex:i] intValue]);
		fullRow = fullRow + [[seasonEpNums objectAtIndex:i] intValue];
	}
	
	if (tableView == self.tableView) {
		fullRow = fullRow + indexPath.row;
	} else {
		fullRow = indexPath.row;
		//NSLog(@"Did the right thing.");
	}
    
    NSDictionary *currentObject = [tableData objectAtIndex:fullRow];
	DetailViewPhone *targetViewController = [[DetailViewPhone alloc] init];
	
	MediaItem *media = [[MediaItem alloc] init];
	media.strShowName = viewTitle;
	media.strTitle = [currentObject valueForKey:@"strTitle"];
	media.strPath = [currentObject valueForKey:@"strPath"];
	media.strDescription = [currentObject valueForKey:@"strDescription"];
	media.iEpisode = [NSNumber numberWithInt:[[currentObject valueForKey:@"iEpisode"] intValue]];
	media.iSeason = [NSNumber numberWithInt:[[currentObject valueForKey:@"iSeason"] intValue]];
	media.strCover = [currentObject valueForKey:@"strCover"];
	
	targetViewController.mediaItem = media;
	[self.navigationController pushViewController:targetViewController animated:YES];
	[targetViewController release];
}

@end
