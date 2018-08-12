//
//  SKVCustomPresentationController.m
//  Custom Menu
//
//  Created by Limitation on 8/11/18.
//  Copyright © 2018 Limitation. All rights reserved.
//

#import "SKVCustomPresentationController.h"

//! The corner radius applied to the view containing the presented view
//! controller.
//static const CGFloat kPresentedViewCornerRadius = 16.f;
static const CGFloat kPresentedViewWidthMultiplier = 3.0f / 4.0f;
static const CGFloat kTransitionDuration = 0.35f;
static const CGFloat kDimmingViewAlphaMax = 0.5f;
static const CGFloat kDimmingViewAlphaMin = 0.0f;

@interface SKVCustomPresentationController () <UIViewControllerAnimatedTransitioning>
@property (nonatomic, strong) UIView *presentationWrappingView;
@property (nonatomic, strong) UIView *dimmingView;
@end

@implementation SKVCustomPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController
                         presentingViewController:presentingViewController];
    
    if (self) {
        // The presented view controller must have a modalPresentationStyle
        // of UIModalPresentationCustom for a custom presentation controller
        // to be used.
        presentedViewController.modalPresentationStyle = UIModalPresentationCustom;
    }
    
    return self;
}


- (UIView *)presentedView {
    // Return the wrapping view created in -presentationTransitionWillBegin.
    return self.presentationWrappingView;
}


//  This is one of the first methods invoked on the presentation controller
//  at the start of a presentation.  By the time this method is called,
//  the containerView has been created and the view hierarchy set up for the
//  presentation.  However, the -presentedView has not yet been retrieved.
//
- (void)presentationTransitionWillBegin {
    // The default implementation of -presentedView returns
    // self.presentedViewController.view.
    UIView *presentedViewControllerViewActual = [super presentedView];
    
    // Wrap the presented view controller's view in an intermediate hierarchy
    // that applies a shadow/ The final effect is built using three intermediate views.
    //
    //  |- UITransitionView
    //      |- dimmingView                          <- dimm
    //      |- presentationWrapperViewWithShadow    <- shadow
    //           |- presentedViewControllerViewActual      <- view itself (presentedViewController.view)
    //
    
    // Add a dimming view behind presentedViewControllerViewActual
    // Actual view is added later (by the animator) so any views
    // added here will be appear behind the -presentedView.
    {
        UIView *dimmingView = [[UIView alloc] initWithFrame:self.containerView.bounds];
        dimmingView.backgroundColor = [UIColor blackColor];
        dimmingView.opaque = NO;
        dimmingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [dimmingView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimmingViewTapped:)]];
        self.dimmingView = dimmingView;
        [self.containerView addSubview:dimmingView];
        
        // Get the transition coordinator for the presentation so we can
        // fade in the dimmingView alongside the presentation animation.
        id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
        
        self.dimmingView.alpha = kDimmingViewAlphaMin;
        [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            self.dimmingView.alpha = kDimmingViewAlphaMax;
        } completion:nil];
    }
    
    // Adding shadow to the actually presented view
    {
        UIView *presentationWrapperViewWithShadow = [[UIView alloc] initWithFrame:self.frameOfPresentedViewInContainerView];
        presentationWrapperViewWithShadow.layer.shadowOpacity = 0.44f;
        presentationWrapperViewWithShadow.layer.shadowRadius = 13.f;
        presentationWrapperViewWithShadow.layer.shadowOffset = CGSizeMake(0, -6.f);
        
        // Add presentedViewControllerViewActual -> presentedViewControllerWrapperView
        presentedViewControllerViewActual.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        presentedViewControllerViewActual.frame = self.frameOfPresentedViewInContainerView;
        [presentationWrapperViewWithShadow addSubview:presentedViewControllerViewActual];
        
        // Setting resulted view to the property to retrun in -presentedView
        self.presentationWrappingView = presentationWrapperViewWithShadow;
    }
}


