/*
 * COPYRIGHT © 2018 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>
#import "YSLinearCreative.h"
#import "YSUIProperties.h"
#import "YSPricing.h"

/** The YSAdvert protocol provides an interface to an advert object, whose details are passed as a payload during analytic callbacks.
 
 */
@protocol YSAdvert <NSObject>

/** Returns the advert identifier.
 
 @return The advert identifier.
 @since from 1.0
 */
- (NSString* _Nonnull) advertIdentifier;

/** Returns the value of an advert property. Supports: `Description`, `sequence`, `AdSystem`, `AdTitle`,
    `Advertiser`, `Survey` and `Extensions`. If extension data is present for this advert, a
    string representing the opaque block of text between the `&lt;Extensions&gt;` tag is returned.
 
 @param property A string representation of the VAST advert property
 @return The value associated with the advert property, or empty if the property is not present.
 @since from 1.0
 */
- (NSString* _Nullable) advertProperty:(NSString* _Nonnull)property;

/** Returns the advert start position.
 
 @return The advert start position.
 @since from 1.0
 */
- (NSTimeInterval) advertStart;

/** Returns the advert end position.
 
 @return The advert end position.
 @since from 1.0
 */
- (NSTimeInterval) advertEnd;

/** Returns the advert duration.
 
 @return The advert duration.
 @since from 1.3
 */
- (NSTimeInterval) advertDuration;

/** Returns a reference to the advert user interface properties.
 
 @return The user interface properties.
 @since from 1.0
 */
- (id<YSUIProperties> _Nullable) userInterfaceProperties;

/** Returns a dictionary of impressions associated with this advert.
 
 @return A dictionary of impression URLs, keyed on the impression Id.
 @since from 1.0
 */
- (NSDictionary* _Nullable) impressions;

/** Returns an object representing the Pricing for this YSAdvert.
 
 @return A protocol representing the Pricing object, or null if none exists.
 @since from 1.0
 */
- (id<YSPricing> _Nullable) advertPricing;

/** Returns the linear creative associated with this advert.
 
 @return The linear creative.
 @since from 1.0
 */
- (id<YSLinearCreative> _Nonnull) linearCreativeElement;

/** Returns whether the advert's linear creative has an interactive unit.
 
 @return `YES` if the linear creative has an interactive unit, `NO` otherwise.
 @since from 1.4
 */
- (BOOL) hasLinearInteractiveUnit;

/** Returns an array of nonlinear creatives associated with this advert.
 
 @return An array of nonlinear creatives.
 @since from 1.0
 */
- (NSArray* _Nullable) nonlinearCreativeElements;

/** Returns whether the advert is filler.
 
 @return `YES` if the advert is filler, `NO` otherwise.
 @since from 1.3
 */
- (BOOL) isFiller;

/** Returns whether the advert is active or inactive. If it is active, any action or policy associated with the advert will occur between the start and end time.
 
 @return `YES` if the advert is active, `NO` otherwise.
 @since from 1.0
 */
- (BOOL) isAdvertActive;

/** Sets the advert as active or inactive. If it is active, any action or policy associated with the advert will occur between the start and end time.
 
 @param active `YES` if the advert should be set active, `NO` otherwise
 @since from 1.0
 */
- (void) setAdvertActive:(BOOL)active;

@end
