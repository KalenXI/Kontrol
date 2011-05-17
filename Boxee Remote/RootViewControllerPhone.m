//
//  RootViewControllerPhone.m
//  Boxee Remote
//
//  Created by Kevin Vinck on 25/03/2011.
//  Copyright 2011 None. All rights reserved.
//

#import "RootViewControllerPhone.h"

#import "DetailViewController.h"
#import <dispatch/dispatch.h>

@implementation RootViewControllerPhone

//NSString * const hideMediaListPopupNotification = @"HideMediaPopup";

@synthesize detailViewController,isRootDirectory,isLibraryDirectory,libraryType;

dispatch_queue_t myQueue;

- (void)awakeFromNib {
    //NSLog(@"RootViewControllerPhone awoken from nib.");
    viewTitle = @"Media Library";
    self.title = viewTitle;
    isRootDirectory = YES;
    isLibraryDirectory = YES;
    //NSLog(@"Registering media lisssst.");
    if (isRootDirectory == YES) {
        //NSLog(@"Loading root directory.");
        m_boxee = [BoxeeHTTPInterface sharedInstance];
        //mediaShares = [m_boxee getShares];
        //[mediaShares retain];
        numOfShares = [mediaShares count];
    }
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    //NSLog(@"Registering with notification center.");
    [nc addObserver:self
           selector:@selector(reloadMediaList:) 
               name:MediaListNeedsReloadingNotificationPhone
             object:nil];
    self.navigationController.delegate = self;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(RootViewControllerPhone *)viewController animated:(BOOL)animated {
    //NSLog(@"Title: %@",viewController.title);
    /*if ([viewController.title isEqualToString:@"Media Library"]) {
        viewController.isRootDirectory = YES;
        if ([m_boxee isDatabaseEnabled]) {
            //NSLog(@"Checkpoint 1");
            isLibraryDirectory = YES;
        } else {
            isLibraryDirectory = NO;
        }
    } else if ([viewController.title isEqualToString:@"Files"]) {
        viewController.isRootDirectory = YES;
        viewController.isLibraryDirectory = NO;
        viewController.libraryType = 3;
    } else if ([viewController.title isEqualToString:@"TV Shows"]) {
        //viewController.isRootDirectory = NO;
        //viewController.isLibraryDirectory = YES;
        //viewController.libraryType = 0;
    } else if ([viewController.title isEqualToString:@"Albums"]) {
        viewController.isRootDirectory = NO;
        viewController.isLibraryDirectory = YES;
        viewController.libraryType = 5;
        //NSLog(@"Returned to album.");
    } else if ([viewController.title isEqualToString:@"Artists"]) {
        viewController.isRootDirectory = NO;
        viewController.isLibraryDirectory = YES;
        viewController.libraryType = 6;
    }*/
    //NSLog(@"LibraryType: %i",libraryType);
}

- (void)reloadMediaList:(NSNotification *)note {
    //NSLog(@"Reloading media list.");
    if (self.navigationController.visibleViewController == self.navigationController.topViewController) {
        //NSLog(@"Going back to root view.");
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    isRootDirectory = YES;
    //NSLog(@"Checking if database is enabled.");
    if ([m_boxee isDatabaseEnabled]) {
        isLibraryDirectory = YES;
    } else {
        isLibraryDirectory = NO;
    }
    [mediaShares release];
    mediaShares = [m_boxee getShares];
    if (mediaShares != nil) {
        [mediaShares retain];
        numOfShares = [mediaShares count];
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    myQueue = dispatch_queue_create("com.lastdit.kontrol", NULL);
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    self.title = viewTitle;
    //NSLog(@"viewDidLoad");
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

-(id)initWithTVShows {
    self = [super init];
    if (self) {
        //NSLog(@"initWithTVShows");
        viewTitle = @"TV Shows";
        m_boxee = [BoxeeHTTPInterface sharedInstance];
        NSSortDescriptor *sortByTitle = [[NSSortDescriptor alloc] initWithKey:@"strTitle" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        dataSource = [[m_boxee getTVShows] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByTitle]];
        [sortByTitle release];
        //NSLog(@"dataSource: %@",dataSource);
        [dataSource retain];
        isRootDirectory = NO;
        isLibraryDirectory = YES;
        libraryType = 0;
        numOfShares = [dataSource count];
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

-(id)initWithMusic {
    self = [super init];
    if (self) {
        //NSLog(@"initWithPath");
        viewTitle = @"Music";
        m_boxee = [BoxeeHTTPInterface sharedInstance];
        dataSource = [NSArray arrayWithObjects:@"Albums",@"Artists", nil];
        [dataSource retain];
        isRootDirectory = NO;
        isLibraryDirectory = YES;
        libraryType = 2;
        numOfShares = [dataSource count];
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
        isRootDirectory = NO;
        isLibraryDirectory = YES;
        libraryType = 6;
        numOfShares = [dataSource count];
    }
    return self;
}

-(id)initWithAlbums {
    self = [super init];
    if (self) {
        //NSLog(@"initWithPath");
        viewTitle = @"Albums";
        m_boxee = [BoxeeHTTPInterface sharedInstance];
        NSSortDescriptor *sortByTitle = [[NSSortDescriptor alloc] initWithKey:@"strTitle" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        dataSource = [[m_boxee getAlbums] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByTitle]];
        [sortByTitle release];
        [dataSource retain];
        isRootDirectory = NO;
        isLibraryDirectory = YES;
        libraryType = 5;
        numOfShares = [dataSource count];
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

-(id)initWithArtist:(NSString *)artist Name:(NSString *)name {
    self = [super init];
    if (self) {
        //NSLog(@"initWithPath");
        viewTitle = name;
        m_boxee = [BoxeeHTTPInterface sharedInstance];
        NSSortDescriptor *sortByTitle = [[NSSortDescriptor alloc] initWithKey:@"strTitle" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        dataSource = [[m_boxee getSongsForArtist:artist] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByTitle]];
        [sortByTitle release];
        [dataSource retain];
        isRootDirectory = NO;
        isLibraryDirectory = YES;
        libraryType = 8;
        numOfShares = [dataSource count];
    }
    return self;
}

-(id)initWithFiles {
    self = [super init];
    if (self) {
        //NSLog(@"initWithPath");
        viewTitle = @"Files";
        
        m_boxee = [BoxeeHTTPInterface sharedInstance];
        mediaShares = [m_boxee getShares];
        [mediaShares retain];
        numOfShares = [mediaShares count];
        isRootDirectory = YES;
        isLibraryDirectory = NO;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"View will appear.");
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ((numOfShares > 0) && (isLibraryDirectory == NO)) {
        if (isRootDirectory == YES) {
            return numOfShares;
        } else {
            return numOfShares;
        }
    } else if ((numOfShares > 0) && (isLibraryDirectory == YES)) {
        if (isRootDirectory == YES) {
            return 4;
        } else {
            return numOfShares;
        }
    } else {
        return 1;
    }
    
}

// Template for determining source.

/*if ((numOfShares > 0) && (isLibraryDirectory == NO)) {
 if (isRootDirectory == YES) {
 //Root file directory.
 } else {
 //Sub file directory.
 }
 } else if ((numOfShares > 0) && (isLibraryDirectory == YES)) {
 if (isRootDirectory == YES) {
 //Root library directory
 } else {
 //Sub library directory
 }
 } else {
 //No directories.
 }*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((numOfShares > 0) && (isLibraryDirectory == NO)) {
        if (isRootDirectory == YES) {
            //Return cells for root file directory.
            //NSLog(@"mediaShares: %@",[mediaShares objectAtIndex:0]);
            NSString *replyString = [[mediaShares objectAtIndex:0] objectAtIndex:0];
            if ([replyString isEqualToString:@"Error"]) {
                static NSString *CellIdentifier = @"ErrorCell";
                
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
                }
                //NSLog(@"mediaShares: %@",mediaShares);
                cell.textLabel.text = @"Error retreiving shares.";
                //cell.detailTextLabel.text = [[mediaShares objectAtIndex:indexPath.row] objectAtIndex:2];
                //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell; 
            }
            //NSLog(@"Returning cells for root file directory.");
            static NSString *CellIdentifier = @"Cell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            }
            //NSLog(@"mediaShares: %@",mediaShares);
            cell.textLabel.text = [[mediaShares objectAtIndex:indexPath.row] objectAtIndex:1];
            cell.detailTextLabel.text = [[mediaShares objectAtIndex:indexPath.row] objectAtIndex:2];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        } else {
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
            
            cell.textLabel.text = [cellObject objectAtIndex:1];
            cell.detailTextLabel.text = [cellObject objectAtIndex:0];
            return cell;
        }
    } else if ((numOfShares > 0) && (isLibraryDirectory == YES)) {
        //NSLog(@"In library directory");
        if (isRootDirectory == YES) {
            //Return cells for root library directory.
            //NSLog(@"Returning cells for library root directory.");
            static NSString *CellIdentifier = @"Cell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            }
            
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"TV Shows";
                    break;
                case 1:
                    cell.textLabel.text = @"Movies";
                    break;
                case 2:
                    cell.textLabel.text = @"Music";
                    break;
                case 3:
                    cell.textLabel.text = @"Files";
                    break;
                    
                default:
                    cell.textLabel.text = @"You shouldn't be seeing this.";
                    break;
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    } else if ((numOfShares == 0) && (isLibraryDirectory == YES)) {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
        cell.textLabel.text = @"No videos found.";
        return cell;
    } else {
        //Return instruction cell if server not connected.
        static NSString *CellIdentifier = @"Cell";
        //NSLog(@"Number of cells: %i",numOfShares);
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
        cell.textLabel.text = @"Select a Boxee server.";
        return cell;
    }
	
	//Return instruction cell if server not connected.
	static NSString *CellIdentifier = @"Cell";
	//NSLog(@"Number of cells: %i",numOfShares);
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	cell.textLabel.text = @"Select a Boxee server.";
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"libraryView: %i",libraryType);    
    if ((numOfShares > 0) && (isLibraryDirectory == NO)) {
        if (isRootDirectory == YES) {
            [tableView deselectRowAtIndexPath:indexPath	animated:YES];
            NSString *path = [[mediaShares objectAtIndex:indexPath.row] objectAtIndex:2];
            UITableViewController *targetViewController = [[FolderTableView_Phone alloc] initWithPath:path title:[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text];
            [self.navigationController pushViewController:targetViewController animated:YES];
            [targetViewController release];
        }
    } else if ((numOfShares > 0) && (isLibraryDirectory == YES)) {
        if (isRootDirectory == YES) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            if (indexPath.row == 0) {
                //TV Show
                UITableViewController *targetViewController = [[TVShowsTableView_Phone alloc] initWithTVShows];
                [self.navigationController pushViewController:targetViewController animated:YES];
                [targetViewController release];
                libraryType = 0;
                //NSLog(@"Clicked TV show.");
            } else if (indexPath.row == 1) {
                libraryType = 1;
                UITableViewController *targetViewController = [[MoviesTableView_Phone alloc] initWithMovies];
                [self.navigationController pushViewController:targetViewController animated:YES];
                [targetViewController release];
                //NSLog(@"Clicked movies.");
            } else if (indexPath.row == 2) {
                //Music
                //NSLog(@"Clicked music.");
                UITableViewController *targetViewController = [[MusicTableView_Phone alloc] initWithMusic];
                [self.navigationController pushViewController:targetViewController animated:YES];
                [targetViewController release];
            } else if (indexPath.row == 3) {
                //NSLog(@"Clicked file.");
                isRootDirectory = YES;
                isLibraryDirectory = NO;
                UITableViewController *targetViewController = [[FilesTableView_Phone alloc] initWithFiles];
                [self.navigationController pushViewController:targetViewController animated:YES];
                [targetViewController release];
            }
        }
    } else {
        [tableView deselectRowAtIndexPath:indexPath	animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [detailViewController release];
    detailViewController = nil;
    [super dealloc];
}

@end
