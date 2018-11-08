/*
 * COPYRIGHT © 2018 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>
#import "YSAdManagement.h"

/** The YPPolicyHandling protocol declares a set of methods to provide playback policy to clients.<br/>
    It is implemented by a policy plugin and policy calls to the Yospace Session Manager are delegated to this plugin.
 */
@protocol YPPolicyHandling <NSObject>

/** Returns to the client whether playback can start.
 
 @param playhead The current playhead position
 @param timeline The stream timeline represented as an array of YSAdBreak objects
 @return YES if playback can start, NO otherwise.
 @since from 1.0
 */
- (BOOL) canStart:(NSTimeInterval)playhead timeline:(NSArray* _Nonnull)timeline;

/** Returns to the client whether playback can stop.
 
 @param playhead The current playhead position
 @param timeline The stream timeline represented as an array of YSAdBreak objects
 @return YES if playback can stop, NO otherwise.
 @since from 1.0
 */
- (BOOL) canStop:(NSTimeInterval)playhead timeline:(NSArray* _Nonnull)timeline;

/** Returns to the client whether playback can pause.
 
 @param playhead The current playhead position
 @param timeline The stream timeline represented as an array of YSAdBreak objects
 @return YES if playback can pause, NO otherwise.
 @since from 1.0
 */
- (BOOL) canPause:(NSTimeInterval)playhead timeline:(NSArray* _Nonnull)timeline;

/** Returns to the client whether playback can rewind from the current playhead position.
 
 @param playhead The current playhead position
 @param timeline The stream timeline represented as an array of YSAdBreak objects
 @return YES if playback can rewind, NO otherwise.
 @since from 1.4
 */
- (BOOL) canRewind:(NSTimeInterval)playhead timeline:(NSArray* _Nonnull)timeline;

/** Returns to the client whether the currently playing advert can be skipped.
 
 @param playhead The current playhead position
 @param timeline The stream timeline represented as an array of YSAdBreak objects
 @param duration The nonlinear stream duration, or zero if the stream is live
 @return delay in seconds before the advert can be skipped, or -1 otherwise.
 @since from 1.7
 */
- (NSTimeInterval) canSkip:(NSTimeInterval)playhead timeline:(NSArray* _Nonnull)timeline duration:(NSTimeInterval)duration;

/** Returns to the client whether playback can seek from the current playhead position.
 
 @param playhead The current playhead position
 @param timeline The stream timeline represented as an array of YSAdBreak objects
 @return YES if playback can seek, NO otherwise.
 @since from 1.0
 */
- (BOOL) canSeek:(NSTimeInterval)playhead timeline:(NSArray* _Nonnull)timeline;

/** Returns to the client the playhead position that the user can seek to.
 
 @param position the playhead position that the user wishes to seek to
 @param timeline The stream timeline represented as an array of YSAdBreak objects
 @return the actual playhead position that the user can seek to, based on the implemented policy.
 @since from 1.0
 */
- (NSTimeInterval) willSeekTo:(NSTimeInterval)position timeline:(NSArray* _Nonnull)timeline;

/** Returns to the client whether volume can be muted.
 
 @param playhead The current playhead position
 @param timeline The stream timeline represented as an array of YSAdBreak objects
 @return YES if volume can be muted, NO otherwise.
 @since from 1.0
 */
- (BOOL) canMute:(NSTimeInterval)playhead timeline:(NSArray* _Nonnull)timeline;

/** Returns to the client whether expanding the player to full screen is allowed.
 
 @param playhead The current playhead position
 @param timeline The stream timeline represented as an array of YSAdBreak objects
 @return YES if full screen is allowed, NO otherwise.
 @since from 1.4
 */
- (BOOL) canGoFullScreen:(NSTimeInterval)playhead timeline:(NSArray* _Nonnull)timeline;

/** Returns to the client whether exiting full screen of the player is allowed.
 
 @param playhead The current playhead position
 @param timeline The stream timeline represented as an array of YSAdBreak objects
 @return YES if exiting full screen is allowed, NO otherwise.
 @since from 1.4
 */
- (BOOL) canExitFullScreen:(NSTimeInterval)playhead timeline:(NSArray* _Nonnull)timeline;

/** Returns to the client whether the linear creative can be expanded.<br/>
 Note that this method is not applicable to non-linear creative.
 
 @param playhead The current playhead position
 @param timeline The stream timeline represented as an array of YSAdBreak objects
 @return YES if the creative can be expanded, NO otherwise.
 @since from 1.0
 */
- (BOOL) canExpandCreative:(NSTimeInterval)playhead timeline:(NSArray* _Nonnull)timeline;

/** Returns to the client whether the linear creative can be collapsed.<br/>
 Note that this method is not applicable to non-linear creative.
 
 @param playhead The current playhead position
 @param timeline The stream timeline represented as an array of YSAdBreak objects
 @return YES if the creative can be collapsed, NO otherwise.
 @since from 1.4
 */
- (BOOL) canCollapseCreative:(NSTimeInterval)playhead timeline:(NSArray* _Nonnull)timeline;

/** Returns to the client whether the user can click-through.
 
 @param url The click-through Url.
 @param playhead The current playhead position
 @param timeline The stream timeline represented as an array of YSAdBreak objects
 @return YES if the user can click through, NO otherwise.
 @since from 1.0
 */
- (BOOL) canClickThrough:(NSURL* _Nonnull)url playhead:(NSTimeInterval)playhead timeline:(NSArray* _Nonnull)timeline;

/** Returns to the client whether to fetch and load non-linear creative graphical elements from any VAST received from the ad server.
 If true the graphical elements will be available to retrieve from the SDK at the point an advert starts.
 If false then the client must fetch any remote resources itself, which may delay their display.
 
 @return YES if the SDK should pre-load graphical elements.
 @since from 1.0
 */
- (BOOL) shouldPreloadNonLinearGraphicalElements;

/** Returns to the client whether to fetch and load non-linear iFrame resource elements from any VAST received from the ad server.
 If true the iFrame elements will be available to retrieve from the SDK at the point an advert starts.
 If false then the client must fetch any remote resources itself, which may delay their display.
 
 @return YES if the SDK should pre-load iFrame resource elements.
 @since from 1.2
 */
- (BOOL) shouldPreloadIFrameResourceElements;

/** Returns to the client whether to fetch and load interactive units, for example VPAID, from any VAST received from the ad server.
 If true the interactive unit will be available to retrieve from the SDK at the point an advert starts.
 If false then the client must fetch any remote resources itself, which may delay their display.
 
 @return YES if the SDK should pre-load interactive units.
 @since from 1.3
 */
- (BOOL) shouldPreloadInteractiveUnits;

/** Sets the playback mode that the stream is running in. The policy handler implementation may use this to modify the policy for specific
 requests, for example allowing pause in video-on-demand but not live playback.
 
 @param playbackMode The playback mode for the stream
 @since from 1.6
 */
- (void) setPlaybackMode:(YSEPlaybackMode)playbackMode;

@end
