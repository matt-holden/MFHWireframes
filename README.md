# MFHWireframes

##Context-specific data and decisionmaking for iOS View Controllers.

One of the many trouble-makers leading to the dreaded "Massive View Controller," is the intimiate knowledge that each View Controller tends to have about others.  When we start to reuse a ViewController in more than one part of our app, or present a View Controller via varying workflows, we started cluttering the public interface with flag properties like `@property (nonatomic) HowDidWeGetHere *howDidWeGetHere`. When ViewControllerA wants to present ViewControllerB, ViewControllerA has to know *exactly* how to create and configure ViewControllerB.

What happens when we want to introduce ViewControllerC, and place is
sequentially before ViewControllerB?  We'd have to rip our
"B" code out of "A", and replace it with code to create and show "C,"
and modify "C" with instructions to create and show "B."

This tight coupling tends to cause more and more headaches as new
application requirements are introduced.

##...Enter Wireframes

"Wireframes" is a term borrowed from the description in the [VIPER pattern](http://mutualmobile.github.io/blog/2013/12/04/viper-introduction/), although the implementations are very different.

####Read these before you tl;dr;

1. MFHWireframes provides a single class, `MFHWireframe`, which can be used as-is or subclassed.
2. MFHWireframes adds a category on UIViewController to introduce a `-[UIViewController wireframe]` accessor method.
    - If `wireframe` collides with existing properties on your view controllers, just redefine it in your prefix header with:  
    `#define MFH_WIREFRAME_ACCESSOR_SELECTOR myBetterName`


####Features





## Usage

To run the example project; clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

MFHWireframes is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "MFHWireframes"

## Author

Matthew Holden, @MFHolden	

## License

MFHWireframes is available under the MIT license. See the LICENSE file for more info.

