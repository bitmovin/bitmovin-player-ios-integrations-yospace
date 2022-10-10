/*
 * COPYRIGHT 2020-2022 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <YOAdManagement/YOSession.h>

/**
 * Concrete Session implementation representing a viewing of a single live stream sourced from
 * the Yospace Video Platform via the Central Streaming Manager (CSM)
*/
@interface YOSessionLive : YOSession

/**
 * Class method that starts to create a YOSessionLive object, providing a URL to play a live video stream.\n
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
