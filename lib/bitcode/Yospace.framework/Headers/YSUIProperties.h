/*
 * COPYRIGHT © 2018 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** The YSUIProperties protocol provides an interface to user interface properties associated with the parent object - usually a media object on the stream timeline from which it was obtained.
 
 */
@protocol YSUIProperties <NSObject>

/** Returns whether the element that this object refers to is hidden.
 
 @return YES if the object is hidden, NO otherwise.
 @since from 1.0
 */
- (BOOL) isHidden;

/** Returns whether the element that this object refers to is scalable.
 
 @return YES if the object is scalable, NO otherwise.
 @since from 1.0
 */
- (BOOL) isScalable;

/** Returns whether the element that this object refers to maintains its aspect ratio.
 
 @return YES if the object maintains its aspect ratio, NO otherwise.
 @since from 1.0
 */
- (BOOL) maintainAspectRatio;

/** Returns the colour of the element that this object refers to.
 
 @return The object's colour.
 @since from 1.0
 */
- (UIColor* _Nullable) colour;

/** Returns the opacity of the element that this object refers to.
 
 @return The object's opacity.
 @since from 1.0
 */
- (float) opacity;

/** Returns the bounding rectangle of the element that this object refers to.
 
 @return The object's bounding rectangle.
 @since from 1.0
 */
- (CGRect) rect;

/** Returns the expanded width of the element that this object refers to.
 
 @return The object's expanded width.
 @since from 1.2
 */
- (NSInteger) expandedWidth;

/** Returns the expanded height of the element that this object refers to.
 
 @return The object's expanded height.
 @since from 1.2
 */
- (NSInteger) expandedHeight;

@end
