//
//  DetailViewController.m
//  Boxee Remote
//
//  Created by Kevin Vinck on 25/03/2011.
//  Copyright 2011 None. All rights reserved.
//

#import "DetailViewController.h"
#import "RemoteViewController.h"
#import "SettingsViewController.h"
#import "SplashScreenViewController.h"
#import "BoxeeHTTPInterface.h"

#import "RootViewController.h"

@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize titleLabel,titleText,splashView, isSplashViewOn, isPlaybackControlHidden,episodeLabel,seasonLabel,episodeTitleLabel,thumbnailView,popupMsgStr;
@synthesize mediaItem;
@synthesize descriptionLabel;
@synthesize volumeSlider;
@synthesize fileProgress;
@synthesize nowPlayingTitle;
@synthesize toolbar=_toolbar;

@synthesize detailItem=_detailItem;

@synthesize detailDescriptionLabel=_detailDescriptionLabel;

@synthesize popoverController=_myPopoverController;
@synthesize popover;
@synthesize popupView;
@synthesize popupLabel;
@synthesize addQueueButton,playNowButton;

#pragma mark - Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */

UIViewController *currentViewController;

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        //NSLog(@"Releasing detailitem");
        [_detailItem release];
        _detailItem = [newDetailItem retain];
        
        // Update the view.
        [self configureView];
    }

    if (self.popoverController != nil) {
        [self.popoverController dismissPopoverAnimated:YES];
    }        
}

- (void)removePopover {
    if (self.popoverController != nil) {
        [self.popoverController dismissPopoverAnimated:YES];
    }
    //NSLog(@"Removing popover");
}

- (void)hidePopup {
    CGPoint pos = popupView.center;
    [UIView beginAnimations:nil context:NULL];
    //[UIView setAnimationDuration:1.0];
    [UIView setAnimationDelay:5.0];
    //[UIView setAnimationRepeatAutoreverses:YES];
    //CGPoint pos = splashView.center;
    if (isPopupOn == YES) {
        pos.y = popupView.center.y - popupView.frame.size.height;
        isPopupOn = NO;
        //NSLog(@"pos.y = %f",pos.y);
    }
    popupView.center = pos;
    [UIView commitAnimations];
}

- (void)showPopup {
    popupLabel.text = popupMsgStr;
    CGPoint pos = popupView.center;
    [UIView beginAnimations:nil context:NULL];
    //[UIView setAnimationDelay:0.25];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hidePopup)];
    //CGPoint pos = splashView.center;
    if (isPopupOn == NO) {
        pos.y = popupView.center.y + popupView.frame.size.height;
        isPopupOn = YES;
        //NSLog(@"center.y = %f",popupView.center.y);
        //NSLog(@"height = %f",popupView.frame.size.height);
        //NSLog(@"pos.y = %f",pos.y);
     }
     popupView.center = pos;
     [UIView commitAnimations];
}

- (void)popupMessage:(NSString *)msg {
    popupMsgStr = [[NSString alloc] initWithString:msg];
    [UIView beginAnimations:nil context:NULL];
    //[UIView setAnimationDuration:1.0];
    //[UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(showPopup)];
    CGPoint pos = popupView.center;
    if (isPopupOn == YES) {
        //NSLog(@"Yes the popup is on!");
        pos.y = popupView.center.y - popupView.frame.size.height;
        isPopupOn = NO;
        //NSLog(@"pos.y = %f",pos.y);
    }
    popupView.center = pos;
    [UIView commitAnimations];
}

- (IBAction)volumeSliderChanged:(id)sender {
    [m_boxee setVolume:volumeSlider.value];
}

- (IBAction)positionSliderChanged:(id)sender {
    //nowPlayingTimeLabel.text = [NSString stringWithFormat:@"%f",nowPlayingPositionSlider.value];
    [m_boxee setSeekPosition:nowPlayingPositionSlider.value];
}

