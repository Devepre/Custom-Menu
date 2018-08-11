//
//  ViewController.m
//  Custom Menu
//
//  Created by Limitation on 8/11/18.
//  Copyright © 2018 Limitation. All rights reserved.
//

#import "ViewController.h"
#import "AAPLCustomPresentationController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)showMenu:(UIButton *)sender {
    UIViewController *secondViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SecondViewController"];
    
    // For presentations which will use a custom presentation controller,
    // it is possible for that presentation controller to also be the
    // transitioningDelegate.  This avoids introducing another object
    // or implementing <UIViewControllerTransitioningDelegate> in the
    // source view controller.
    //
    // transitioningDelegate does not hold a strong reference to its
    // destination object.  To prevent presentationController from being
    // released prior to calling -presentViewController:animated:completion:
    // the NS_VALID_UNTIL_END_OF_SCOPE attribute is appended to the declaration.
    AAPLCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
    
    presentationController = [[AAPLCustomPresentationController alloc]
                              initWithPresentedViewController:secondViewController
                              presentingViewController:self];
    
    secondViewController.transitioningDelegate = presentationController;
    
    [self presentViewController:secondViewController animated:YES completion:NULL];
}

@end
