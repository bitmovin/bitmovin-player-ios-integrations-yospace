/*
 * COPYRIGHT © 2019 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>
#import "YSAdManagement.h"
#import "YSUIProperties.h"
#import "YSXmlNode.h"

/** The YSNonLinearCreative protocol provides an interface to an advert's non-linear creative object - if VAST is associated with the advert, and whose details are passed as a payload during analytic callbacks. There may be zero or more non-linear creatives associated with an advert.
 
 */
@protocol YSNonLinearCreative <NSObject>

/** Returns the nonlinear creative's identifier. This is the `id` attribute of the `<NonLinear>`.
 
 @return The identifier, or nil.
 @since from 1.0
 */
- (NSString* _Nullable) nonlinearIdentifier;

/** Returns the creative's identifier.  This is the `id` attribute of the `<Creative>`.
 
 @return The identifier, or nil.
 @since from 1.12
 */
- (NSString* _Nullable) creativeIdentifier;

/** Returns the nonlinear creative's sequence number.
 
 @return The sequence identifier.
 @since from 1.0
 */
- (NSString* _Nullable) nonlinearSequenceIdentifier;

/** Returns the nonlinear creative's Ad identifier. This is the `AdID` attribute of the `<Creative>`.
 
 @return The Ad identifier, or nil.
 @since from 1.0
 */
- (NSString* _Nullable) nonlinearAdIdentifier;

/** Returns the nonlinear creative's clickthrough URL.
 
 @return The clickthrough URL, or nil.
 @since from 1.0
 */
- (NSURL* _Nullable) nonlinearClickthroughURL;

/** Returns the nonlinear creative's source URL.
 
 @return The source URL.
 @since from 1.0
 */
- (NSURL* _Nonnull) creativeSource;

/** Returns the nonlinear creative's pre-loaded resource, if pre-loading of VAST resources are enabled
 for this type. Pre-loading policy is defined in YSSessionProperties.
 
 @return The pre-loaded resource as an NSData or nil.
 @since from 1.0
 */
- (NSData* _Nullable) creativeElement;

/** Returns the nonlinear creative's user interface properties.
 
 @return The user interface properties.
 @since from 1.0
 */
- (id<YSUIProperties> _Nonnull) userInterfaceProperties;

/** Returns the minimum duration that the nonlinear creative should be displayed for.
 
 @return The minimum duration.
 @since from 1.0
 */
- (NSTimeInterval) minimumSuggestedDuration;

/** Returns the MIME type of the nonlinear creative's source.
 
 @return The MIME type.
 @since from 1.0
 */
- (NSString* _Nonnull) creativeMIMEType;

/** Returns any adParameters associated with this nonlinear creative.<br/>
 Note that the string is always XML encoded.
 
 @return adParameters associated with this nonlinear creative, or nil.
 @since from 1.2
 */
- (NSString* _Nullable) nonlinearAdParameters;

/** Returns the API Framework used by this nonlinear creative, or nil if there is none.<br/>
 
 @return The API framework used this nonlinear creative, or nil.
 @since from 1.4
 */
- (NSString* _Nullable) nonlinearAPIFramework;

/** If this nonlinear creative is an interactive unit, returns an array of VAST tracking events for this creative.
 
 @return An array of YSTrackingEvent objects, or nil.
 @since from 1.3
 */
- (NSArray* _Nullable) trackingEvents;

/** Returns any nonlinear creative extension data or nil if there is none.

@return A YSXmlNode representing the <Extensions> element. Children of this object represent the extension data
@see YSXmlNode
@since from 1.9
*/
- (id<YSXmlNode> _Nullable) nonlinearExtensions;

@end