- (IBAction)positionSliderDidChange:(id)sender {
    //[m_boxee setSeekPosition:nowPlayingPositionSlider.value];
    //NSLog(@"Slider did change.");
}

- (IBAction)hideNowPlaying:(id)sender {
}

- (void)configureView
{
    [UIView beginAnimations:nil context:NULL];
    //CGRect playbackControlsFrame = playbackControlsView.frame;
    [UIView setAnimationDuration:.5];
    // Update the user interface for the detail item.
    //NSLog(@"strShowName: %@",self.mediaItem.strShowName);
    if (self.mediaItem.strShowName != nil)
        titleLabel.text = self.mediaItem.strShowName;
    if (self.mediaItem.strTitle != nil)
        episodeTitleLabel.text = mediaItem.strTitle;
    if (self.mediaItem.strDescription != nil)
        descriptionLabel.text = mediaItem.strDescription;
    if ([mediaItem.iEpisode intValue] != 0) {
        episodeLabel.text = [NSString stringWithFormat:@"Season: %i Episode: %i",[mediaItem.iSeason intValue],[mediaItem.iEpisode intValue]];
    } else {
        episodeLabel.text = @"";
    }
    [UIView commitAnimations];
    
}


- (IBAction)remoteClicked:(id)sender {
    //NSLog(@"Remote button clicked.");
    if ([popover isPopoverVisible]) {
        [popover dismissPopoverAnimated:YES];
    } else {
    RemoteViewController *remote = [[RemoteViewController alloc] init];
    popover = [[UIPopoverController alloc]
              initWithContentViewController:remote];
    //NSLog(@"Releasing remote");
    [remote release];
    
    popover.popoverContentSize = CGSizeMake(312, 339);
    
    [popover presentPopoverFromBarButtonItem:sender 
                    permittedArrowDirections:UIPopoverArrowDirectionAny 
                                    animated:YES];
    }
}

- (IBAction)settingsTapped:(id)sender {
    if ([popover isPopoverVisible]) {
        [popover dismissPopoverAnimated:YES];
    } else {
        SettingsViewController *settings = [[SettingsViewController alloc] init];
        popover = [[UIPopoverController alloc]
                   initWithContentViewController:settings];
        //NSLog(@"Releasing settings");
        [settings release];
        
        popover.popoverContentSize = CGSizeMake(372, 311);
        
        [popover presentPopoverFromBarButtonItem:sender 
                        permittedArrowDirections:UIPopoverArrowDirectionAny 
                                        animated:YES];
    }
}

- (IBAction)addToQueueButtonClicked:(id)sender {
    [m_boxee addToPlaylist:self.mediaItem.strPath];
}

- (IBAction)playNowButtonClicked:(id)sender {
    //NSLog(@"Playing file %@",self.mediaItem.strPath);
    [m_boxee playFile:self.mediaItem.strPath inPlaylist:nil];
}

- (IBAction)updatePlayingInfoButtonClicked:(id)sender {
    //NSLog(@"TVShow info: %@",[m_boxee getTVShows]);
    //NSLog(@"Episodes: %@",[m_boxee getEpisodesForTVShow:[[[m_boxee getTVShows] objectAtIndex:0] valueForKey:@"strTitle"]]); 
}

- (IBAction)playBackButtonClicked:(id)sender {
    [m_boxee playPrev];
}

- (IBAction)playPauseButtonClicked:(id)sender {
    [m_boxee pause];
}

- (IBAction)playNextButtonClicked:(id)sender {
    [m_boxee playNext];
}

- (void)removeSplash {
    [UIView beginAnimations:nil context:NULL];
    
    [UIView setAnimationDuration:1.0];
    //[UIView setAnimationRepeatAutoreverses:YES];
    
    CGPoint pos = splashView.center;
    if (isSplashViewOn == YES) {
        pos.x = splashView.center.x + 768;
        isSplashViewOn = NO;
    } else {
        pos.x = splashView.center.x - 768;
        isSplashViewOn = YES;
    }
    splashView.center = pos;
    
    [UIView commitAnimations];
    //[splashView removeFromSuperview];
}

