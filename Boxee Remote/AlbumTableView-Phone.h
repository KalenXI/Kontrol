//
//  AlbumTableView-Phone.h
//  Kontrol
//
//  Created by Kevin Vinck on 5/10/11.
//  Copyright 2011 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoxeeHTTPInterface.h"
#import "SettingsViewControllerPhone.h"
#import "DetailViewPhone.h"

@interface AlbumTableView_Phone : UITableViewController <UISearchBarDelegate,UISearchDisplayDelegate> {
    BoxeeHTTPInterface *m_boxee;
    NSArray *mediaShares;
    NSArray *dataSource;
    NSString *viewTitle;
    NSString *curShowName;
    int numOfShares;
    BOOL isRootDirectory;
    BOOL isLibraryDirectory;
    int libraryType;
    
    NSMutableArray *tableData;
	NSMutableArray *tableSearch;
    
    UISearchBar *searchBar;
	UISearchDisplayController *searchDC;
}

@property (nonatomic,retain) UISearchBar *searchBar;
@property (nonatomic,retain) UISearchDisplayController *searchDC;

-(id)initWithAlbum:(NSString *)album Name:(NSString *)name;

@end