- (void)presentationTransitionDidEnd:(BOOL)completed {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handlePanGesture:)];
    [self.presentedView addGestureRecognizer:panGesture];
    
    // The value of the 'completed' argument is the same value passed to the
    // -completeTransition: method by the animator.  It may
    // be NO in the case of a cancelled interactive transition.
    if (completed == NO) {
        // The system removes the presented view controller's view from its
        // superview and disposes of the containerView.  This implicitly
        // removes the views created in -presentationTransitionWillBegin: from
        // the view hierarchy.  However, we still need to relinquish our strong
        // references to those view.
        self.presentationWrappingView = nil;
        self.dimmingView = nil;
    }
}


- (void)dismissalTransitionWillBegin {
    // Get the transition coordinator for the dismissal so we can
    // fade out the dimmingView alongside the dismissal animation.
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
    
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.dimmingView.alpha = kDimmingViewAlphaMin;
    } completion:NULL];
}


- (void)dismissalTransitionDidEnd:(BOOL)completed {
    // The value of the 'completed' argument is the same value passed to the
    // -completeTransition: method by the animator.  It may
    // be NO in the case of a cancelled interactive transition.
    if (completed == YES) {
        // The system removes the presented view controller's view from its
        // superview and disposes of the containerView.  This implicitly
        // removes the views created in -presentationTransitionWillBegin: from
        // the view hierarchy.  However, we still need to relinquish our strong
        // references to those view.
        self.presentationWrappingView = nil;
        self.dimmingView = nil;
    }
}

#pragma mark -
#pragma mark Layout

//  This method is invoked whenever the presentedViewController's
//  preferredContentSize property changes.  It is also invoked just before the
//  presentation transition begins (prior to -presentationTransitionWillBegin).
//
- (void)preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container {
    [super preferredContentSizeDidChangeForChildContentContainer:container];
    
    if (container == self.presentedViewController) {
        [self.containerView setNeedsLayout];
    }
}


//  When the presentation controller receives a
//  -viewWillTransitionToSize:withTransitionCoordinator: message it calls this
//  method to retrieve the new size for the presentedViewController's view.
//  The presentation controller then sends a
//  -viewWillTransitionToSize:withTransitionCoordinator: message to the
//  presentedViewController with this size as the first argument.
//
//  Note that it is up to the presentation controller to adjust the frame
//  of the presented view controller's view to match this promised size.
//  We do this in -containerViewWillLayoutSubviews.
//
- (CGSize)sizeForChildContentContainer:(id<UIContentContainer>)container
               withParentContainerSize:(CGSize)parentSize {
    if (container == self.presentedViewController) {
        CGSize preferedSize = CGSizeMake(parentSize.width * kPresentedViewWidthMultiplier,
                                         parentSize.height);
        return preferedSize;
    } else {
        return [super sizeForChildContentContainer:container
                           withParentContainerSize:parentSize];
    }
}


- (CGRect)frameOfPresentedViewInContainerView {
    CGRect containerViewBounds = self.containerView.bounds;
    CGSize presentedViewContentSize = [self sizeForChildContentContainer:self.presentedViewController
                                                 withParentContainerSize:containerViewBounds.size];
    
    // The presented view extends presentedViewContentSize.height points from
    // the bottom edge of the screen.
    CGRect presentedViewControllerFrame = containerViewBounds;
    presentedViewControllerFrame.size = presentedViewContentSize;
    presentedViewControllerFrame.origin.y = CGRectGetMaxY(containerViewBounds) - presentedViewContentSize.height;
    return presentedViewControllerFrame;
}


//  This method is similar to the -viewWillLayoutSubviews method in
//  UIViewController.  It allows the presentation controller to alter the
//  layout of any custom views it manages.
//
- (void)containerViewWillLayoutSubviews {
    [super containerViewWillLayoutSubviews];
    
    self.dimmingView.frame = self.containerView.bounds;
    self.presentationWrappingView.frame = self.frameOfPresentedViewInContainerView;
}


#pragma mark -
#pragma mark UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return [transitionContext isAnimated] ? kTransitionDuration : 0;
}


