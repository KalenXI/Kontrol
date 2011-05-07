//
//  TVShowTableView.h
//  Kontrol
//
//  Created by Kevin Vinck on 5/4/11.
//  Copyright 2011 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoxeeHTTPInterface.h"
#import "TVShowTableView.h"

@interface TVShowsTableView : UITableViewController {
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

-(id)initWithTVShows;

@end
