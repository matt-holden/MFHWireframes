# MFHWireframes

##Context-specific data and decisionmaking for iOS View Controllers.

One of the many trouble-makers leading to the dreaded "Massive View Controller" is the intimiate knowledge that each View Controller tends to have about its neighbors.  

When we try to reuse a ViewController in more than one context within our app, or present a View Controller via varying workflows, we start cluttering the public interface with flag properties like `@property (nonatomic) CurrentAppMode *howDidWeGetHere`.

When ViewControllerA wants to present ViewControllerB, ViewControllerA has to know *exactly* how to create and configure ViewControllerB.

That works for a time, but it breaks apart when we want to introduce ViewControllerC, and place it sequentially before we show ViewControllerB?  Normally, we'd have to rip our "B" code out of "A", replacing it with code to create and show "C." And of course, we have to modify "C" with instructions to create and show "B."

This tight coupling tends to cause more and more headaches as new
application requirements are introduced.

##...Enter Wireframes

"Wireframes" is a term borrowed from the description in the [VIPER pattern](http://mutualmobile.github.io/blog/2013/12/04/viper-introduction/), although the implementations are very different.

####Read these before you tl;dr;

1. MFHWireframes introduces just one class, `MFHWireframe`, which can be used as-is or subclassed.
2. MFHWireframes adds a category method on UIViewController: `-[UIViewController wireframe]`. 
    - If `wireframe` collides with existing properties on your view controllers, just redefine it in your prefix header with:  
    `#define MFH_WIREFRAME_ACCESSOR_SELECTOR myBetterName`
3. The base `MFHWireframe` wraps a **thread safe** mutable dictionary whose properties can be set via object subscripting notation.


## Basic Usage

```objc
// SomeViewController.m

- (void)viewDidLoad
{
  // Create the wireframe.
  MFHWireframe *wireframe = [[MFHWireframe alloc] init];

  // Attach it to the current view controller. 
  // The view controller retains the wireframe, when the view controller is deallocated
  // the wireframe will be released, too.
  [wireframe attachToViewController:nextVc];
}

// Some arbitrary event handler...
- (void)continueTapped:(id)sender 
{
  // Create your next view controller
  NextViewController *nextVc = [[MyViewController alloc] init.....];

  // Attach the current wireframe available via category extension at `[self wireframe]`
  [self.wireframe attachToViewController:nextVc];

  // Store arbitrary information in the wireframe.
  wireframe[@"someKey"] = @"someValue";

  // Show your new ViewController however you'd like:
  [self.navigationController pushViewController:vc animated:YES];
}


// NextViewController.m

// Note that the wireframe created and attached `SomeViewController` is now available
// to use inside NextViewController, via `-[self wireframe]`
- (void)viewDidLoad
{

  // Access information stored in the backing dictionary...
  self.wireframe[@"someKey"];  // @"someValue"
}
```

## More interesting usage with subclasses

Wireframe subclasses are a great place to delegate the decisionmaking
and transition logic that has previously tightly coupled two view
controllers:

```objc
// MyWireframe.m

@interface MyWireframe : MFHWireframe
- (void)viewControllerDidRequestNextStep:(UIViewController*)viewController
@end
@implementation MyWireframe 
- (void)viewControllerDidRequestNextStep:(UIViewController*)viewController
{
  UIViewController *nextViewController;

  if ([self[@"ShowIntro"] isEqualToNumber:@YES]) {
    nextViewController = [[IntroViewController alloc] init...];
  }
  else {
    nextViewController = [[AppViewController alloc] init...];
  }

  [self attachToViewController:nextVC];

  [viewController.navigationController pushViewController:nextViewController animated:YES];
}
@end

// SomeViewController.m

- (void)continueTapped:(id)sender 
{
  [self.wireframe viewControllerDidRequestNextStep:self];
}
```

## Wireframe branches

A wireframe can 'branch' from another wireframe, such that the branched
wireframe keeps a weak reference to the parent.  

If a client requests the object for `key` that has not been yet been stored in the 
backing dictionary, parent wireframe(s) are searched recursively to the topmost parent
until it finds an object stored at `key`.

```objc
MFHWireframe *firstWireframe = [[MFHWireframe alloc] init];
MFHWireframe *childWireframe = [[MFHWireframe alloc] initBranchedWireframeFromWireframe:firstWireframe];

// Set something on the parent wireframe:
firstWireframe[@"ABC"]  = @123;

// Retrieve this value via the child wireframe:
NSLog(@"%@", childWireframe[@"ABC"]); // @123;

// Set a different value on the child wireframe:
childWireframe[@"ABC"] = @456;

NSLog(@"%@", firstWireframe[@"ABC"]); // @123
NSLog(@"%@", childWireframe[@"ABC"]); // @456;

```

## Check it out

To run the example project; clone the repo, and run `pod install` from the Example directory first.

## Installation

MFHWireframes is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "MFHWireframes"

## Author

Matthew Holden, @MFHolden	

## License

MFHWireframes is available under the MIT license. See the LICENSE file for more info.