- (IBAction)showPlaybackControls:(id)sender {
    //NSLog(@"Current status %i",nowPlayingWindowStatus);
    if ((nowPlayingWindowStatus == 0) || (nowPlayingWindowStatus == 1)) {
        [self setPlaybackControlsStatus:2];
    } else {
        [self setPlaybackControlsStatus:1];
    }
}

- (IBAction)showKeyboard:(id)sender {
    if ([keyboardField isFirstResponder]) {
        [keyboardField resignFirstResponder];
    } else {
        [keyboardField becomeFirstResponder];
    }
}

- (IBAction)keyTyped:(id)sender {
    //NSLog(@"Key typed: %@",keyboardField.text);
    //keyboardField.text = @"";
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //NSLog(@"Key typed: %@",textField.text);
    //range = NSMakeRange(0, 5);
    if (textField == keyboardField) {
        NSData *keyTyped = [string dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        int intValue = 0;
        //NSLog(@"Length: %i",[keyTyped length]);
        if ([keyTyped length] == 0){
            //NSLog(@"Typed backspace");
            [m_boxee sendKey:(61704)];
            return NO;
        } else {
            [keyTyped getBytes:&intValue range:NSMakeRange(0, 1)];
            //NSLog(@"Key typed: %@ (%i)",string,intValue);
            [m_boxee sendKey:(intValue + 61696)];
            return NO;
        }
    } else if (textField == passwordField) {
	} else {
		return YES;
	}
	return YES;
}

-(void) setPlaybackControlsHidden:(BOOL)hidden {
    if ((hidden == YES) && (isPlaybackControlHidden == NO)) {
        [self showPlaybackControls:self];
    } else if ((hidden == NO) && (isPlaybackControlHidden == YES)) {
        [self showPlaybackControls:self];
    }
}

-(void) setPlaybackControlsStatus:(int)status {
    [UIView beginAnimations:nil context:NULL];
    CGPoint pos = playbackControlsView.center;
    //CGRect playbackControlsFrame = playbackControlsView.frame;
    [UIView setAnimationDuration:.5];
    
    if (status == 0) {
        switch (nowPlayingWindowStatus) {
            case 1:
                //Minimized > Hidden
                pos.y = playbackControlsView.center.y + 35;
                break;
            case 2:
                //Full > Hidden
                pos.y = playbackControlsView.center.y + 280;
                hideNowPlayingButton.transform = CGAffineTransformMakeRotation(2*M_PI);
                break;
        }
        playbackControlsView.center = pos;
        nowPlayingWindowStatus = 0;
    } else if (status == 1) {
        switch (nowPlayingWindowStatus) {
            case 0:
                //Hidden > Minimized
                pos.y = playbackControlsView.center.y - 35;
                break;
            case 2:
                //Full > Minimized
                pos.y = playbackControlsView.center.y + 245;
                hideNowPlayingButton.transform = CGAffineTransformMakeRotation(2*M_PI);
                break;
        }
        playbackControlsView.center = pos;
        nowPlayingWindowStatus = 1;
    } else if (status == 2) {
        switch (nowPlayingWindowStatus) {
            case 0:
                //Hidden > Full
                pos.y = playbackControlsView.center.y - 280;
                hideNowPlayingButton.transform = CGAffineTransformMakeRotation(M_PI);
                break;
            case 1:
                //Minimized > Full
                pos.y = playbackControlsView.center.y - 245;
                hideNowPlayingButton.transform = CGAffineTransformMakeRotation(M_PI);
                break;
        }
        playbackControlsView.center = pos;
        nowPlayingWindowStatus = 2;
    }
    
    [UIView commitAnimations];
}

- (void) setDetailDisplayFormat:(int)format {
    //0 = TV Episode
    //1 = TV Series
    //2 = Movie
    //3 = Music Track
    //4 = File
    
    
    
}

- (void) pingServer:(NSTimer *)timer {
    //NSLog(@"Timer hit: %@",timer);
    //[m_boxee ping];
}

- (void) pingReceived {
    pingFailCount = 0;
}

- (void) pingTimedOut {
    pingFailCount++;
    if (pingFailCount > 3) {
        //NSLog(@"Lost connection.");
        UIAlertView *lostConnectionAlert = [[UIAlertView alloc] initWithTitle:@"Lost Connection" message:@"The connection to the Boxee server has been lost please reconnect." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [lostConnectionAlert show];
        //NSLog(@"Releasing lostconnectionalert");
        [lostConnectionAlert release];
        [m_boxee lostServerConnection];
        [self setPlaybackControlsStatus:0];
        [pingTimer invalidate];
        if ([nowPlayingTimer isValid])
            [nowPlayingTimer invalidate];
        //NSLog(@"Invalidating timer.");
        pingFailCount = 0;
        return;
    }
}

- (void) refreshPlayingStatus:(NSTimer *)timer {
    if (timer == nowPlayingTimer) {
    [timer invalidate];
    //NSLog(@"////////Refreshing playing status.\\\\\\\\\\\\");
    NSMutableDictionary *currentStatus = [m_boxee getCurrentlyPlayingInfo];
        if (currentStatus != nil) {
    //NSLog(@"Getting volume");
    [currentStatus retain];
    if ([[currentStatus valueForKey:@"Filename"] isEqualToString:@"[Nothing Playing]"]) {
        [self setPlaybackControlsStatus:0];
        nowPlayingButton.enabled = NO;
        //NSLog(@"Nothing is playing.");
    } else if ([currentStatus valueForKey:@"Filename"] == nil) {
        //NSLog(@"Server not found.");
        nowPlayingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 
                                                           target:self
                                                         selector:@selector(refreshPlayingStatus:) 
                                                         userInfo:nil 
                                                          repeats:YES];
        return;
    } else {
        nowPlayingButton.enabled = YES;
        //A file is currently playing.
        //NSLog(@"Something is playing: %@",[currentStatus valueForKey:@"Filename"]);
        
        if (nowPlayingWindowStatus == 0) {
            [self setPlaybackControlsStatus:1];
        }
        
        if ([[currentStatus valueForKey:@"PlayStatus"] isEqualToString:@"Playing"]) {
            playButton.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_controls_4.png" ofType:nil]]; 
        } else {
            playButton.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_controls_3.png" ofType:nil]];
        }
        
        if (([currentStatus valueForKey:@"Title"] != nil) && ([currentStatus valueForKey:@"Show Title"] != nil)) {
            nowPlayingTitleLabel.text = [NSString stringWithFormat:@"%@ - %@",[currentStatus valueForKey:@"Show Title"],[currentStatus valueForKey:@"Title"]];
        } else if ([currentStatus valueForKey:@"Title"] != nil) {
            nowPlayingTitleLabel.text = [currentStatus valueForKey:@"Title"];
        } else {
            NSArray *filename = [[currentStatus valueForKey:@"Filename"] componentsSeparatedByString:@"/"];
            nowPlayingTitleLabel.text = [filename objectAtIndex:[filename count] - 1];
        }
        
        if ([currentStatus valueForKey:@"Plot"] != nil) {
            nowPlayingDescriptionView.text = [currentStatus valueForKey:@"Plot"];
        } else {
           nowPlayingDescriptionView.text = @"No description available.";
        }
        
        if (![nowPlayingThumbnailURL isEqualToString:[currentStatus valueForKey:@"Thumb"]]) {
            NSData *thumbnailData = [m_boxee getFile:[currentStatus valueForKey:@"Thumb"]];
            nowPlayingImageView.image = [UIImage imageWithData:thumbnailData];
            nowPlayingThumbnailURL = [currentStatus valueForKey:@"Thumb"];
        }
        
        nowPlayingPositionSlider.value = [[currentStatus valueForKey:@"Percentage"] intValue];
        nowPlayingDurationLabel.text = [currentStatus valueForKey:@"Duration"];
        nowPlayingTimeLabel.text = [currentStatus valueForKey:@"Time"];
    }
    //NSLog(@"Releasing current status.");
    //[currentStatus release];
    //currentStatus = nil;
    int volume = [m_boxee getVolume];
    volumeSlider.value = volume;
    //NSLog(@"\\\\\\\\\\\\\\Done refreshing playing status./////////////");
        nowPlayingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 
                                                           target:self
                                                         selector:@selector(refreshPlayingStatus:) 
                                                         userInfo:nil 
                                                          repeats:YES];
    }
    }
}

