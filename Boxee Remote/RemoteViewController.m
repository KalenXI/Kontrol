//
//  RemoteViewController.m
//  Boxee Remote
//
//  Created by Kevin Vinck on 25/03/2011.
//  Copyright 2011 None. All rights reserved.
//

#import "RemoteViewController.h"


@implementation RemoteViewController

@synthesize audioPlayer;

@synthesize muteButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        m_boxee = [BoxeeHTTPInterface sharedInstance];
        currentView = 1;
    }
    return self;
}

- (void)setViewTo:(int)viewNum {
    [UIView beginAnimations:nil context:NULL];
    
    CGPoint pos = mainView.center;
    
    if (viewNum == 0) {
        pos.x = 468;
    } else if (viewNum == 1) {
        pos.x = 156;
    } else if (viewNum == 2) {
        pos.x = -156;
    }
    
    mainView.center = pos;
    
    [UIView commitAnimations];
}

- (void)dealloc
{
    [muteButton release];
    [mainView release];
    [switchButtons release];
    [fullscreenClicked release];
    [appsClicked release];
    [subtitleTrackClicked release];
    [subtitleDelayDec release];
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
    isMuted = NO;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [muteButton release];
    muteButton = nil;
    [mainView release];
    mainView = nil;
    [switchButtons release];
    switchButtons = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Button code

- (void) playClick {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"click2" withExtension: @"aiff"];
    if (!url){NSLog(@"file not found"); return;}
    NSError *error;
    self.audioPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error] autorelease];
    [audioPlayer play];
}

- (void)buttonTouch:(NSTimer *)sender {
    if ([[sender userInfo] isEqualToString:@"Up"]) {
        [m_boxee sendKey:270];
    } else if ([[sender userInfo] isEqualToString:@"Down"]) {
        [m_boxee sendKey:271];
    } else if ([[sender userInfo] isEqualToString:@"Left"]) {
        [m_boxee sendKey:272];
    } else if ([[sender userInfo] isEqualToString:@"Right"]) {
        [m_boxee sendKey:273];
    }
}

- (void)buttonBeginTouch:(NSTimer *)sender {
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                             target:self
                                           selector:@selector(buttonTouch:)
                                           userInfo:[sender userInfo] 
                                            repeats:YES];
    if (holdTimer != nil)
        [holdTimer invalidate];
    holdTimer = nil;
}

#pragma mark - Remote buttons

- (IBAction)selectButtonClicked:(id)sender {
    [self playClick];
    [m_boxee sendKey:256];
    //NSLog(@"Clicked select.");
}

- (IBAction)rightButtonClicked:(id)sender {
    [self playClick];
    [m_boxee sendKey:273];
    if ([timer isValid]) 
        [timer invalidate];
    timer = nil;
    if (holdTimer != nil)
        [holdTimer invalidate];
    holdTimer = nil;
    //NSLog(@"Clicked right.");
}

- (IBAction)downButtonClicked:(id)sender {
    [self playClick];
    [m_boxee sendKey:271];
    if ([timer isValid]) 
        [timer invalidate];
    timer = nil;
    if (holdTimer != nil)
        [holdTimer invalidate];
    holdTimer = nil;
    //NSLog(@"Clicked down.");
}

- (IBAction)leftButtonClicked:(id)sender {
    [self playClick];
    [m_boxee sendKey:272];
    if ([timer isValid]) 
        [timer invalidate];
    timer = nil;
    if (holdTimer != nil)
        [holdTimer invalidate];
    holdTimer = nil;
    //NSLog(@"Clicked left.");
}

- (IBAction)upButtonClicked:(id)sender {
    [self playClick];
    [m_boxee sendKey:270];
    if ([timer isValid]) 
        [timer invalidate];
    timer = nil;
    if (holdTimer != nil)
        [holdTimer invalidate];
    holdTimer = nil;
    //NSLog(@"Clicked up.");
}

- (IBAction)backButtonClicked:(id)sender {
    [self playClick];
    [m_boxee sendKey:275];
    //NSLog(@"Clicked back.");
}

- (IBAction)muteButtonClicked:(id)sender {
    if (isMuted == NO) {
        [m_boxee mute];
        [muteButton setSelected:YES];
        isMuted = YES;
    } else {
        [m_boxee mute];
        [muteButton setSelected:NO];
        isMuted = NO;
    }
}

- (IBAction)upButtonTouchDown:(id)sender {
    holdTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                 target:self
                                               selector:@selector(buttonBeginTouch:)
                                               userInfo:@"Up" 
                                                repeats:YES];
}

- (IBAction)leftButtonTouchDown:(id)sender {
    holdTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                 target:self
                                               selector:@selector(buttonBeginTouch:)
                                               userInfo:@"Left" 
                                                repeats:YES];
}

- (IBAction)rightButtonTouchDown:(id)sender {
    holdTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                 target:self
                                               selector:@selector(buttonBeginTouch:)
                                               userInfo:@"Right" 
                                                repeats:YES];
}

- (IBAction)downButtonTouchDown:(id)sender {
    holdTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                 target:self
                                               selector:@selector(buttonBeginTouch:)
                                               userInfo:@"Down" 
                                                repeats:YES];
}

#pragma mark - System buttons

- (IBAction)nowPlayingClicked:(id)sender {
    [m_boxee action:18];
}

- (IBAction)tvShowsClicked:(id)sender {
    [m_boxee activateWindow:10480];
}

- (IBAction)moviesClicked:(id)sender {
    [m_boxee activateWindow:10481];
}

- (IBAction)fileBrowserClicked:(id)sender {
    [m_boxee activateWindow:10479];
}

- (IBAction)musicClicked:(id)sender {
    [m_boxee activateWindow:10484];
}

- (IBAction)fullscreenClicked:(id)sender {
    [m_boxee action:199];
}

- (IBAction)homeClicked:(id)sender {
    [m_boxee activateWindow:10000];
}

- (IBAction)appsClicked:(id)sender {
    [m_boxee activateWindow:10482];
}

#pragma mark - Video buttons

- (IBAction)viewModeClicked:(id)sender {
    [m_boxee action:19];
}

- (IBAction)audioTrackClicked:(id)sender {
    [m_boxee action:56];
}

- (IBAction)subtitlesClicked:(id)sender {
    [m_boxee action:25];
}

- (IBAction)subtitleTrackClicked:(id)sender {
    [m_boxee action:26];
}

- (IBAction)audioDelayInc:(id)sender {
    [m_boxee action:55];
}

- (IBAction)audioDelayDec:(id)sender {
    [m_boxee action:54];
}

- (IBAction)subtitleDelayInc:(id)sender {
    [m_boxee action:53];
}

- (IBAction)subtitleDelayDec:(id)sender {
    [m_boxee action:52];
}

- (IBAction)switchBarClicked:(id)sender {
    [self setViewTo:switchButtons.selectedSegmentIndex];
}
@end
