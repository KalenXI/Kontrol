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
        [sortBySeason release];
        [sortByEpisode release];
        [dataSource retain];
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
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return numOfShares;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"EpisodeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
    NSDictionary *curObject = [dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@-%@ %@",[curObject valueForKey:@"iSeason"],[curObject valueForKey:@"iEpisode"],[curObject valueForKey:@"strTitle"]];
    cell.detailTextLabel.text = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"strPath"];
    cell.detailTextLabel.lineBreakMode = UILineBreakModeHeadTruncation;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RootViewController* firstLevelViewController = [self.navigationController.viewControllers objectAtIndex:0];
    NSDictionary *currentObject = [dataSource objectAtIndex:indexPath.row];
    
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
