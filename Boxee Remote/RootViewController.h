//
//  RootViewController.h
//  Boxee Remote
//
//  Created by Kevin Vinck on 25/03/2011.
//  Copyright 2011 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoxeeHTTPInterface.h"
#import "SettingsViewController.h"
#import "SettingsViewControllerPhone.h"
#import "TVShowsTableView.h"

@class DetailViewController;

@interface RootViewController : UITableViewController <UINavigationControllerDelegate> {
    BoxeeHTTPInterface *m_boxee;
    NSArray *mediaShares;
    NSArray *dataSource;
    NSString *viewTitle;
    NSString *curShowName;
    int numOfShares;
    BOOL isRootDirectory;
    BOOL isLibraryDirectory;
    int libraryType;
}

-(id)initWithPath:(NSString *)path title:(NSString*)title;
-(id)initWithTVShow:(NSString *)show;
-(id)initWithMovies;
-(id)initWithMusic;
-(id)initWithArtists;
-(id)initWithAlbums;
-(id)initWithAlbum:(NSString *)album Name:(NSString *)name;
-(id)initWithArtist:(NSString *)artist Name:(NSString *)name;
-(id)initWithFiles;

extern NSString * const hideMediaListPopupNotification;

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic) BOOL isRootDirectory;
@property (nonatomic) BOOL isLibraryDirectory;
@property (nonatomic )int libraryType;

@end
