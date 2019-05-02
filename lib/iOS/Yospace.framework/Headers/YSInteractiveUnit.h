/*
 * COPYRIGHT © 2019 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>
#import "YSAdManagement.h"

/** The YSInteractiveUnit protocol provides an interface to a linear creative's interactive unit, for example a VPAID unit.
 */
@protocol YSInteractiveUnit <NSObject>

/** Returns the interactive unit's source URL.
 
 @return The unit source URL.
 @since from 1.4
 */
- (NSURL* _Nonnull) unitSource;

/** Returns the interactive unit's pre-loaded resource, if pre-loading of VAST resources are enabled
 for this type. Pre-loading policy is defined by the PlayerPolicy component (YPPolicyHandling implementation)
 
 @return The pre-loaded resource or nil.
 @since from 1.4
 */
- (NSData* _Nullable) unitResource;

/** Returns an array of VAST tracking events associated with this interactive unit.
 
 @return An array of YSTrackingEvent objects.
 @since from 1.4
 */
- (NSArray* _Nonnull) trackingEvents;

/** Returns any adParameters associated with this interactive unit.<br/>
 Note that the string is always XML encoded.
 
 @return adParameters associated with this interactive unit.
 @since from 1.4
 */
- (NSString* _Nullable) unitAdParameters;

/** Returns the MIME type of the interactive unit's source.
 
 @return The MIME type.
 @since from 1.4
 */
- (NSString* _Nonnull) unitMIMEType;

/** Returns the API framework in use by this interactive unit.<br/>
 
 @return apiFramework in use by this interactive unit.
 @since from 1.4
 */
- (NSString* _Nullable) unitAPIFramework;

/** Returns the Interactive unit's duration.
 
 @return this interactive unit's duration.
 @since from 1.8
 */
- (NSTimeInterval) unitDuration;

/** Fires a tracking report on behalf of the VPAID, if the event exists in its list of tracking events.
    If the event is time based, it will only be fired once for the VPAID.
 
 @param event the VPAID event to fire
 @since from 1.7
 */
- (void) trackingEventDidOccur:(YSETrackingEvent)event;

@end