//  The presentation animation is tightly integrated with the overall
//  presentation so it makes the most sense to implement
//  <UIViewControllerAnimatedTransitioning> in the presentation controller
//  rather than in a separate object.
//
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = transitionContext.containerView;
    
    // For a Presentation:
    //      fromView = The presenting view.
    //      toView   = The presented view.
    // For a Dismissal:
    //      fromView = The presented view.
    //      toView   = The presenting view.
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    // If NO is returned from -shouldRemovePresentersView, the view associated
    // with UITransitionContextFromViewKey is nil during presentation.  This
    // intended to be a hint that your animator should NOT be manipulating the
    // presenting view controller's view.  For a dismissal, the -presentedView
    // is returned.
    //
    // Why not allow the animator manipulate the presenting view controller's
    // view at all times?  First of all, if the presenting view controller's
    // view is going to stay visible after the animation finishes during the
    // whole presentation life cycle there is no need to animate it at all — it
    // just stays where it is.  Second, if the ownership for that view
    // controller is transferred to the presentation controller, the
    // presentation controller will most likely not know how to layout that
    // view controller's view when needed, for example when the orientation
    // changes, but the original owner of the presenting view controller does.
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    BOOL isPresenting = (fromViewController == self.presentingViewController);
    
    // This will be the current frame of fromViewController.view.
    CGRect __unused fromViewInitialFrame = [transitionContext initialFrameForViewController:fromViewController];
    // For a presentation which removes the presenter's view, this will be
    // CGRectZero.  Otherwise, the current frame of fromViewController.view.
    CGRect fromViewFinalFrame = [transitionContext finalFrameForViewController:fromViewController];
    // This will be CGRectZero.
    CGRect toViewInitialFrame = [transitionContext initialFrameForViewController:toViewController];
    // For a presentation, this will be the value returned from the
    // presentation controller's -frameOfPresentedViewInContainerView method.
    CGRect toViewFinalFrame = [transitionContext finalFrameForViewController:toViewController];
    
    // We are responsible for adding the incoming view to the containerView
    // for the presentation (will have no effect on dismissal because the
    // presenting view controller's view was not removed).
    [containerView addSubview:toView];
    
    NSTimeInterval transitionDuration = [self transitionDuration:transitionContext];
    
    void (^animationCompletion)(BOOL) = ^void(BOOL finished) {
        // When we complete, tell the transition context
        // passing along the BOOL that indicates whether the transition
        // finished or not.
        BOOL wasCancelled = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!wasCancelled];
    };
    
    if (isPresenting) {
//        toViewInitialFrame.origin = CGPointMake(CGRectGetMinX(containerView.bounds), CGRectGetMaxY(containerView.bounds));
        
//        toViewInitialFrame.origin = CGPointMake(CGRectGetMinX(containerView.bounds), CGRectGetMinY(containerView.bounds));
        CGPoint toViewInitialPoint = CGPointMake(CGRectGetMinX(containerView.bounds) - CGRectGetWidth(toView.frame),
                                                 CGRectGetMinY(containerView.bounds) );
        toViewInitialFrame.origin = toViewInitialPoint;
        
        toViewInitialFrame.size = toViewFinalFrame.size;
        toView.frame = toViewInitialFrame;
        
        [UIView animateWithDuration:transitionDuration
                              delay:0
             usingSpringWithDamping:0.8
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             toView.frame = toViewFinalFrame;
                         }
                         completion:animationCompletion];
    } else {
        // Because our presentation wraps the presented view controller's view
        // in an intermediate view hierarchy, it is more accurate to rely
        // on the current frame of fromView than fromViewInitialFrame as the
        // initial frame (though in this example they will be the same).
//        fromViewFinalFrame = CGRectOffset(fromView.frame, 0, CGRectGetHeight(fromView.frame));
        fromViewFinalFrame = CGRectOffset(fromView.frame, -CGRectGetWidth(fromView.frame), 0);
        
        [UIView animateWithDuration:transitionDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             fromView.frame = fromViewFinalFrame;
                         }
                         completion:animationCompletion];
    }
}

#pragma mark -
#pragma mark UIViewControllerTransitioningDelegate

