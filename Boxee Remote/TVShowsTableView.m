//
//  TVShowTableView.m
//  Kontrol
//
//  Created by Kevin Vinck on 5/4/11.
//  Copyright 2011 None. All rights reserved.
//

#import "TVShowsTableView.h"
#import "DetailViewController.h"
#import "RootViewController.h"

dispatch_queue_t myQueue;


@implementation TVShowsTableView

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithTVShows {
    self = [super init];
    if (self) {
        NSLog(@"initWithTVShows");
        viewTitle = @"TV Shows";
        m_boxee = [BoxeeHTTPInterface sharedInstance];
        NSSortDescriptor *sortByTitle = [[NSSortDescriptor alloc] initWithKey:@"strTitle" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        dataSource = [[m_boxee getTVShows] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByTitle]];
        [sortByTitle release];
        NSLog(@"dataSource: %@",dataSource);
        [dataSource retain];
        isRootDirectory = NO;
        isLibraryDirectory = YES;
        libraryType = 0;
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
    NSString *cellIdentifier;
    cellIdentifier = @"TVShowCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
    }
    
        cell.textLabel.text = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"strTitle"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RootViewController* firstLevelViewController = [self.navigationController.viewControllers objectAtIndex:0];
    
    NSDictionary *currentObject = [dataSource objectAtIndex:indexPath.row];
    NSString *tvShow = [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    UITableViewController *targetViewController = [[TVShowTableView alloc] initWithTVShow:tvShow];
    curShowName = [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    [self.navigationController pushViewController:targetViewController animated:YES];
    [targetViewController release];
    MediaItem *media = [[MediaItem alloc] init];
        
    media.strShowName = [currentObject valueForKey:@"strTitle"];
    media.strTitle = viewTitle;
    media.strDescription = [currentObject valueForKey:@"strDescription"];
    firstLevelViewController.detailViewController.playNowButton.enabled = NO;
        
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
        
    firstLevelViewController.detailViewController.mediaItem = media;
    [firstLevelViewController.detailViewController configureView];
}

@end
