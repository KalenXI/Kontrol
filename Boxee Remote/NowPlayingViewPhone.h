//
//  NowPlayingViewPhone.h
//  Kontrol
//
//  Created by Kevin Vinck on 23/04/2011.
//  Copyright 2011 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GradientButton.h"
#import "SettingsViewControllerPhone.h"


@interface NowPlayingViewPhone : UIViewController {
    
    BoxeeHTTPInterface *m_boxee;
    
    IBOutlet UIImageView *playingImageVIew;
    IBOutlet UILabel *playingDurationLabel;
    IBOutlet UILabel *playingPositionLabel;
    IBOutlet UILabel *playingTitle;
    IBOutlet UISlider *seekSlider;
    IBOutlet UIButton *playButton;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *forwardButton;
    IBOutlet UIView *controlsView;
    IBOutlet UIView *volumeView;
    IBOutlet UISlider *volumeSlider;
    
    NSTimer *nowPlayingTimer;
    NSString *nowPlayingThumbnailURL;
}

- (IBAction)showPlaybackControls:(id)sender;
- (IBAction)playPauseTapped:(id)sender;
- (IBAction)nextButtonTapped:(id)sender;
- (IBAction)backButtonTapped:(id)sender;
- (IBAction)volumeChanged:(id)sender;
- (IBAction)positionChanged:(id)sender;

@end
