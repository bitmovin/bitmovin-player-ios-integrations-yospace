/*
 * COPYRIGHT 2020-2022 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <YOAdManagement/YOSessionSeekable.h>

/**
 * Concrete Session implementation representing a viewing of a single Video-on-Demand (VOD) stream sourced from
 * the Yospace Video Platform via the Yospace VOD access service
*/
@interface YOSessionVOD : YOSessionSeekable

/**
 * Class method that starts to create a YOSessionVOD object, providing a URL to play a non-linear video stream.\n
 * The method returns a unique initialisation token that can be used to identify the session instance in the
 * case that multiple sessions are created.
 *
 * @param url A Yospace access request URL.
 * @param properties An optional initialisation properties object.
 * @param handler The completion handler to call when the initialisation request is complete. This handler is called on the application's main thread.
 * @return a unique initialisation token
 * @see YOSessionProperties
 * @see YOSession#token
 */
+ (nonnull NSString*) create:(nonnull NSString*)url properties:(nullable YOSessionProperties*)properties completionHandler:(nonnull completionHandler)handler;

/**
 * Provides a relative content playhead position to the client, discounting the sum of all ad break
 * durations prior to the absolute playhead position provided. This allows the client to return
 * to the same content position if a VOD stream is stopped before playback ends.
 *
 * @param playhead The playhead position, in seconds.
 * @return The relative content position for a given absolute playhead position, in seconds.
 * @see YOSessionVOD#playheadForContentPosition:
 */
- (NSTimeInterval) contentPositionForPlayhead:(NSTimeInterval)playhead;

/**
 * Provides an absolute playhead position to the client calculating the sum of all ad break durations
 * prior to that absolute playhead position plus the relative content playhead position.
 * This allows the client to return to the same content position if a VOD stream is stopped
 * before playback ends.
 *
 * @param position The playhead position, in seconds.
 * @return The absolute playhead position for any given relative content position, in seconds.
 * @see YOSessionVOD#contentPositionForPlayhead:
 */
- (NSTimeInterval) playheadForContentPosition:(NSTimeInterval)position;

@end
