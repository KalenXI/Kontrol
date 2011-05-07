//
//  DetailViewController.h
//  Boxee Remote
//
//  Created by Kevin Vinck on 25/03/2011.
//  Copyright 2011 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GradientButton.h"
#import "BoxeeHTTPInterface.h"
#import "TSAlertView.h"

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate> {
    BoxeeHTTPInterface *m_boxee;
    IBOutlet GradientButton *addQueueButton;
    IBOutlet GradientButton *playNowButton;
    IBOutlet GradientButton *playButton;
    IBOutlet GradientButton *playPrevButton;
    IBOutlet GradientButton *playNextButton;
    IBOutlet UISlider *volumeSlider;
    IBOutlet UIView *splashView;
    IBOutlet UIView *playbackControlsView;
    UILabel *titleLabel;
    IBOutlet UITextView *descriptionLabel;
    UIProgressView *fileProgress;
    UILabel *nowPlayingTitle;
    UIPopoverController *popover;
    UIView *popupView;
    UILabel *popupLabel;
    IBOutlet UIView *DetailView;
    NSString *titleText;
    NSString *nowPlayingThumbnailURL;
    BOOL isSplashViewOn;
    BOOL isPopupOn;
    BOOL isPlaybackControlHidden;
    BOOL isCurrentlyPlaying;
    int nowPlayingWindowStatus;
    IBOutlet UILabel *episodeTitleLabel;
    IBOutlet UILabel *seasonLabel;
    IBOutlet UIImageView *coverView;
    IBOutlet UIButton *hideNowPlayingButton;
    
    IBOutlet UILabel *episodeLabel;
    IBOutlet UITextField *keyboardField;
    IBOutlet UIImageView *thumbnailView;
    IBOutlet UILabel *nowPlayingDescriptionTitle;
    
    IBOutlet UIBarButtonItem *remoteButton;
    IBOutlet UIBarButtonItem *keyboardButton;
    
    UIAlertView *databaseAlert;
    UIAlertView *passwordAlert;
	UITextField *passwordField;
    
    NSString *password;
    
    NSString *popupMsgStr;
    
    IBOutlet UIImageView *nowPlayingImageView;
    IBOutlet UITextView *nowPlayingDescriptionView;
    IBOutlet UILabel *nowPlayingTitleLabel;
    IBOutlet UISlider *nowPlayingPositionSlider;
    IBOutlet UILabel *nowPlayingTimeLabel;
    IBOutlet UILabel *nowPlayingDurationLabel;
    IBOutlet UIBarButtonItem *nowPlayingButton;
    
    int pingFailCount;
    
    NSTimer *nowPlayingTimer;
    NSTimer *pingTimer;

}

@property (nonatomic, retain) IBOutlet  GradientButton *addQueueButton;
@property (nonatomic, retain) IBOutlet  GradientButton *playNowButton;
@property (nonatomic, retain) IBOutlet UIView *splashView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UITextView *descriptionLabel;
@property (nonatomic, retain) IBOutlet UISlider *volumeSlider;
@property (nonatomic, retain) IBOutlet UIProgressView *fileProgress;
@property (nonatomic, retain) IBOutlet UILabel *nowPlayingTitle;
@property (nonatomic, retain) MediaItem *mediaItem;
@property (nonatomic, retain) NSString *titleText;
@property (nonatomic, retain) NSString *popupMsgStr;
@property (nonatomic) BOOL isSplashViewOn;
@property (nonatomic) BOOL isPlaybackControlHidden;

@property (nonatomic, retain) IBOutlet UILabel *episodeTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *seasonLabel;
@property (nonatomic, retain) IBOutlet UILabel *episodeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *thumbnailView;

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) id detailItem;
@property (nonatomic, retain) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic, retain) UIPopoverController *popover;
@property (nonatomic, retain) IBOutlet UIView *popupView;
@property (nonatomic, retain) IBOutlet UILabel *popupLabel;

- (IBAction)hideNowPlaying:(id)sender;
- (void)configureView;
- (void)lostConnection;
- (void)removePopover;
- (IBAction)volumeSliderChanged:(id)sender;
- (IBAction)positionSliderChanged:(id)sender;
- (IBAction)positionSliderDidChange:(id)sender;
- (void) pingServer:(NSTimer *)timer;
- (void) pingReceived;
- (void) pingTimedOut;
- (void) refreshPlayingStatus:(NSTimer *)timer;
- (void) setPlaybackControlsStatus:(int)status;
- (void) setDetailDisplayFormat:(int)format;
- (void)setupTimer;
- (IBAction)remoteClicked:(id)sender;
- (IBAction)settingsTapped:(id)sender;
- (IBAction)addToQueueButtonClicked:(id)sender;
- (IBAction)playNowButtonClicked:(id)sender;
- (IBAction)updatePlayingInfoButtonClicked:(id)sender;
- (IBAction)playBackButtonClicked:(id)sender;
- (IBAction)playPauseButtonClicked:(id)sender;
- (IBAction)playNextButtonClicked:(id)sender;
- (void)removeSplash;
- (void)popupMessage:(NSString *)msg;
- (void)showPopup;
- (void)hidePopup;
- (IBAction)showPlaybackControls:(id)sender;
- (IBAction)showKeyboard:(id)sender;
- (IBAction)keyTyped:(id)sender;

@end
