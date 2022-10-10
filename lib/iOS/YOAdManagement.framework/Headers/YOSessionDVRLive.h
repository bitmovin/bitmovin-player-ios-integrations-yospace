/*
 * COPYRIGHT 2022 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <YOAdManagement/YOSessionSeekable.h>

/**
 * Concrete Session implementation representing a viewing of a single DVR Live stream sourced from
 * the Yospace Video Platform via the Central Streaming Manager (CSM) service
*/
@interface YOSessionDVRLive : YOSessionSeekable

/** Defines the start point of the DVR Live stream. */
@property (readonly) NSTimeInterval streamStart;

/** Defines the window start point of a DVR Live stream relative to the stream start. */
@property (readonly) NSTimeInterval windowStart;

/** Defines the window end point of a DVR Live stream relative to the stream start. */
@property (readonly) NSTimeInterval windowEnd;

/** Defines the window size of a DVR Live stream. */
@property (readonly) NSTimeInterval windowSize;

/**
 * Class method that starts to create a YOSessionDVR object, providing a URL to play a DVR-enabled video stream.\n
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

@end
