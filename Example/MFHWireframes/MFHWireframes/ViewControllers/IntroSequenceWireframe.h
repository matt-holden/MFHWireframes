//
//  IntroSequenceWireframe.h
//  MFHWireframes
//
//  Created by Matthew Holden on 4/27/14.
//  Copyright (c) 2014 Matt Holden. All rights reserved.
//

#import <MFHWireframes/MFHWireframe.h>

@interface IntroSequenceWireframe : MFHWireframe

@property (nonatomic, getter = isFirstTimeUser) BOOL firstTimeUser;
- (void)viewControllerDidRequestNextStep:(UIViewController*)viewController;

@end
