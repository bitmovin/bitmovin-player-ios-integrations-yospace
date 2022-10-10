/*
 * COPYRIGHT 2020-2022 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <Foundation/Foundation.h>
#import <YOAdManagement/YOAnalyticEvents.h>
#import <YOAdManagement/YOPlaybackEventHandling.h>
#import <YOAdManagement/YOPlaybackPolicyHandling.h>
#import <YOAdManagement/YOPlaybackPolicyDelegate.h>
#import <YOAdManagement/YOAdManagementTypes.h>

@class YOSessionProperties;
@class YOAdBreak;
@class YOAdvert;

/**
 * Abstract base class of a linear and non-linear Yospace CSM sessions.
 */
@interface YOSession : NSObject <YOPlaybackEventHandling, YOPlaybackPolicyDelegate>

/**
 * Defines the result of Session initialisation.
 *
 * @see YOSessionResult
 */
@property (readonly) YOSessionResult sessionResult;

/**
 * Defines the result code for initialisation of the Session. This may be
 * - 0 (no error)
 * - a network error code, defined in YOAdManagementTypes.h
 * - YOCONNECTION_ERROR
 * - YOCONNECTION_TIMEOUT
 * - YOMALFORMED_URL
 * - YOUNKNOWN_FORMAT
 * - an HTTP status code, for example `404`
 * .
 */
@property (readonly) NSInteger resultCode;

/** Defines the playback URL of the Session. */
@property (nullable, readonly) NSString* playbackUrl;

/**  Defines the unique identifier of the Session. */
@property (nullable, readonly) NSString* identifier;

/**  Defines the unique initialisation token of the Session. */
@property (nullable, readonly) NSString* token;

/**
 * Defines the playback mode for the Session.
 *
 * @see YOPlaybackMode
 * */
@property (readonly) YOPlaybackMode playbackMode;

/**
 * Returns the current ad break, or `nil` if not in a break or if the ad break is not yet known.
 *
 * @return The current ad break, or `nil`.
 * @see YOAdBreak
 */
- (nullable YOAdBreak*) currentAdBreak;

/**
 * Returns the current advert, or `nil` if not in a break or if the ad break is not yet known.
 *
 * @return The current advert, or `nil`.
 * @see YOAdvert
 */
- (nullable YOAdvert*) currentAdvert;

/**
 * Returns the current list of ad breaks for the stream of the type specified.
 *
 * @param type the ad break type
 * @return An array of ad breaks, which may be empty.
 * @see YOAdBreakType
 */
- (nonnull NSArray*) adBreaks:(YOAdBreakType)type;

/**
 * Removes a non-linear ad break from the stream.
 *
 * @param adBreak The non-linear ad break to remove.
 * @see YOAdBreak
 */
- (void) removeNonlinearAdBreak:(nonnull YOAdBreak*)adBreak;

/**
 * Removes all non-linear ad breaks from the stream.
 */
- (void) removeAllNonlinearAdBreaks;

/**
 * Sets the playback policy handler instance on the Session. The Session delegates
 * calls made on YOPlaybackPolicyDelegate to the handler provided.
 * Note: the session retains a strong reference to the policy handler so that the
 * calling client does not have to do so.
 *
 * @param handler The handler with which to delegate policy decisions.
 * @see YOPlaybackPolicyHandling
 */
- (void) setPlaybackPolicyHandler:(nonnull id<YOPlaybackPolicyHandling>)handler;

/**
 * Suppresses or enables remote analytic tracking calls. If analytics are unsuppressed during an
 * ad break and the AdBreak has associated breakStart beacons then these will be fired immediately.
 * By default, analytic tracking calls are enabled.
 *
 * @param suppress If `YES` then analytics will be suppressed, otherwise they are enabled.
 */
- (void) suppressAnalytics:(BOOL)suppress;

/**
 * Returns whether analytics are currently suppressed for this playback session.
 * @return `YES` if analytics are suppressed, `NO` otherwise.
 */
- (BOOL) analyticsSuppressed;

/**
 * Shuts down the Session cleanly.\n
 * This method must be called on the main thread when playback of the stream has stopped.
 */
- (void) shutdown;

@end
