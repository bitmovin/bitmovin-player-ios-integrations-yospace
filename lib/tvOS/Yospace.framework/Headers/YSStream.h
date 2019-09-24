/*
 * COPYRIGHT © 2019 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
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
 
 @return The stream window end if in Live Pause mode, or 0 if in any other mode.
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

/** Provides a relative content playhead position to the client, discounting the sum of all ad break
 durations prior to the absolute playhead position provided. This allows the client to return
 to the same content position if a nonlinear stream is stopped before playback ends.
 
 @return for nonlinear playback, the relative content position for a given absolute playhead position.
            For live playback this method returns zero.
 @see [playheadForContentPosition:]([YSStream playheadForContentPosition:])
 @since from 1.9
 */
- (NSTimeInterval) contentPositionForPlayhead:(NSTimeInterval)playhead;

/** Provides an absolute playhead position to the client calculating the sum of all ad break durations
 prior to that absolute playhead position plus the relative content playhead position.
 This allows the client to return to the same content position if a nonlinear stream is stopped
 before playback ends.
 
 @return for nonlinear playback, the absolute playhead position for any given relative content position.
         For live playback this method returns zero.
 @see [contentPositionForPlayhead:]([YSStream contentPositionForPlayhead:])
 @since from 1.9
 */
- (NSTimeInterval) playheadForContentPosition:(NSTimeInterval)position;

/** Sets all adverts inactive in all ad breaks prior to the given playhead position. If the playhead
 is within an advert then that advert is NOT marked as inactive. This method allows client applications
 to seek to a position before playback begins. This method has no effect for linear playback.
 @see [setAdvertActive:]([YSAdvert setAdvertActive])
 @since from 1.9
 */
- (void) setAdBreaksInactivePriorTo:(NSTimeInterval) playhead;

@end
