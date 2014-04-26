//
//  NewFeaturesTourViewController.m
//  MFHWireframes
//
//  Created by Matthew Holden on 4/27/14.
//  Copyright (c) 2014 Matt Holden. All rights reserved.
//

#import "NewFeaturesTourViewController.h"
#import "IntroSequenceWireframe.h"

@interface NewFeaturesTourViewController ()

@end

@implementation NewFeaturesTourViewController


- (IBAction)continueTapped:(id)sender {
    IntroSequenceWireframe *wireframe = (id)self.wireframe;

    [wireframe viewControllerDidRequestNextStep:self];
}

@end
