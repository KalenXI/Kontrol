//
//  TVShowTableView-Phone.m
//  Kontrol
//
//  Created by Kevin Vinck on 5/10/11.
//  Copyright 2011 None. All rights reserved.
//

#import "TVShowTableView-Phone.h"


@implementation TVShowTableView_Phone

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
    static NSString *CellIdentifier = @"EpisodeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary *curObject = [dataSource objectAtIndex:indexPath.row];
	cell.textLabel.text = [NSString stringWithFormat:@"%@-%@ %@",[curObject valueForKey:@"iSeason"],[curObject valueForKey:@"iEpisode"],[curObject valueForKey:@"strTitle"]];
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
    NSDictionary *currentObject = [dataSource objectAtIndex:indexPath.row];
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
