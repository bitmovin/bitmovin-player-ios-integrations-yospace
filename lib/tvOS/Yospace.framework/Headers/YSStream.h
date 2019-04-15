/*
 * COPYRIGHT © 2018 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>
#import "YSAdManagement.h"

/** The YSStream protocol provides an interface to a live, Non-Linear Start Over or VOD stream, whose details are passed as a payload during analytic callbacks.
 
 */
@protocol YSStream <NSObject>

/** Returns the stream identifier.
 
 @return The stream identifier.
 @since from 1.0
 */
- (NSString* _Nonnull) streamIdentifier;

/** Returns the playback mode of the stream.
 
 @return The playback mode of the stream.
 @since from 1.6
 */
- (YSEPlaybackMode) playbackMode;

/** Returns the (program date time) start point of a Live Pause stream.
 
 @return The stream start if in Live Pause mode, or nil if in any other mode.
 @since from 1.6
 */
- (NSDate* _Nullable) streamStart;

/** Returns the window start point of a Live pause stream relative to the streamStart.
 
 @return The stream window start if in Live Pause mode, or 0 if in any other mode.
 @since from 1.6
 */
- (NSTimeInterval) streamWindowStart;

/** Returns the window end point of a Live Pause stream releative to the streamStart.
 
 @return The stream window start if in Live Pause mode, or 0 if in any other mode.
 @since from 1.6
 */
- (NSTimeInterval) streamWindowEnd;

/** Returns the window duration of a Live Pause stream.
 
 @return The stream window duration if in Live Pause mode, or 0 if in any other mode.
 @since from 1.6
 */
- (NSTimeInterval) streamWindowSize;

/** Returns the duration of the stream, or current playlength in the case of live or live pause.
 
 @return The stream duration.
 @since from 1.0
 */
- (NSTimeInterval) streamDuration;

/** Returns the stream source.
 
 @return The stream source.
 @since from 1.0
 */
- (NSURL* _Nonnull) streamSource;

/** If the stream is LivePause, VoD or vLive, returns the timeline as an array of YSAdBreak objects, or nil if the stream is live.
 
 @return Array of YSAdBreak objects, or nil.
 @since from 1.6
 @see YSAdBreak
 */
- (NSArray* _Nullable) timeline;

/** Returns whether this stream is the failover Url.
 
 @return YES if the source is the failover Url, NO otherwise.
 @since from 1.0
 */
- (BOOL) isFailover;

/** Returns whether this stream has pre-roll adverts.
  Note that for a live stream with a pre-roll, this will only return `YES`
  when the event [YSAnalyticObserver advertBreakDidStart:] is raised, and not before.
 
 @return YES if the stream has pre-roll adverts, NO otherwise.
 @since from 1.0
 */
- (BOOL) hasPrerollAdBreak;

/** Returns whether this stream has post-roll adverts. Not relevant for a live stream.
 
 @return YES if the stream has post-roll adverts, NO otherwise.
 @since from 1.0
 */
- (BOOL) hasPostrollAdBreak;

@end
