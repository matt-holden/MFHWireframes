//
//  MFHWireframeSpec.m
//  MFHWireframes
//
//  Created by Matthew Holden on 4/30/14.
//  Copyright 2014 Matt Holden. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <MFHWireframes/MFHWireframe.h>

/** dummy protocol for specs */
@protocol MFHSomeProtocol1 <NSObject>
@end
/** dummy protocol for specs */
@protocol MFHSomeProtocol2 <NSObject>
@end

/** dummy subclass for specs */
@interface MFHWireframeSubclass1 : MFHWireframe <MFHSomeProtocol1>
@end
@implementation MFHWireframeSubclass1
@end

/** dummy subclass for specs */
@interface MFHWireframeSubclass2 : MFHWireframe <MFHSomeProtocol2>
@end
@implementation MFHWireframeSubclass2
@end


SPEC_BEGIN(MFHWireframeSpec)

describe(@"MFHWireframe", ^{
    __block MFHWireframe *wf;
    __block UIViewController *vc;

    beforeEach(^{
        vc = [UIViewController new];
        wf = [MFHWireframe new];
        [wf attachToViewController:vc];
    });

    context(@"the viewcontroller", ^{
        it(@"should access the wireframe via the value of the wireframe property", ^{
            id obj = [vc wireframe];
            [[theValue(obj == wf) should] beYes];
        });
    });

    context(@"can set, and retrieve remove arbitrary values", ^{

        specify(^{
            [wf setObject:@"bar" forKey:@"foo"];
            [[[wf objectForKey:@"foo"] should] equal:@"bar"];
        });

        it(@"should be readable via object subscripting", ^{
            [wf setObject:@"bar" forKey:@"foo"];
            [[wf[@"foo"] should] equal:@"bar"];
        });

        it(@"should be writeable via object subscripting", ^{
            wf[@"foo"] = @"bar";
            [[wf[@"foo"] should] equal:@"bar"];
        });

        it(@"should remove an object when asked to", ^{
            wf[@"key"] = @"value";
            [[wf[@"key"] should] equal:@"value"];
            [wf removeObjectForKey:@"key"];
            [[wf[@"key"] should] beNil];
        });
    });

    context(@"when branching from another wireframe", ^{
        __block MFHWireframe *branchedWireframe;
        __block UIViewController *vc2;

        beforeEach(^{
            vc2 = [UIViewController new];
            branchedWireframe = [[MFHWireframe alloc] initWireframeBranchedFromWireframe:wf];
            [branchedWireframe attachToViewController:vc2];
        });

        it(@"should have a reference to the parent wireframe", ^{
            [[branchedWireframe.parentWireframe should] equal:wf];
        });

        it(@"should be attached to the second ViewController", ^{
            [[branchedWireframe should] equal:vc2.wireframe];
        });

        it(@"should have a reference to the parent wireframe", ^{
            [[[branchedWireframe parentWireframe] should] equal:wf];
        });

        context(@"when looking for parent wireframes: %@", ^{
            __block MFHWireframe          *rootWireframe;
            __block MFHWireframeSubclass1 *subclass1Wireframe;
            __block MFHWireframeSubclass2 *subclass2Wireframe;
            __block UIViewController     *someVC;
            beforeEach(^{
                rootWireframe = [MFHWireframe new];
                subclass1Wireframe = [[MFHWireframeSubclass1 alloc] initWireframeBranchedFromWireframe:rootWireframe];
                subclass2Wireframe = [[MFHWireframeSubclass2 alloc] initWireframeBranchedFromWireframe:subclass1Wireframe];

                someVC = [UIViewController new];
                [subclass2Wireframe attachToViewController:someVC];
            });
            it(@"should provide access to itself or a parent wireframes matching a class in the WF hierarchy", ^{
                // Should look all the way to the top, since we use 'memberOfClass'
                [[[someVC wireframeInHierarchyOfClass:[MFHWireframe class] includeSelf:YES] should] equal:rootWireframe];

                // Should only have to look up one level
                [[[someVC wireframeInHierarchyOfClass:[MFHWireframeSubclass1 class] includeSelf:YES] should] equal:subclass1Wireframe];

                // Should return its own wireframe
                [[[someVC wireframeInHierarchyOfClass:[MFHWireframeSubclass2 class] includeSelf:YES] should] equal:subclass2Wireframe];

                // Sanity check, this test should be equivalent to the one above it
                [[[someVC wireframeInHierarchyOfClass:[MFHWireframeSubclass2 class] includeSelf:YES] should] equal:someVC.wireframe];
            });

            context(@"should provide access to itself or a parent wireframes matching a protocol in the WF hierarchy", ^{
                // Should look all the way to the top, since we use 'memberOfClass'
                it(@"should return nil if no match is found", ^{
                    [[[someVC wireframeInHierarchyConformingToProtocol:@protocol(UITableViewDelegate) includeSelf:YES] should] beNil];
                });

                it(@"should return the appropriate wireframe if a match is found", ^{
                    //MFHWireframeSubclass1 conforms to MFHSomeProtocol1 (see top of spec file)
                    [[[someVC wireframeInHierarchyConformingToProtocol:@protocol(MFHSomeProtocol1) includeSelf:YES] should] equal:subclass1Wireframe];

                    [[[someVC wireframeInHierarchyConformingToProtocol:@protocol(MFHSomeProtocol2) includeSelf:YES] should] equal:subclass2Wireframe];
                });
            });


        });

        context(@"when accessing properties", ^{
            beforeEach(^{
                // Set a property in the parent wireframe
                wf[@"foo"] = @"bar";
            });

            it(@"should look to parent wireframes until it finds a value for a key that it does not store itself", ^{
                [[branchedWireframe[@"foo"] should] equal:@"bar"];
            });

            it(@"should return dictionary values stored on itself, even if that value is present in the parent wireframe's dictionary", ^{
                branchedWireframe[@"foo"] = @"baz";
                [[branchedWireframe[@"foo"] should] equal:@"baz"];
            });
        });

        it(@"should work with many levels of nesting", ^{
            // Sanity check
            NSMutableArray *wireframes = [@[branchedWireframe] mutableCopy];
            MFHWireframe *wireframe;
            for (int i = 0; i < 5; i++) {
                UIViewController *vc = [UIViewController new];
                wireframe = [[MFHWireframe alloc] initWireframeBranchedFromWireframe:[wireframes lastObject]];
                [wireframe attachToViewController:vc];

                if (i == 0) {
                    wireframe[@"hello"] = @"world";
                }

                if (i == 2) {
                    wireframe[@"hello"] = @"how";
                }

                if (i == 4) {
                    wireframe[@"hello"] = @"you";
                }

                [wireframes addObject:wireframe];
            }

            MFHWireframe *lastWireframe = [wireframes lastObject];
            [[lastWireframe[@"hello"] should] equal:@"you"];
        });

    });
});

SPEC_END
