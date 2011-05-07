//
//  RootViewController.m
//  Boxee Remote
//
//  Created by Kevin Vinck on 25/03/2011.
//  Copyright 2011 None. All rights reserved.
//

#import "RootViewController.h"

#import "DetailViewController.h"
#import <dispatch/dispatch.h>

@implementation RootViewController

NSString * const hideMediaListPopupNotification = @"HideMediaPopup";
		
@synthesize detailViewController,isRootDirectory,isLibraryDirectory,libraryType;

dispatch_queue_t myQueue;

- (void)awakeFromNib {
    //NSLog(@"RootViewController awoken from nib.");
    viewTitle = @"Media Library";
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
    [nc addObserver:self
           selector:@selector(reloadMediaList:) 
               name:MediaListNeedsReloadingNotification
             object:nil];
    self.navigationController.delegate = self;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(RootViewController *)viewController animated:(BOOL)animated {
    //NSLog(@"Title: %@",viewController.title);
    if ([viewController.title isEqualToString:@"Media Library"]) {
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
        viewController.isRootDirectory = NO;
        viewController.isLibraryDirectory = YES;
        viewController.libraryType = 0;
    } else if ([viewController.title isEqualToString:@"Albums"]) {
        viewController.isRootDirectory = NO;
        viewController.isLibraryDirectory = YES;
        viewController.libraryType = 5;
        //NSLog(@"Returned to album.");
    } else if ([viewController.title isEqualToString:@"Artists"]) {
        viewController.isRootDirectory = NO;
        viewController.isLibraryDirectory = YES;
        viewController.libraryType = 6;
    }
    //NSLog(@"LibraryType: %i",libraryType);
}

- (void)reloadMediaList:(NSNotification *)note {
    //NSLog(@"Reloading media list.");
    if (self.navigationController.visibleViewController == self.navigationController.topViewController) {
        //NSLog(@"Going back to root view.");
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    isRootDirectory = YES;
    //NSLog(@"Reloadmedialist: Checking if database is enabled.");
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
    return YES;
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
            return 5;
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
                case 4:
                    cell.textLabel.text = @"RSS";
                    break;
                    
                default:
                    cell.textLabel.text = @"Cell display error.";
                    break;
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        } else {
            //Return cells for sub library directory.
            NSString *cellIdentifier;
            //NSLog(@"libraryType: %i",libraryType);
            //NSLog(@"Returning cells for sub library directory.");            
            if ([self.title isEqualToString:@"TV Shows"]) {
                cellIdentifier = @"TVShowCell";
            } else if (libraryType == 1) {
                cellIdentifier = @"MovieCell";
            } else if (libraryType == 2) {
                cellIdentifier = @"MusicCell";
            } else if (libraryType == 4) {
                cellIdentifier = @"EpisodeCell";
            } else if (libraryType == 5) {
                cellIdentifier = @"AlbumCell";
            } else if (libraryType == 6) {
                cellIdentifier = @"ArtistCell";
            } else if (libraryType == 7) {
                cellIdentifier = @"AlbumSongCell";
            } else if (libraryType == 8) {
                cellIdentifier = @"ArtistSongCell";
            } else {
                cellIdentifier = @"Cell";
            }
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
            }
                        
            if ([self.title isEqualToString:@"TV Shows"]) {
                cell.textLabel.text = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"strTitle"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else if (libraryType == 1) {
                cell.textLabel.text = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"strTitle"];
                cell.detailTextLabel.text = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"strPath"];
                cell.detailTextLabel.lineBreakMode = UILineBreakModeHeadTruncation;
            } else if (libraryType == 4) {
                NSDictionary *curObject = [dataSource objectAtIndex:indexPath.row];
                cell.textLabel.text = [NSString stringWithFormat:@"%@-%@ %@",[curObject valueForKey:@"iSeason"],[curObject valueForKey:@"iEpisode"],[curObject valueForKey:@"strTitle"]];
                cell.detailTextLabel.text = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"strPath"];
                cell.detailTextLabel.lineBreakMode = UILineBreakModeHeadTruncation;
            } else if ([self.title isEqualToString:@"Music"]) {
                cell.textLabel.text = [dataSource objectAtIndex:indexPath.row];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else if ([self.title isEqualToString:@"Albums"]) {
                cell.textLabel.text = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"strTitle"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else if ([self.title isEqualToString:@"Artists"]) {
                cell.textLabel.text = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"strName"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else if (libraryType == 7) {
                cell.textLabel.text = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"strTitle"];
                cell.detailTextLabel.text = [m_boxee getArtistWithID:[[dataSource objectAtIndex:indexPath.row] valueForKey:@"idArtist"]];
            } else if (libraryType == 8) {
                cell.textLabel.text = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"strTitle"];
                cell.detailTextLabel.text = [m_boxee getAlbumWithID:[[dataSource objectAtIndex:indexPath.row] valueForKey:@"idAlbum"]];
            } else {
                cell.textLabel.text = @"Unidentified cell source.";
            }
            
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
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"libraryView: %i",libraryType);
    RootViewController* firstLevelViewController = [self.navigationController.viewControllers objectAtIndex:0];
    
    if ((numOfShares > 0) && (isLibraryDirectory == NO)) {
     if (isRootDirectory == YES) {
         [tableView deselectRowAtIndexPath:indexPath	animated:YES];
         NSString *path = [[mediaShares objectAtIndex:indexPath.row] objectAtIndex:2];
         UITableViewController *targetViewController = [[RootViewController alloc] initWithPath:path title:[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text];
         [self.navigationController pushViewController:targetViewController animated:YES];
         [targetViewController release];
     } else {
         NSString *type = [[dataSource objectAtIndex:indexPath.row] objectAtIndex:2];
         
         if ([type isEqualToString:@"tFolder"]) {
             
             [tableView deselectRowAtIndexPath:indexPath	animated:YES];
             
             NSString *path = [[dataSource objectAtIndex:indexPath.row] objectAtIndex:0];
             
             UITableViewController *targetViewController = [[RootViewController alloc] initWithPath:path title:[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text];
             
             [self.navigationController pushViewController:targetViewController animated:YES];
             [targetViewController release];
             
         } else if ([type isEqualToString:@"tFile"]) {
             
             //RootViewController* firstLevelViewController = [self.navigationController.viewControllers objectAtIndex:0];
             NSArray *currentObject = [dataSource objectAtIndex:indexPath.row];
             
             MediaItem *media = [[MediaItem alloc] init];
             
             NSDictionary *fileInfo = [m_boxee getInfoForFile:[currentObject objectAtIndex:0]];
             
             //media.strTitle = [currentObject objectAtIndex:1];
             //media.strPath = [currentObject objectAtIndex:0];
             
             if ([fileInfo valueForKey:@"strTitle"] != nil) {
                 media.strShowName = [fileInfo valueForKey:@"strTitle"];
                 media.strDescription = [fileInfo valueForKey:@"strDescription"];
                 dispatch_async(myQueue, ^ { 
                     //NSLog(@"strCover: %@",[fileInfo valueForKey:@"strCover"]);
                     NSURL *thumbURL = [NSURL URLWithString:[fileInfo valueForKey:@"strCover"]];
                     NSData *thumbData = [NSData dataWithContentsOfURL:thumbURL];
                     UIImage *thumbnail = [UIImage imageWithData:thumbData];
                     dispatch_async(dispatch_get_main_queue(), ^ {firstLevelViewController.detailViewController.thumbnailView.image = thumbnail;});
                 } );
             } else {
                 NSArray *filename = [[currentObject objectAtIndex:0] componentsSeparatedByString:@"/"];
                 media.strShowName = [filename objectAtIndex:[filename count] - 1];
                 firstLevelViewController.detailViewController.thumbnailView.image = nil;
                 media.strDescription = @"";
             }
             media.strPath = [currentObject objectAtIndex:0];
             media.strTitle = viewTitle;
             
             //NSLog(@"File info: %@",fileInfo);
             firstLevelViewController.detailViewController.playNowButton.enabled = YES;
             if (firstLevelViewController.detailViewController.isSplashViewOn == YES) {
                 [firstLevelViewController.detailViewController removeSplash];
                 firstLevelViewController.detailViewController.isSplashViewOn = NO;
             }
             NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
             [nc postNotificationName:hideMediaListPopupNotification object:self];
             firstLevelViewController.detailViewController.mediaItem = media;
             [firstLevelViewController.detailViewController configureView];
             
         }
     }
     } else if ((numOfShares > 0) && (isLibraryDirectory == YES)) {
         if (isRootDirectory == YES) {
             [tableView deselectRowAtIndexPath:indexPath animated:YES];
             if (indexPath.row == 0) {
                 //TV Show
                 /*UITableViewController *targetViewController = [[RootViewController alloc] initWithTVShows];
                 [self.navigationController pushViewController:targetViewController animated:YES];
                 [targetViewController release];
                 libraryType = 0;*/
                 
                 UITableViewController *targetViewController = [[TVShowsTableView alloc] initWithTVShows];
                 [self.navigationController pushViewController:targetViewController animated:YES];
                 [targetViewController release];
                 
                 //NSLog(@"Clicked TV show.");
             } else if (indexPath.row == 1) {
                 libraryType = 1;
                 UITableViewController *targetViewController = [[RootViewController alloc] initWithMovies];
                 [self.navigationController pushViewController:targetViewController animated:YES];
                 [targetViewController release];
                 //NSLog(@"Clicked movies.");
             } else if (indexPath.row == 2) {
                 //Music
                 //NSLog(@"Clicked music.");
                 UITableViewController *targetViewController = [[RootViewController alloc] initWithMusic];
                 [self.navigationController pushViewController:targetViewController animated:YES];
                 [targetViewController release];
             } else if (indexPath.row == 3) {
                 //NSLog(@"Clicked file.");
                 isRootDirectory = YES;
                 isLibraryDirectory = NO;
                 UITableViewController *targetViewController = [[RootViewController alloc] initWithFiles];
                 [self.navigationController pushViewController:targetViewController animated:YES];
                 [targetViewController release];
             }
         } else if ([self.title isEqualToString:@"Music"]) {
             if (indexPath.row == 0) {
                 libraryType = 5;
                 UITableViewController *targetViewController = [[RootViewController alloc] initWithAlbums];
                 [self.navigationController pushViewController:targetViewController animated:YES];
                 [targetViewController release];
                 //NSLog(@"Clicked albums");
             } else if (indexPath.row == 1) {
                 libraryType = 6;
                 UITableViewController *targetViewController = [[RootViewController alloc] initWithArtists];
                 [self.navigationController pushViewController:targetViewController animated:YES];
                 [targetViewController release];
                 //NSLog(@"Clicked Artists.");
             }
         } else {
             //Sub library directory
             if ([[self.tableView cellForRowAtIndexPath:indexPath].reuseIdentifier isEqualToString:@"TVShowCell"]) {
                 //Touched TV Show.
                 //NSLog(@"Touched TV show.");
                 libraryType = 4;
                 NSDictionary *currentObject = [dataSource objectAtIndex:indexPath.row];
                 //RootViewController* firstLevelViewController = [self.navigationController.viewControllers objectAtIndex:0];
                 NSString *tvShow = [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text;
                 UITableViewController *targetViewController = [[RootViewController alloc] initWithTVShow:tvShow];
                 curShowName = [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text;
                 [self.navigationController pushViewController:targetViewController animated:YES];
                 [targetViewController release];
                 MediaItem *media = [[MediaItem alloc] init];
                 
                 media.strShowName = [currentObject valueForKey:@"strTitle"];
                 media.strTitle = viewTitle;
                 //media.strPath = [currentObject valueForKey:@"strPath"];
                 media.strDescription = [currentObject valueForKey:@"strDescription"];
                 //media.iEpisode = [NSNumber numberWithInt:[[currentObject valueForKey:@"iEpisode"] intValue]];
                 //media.iSeason = [NSNumber numberWithInt:[[currentObject valueForKey:@"iSeason"] intValue]];
                 firstLevelViewController.detailViewController.playNowButton.enabled = NO;
                 

                 dispatch_async(myQueue, ^ { 
                     //NSLog(@"strCover: %@",[currentObject valueForKey:@"strCover"]);
                     NSURL *thumbURL = [NSURL URLWithString:[currentObject valueForKey:@"strCover"]];
                     NSData *thumbData = [NSData dataWithContentsOfURL:thumbURL];
                     UIImage *thumbnail = [UIImage imageWithData:thumbData];
                     dispatch_async(dispatch_get_main_queue(), ^ {firstLevelViewController.detailViewController.thumbnailView.image = thumbnail;});
                 } );
                 
                 //NSData *thumbData = [NSData dataWithContentsOfURL:thumbURL];
                                  
                 if (firstLevelViewController.detailViewController.isSplashViewOn == YES) {
                     [firstLevelViewController.detailViewController removeSplash];
                     firstLevelViewController.detailViewController.isSplashViewOn = NO;
                 }
                 
                 firstLevelViewController.detailViewController.mediaItem = media;
                 [firstLevelViewController.detailViewController configureView];
                 
             } else if ([[self.tableView cellForRowAtIndexPath:indexPath].reuseIdentifier isEqualToString:@"EpisodeCell"]) {
                 //Touched TV episode.
                 //NSLog(@"Touched tv episode.");
                 //RootViewController* firstLevelViewController = [self.navigationController.viewControllers objectAtIndex:0];
                 NSDictionary *currentObject = [dataSource objectAtIndex:indexPath.row];
                 
                 MediaItem *media = [[MediaItem alloc] init];
                 
                 //NSLog(@"Current object: %@",currentObject);
                 
                 media.strShowName = viewTitle;
                 media.strTitle = [currentObject valueForKey:@"strTitle"];
                 media.strPath = [currentObject valueForKey:@"strPath"];
                 media.strDescription = [currentObject valueForKey:@"strDescription"];
                 media.iEpisode = [NSNumber numberWithInt:[[currentObject valueForKey:@"iEpisode"] intValue]];
                 media.iSeason = [NSNumber numberWithInt:[[currentObject valueForKey:@"iSeason"] intValue]];
                 firstLevelViewController.detailViewController.playNowButton.enabled = YES;
                 
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
             } else if ([[self.tableView cellForRowAtIndexPath:indexPath].reuseIdentifier isEqualToString:@"MovieCell"]) {
                 //NSLog(@"Touched movie.");
                 
                 //RootViewController* firstLevelViewController = [self.navigationController.viewControllers objectAtIndex:0];
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
             } else if ([[self.tableView cellForRowAtIndexPath:indexPath].reuseIdentifier isEqualToString:@"AlbumCell"]) {
                 libraryType = 7;
                 NSDictionary *currentObject = [dataSource objectAtIndex:indexPath.row];
                 NSString *album = [currentObject valueForKey:@"idAlbum"];
                 //NSLog(@"Clicked on album id: %@",album);
                 UITableViewController *targetViewController = [[RootViewController alloc] initWithAlbum:album Name:[currentObject valueForKey:@"strTitle"]];
                 [self.navigationController pushViewController:targetViewController animated:YES];
                 [targetViewController release];
             } else if ([[self.tableView cellForRowAtIndexPath:indexPath].reuseIdentifier isEqualToString:@"ArtistCell"]) {
                 //NSLog(@"Clicked on artist.");
                 NSDictionary *currentObject = [dataSource objectAtIndex:indexPath.row];
                 NSString *artist = [currentObject valueForKey:@"idArtist"];
                 //NSLog(@"Clicked on artist id: %@",artist);
                 UITableViewController *targetViewController = [[RootViewController alloc] initWithArtist:artist Name:[currentObject valueForKey:@"strName"]];
                 [self.navigationController pushViewController:targetViewController animated:YES];
                 [targetViewController release];
             } else if ([[self.tableView cellForRowAtIndexPath:indexPath].reuseIdentifier isEqualToString:@"AlbumSongCell"]) {
                 //NSLog(@"Clicked on album song.");
                 //RootViewController* firstLevelViewController = [self.navigationController.viewControllers objectAtIndex:0];
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

             } else if ([[self.tableView cellForRowAtIndexPath:indexPath].reuseIdentifier isEqualToString:@"ArtistSongCell"]) {
                 //NSLog(@"Clicked on artist song.");
                 //RootViewController* firstLevelViewController = [self.navigationController.viewControllers objectAtIndex:0];
                 NSDictionary *currentObject = [dataSource objectAtIndex:indexPath.row];
                 
                 MediaItem *media = [[MediaItem alloc] init];
                 
                 media.strShowName = [currentObject valueForKey:@"strTitle"];
                 media.strPath = [currentObject valueForKey:@"strPath"];
                 media.strTitle = [m_boxee getArtistWithID:[currentObject valueForKey:@"idArtist"]];
                 media.strDescription = @"";
                 firstLevelViewController.detailViewController.playNowButton.enabled = YES;
                 //media.strShowName = viewTitle;
                 
                 /*//NSLog(@"strCover: %@",[currentObject valueForKey:@"strCover"]);
                  NSURL *thumbURL = [NSURL URLWithString:[currentObject valueForKey:@"strCover"]];
                  NSData *thumbData = [NSData dataWithContentsOfURL:thumbURL];
                  UIImage *thumbnail = [UIImage imageWithData:thumbData];
                  
                  firstLevelViewController.detailViewController.thumbnailView.image = thumbnail;*/
                 
                 if (firstLevelViewController.detailViewController.isSplashViewOn == YES) {
                     [firstLevelViewController.detailViewController removeSplash];
                     firstLevelViewController.detailViewController.isSplashViewOn = NO;
                 }
                 NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                 [nc postNotificationName:hideMediaListPopupNotification object:self];
                 firstLevelViewController.detailViewController.mediaItem = media;
                 [firstLevelViewController.detailViewController configureView];
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