- (void)setupTimer {
    //NSLog(@"Setting up timer.");
    nowPlayingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 
                                    target:self
                                  selector:@selector(refreshPlayingStatus:) 
                                  userInfo:nil 
                                   repeats:YES];
    
    //pingTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 
    //                                                   target:self
                                                    //selector:@selector(pingServer:) 
                                                     //userInfo:nil 
                                                      //repeats:YES];
}

- (IBAction)addToQueue:(id)sender {
}

- (void)viewWillAppear:(BOOL)animated
{
    [addQueueButton useBlackStyle];
    [playNowButton useBlackStyle];
    [playButton useBlackStyle];
    [playNextButton useBlackStyle];
    [playPrevButton useBlackStyle];
    playNowButton.enabled = NO;
    //[self setPlaybackControlsStatus:0];
    //NSLog(@"viewWillAppear");
    [super viewWillAppear:animated];
}

-(void)awakeFromNib {
    //NSLog(@"Awoken from nib.");
    isSplashViewOn = YES;
    isPopupOn = YES;
    isPlaybackControlHidden = YES;
    nowPlayingWindowStatus = 0;
}

- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"viewDidAppear");
    [self.view setNeedsDisplay];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //NSLog(@"viewWillAppear");
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    //NSLog(@"viewDidDisappear");
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Split view support

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController: (UIPopoverController *)pc
{
    barButtonItem.title = @"Media Library";
    NSMutableArray *items = [[self.toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [self.toolbar setItems:items animated:YES];
    //NSLog(@"Releasing items");
    [items release];
    self.popoverController = pc;
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSMutableArray *items = [[self.toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [self.toolbar setItems:items animated:YES];
    //NSLog(@"Releasing items");
    [items release];
    self.popoverController = nil;
}

- (void) connectedToServer {
    [self popupMessage:[NSString stringWithFormat:@"Connected to %@:%@",m_boxee.serverIP,m_boxee.serverPort]];
    if (isSplashViewOn == NO)
        [self removeSplash];
    [self setPlaybackControlsStatus:0];
    nowPlayingWindowStatus = 0;
    if (![m_boxee isBoxeeBox]) {
        if ([m_boxee isDatabaseEnabled]) {
            //NSLog(@"Database is enabled!");
        } else {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if ([defaults integerForKey:[NSString stringWithFormat:@"ask%@ForDatabase",m_boxee.serverIP]] != 1) {
                //NSLog(@"Database isn't enabled :(");
                databaseAlert = [[UIAlertView alloc] initWithTitle:@"Library Access" message:@"Remote library access is not setup on this server, would you like to enable?" delegate:self cancelButtonTitle:@"Ignore" otherButtonTitles:@"Enable for Mac/Linux",@"Enable for Windows",@"No, do not ask again.", nil];
                [databaseAlert show];
            }
        }
    } else {
        [m_boxee showAlert:@"You appear to be connecting to a Boxee Box. Since the Boxee Box does not allow remote access to media shares, functionality will be impared. Remote and playback controls should continue to work."];
    }
    pingFailCount = 0;
    keyboardButton.enabled = YES;
    remoteButton.enabled = YES;
}

- (void) lostConnection {
    if (isSplashViewOn == NO) {
        [self removeSplash];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ((alertView == passwordAlert) && (buttonIndex == 1)) {
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        NSLog(@"Password: %@",passwordField.text);
		m_boxee.serverPassword = passwordField.text;
		if ([m_boxee isPasswordProtected]) {
			[m_boxee showAlert:@"Authentication failed."];
			m_boxee.isConnected = NO;
		} else {
			[nc postNotificationName:MediaListNeedsReloadingNotification object:self];
			m_boxee.isConnected = YES;
			[self connectedToServer];
			[self setupTimer];
		}
    }
    
    if ((alertView == databaseAlert) && (buttonIndex == 1)) {
        [m_boxee setupRemoteDatabaseMac];
    } else if ((alertView == databaseAlert) && (buttonIndex == 2)) {
        [m_boxee setupRemoteDatabaseWin];
    } else if ((alertView == databaseAlert) && (buttonIndex == 3)) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
        [defaults setInteger:1 forKey:[NSString stringWithFormat:@"ask%@ForDatabase",m_boxee.serverIP]];
        
    }
}

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    //NSLog(@"viewDidLoad");
    [super viewDidLoad];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    /*[nc addObserver:self
           selector:@selector(showPlaybackControls:) 
               name:showPlaybackControlsNotification
             object:nil];*/
    [nc addObserver:self
           selector:@selector(settingsTapped:) 
               name:hideServerPopupNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(removePopover) 
               name:hideMediaListPopupNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(setupTimer) 
               name:hideServerPopupNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(connectedToServer) 
               name:hideServerPopupNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(lostConnection) 
               name:ConnectionLostNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(pingReceived) 
               name:PingReceivedNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(pingTimedOut) 
               name:PingTimedOutNotification
             object:nil];
    keyboardField.delegate = self;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    m_boxee = [BoxeeHTTPInterface sharedInstance];
    
    /*TSAlertView* av = [[[TSAlertView alloc] init] autorelease];
    av.title = @"Authorization";
    av.message = @"Your Boxee server requires a password.";
    
    [av addButtonWithTitle: @"Cancel"];
    [av addButtonWithTitle: @"OK"];
    
    av.style = TSAlertViewStyleInput;
    av.usesMessageTextView = YES;
    av.buttonLayout = TSAlertViewButtonLayoutNormal;
    
    [av show];*/
	
	NSLog(@"lastServerIP: %@",[defaults stringForKey:@"lastServerIP"]);
	NSLog(@"lastServerPort: %@",[defaults stringForKey:@"lastServerPort"]);
    if ([defaults stringForKey:@"lastServerIP"] != nil) {
        m_boxee.serverIP = [defaults stringForKey:@"lastServerIP"];
        m_boxee.serverPort = [defaults stringForKey:@"lastServerPort"];
        if ([m_boxee ping]) {
            if ([m_boxee isPasswordProtected]) {
                // Ask for Username and password.
                passwordAlert = [[UIAlertView alloc] initWithTitle:@"Boxee Authentication" message:@"\n \n \n \n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                
                UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 40.0, 260.0, 50.0)];
                messageLabel.text = @"This server requires authentication.";
                messageLabel.lineBreakMode = UILineBreakModeWordWrap;
                messageLabel.numberOfLines = 0;
                messageLabel.textAlignment = UITextAlignmentCenter;
                messageLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
                messageLabel.textColor = [UIColor colorWithWhite:100 alpha:1];
                [passwordAlert addSubview:messageLabel];
                
                // Adds a password Field
                passwordField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 100.0, 260.0, 25.0)]; passwordField.placeholder = @"Password";
                [passwordField setSecureTextEntry:YES];
                passwordField.delegate = self;
                [passwordField setBackgroundColor:[UIColor whiteColor]]; [passwordAlert addSubview:passwordField];
                
                
                // Show alert on screen.
                [passwordAlert show];
				[passwordField becomeFirstResponder];
                [passwordAlert release];
                
                [messageLabel release];
                [passwordField release];
            } else {
                [nc postNotificationName:MediaListNeedsReloadingNotification object:self];
				m_boxee.isConnected = YES;
                [self connectedToServer];
                [self setupTimer];
            }
            NSLog(@"Last server found, connecting.");
        } else {
            NSLog(@"Last server not found.");
        }
    }
	
}


