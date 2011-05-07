//
//  SplashScreenViewController.m
//  Boxee Remote
//
//  Created by Kevin Vinck on 26/03/2011.
//  Copyright 2011 None. All rights reserved.
//

#import "SplashScreenViewController.h"
#import "DetailViewController.h"

@interface SplashScreenViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
@end

@implementation SplashScreenViewController

@synthesize toolbar=_toolbar;

@synthesize detailItem=_detailItem;

@synthesize detailDescriptionLabel=_detailDescriptionLabel;

@synthesize popoverController=_myPopoverController;
@synthesize popover;
@synthesize detailViewOverlay;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

UIViewController *currentView;

- (void) displayView:(int)intNewView {
    //NSLog(@"Showing detailview.");
    [currentView.view removeFromSuperview];
    [currentView release];
    switch (intNewView) {
        case 1:
            currentView = [[SplashScreenViewController alloc] init];
            break;
        case 2:
            currentView = [[DetailViewController alloc] init];
            break;
    }
    [self.view addSubview:currentView.view];
        
}

- (void)dealloc
{
    [_detailView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)configureView
{
    // Update the user interface for the detail item.
    self.detailDescriptionLabel.text = [self.detailItem description];
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController: (UIPopoverController *)pc
{
    barButtonItem.title = @"Media Library";
    NSMutableArray *items = [[self.toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [self.toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = pc;
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSMutableArray *items = [[self.toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [self.toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    currentView = [[SplashScreenViewController alloc] init];
    [self.view addSubview:currentView.view];
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
	return YES;
}

@end
