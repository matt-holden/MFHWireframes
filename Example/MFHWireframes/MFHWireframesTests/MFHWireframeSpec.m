//
//  MFHWireframeSpec.m
//  MFHWireframes
//
//  Created by Matthew Holden on 4/30/14.
//  Copyright 2014 Matt Holden. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <MFHWireframes/MFHWireframe.h>


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

    context(@"can set and retrieve arbitrary values", ^{

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
