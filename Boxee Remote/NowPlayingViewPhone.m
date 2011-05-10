//
//  NowPlayingViewPhone.m
//  Kontrol
//
//  Created by Kevin Vinck on 23/04/2011.
//  Copyright 2011 None. All rights reserved.
//

#import "NowPlayingViewPhone.h"


@implementation NowPlayingViewPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib {
    m_boxee = [BoxeeHTTPInterface sharedInstance];
}

- (void) refreshPlayingStatus:(NSTimer *)timer {
    if ((timer == nowPlayingTimer) && (m_boxee.isConnected == YES) && ([m_boxee getCurrentlyPlayingInfo] != nil)) {
        [timer invalidate];
        //NSLog(@"////////Refreshing playing status.\\\\\\\\\\\\");
        NSMutableDictionary *currentStatus = [m_boxee getCurrentlyPlayingInfo];
        if (currentStatus != nil) {
            //NSLog(@"Getting volume");
            [currentStatus retain];
            if ([[currentStatus valueForKey:@"Filename"] isEqualToString:@"[Nothing Playing]"]) {
                playingTitle.text = @"Nothing playing";
                playingImageVIew.image = nil;
                playButton.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_controls_3.png" ofType:nil]];
                seekSlider.value = 0;
                playingDurationLabel.text = @"0:00";
                playingPositionLabel.text = @"0:00";
                //NSLog(@"Nothing is playing.");
            } else if ([currentStatus valueForKey:@"Filename"] == nil) {
                //NSLog(@"Server not found, restarting timer");
                nowPlayingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 
                                                                   target:self
                                                                 selector:@selector(refreshPlayingStatus:) 
                                                                 userInfo:nil 
                                                                  repeats:YES];
                return;
            } else {
                //A file is currently playing.
                //NSLog(@"Something is playing: %@",[currentStatus valueForKey:@"Filename"]);
                
                
                if ([[currentStatus valueForKey:@"PlayStatus"] isEqualToString:@"Playing"]) {
                    playButton.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_controls_4.png" ofType:nil]]; 
                } else {
                    playButton.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_controls_3.png" ofType:nil]];
                }
                
                if (([currentStatus valueForKey:@"Title"] != nil) && ([currentStatus valueForKey:@"Show Title"] != nil)) {
                    playingTitle.text = [NSString stringWithFormat:@"%@ - %@",[currentStatus valueForKey:@"Show Title"],[currentStatus valueForKey:@"Title"]];
                } else if ([currentStatus valueForKey:@"Title"] != nil) {
                    playingTitle.text = [currentStatus valueForKey:@"Title"];
                } else {
                    NSArray *filename = [[currentStatus valueForKey:@"Filename"] componentsSeparatedByString:@"/"];
                    playingTitle.text = [filename objectAtIndex:[filename count] - 1];
                }
                
                if (![nowPlayingThumbnailURL isEqualToString:[currentStatus valueForKey:@"Thumb"]]) {
                    NSData *thumbnailData = [m_boxee getFile:[currentStatus valueForKey:@"Thumb"]];
                    playingImageVIew.image = [UIImage imageWithData:thumbnailData];
                    nowPlayingThumbnailURL = [currentStatus valueForKey:@"Thumb"];
                }
                
                seekSlider.value = [[currentStatus valueForKey:@"Percentage"] intValue];
                playingDurationLabel.text = [currentStatus valueForKey:@"Duration"];
                playingPositionLabel.text = [currentStatus valueForKey:@"Time"];
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
    nowPlayingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 
                                                       target:self
                                                     selector:@selector(refreshPlayingStatus:) 
                                                     userInfo:nil 
                                                      repeats:YES];
}


- (void)dealloc
{
    [playButton release];
    [backButton release];
    [forwardButton release];
    [controlsView release];
    [volumeView release];
    [seekSlider release];
    [playingTitle release];
    [playingPositionLabel release];
    [playingDurationLabel release];
    [volumeSlider release];
    [playingImageVIew release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated {
    [self setupTimer];
    [self refreshPlayingStatus:nowPlayingTimer];
}

- (void) viewDidDisappear:(BOOL)animated {
    //NSLog(@"viewDidDisappear");
    if (nowPlayingTimer != nil) {
        [nowPlayingTimer invalidate];
        nowPlayingTimer = nil;
    }
}

- (void)viewDidUnload
{
    [playButton release];
    playButton = nil;
    [backButton release];
    backButton = nil;
    [forwardButton release];
    forwardButton = nil;
    [controlsView release];
    controlsView = nil;
    [volumeView release];
    volumeView = nil;
    [seekSlider release];
    seekSlider = nil;
    [playingTitle release];
    playingTitle = nil;
    [playingPositionLabel release];
    playingPositionLabel = nil;
    [playingDurationLabel release];
    playingDurationLabel = nil;
    [volumeSlider release];
    volumeSlider = nil;
    [playingImageVIew release];
    playingImageVIew = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)showPlaybackControls:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    //[UIView setAnimationDuration:.5];
    if (controlsView.alpha == 0) {
        controlsView.alpha = 1;
        volumeView.alpha = 1;
    } else {
        controlsView.alpha = 0;
        volumeView.alpha = 0;
    }
    [UIView commitAnimations];
}

- (IBAction)playPauseTapped:(id)sender {
    [m_boxee pause];
}

- (IBAction)nextButtonTapped:(id)sender {
    [m_boxee playNext];
}

- (IBAction)backButtonTapped:(id)sender {
    [m_boxee playPrev];
}

- (IBAction)volumeChanged:(id)sender {
    [m_boxee setVolume:volumeSlider.value];
}

- (IBAction)positionChanged:(id)sender {
    [m_boxee setSeekPosition:seekSlider.value];
}
@end
