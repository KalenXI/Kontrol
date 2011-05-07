//
//  RemoteViewControllerPhone.m
//  Kontrol
//
//  Created by Kevin Vinck on 23/04/2011.
//  Copyright 2011 None. All rights reserved.
//

#import "RemoteViewControllerPhone.h"


@implementation RemoteViewControllerPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        m_boxee = [BoxeeHTTPInterface sharedInstance];
        //NSLog(@"initing boxee interface.");
    }
    return self;
}

- (void)awakeFromNib {
    m_boxee = [BoxeeHTTPInterface sharedInstance];
}

- (void)dealloc
{
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (self.tabBarController.selectedViewController == self) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

- (void)buttonTouch:(NSTimer *)sender {
    //NSLog(@"Sending key");
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

- (IBAction)selectButtonTouched:(id)sender {
    //NSLog(@"Touched select.");
    [m_boxee sendKey:256];
}

- (IBAction)downButtonTouched:(id)sender {
    [m_boxee sendKey:271];
    if ([timer isValid]) 
        [timer invalidate];
    timer = nil;
    if (holdTimer != nil)
        [holdTimer invalidate];
    holdTimer = nil;
}

- (IBAction)UpButtonTouched:(id)sender {
    [m_boxee sendKey:270];
    if (timer != nil) 
        [timer invalidate];
    timer = nil;
    if (holdTimer != nil)
        [holdTimer invalidate];
    holdTimer = nil;
}

- (IBAction)rightButtonTouched:(id)sender {
    [m_boxee sendKey:273];
    if (timer != nil) 
        [timer invalidate];
    timer = nil;
    if (holdTimer != nil)
        [holdTimer invalidate];
    holdTimer = nil;
}

- (IBAction)leftButtonTouched:(id)sender {
    [m_boxee sendKey:272];
    if (timer != nil) 
        [timer invalidate];
    timer = nil;
    if (holdTimer != nil)
        [holdTimer invalidate];
    holdTimer = nil;
}

- (IBAction)backButtonTouched:(id)sender {
    [m_boxee sendKey:275];
}

- (IBAction)downButtonTouchDown:(id)sender {
    holdTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                             target:self
                                           selector:@selector(buttonBeginTouch:)
                                           userInfo:@"Down" 
                                            repeats:YES];
}

- (IBAction)rightButtonTouchDown:(id)sender {
    holdTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                             target:self
                                           selector:@selector(buttonBeginTouch:)
                                           userInfo:@"Right" 
                                            repeats:YES];
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
@end
