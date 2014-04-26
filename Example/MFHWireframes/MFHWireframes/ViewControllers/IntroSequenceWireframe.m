//
//  IntroSequenceWireframe.m
//  MFHWireframes
//
//  Created by Matthew Holden on 4/27/14.
//  Copyright (c) 2014 Matt Holden. All rights reserved.
//

#import "IntroSequenceWireframe.h"
#import "LandingScreenViewController.h"
#import "NewFeaturesTourViewController.h"
#import "RestOfMyAppViewController.h"

@implementation IntroSequenceWireframe

- (void)viewControllerDidRequestNextStep:(UIViewController*)requestingViewController
{
    UIViewController *nextViewController;

    if ([requestingViewController isKindOfClass:[LandingScreenViewController class]]
        && [self isFirstTimeUser]) {
        nextViewController = [NewFeaturesTourViewController new];
    }
    else {
        nextViewController = [RestOfMyAppViewController new];
    }

    [self attachToViewController:nextViewController];
    [requestingViewController.navigationController pushViewController:nextViewController animated:YES];
}

@end
