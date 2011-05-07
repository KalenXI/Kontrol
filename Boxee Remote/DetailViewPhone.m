//
//  DetailViewPhone.m
//  Kontrol
//
//  Created by Kevin Vinck on 4/23/11.
//  Copyright 2011 None. All rights reserved.
//

#import "DetailViewPhone.h"


@implementation DetailViewPhone

@synthesize episodeTitleLabel,showTitleLabel,seasonEpisodeLabel;
@synthesize episodeDescriptionView,backgroundImageView;
@synthesize mediaItem;

dispatch_queue_t myQueue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [showTitleLabel release];
    [episodeTitleLabel release];
    [seasonEpisodeLabel release];
    [episodeDescriptionView release];
    [backgroundImageView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)playMedia {
    //NSLog(@"Play media");
    [m_boxee playFile:self.mediaItem.strPath inPlaylist:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    m_boxee = [BoxeeHTTPInterface sharedInstance];
    if (self.mediaItem.strShowName != nil)
        showTitleLabel.text = self.mediaItem.strShowName;
    if (self.mediaItem.strTitle != nil)
        episodeTitleLabel.text = mediaItem.strTitle;
    if (self.mediaItem.strDescription != nil)
        episodeDescriptionView.text = mediaItem.strDescription;
    if ([mediaItem.iEpisode intValue] != 0) {
        seasonEpisodeLabel.text = [NSString stringWithFormat:@"Season: %i Episode: %i",[mediaItem.iSeason intValue],[mediaItem.iEpisode intValue]];
    } else {
        seasonEpisodeLabel.text = @"";
    }
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
	temporaryBarButtonItem.title = @"Play";
    temporaryBarButtonItem.target = self;
    temporaryBarButtonItem.action = @selector(playMedia);
	self.navigationItem.rightBarButtonItem = temporaryBarButtonItem;
	[temporaryBarButtonItem release];
    
    dispatch_async(myQueue, ^ { 
        //NSLog(@"strCover: %@",[currentObject valueForKey:@"strCover"]);
        NSURL *thumbURL = [NSURL URLWithString:mediaItem.strCover];
        NSData *thumbData = [NSData dataWithContentsOfURL:thumbURL];
        UIImage *thumbnail = [UIImage imageWithData:thumbData];
        dispatch_async(dispatch_get_main_queue(), ^ {backgroundImageView.image = thumbnail;});
    } );
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [showTitleLabel release];
    showTitleLabel = nil;
    [episodeTitleLabel release];
    episodeTitleLabel = nil;
    [seasonEpisodeLabel release];
    seasonEpisodeLabel = nil;
    [episodeDescriptionView release];
    episodeDescriptionView = nil;
    [backgroundImageView release];
    backgroundImageView = nil;
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
