//
//  ArtistTableView.h
//  Kontrol
//
//  Created by Kevin Vinck on 5/7/11.
//  Copyright 2011 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoxeeHTTPInterface.h"
#import "DetailViewController.h"
#import "RootViewController.h"

@interface ArtistTableView : UITableViewController {
    BoxeeHTTPInterface *m_boxee;
    NSArray *mediaShares;
    NSArray *dataSource;
    NSString *viewTitle;
    NSString *curShowName;
    int numOfShares;
    BOOL isRootDirectory;
    BOOL isLibraryDirectory;
    int libraryType;
    dispatch_queue_t myQueue;
}

-(id)initWithArtist:(NSString *)artist Name:(NSString *)name;

@end
