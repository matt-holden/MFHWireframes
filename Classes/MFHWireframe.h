//
//  MFHWireframe.h
//  
//
//  Created by Matthew Holden on 4/25/14.
//
//

#import <Foundation/Foundation.h>


// Let our users choose something less-intrusive if 'wireframe'
// is already a property on one of their ViewControllers.
// Just add
#ifndef MFH_WIREFRAME_ACCESSOR_SELECTOR
#define MFH_WIREFRAME_ACCESSOR_SELECTOR wireframe
#endif

@class MFHWireframe;
@interface UIViewController(MFHWireframe)
/**
 Extends UIViewController to support
 strongly retaining a reference to an MFHWireframe,
 and exposing that MFHWireframe via the added MFH_WIREFRAME_ACCESSOR_SELECTOR property
 */
- (MFHWireframe*)MFH_WIREFRAME_ACCESSOR_SELECTOR;

/**
 Returns the first wireframe in the receiver's wireframe hierarchy matching 'wireframeClass'

 @param includeSelf - If YES, the receiver will be tested for first before looking at parent nodes
 @notes the search starts with the receiver and recursively searches UP the tree
 @important This algorithm uses `isMemberOfClass` for its test, not `isKindOfClass`
 */
- (MFHWireframe*)wireframeInHierarchyOfClass:(Class)wireframeClass includeSelf:(BOOL)includeSelf;

/**
 Returns the first wireframe in the receiver's wireframe hierarchy conforming to 'wireframeProtocol'

 @param includeSelf - If YES, the receiver will be tested for first before looking at parent nodes
 @notes the search starts with the receiver and recursively searches UP the tree
 */
- (MFHWireframe*)wireframeInHierarchyConformingToProtocol:(Protocol*)wireframeProtocol includeSelf:(BOOL)includeSelf;
@end



@interface MFHWireframe : NSObject

- (__weak MFHWireframe*)parentWireframe;

/** Create a wireframe that keeps a weak reference to the wireframe it was forked from */
- (id)initWireframeBranchedFromWireframe:(__weak MFHWireframe*)parentWireframe;

/** The view controller will keep a strong reference to the receiver,
 but the receiver will have a weak reference to the viewController */
- (void)attachToViewController:(UIViewController*)viewController;

/** Retrieve an arbitrary object stored on the wireframe, optionally searching
 for this value through parent wireframes until a value is found */
- (id)objectForKeyIgnoringParentWireframes:(NSString*)key;
- (id)objectForKey:(id<NSCopying>)key;

/** Return the value stroed at `key` in this wireframe, scanning its parent until a value is found */
- (id)objectForKeyedSubscript:(id<NSCopying>)key;

/** Store an object at `key`. If a parent wireframe store a value at this same key,
 calls to `objectForKey` on the receiver will return the value you set here, effectively 
 hiding the parent wireframe's value */
- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key;

- (void)setObject:(id)obj forKey:(id<NSCopying>)key;

/** Remove the object stored at `key` */
- (void)removeObjectForKey:(id<NSCopying>)key;
@end