//  If the modalPresentationStyle of the presented view controller is
//  UIModalPresentationCustom, the system calls this method on the presented
//  view controller's transitioningDelegate to retrieve the presentation
//  controller that will manage the presentation.  If your implementation
//  returns nil, an instance of UIPresentationController is used.
//
- (UIPresentationController*)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                     presentingViewController:(UIViewController *)presenting
                                                         sourceViewController:(UIViewController *)source {
    NSAssert(self.presentedViewController == presented,
             @"You didn't initialize %@ with the correct presentedViewController.  Expected %@, got %@.",
             self, presented, self.presentedViewController);
    
    return self;
}


//  The system calls this method on the presented view controller's
//  transitioningDelegate to retrieve the animator object used for animating
//  the presentation of the incoming view controller.  Your implementation is
//  expected to return an object that conforms to the
//  UIViewControllerAnimatedTransitioning protocol, or nil if the default
//  presentation animation should be used.
//
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    return self;
}


//  The system calls this method on the presented view controller's
//  transitioningDelegate to retrieve the animator object used for animating
//  the dismissal of the presented view controller.  Your implementation is
//  expected to return an object that conforms to the
//  UIViewControllerAnimatedTransitioning protocol, or nil if the default
//  dismissal animation should be used.
//
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}


#pragma mark - Gestures

//  IBAction for the tap gesture recognizer added to the dimmingView.
//  Dismisses the presented view controller.
//
- (IBAction)dimmingViewTapped:(UITapGestureRecognizer*)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:NULL];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
//    BOOL gestureIsDraggingFromRightToLeft = [recognizer velocityInView:self.presentedView].x > 0;
    
    static CGFloat translation = 0;
    CGFloat alphaValue = self.dimmingView.alpha;
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            translation = 0;
            alphaValue = self.dimmingView.alpha;
            break;
        case UIGestureRecognizerStateChanged: {
            translation += [recognizer translationInView:self.presentedView].x;
            CGFloat translationInPercents = translation / CGRectGetWidth(self.presentedView.bounds);
            NSLog(@"Trans p: %f", translationInPercents);
            if (translationInPercents > 0) {
                return;
            }
            
            CGPoint newCenter = self.presentedView.center;
            newCenter.x += [recognizer translationInView:self.presentedView].x;
            self.presentedView.center = newCenter;
            [recognizer setTranslation:CGPointZero
                                inView:self.presentedView];
            
            // Setting alpha for dimming view
            CGFloat newAlpha = kDimmingViewAlphaMax - kDimmingViewAlphaMax * ABS(translationInPercents);
            self.dimmingView.alpha = newAlpha;
            break;
        }
        case UIGestureRecognizerStateEnded: {
            CGFloat delta = CGRectGetMidX(self.presentedView.bounds) / 2.0;
            BOOL hasMovedGreaterThanHalfWay = self.presentedView.center.x < delta;
            [self animatePanelShouldExpand:!hasMovedGreaterThanHalfWay];
            break;
        }
        default:
            break;
    }
}


- (void)animatePanelShouldExpand:(BOOL)shouldExpand {
    if (shouldExpand) {
        NSInteger newX = 0;
        [self animateCenterPanelXPosition:newX
                        completionHandler:^(BOOL param) {
                            ;
                        }];
    } else {
        NSInteger newX = -CGRectGetWidth(self.presentedView.frame);
        [self animateCenterPanelXPosition:newX
                        completionHandler:^(BOOL param) {
                            [self.presentingViewController dismissViewControllerAnimated:YES
                                                                              completion:NULL];
                        }];
    }
}


- (void)animateCenterPanelXPosition:(NSInteger)targetXPosition
                  completionHandler:(void (^)(BOOL))completion {
    CGFloat endAlpha = 0.0;
    CGFloat springValue = 0.0;
    if (targetXPosition == 0) {
        springValue = 0.8;
        endAlpha = kDimmingViewAlphaMax;
    }
    [UIView animateWithDuration:0.2
                          delay:0
         usingSpringWithDamping:springValue
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect newFrame = self.presentedView.frame;
                         newFrame.origin.x = targetXPosition;
                         self.presentedView.frame = newFrame;
                         self.dimmingView.alpha = endAlpha;
                     } completion:completion];
}

@end
