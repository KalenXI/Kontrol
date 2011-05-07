//
//  RemoteViewController.h
//  Boxee Remote
//
//  Created by Kevin Vinck on 25/03/2011.
//  Copyright 2011 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoxeeHTTPInterface.h"


@interface RemoteViewController : UIViewController {
    BoxeeHTTPInterface *m_boxee;
    IBOutlet UIButton *muteButton;
    BOOL isMuted;
    int currentView;
    IBOutlet UIView *mainView;
    
    IBOutlet UISegmentedControl *switchButtons;
    UIButton *fullscreenClicked;
    UIButton *appsClicked;
    UIButton *subtitleTrackClicked;
    UIButton *subtitleDelayDec;
    NSTimer *timer;
    NSTimer *holdTimer;
}

//View controls
- (void)setViewTo:(int)viewNum;

//Remote buttons
- (IBAction)selectButtonClicked:(id)sender;
- (IBAction)rightButtonClicked:(id)sender;
- (IBAction)downButtonClicked:(id)sender;
- (IBAction)leftButtonClicked:(id)sender;
- (IBAction)upButtonClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)muteButtonClicked:(id)sender;
- (IBAction)upButtonTouchDown:(id)sender;
- (IBAction)leftButtonTouchDown:(id)sender;
- (IBAction)rightButtonTouchDown:(id)sender;
- (IBAction)downButtonTouchDown:(id)sender;

//System buttons
- (IBAction)nowPlayingClicked:(id)sender;
- (IBAction)tvShowsClicked:(id)sender;
- (IBAction)moviesClicked:(id)sender;
- (IBAction)fileBrowserClicked:(id)sender;
- (IBAction)musicClicked:(id)sender;
- (IBAction)fullscreenClicked:(id)sender;
- (IBAction)homeClicked:(id)sender;
- (IBAction)appsClicked:(id)sender;

//Video buttons
- (IBAction)viewModeClicked:(id)sender;
- (IBAction)audioTrackClicked:(id)sender;
- (IBAction)subtitlesClicked:(id)sender;
- (IBAction)subtitleTrackClicked:(id)sender;
- (IBAction)audioDelayInc:(id)sender;
- (IBAction)audioDelayDec:(id)sender;
- (IBAction)subtitleDelayInc:(id)sender;
- (IBAction)subtitleDelayDec:(id)sender;


- (IBAction)switchBarClicked:(id)sender;


@property (nonatomic, retain) IBOutlet UIButton *muteButton;

@end
