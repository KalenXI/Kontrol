//
//  SplashScreenViewController.h
//  Boxee Remote
//
//  Created by Kevin Vinck on 26/03/2011.
//  Copyright 2011 None. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SplashScreenViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate>  {
    
    UIView *_detailView;
}

- (void) displayView:(int)intNewView;

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) id detailItem;
@property (nonatomic, retain) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic, retain) UIPopoverController *popover;
@property (nonatomic, retain) IBOutlet UIView *detailViewOverlay;

@end
