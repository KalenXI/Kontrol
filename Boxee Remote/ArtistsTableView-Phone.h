//
//  ArtistsTableView-Phone.h
//  Kontrol
//
//  Created by Kevin Vinck on 5/10/11.
//  Copyright 2011 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoxeeHTTPInterface.h"
#import "SettingsViewControllerPhone.h"
#import "DetailViewPhone.h"
#import "ArtistTableView-Phone.h"

@interface ArtistsTableView_Phone : UITableViewController {
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

-(id)initWithArtists;

@end
