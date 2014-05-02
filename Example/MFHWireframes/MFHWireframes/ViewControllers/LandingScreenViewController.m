//
//  LandingViewController.m
//  MFHWireframes
//
//  Created by Matthew Holden on 4/27/14.
//  Copyright (c) 2014 Matt Holden. All rights reserved.
//

#import "LandingScreenViewController.h"
#import <MFHWireframes/MFHWireframe.h>
#import "IntroSequenceWireframe.h"

@interface LandingScreenViewController ()
@property (nonatomic) IBOutlet UILabel *friendlyMessageLabel;
@end

@implementation LandingScreenViewController

- (IBAction)continueTapped:(id)sender
{
    IntroSequenceWireframe *wireframe = (IntroSequenceWireframe*)self.wireframe;

    [wireframe viewControllerDidRequestNextStep:self];
}

@end