- (void)viewDidUnload
{
    //NSLog(@"viewDidUnload");
    //NSLog(@"Set title to %@",titleLabel.text);
    [addQueueButton release];
    addQueueButton = nil;
    [playNowButton release];
    playNowButton = nil;
    [DetailView release];
    DetailView = nil;
    [self setTitleLabel:nil];
    [self setDescriptionLabel:nil];
    [self setVolumeSlider:nil];
    [self setFileProgress:nil];
    [self setNowPlayingTitle:nil];
    [volumeSlider release];
    volumeSlider = nil;
    [nowPlayingImageView release];
    nowPlayingImageView = nil;
    [nowPlayingDescriptionView release];
    nowPlayingDescriptionView = nil;
    [nowPlayingTitleLabel release];
    nowPlayingTitleLabel = nil;
    [nowPlayingPositionSlider release];
    nowPlayingPositionSlider = nil;
    [nowPlayingTimeLabel release];
    nowPlayingTimeLabel = nil;
    [nowPlayingDurationLabel release];
    nowPlayingDurationLabel = nil;
    [nowPlayingButton release];
    nowPlayingButton = nil;
    [playButton release];
    playButton = nil;
    [playPrevButton release];
    playPrevButton = nil;
    [playNextButton release];
    playNextButton = nil;
    [keyboardField release];
    keyboardField = nil;
    [remoteButton release];
    remoteButton = nil;
    [keyboardButton release];
    keyboardButton = nil;
    [episodeTitleLabel release];
    episodeTitleLabel = nil;
    [seasonLabel release];
    seasonLabel = nil;
    [episodeLabel release];
    episodeLabel = nil;
    [thumbnailView release];
    thumbnailView = nil;
    [coverView release];
    coverView = nil;
    [hideNowPlayingButton release];
    hideNowPlayingButton = nil;
    [nowPlayingDescriptionTitle release];
    nowPlayingDescriptionTitle = nil;
    [self setPopupView:nil];
    [self setPopupLabel:nil];
	[super viewDidUnload];

	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.popoverController = nil;
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [_myPopoverController release];
    [_toolbar release];
    [_detailItem release];
    [_detailDescriptionLabel release];
    [addQueueButton release];
    [playNowButton release];
    [DetailView release];
    [titleLabel release];
    [descriptionLabel release];
    [volumeSlider release];
    [fileProgress release];
    [nowPlayingTitle release];
    [volumeSlider release];
    [nowPlayingImageView release];
    [nowPlayingDescriptionView release];
    [nowPlayingTitleLabel release];
    [nowPlayingPositionSlider release];
    [nowPlayingTimeLabel release];
    [nowPlayingDurationLabel release];
    [nowPlayingButton release];
    [playButton release];
    [playPrevButton release];
    [playNextButton release];
    [keyboardField release];
    [remoteButton release];
    [keyboardButton release];
    [episodeTitleLabel release];
    [seasonLabel release];
    [episodeLabel release];
    [thumbnailView release];
    [coverView release];
    [hideNowPlayingButton release];
    [nowPlayingDescriptionTitle release];
    [popupView release];
    [popupLabel release];
    [super dealloc];
}

@end
