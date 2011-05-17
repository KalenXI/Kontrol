//
//  TVShowTableView.m
//  Kontrol
//
//  Created by Kevin Vinck on 5/5/11.
//  Copyright 2011 None. All rights reserved.
//

#import "TVShowTableView.h"
#import "DetailViewController.h"
#import "RootViewController.h"

dispatch_queue_t myQueue;

@implementation TVShowTableView

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
		isSearching = NO;
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
		
		//NSLog(@"seasons: %@",seasons);
		//NSLog(@"seasonEpNums: %@",seasonEpNums);
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
    static NSString *cellIdentifier = @"EpisodeCell";
	
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
	
	//NSLog(@"Full row: %i",fullRow);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
    }
	
	//NSLog(@"Indexpath: %i",[indexPath length]);
    
    NSDictionary *curObject = [tableData objectAtIndex:fullRow];
    cell.textLabel.text = [NSString stringWithFormat:@"%@-%@ %@",[curObject valueForKey:@"iSeason"],[curObject valueForKey:@"iEpisode"],[curObject valueForKey:@"strTitle"]];
    cell.detailTextLabel.text = [[tableData objectAtIndex:fullRow] valueForKey:@"strPath"];
    cell.detailTextLabel.lineBreakMode = UILineBreakModeHeadTruncation;
    
    return cell;
}

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
    
    RootViewController* firstLevelViewController = [self.navigationController.viewControllers objectAtIndex:0];
    NSDictionary *currentObject = [tableData objectAtIndex:fullRow];
    
    MediaItem *media = [[MediaItem alloc] init];
	
    media.strShowName = viewTitle;
    media.strTitle = [currentObject valueForKey:@"strTitle"];
    media.strPath = [currentObject valueForKey:@"strPath"];
    media.strDescription = [currentObject valueForKey:@"strDescription"];
    media.iEpisode = [NSNumber numberWithInt:[[currentObject valueForKey:@"iEpisode"] intValue]];
    media.iSeason = [NSNumber numberWithInt:[[currentObject valueForKey:@"iSeason"] intValue]];
    firstLevelViewController.detailViewController.playNowButton.enabled = YES;
    
    dispatch_async(myQueue, ^ { 
        NSURL *thumbURL = [NSURL URLWithString:[currentObject valueForKey:@"strCover"]];
        NSData *thumbData = [NSData dataWithContentsOfURL:thumbURL];
        UIImage *thumbnail = [UIImage imageWithData:thumbData];
        dispatch_async(dispatch_get_main_queue(), ^ {firstLevelViewController.detailViewController.thumbnailView.image = thumbnail;});
    } );
    
    if (firstLevelViewController.detailViewController.isSplashViewOn == YES) {
        [firstLevelViewController.detailViewController removeSplash];
        firstLevelViewController.detailViewController.isSplashViewOn = NO;
    }
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:hideMediaListPopupNotification object:self];
    firstLevelViewController.detailViewController.mediaItem = media;
    [firstLevelViewController.detailViewController configureView];
}

@end
