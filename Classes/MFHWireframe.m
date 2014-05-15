//
//  MFHWireframe.m
//  
//
//  Created by Matthew Holden on 4/25/14.
//
//

#import <MFHWireframes/MFHWireframe.h>
#import <objc/runtime.h>

// 
static char kMFHWireframeViewControllerAssociationKey;
@interface UIViewController(MFHWireframe_Private)
- (void)attachWireframe:(MFHWireframe*)wireframe;
@end
@implementation UIViewController(MFHWireframe)
-(void)attachWireframe:(MFHWireframe *)wireframe
{
    objc_setAssociatedObject(self, &kMFHWireframeViewControllerAssociationKey, wireframe, OBJC_ASSOCIATION_RETAIN);
}
-(MFHWireframe*)MFH_WIREFRAME_ACCESSOR_SELECTOR
{
    return objc_getAssociatedObject(self, &kMFHWireframeViewControllerAssociationKey);
}

-(MFHWireframe*)wireframeOrParentWireframeOfClass:(Class)wireframeClass
{
    MFHWireframe *node = [self MFH_WIREFRAME_ACCESSOR_SELECTOR];
    while (node) {
        if ([node isKindOfClass:wireframeClass])
            return node;

        // TODO implement check for infinite loop (use algorithm for
        // finding loops in a linked list).
        // If a loop is found, AND the main iterator has
        // cycled through one full time, return nil with a warning
        node = [node parentWireframe];
    }

    return nil;
}

MFHWireframe * wireframePassingTest(MFHWireframe *startingNode, BOOL(^predicate)(MFHWireframe *wireframe)) {
    MFHWireframe *node = startingNode;
    while (node) {
        if (predicate(node))
            return node;

        // TODO implement check for infinite loop (use algorithm for
        // finding loops in a linked list).
        // If a loop is found, AND the main iterator has
        // cycled through one full time, return nil with a warning
        node = [node parentWireframe];
    }
    return node;
}

- (MFHWireframe*)wireframeInHierarchyOfClass:(Class)wireframeClass includeSelf:(BOOL)includeSelf
{
    MFHWireframe *node = [self MFH_WIREFRAME_ACCESSOR_SELECTOR];
    if (!includeSelf)
        node = [node parentWireframe];

    MFHWireframe *wf = wireframePassingTest(node, ^BOOL(MFHWireframe* wf){
        return [wf isMemberOfClass:wireframeClass];
    });

    return wf;
}

- (MFHWireframe*)wireframeInHierarchyOfClassOrSubclass:(Class)wireframeClass includeSelf:(BOOL)includeSelf
{
    MFHWireframe *node = [self MFH_WIREFRAME_ACCESSOR_SELECTOR];
    if (!includeSelf)
        node = [node parentWireframe];

    MFHWireframe *wf = wireframePassingTest(node, ^BOOL(MFHWireframe* wf){
        return [wf isKindOfClass:wireframeClass];
    });

    return wf;
}

- (MFHWireframe*)wireframeInHierarchyConformingToProtocol:(Protocol*)wireframeProtocol includeSelf:(BOOL)includeSelf
{
    MFHWireframe *node = [self MFH_WIREFRAME_ACCESSOR_SELECTOR];
    if (!includeSelf)
        node = [node parentWireframe];

    MFHWireframe *wf = wireframePassingTest(node, ^BOOL(MFHWireframe* wf){
        return [wf conformsToProtocol:wireframeProtocol];
    });

    return wf;
}

@end



@interface MFHWireframe() {
    __weak MFHWireframe     *parentWireframe_;
    NSMutableDictionary     *dictionary_;
}
@end

@implementation MFHWireframe

static dispatch_queue_t wireframe_dictionary_access_queue_;
+ (void)initialize
{
    const char * dispatchLabel = "MFH_WIREFRAME_DICTIONARY_ACCESS_QUEUE";
    wireframe_dictionary_access_queue_ = dispatch_queue_create(dispatchLabel, DISPATCH_QUEUE_CONCURRENT);
}

- (__weak MFHWireframe*)parentWireframe
{
    return parentWireframe_;
}

- (id)init
{
    self = [super init];
    self->dictionary_ = [NSMutableDictionary new];
    return self;
}

- (id)initWireframeBranchedFromWireframe:(MFHWireframe*)parentWireframe
{
    NSParameterAssert(parentWireframe);

    self = [self init];
    self->parentWireframe_ = parentWireframe;
    return self;
}

- (void)attachToViewController:(UIViewController*)viewController
{
    [viewController attachWireframe:self];
}

/** Retrieve an arbitrary object stored on the wireframe, optionally searching
 for this value through parent wireframes until a value is found */
- (id)objectForKeyIgnoringParentWireframes:(NSString*)key
{
    __block id obj;
    dispatch_sync(wireframe_dictionary_access_queue_, ^{
        obj = self->dictionary_[key];
    });
    return obj;
}


- (id)objectForKey:(id <NSCopying>)key
{
    __block id obj;
    MFHWireframe *wireframe = self;
    while (!obj && wireframe) {
        dispatch_sync(wireframe_dictionary_access_queue_, ^{
            obj = wireframe->dictionary_[key];
        });
        wireframe = wireframe->parentWireframe_;
    }
    return obj;
}

/** Return the value stroed at `key` in this wireframe, scanning its parent until a value is found */
- (id)objectForKeyedSubscript:(id <NSCopying>)key
{
    return [self objectForKey:key];
}

/** Store an object at `key`. If a parent wireframe store a value at this same key,
 calls to `objectForKey` on the receiver will return the value you set here, effectively 
 hiding the parent wireframe's value */
- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key
{
    [self setObject:obj forKey:key];
}

- (void)setObject:(id)obj forKey:(id<NSCopying>)key
{
    dispatch_barrier_async(wireframe_dictionary_access_queue_, ^{
        [self->dictionary_ setObject:obj forKey:key];
    });
}

- (void)removeObjectForKey:(id<NSCopying>)key
{
    dispatch_barrier_async(wireframe_dictionary_access_queue_, ^{
        [self->dictionary_ removeObjectForKey:key];
    });
}

@end