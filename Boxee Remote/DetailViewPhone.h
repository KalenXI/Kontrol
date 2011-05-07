//
//  DetailViewPhone.h
//  Kontrol
//
//  Created by Kevin Vinck on 4/23/11.
//  Copyright 2011 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoxeeHTTPInterface.h"

@interface DetailViewPhone : UIViewController {
    BoxeeHTTPInterface *m_boxee;
    IBOutlet UILabel *showTitleLabel;
    IBOutlet UILabel *episodeTitleLabel;
    IBOutlet UILabel *seasonEpisodeLabel;
    IBOutlet UITextView *episodeDescriptionView;
    IBOutlet UIImageView *backgroundImageView;
}

@property (nonatomic, retain) IBOutlet UILabel *showTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *episodeTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *seasonEpisodeLabel;
@property (nonatomic, retain) IBOutlet UITextView *episodeDescriptionView;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, retain) MediaItem *mediaItem;

- (void)playMedia;


@end
