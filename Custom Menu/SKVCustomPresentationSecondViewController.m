//
//  SKVCustomPresentationSecondViewController.m
//  Custom Menu
//
//  Created by Limitation on 8/11/18.
//  Copyright © 2018 Limitation. All rights reserved.
//

#import "SKVCustomPresentationSecondViewController.h"

@interface SKVCustomPresentationSecondViewController ()

@end

@implementation SKVCustomPresentationSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
    
    // NOTE: View controllers presented with custom presentation controllers
    //       do not assume control of the status bar appearance by default
    //       (their -preferredStatusBarStyle and -prefersStatusBarHidden
    //       methods are not called).  You can override this behavior by
    //       setting the value of the presented view controller's
    //       modalPresentationCapturesStatusBarAppearance property to YES.
    /* self.modalPresentationCapturesStatusBarAppearance = YES; */
}


- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection
              withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    
    // When the current trait collection changes (e.g. the device rotates),
    // update the preferredContentSize.
    [self updatePreferredContentSizeWithTraitCollection:newCollection];
}


//! Updates the receiver's preferredContentSize based on the verticalSizeClass
//! of the provided \a traitCollection.
//
- (void)updatePreferredContentSizeWithTraitCollection:(UITraitCollection *)traitCollection {
    self.preferredContentSize = CGSizeMake(self.view.bounds.size.width,
                                           traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? 270 : 420);
}

- (IBAction)sliderValueChange:(UISlider*)sender {
    self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, sender.value);
}

#pragma mark -
#pragma mark Unwind Actions

//! Action for unwinding from the presented view controller (C).
//
- (IBAction)unwindToCustomPresentationSecondViewController:(UIStoryboardSegue *)sender
{ }

@end
