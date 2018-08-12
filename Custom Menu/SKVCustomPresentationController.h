//
//  SKVCustomPresentationController.h
//  Custom Menu
//
//  Created by Limitation on 8/11/18.
//  Copyright © 2018 Limitation. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SKVCustomPresentationController : UIPresentationController <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UIView *dimmingView;

@end

NS_ASSUME_NONNULL_END
