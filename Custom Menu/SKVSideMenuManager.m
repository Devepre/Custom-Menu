//
//  SKVSideMenuManager.m
//  Custom Menu
//
//  Created by Limitation on 8/12/18.
//  Copyright © 2018 Limitation. All rights reserved.
//

#import "SKVSideMenuManager.h"

@implementation SKVSideMenuManager

+ (SKVSideMenuManager *)sharedManager {
    static SKVSideMenuManager *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[SKVSideMenuManager alloc] init];
    });
    
    return sharedInstance;
}


@end
