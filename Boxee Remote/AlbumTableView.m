//
//  AlbumTableView.m
//  Kontrol
//
//  Created by Kevin Vinck on 5/7/11.
//  Copyright 2011 None. All rights reserved.
//

#import "AlbumTableView.h"


@implementation AlbumTableView

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

    myQueue = dispatch_queue_create("com.lastdit.kontrol", NULL);
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    self.title = viewTitle;
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
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"strTitle"];
	cell.detailTextLabel.text = [m_boxee getAlbumWithID:[[dataSource objectAtIndex:indexPath.row] valueForKey:@"idAlbum"]];
    
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
	RootViewController* firstLevelViewController = [self.navigationController.viewControllers objectAtIndex:0];
	NSDictionary *currentObject = [dataSource objectAtIndex:indexPath.row];
	
	MediaItem *media = [[MediaItem alloc] init];
	
	media.strShowName = [currentObject valueForKey:@"strTitle"];
	media.strPath = [currentObject valueForKey:@"strPath"];
	media.strTitle = [m_boxee getArtistWithID:[currentObject valueForKey:@"idArtist"]];
	firstLevelViewController.detailViewController.playNowButton.enabled = YES;
	
	
	
	media.strDescription = @"";
	//media.strShowName = viewTitle;
	
	//NSURL *thumbURL = [NSURL URLWithString:[[m_boxee getArtworkForAlbum:[currentObject valueForKey:@"idAlbum"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	////NSLog(@"Thumbnail url: %@",thumbURL);
	NSData *thumbData = [m_boxee getFile:[m_boxee getArtworkForAlbum:[currentObject valueForKey:@"idAlbum"]]];
	UIImage *thumbnail = [UIImage imageWithData:thumbData];
	
	firstLevelViewController.detailViewController.thumbnailView.image = thumbnail;
	
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
