/*
 * COPYRIGHT © 2019 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>
#import "YSAdvert.h"
#import "YSAdManagement.h"

/** The YSAdBreak protocol provides an interface to an ad break, whose details are passed as a payload during analytic callbacks.
 
 */
@protocol YSAdBreak <NSObject>

/** Returns the ad break identifier.
 
 @return The ad break identifier.
 @since from 1.0
 */
- (NSString* _Nonnull) adBreakIdentifier;

/** Returns the ad break description.
 
 @return The ad break description.
 @since from 1.0
 */
- (NSString* _Nonnull) adBreakDescription;

/** Returns the ad Break start position.
 
 @return The ad Break start position.
 @since from 1.0
 */
- (NSTimeInterval) adBreakStart;

/** Returns the ad Break end position.
 
 @return The ad Break end position.
 @since from 1.0
 */
- (NSTimeInterval) adBreakEnd;

/** Returns the ad Break end position.
 
 @return The ad Break duration.
 @since from 1.3
 */
- (NSTimeInterval) adBreakDuration;

/** Returns the media position within the stream, one of pre-, mid- or post-roll
 
 @return The media position within the stream.
 @since from 1.0
 */
- (YSEAdBreakPosition) adBreakPosition;

/** Returns an array of adverts associated with this media.
 
 @return An array of YSAdvert objects.
 @since from 1.0
 */
- (NSArray* _Nonnull) adverts;

/** Returns whether the ad break is active or inactive. If it is active, any action or policy associated with the ad break will occur between the start and end time.
 
 @return YES if the ad break is active, NO otherwise.
 @since from 1.0
 */
- (BOOL) isAdBreakActive;

/** Sets the ad break as active or inactive. If it is active, any action or policy associated with the ad break will occur between the start and end time.
 
 @param active `YES` if the ad break should be set active, `NO` otherwise
 @since from 1.0
 */
- (void) setAdBreakActive:(BOOL)active;

@end
