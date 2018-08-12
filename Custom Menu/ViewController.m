//
//  ViewController.m
//  Custom Menu
//
//  Created by Limitation on 8/11/18.
//  Copyright © 2018 Limitation. All rights reserved.
//

#import "ViewController.h"
#import "SKVCustomPresentationController.h"

@interface ViewController ()
@property (assign, nonatomic, getter=isViewControllerPresented) BOOL viewControllerPresented;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:panGesture];
}


- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    static CGFloat translation = 0;
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            translation = 0;
            break;
        case UIGestureRecognizerStateChanged: {
            translation += [recognizer translationInView:self.view].x;
            CGFloat translationInPercents = translation / CGRectGetWidth(self.view.bounds);
            if (!self.isViewControllerPresented && translationInPercents > 0.3) {
                UIViewController *viewControllerToPresent = [self.storyboard instantiateViewControllerWithIdentifier:@"SecondViewController"];
                [self presentViewController:viewControllerToPresent];
                self.viewControllerPresented = YES;
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            self.viewControllerPresented = NO;
            break;
        }
        default:
            self.viewControllerPresented = NO;
            break;
    }
}


- (IBAction)showMenu:(UIButton *)sender {
    UIViewController *secondViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SecondViewController"];
    [self presentViewController:secondViewController];
}


- (void)presentViewController:(UIViewController *)viewControllerToPresent {
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
    SKVCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
    
    presentationController = [[SKVCustomPresentationController alloc]
                              initWithPresentedViewController:viewControllerToPresent
                              presentingViewController:self];
    
    viewControllerToPresent.transitioningDelegate = presentationController;
    
    [self presentViewController:viewControllerToPresent
                       animated:YES
                     completion:nil];
}

@end
