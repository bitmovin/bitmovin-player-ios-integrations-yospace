/*
 * COPYRIGHT © 2018 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>
#import "YSAdManagement.h"

/** The YSTrackingEvent protocol provides an interface to a VAST time-based or non-time-based tracking event.
 */
@protocol YSTrackingEvent <NSObject>

/** Returns the identifier of the advert that this tracking event belongs to.<br/>
 
 @return the advert identifier.
 @since from 1.3
 */
- (NSString* _Nullable) advertIdentifier;

/** Returns the tracking event URL.
 
 @return The tracking event URL.
 @since from 1.3
 */
- (NSURL* _Nonnull) eventURL;

/** Returns the tracking event type.
 
 @return The YSETrackingEvent type.
 @since from 1.3
 */
- (YSETrackingEvent) eventTrackingType;

/** Returns the timestamp of this event as an offset from it's advert start position.
 
 @return an NSTimeInterval that is the event offset from the advert start position.
 @since from 1.3
 */
- (NSTimeInterval) eventTimestamp;

@end
