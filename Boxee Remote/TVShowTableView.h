//
//  TVShowTableView.h
//  Kontrol
//
//  Created by Kevin Vinck on 5/5/11.
//  Copyright 2011 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoxeeHTTPInterface.h"

@interface TVShowTableView : UITableViewController <UISearchBarDelegate,UISearchDisplayDelegate> {
    BoxeeHTTPInterface *m_boxee;
    NSArray *mediaShares;
    NSArray *dataSource;
	NSMutableArray *tableData;
	NSMutableArray *tableSearch;
    NSString *viewTitle;
    NSString *curShowName;
    int numOfShares;
    BOOL isRootDirectory;
    BOOL isLibraryDirectory;
    int libraryType;
	NSMutableArray *seasons;
	NSMutableArray *seasonEpNums;
	
	UISearchBar *searchBar;
	UISearchDisplayController *searchDC;
	
	BOOL isSearching;
}

@property (nonatomic,retain) UISearchBar *searchBar;
@property (nonatomic,retain) UISearchDisplayController *searchDC;


-(id)initWithTVShow:(NSString *)show;

@end
