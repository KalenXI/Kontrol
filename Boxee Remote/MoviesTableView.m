//
//  MoviesTableView.m
//  Kontrol
//
//  Created by Kevin Vinck on 5/6/11.
//  Copyright 2011 None. All rights reserved.
//

#import "MoviesTableView.h"


@implementation MoviesTableView

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithMovies {
    self = [super init];
    if (self) {
        //NSLog(@"initWithPath");
        viewTitle = @"Movies";
        m_boxee = [BoxeeHTTPInterface sharedInstance];
        NSSortDescriptor *sortByTitle = [[NSSortDescriptor alloc] initWithKey:@"strTitle" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        dataSource = [[m_boxee getMovies] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByTitle]];
        //dataSource = [m_boxee getDirectory:path];
        [sortByTitle release];
        [dataSource retain];
        isRootDirectory = NO;
        isLibraryDirectory = YES;
        libraryType = 1;
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
    static NSString *CellIdentifier = @"MovieCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"strTitle"];
	cell.detailTextLabel.text = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"strPath"];
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
    //NSLog(@"Touched movie.");
	
    RootViewController* firstLevelViewController = [self.navigationController.viewControllers objectAtIndex:0];
	NSDictionary *currentObject = [dataSource objectAtIndex:indexPath.row];
	
	MediaItem *media = [[MediaItem alloc] init];
	
	NSString *dir = [m_boxee getDirectorForVideo:[currentObject valueForKey:@"idVideo"]];
	
	media.strShowName = [currentObject valueForKey:@"strTitle"];
	if (dir != nil) {
		media.strTitle = dir;
	} else {
		media.strTitle = @"";
	}
	media.strPath = [currentObject valueForKey:@"strPath"];
	media.strDescription = [currentObject valueForKey:@"strDescription"];
	firstLevelViewController.detailViewController.playNowButton.enabled = YES;
	//media.strShowName = viewTitle;
	
	dispatch_async(myQueue, ^ { 
		//NSLog(@"strCover: %@",[currentObject valueForKey:@"strCover"]);
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
