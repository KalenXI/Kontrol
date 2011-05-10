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

#pragma mark - Initilization

- (void)awakeFromNib {
    viewTitle = @"Media Library";
    isRootDirectory = YES;
    isLibraryDirectory = YES;
	
	m_boxee = [BoxeeHTTPInterface sharedInstance];
	numOfShares = [mediaShares count];
	
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(reloadMediaList:) 
               name:MediaListNeedsReloadingNotification
             object:nil];
    self.navigationController.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    myQueue = dispatch_queue_create("com.lastdit.kontrol", NULL);
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    self.title = viewTitle;
}

-(id)initWithPath:(NSString *)path title:(NSString*)title {
    self = [super init];
    if (self) {
        viewTitle = title;
        m_boxee = [BoxeeHTTPInterface sharedInstance];
        dataSource = [m_boxee getDirectory:path];
        [dataSource retain];
        isRootDirectory = NO;
        numOfShares = [dataSource count];
    }
    return self;
}

-(id)initWithFiles {
    self = [super init];
    if (self) {
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - TableView Delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(RootViewController *)viewController animated:(BOOL)animated {
    if ([viewController.title isEqualToString:@"Media Library"]) {
        viewController.isRootDirectory = YES;
        if ([m_boxee isDatabaseEnabled]) {
            isLibraryDirectory = YES;
        } else {
            isLibraryDirectory = NO;
        }
    }
}

- (void)reloadMediaList:(NSNotification *)note {
    if (self.navigationController.visibleViewController == self.navigationController.topViewController) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
	
    isRootDirectory = YES;
	
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    		
}

		
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ((numOfShares > 0) && (isLibraryDirectory == NO)) {
        return numOfShares;
    } else if ((numOfShares > 0) && (isLibraryDirectory == YES)) {
        return 4;
    } else {
        return 1;
    }
    		
}

		
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((numOfShares > 0) && (isLibraryDirectory == NO) && (isRootDirectory == YES)) {
		//Return cells for root file directory.
		NSString *replyString = [[mediaShares objectAtIndex:0] objectAtIndex:0];
		
		if ([replyString isEqualToString:@"Error"]) {
			static NSString *CellIdentifier = @"ErrorCell";
                
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			}
			cell.textLabel.text = @"Error retreiving shares.";
			return cell; 
		}
		
		static NSString *CellIdentifier = @"Cell";
            
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		}
		cell.textLabel.text = [[mediaShares objectAtIndex:indexPath.row] objectAtIndex:1];
		cell.detailTextLabel.text = [[mediaShares objectAtIndex:indexPath.row] objectAtIndex:2];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		return cell;
    } else if ((numOfShares > 0) && (isLibraryDirectory == YES) && (isRootDirectory == YES)) {
		//Return cells for root library directory.
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
				cell.textLabel.text = @"";
				break;
		}
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		return cell;
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
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ((numOfShares > 0) && (isLibraryDirectory == NO) && (isRootDirectory == YES)) {             
		//If is root file directory.
		[tableView deselectRowAtIndexPath:indexPath	animated:YES];
		NSString *path = [[mediaShares objectAtIndex:indexPath.row] objectAtIndex:2];
		UITableViewController *targetViewController = [[FolderTableView alloc] initWithPath:path title:[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text];
		[self.navigationController pushViewController:targetViewController animated:YES];
		[targetViewController release];
	} else if ((numOfShares > 0) && (isLibraryDirectory == YES) && (isRootDirectory == YES)) {     
		//If is root library directory
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		if (indexPath.row == 0) { 
			//Clicked TV shows.
			UITableViewController *targetViewController = [[TVShowsTableView alloc] initWithTVShows];
			[self.navigationController pushViewController:targetViewController animated:YES];
			[targetViewController release];
		} else if (indexPath.row == 1) { 
			//Clicked movies.
			libraryType = 1;
			UITableViewController *targetViewController = [[MoviesTableView alloc] initWithMovies];
			[self.navigationController pushViewController:targetViewController animated:YES];
			[targetViewController release];
		} else if (indexPath.row == 2) { 
			//Clicked music.
			UITableViewController *targetViewController = [[MusicTableView alloc] initWithMusic];
			[self.navigationController pushViewController:targetViewController animated:YES];
			[targetViewController release];
		} else if (indexPath.row == 3) { 
			//Clicked files
			isRootDirectory = YES;
			isLibraryDirectory = NO;
			UITableViewController *targetViewController = [[FilesTableView alloc] initWithFiles];
			[self.navigationController pushViewController:targetViewController animated:YES];
			[targetViewController release];
		}
     } else {
         [tableView deselectRowAtIndexPath:indexPath animated:YES];
     }
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [detailViewController release];
    detailViewController = nil;
    [super dealloc];
}

@end
