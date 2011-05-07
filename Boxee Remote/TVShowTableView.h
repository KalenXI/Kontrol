//
//  TVShowTableView.h
//  Kontrol
//
//  Created by Kevin Vinck on 5/5/11.
//  Copyright 2011 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoxeeHTTPInterface.h"

@interface TVShowTableView : UITableViewController {
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

-(id)initWithTVShow:(NSString *)show;

@end
