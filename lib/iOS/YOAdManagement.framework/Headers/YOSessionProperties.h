/*
 * COPYRIGHT 2020-2022 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <Foundation/Foundation.h>
#import <YOAdManagement/YOAdManagementTypes.h>

/**
 * Provides a means for a client to specify custom properties at session initialisation.
 */
@interface YOSessionProperties : NSObject <NSCopying>

/**
 * Defines the timeout interval, in milliseconds, for HTTP requests to the CSM: Yospace session and analytic polling.
 *
 * @note The default value is 5 seconds.
 */
@property NSTimeInterval timeout;

/**
 * Defines the timeout interval, in milliseconds, for HTTP requests to resource endpoints: tracking beacons and
 * pre-fetching non-linear VAST resources.
 *
 * @note The default value is 5 seconds.
 */
@property NSTimeInterval resourceTimeout;

/**
 * Defines whether to keep the proxy component alive after the master video manifest is read by the SDK.
 * The default behaviour is to shutdown the proxy.\n
 * This property is relevant only for Live and DVR Live playback.
 *
 * @note The default value is `NO`.
 */
@property BOOL keepProxyAlive;

/**
 * Defines the User-Agent to include in HTTP requests to initialise a Yospace session and when firing tracking beacons.
 *
 * @note The default value is `nil` in which case the SDK will use the system-defined user agent.
 */
@property (nonnull, copy) NSString* userAgent;

/**
 * Defines the User-Agent to include in HTTP requests when fetching the manifest during Proxied Initialisation for Live or DVR Live playback.
 *
 * @note The default value is `nil` in which case the SDK will use the system-defined user agent.
 */
@property (nonnull, copy) NSString* proxyUserAgent;

/**
 * Defines whether to prefetch non-linear resources contained in a VAST document for this advert. Prefetching resources allows
 * the application to use or display the resource as soon as the advert starts without the application having to fetch it first.
 * If the fetch is successful then the resource is available from the NonLinearCreative or CompanionCreative associated with the Advert.
 *
 * @note The default value is `NO`
 */
@property BOOL prefetchNonlinearResources;

/**
 * Defines whether the SDK should fire timeline tracking beacons (quartiles) for adverts that have finished playing out.
 * The SDK will do this only if it receives beacon data for the historical advert while still playing back the ad break
 * in which that advert was defined. A client may choose to disable this feature to prevent tracking beacons being counted
 * as fraudulent by viewability logic embedded with or used by the client.
 *
 * @note The default value is `YES`.
 */
@property BOOL fireHistoricalBeacons;

/**
 * Describes whether the SDK should modify all tracking beacons as necessary to use the HTTPS protocol.
 *
 * @note The default value is `NO`.
 */
@property BOOL applyEncryptedTracking;

/**
 * Defines the categories of analytic tracking beacons to exclude from analytic suppression.
 * By default, no categories are set.
 *
 * @see YOSession#suppressAnalytics:
 */
@property YOEventCategories excludeFromSuppression;

/**
 * Defines the maximum distance, in seconds, between consecutive ad breaks for them to be
 * considered "back to back". In this case the SDK will adjust the start position of
 * the subsequent ad break to match the end position of the preceding ad break.
 * The maximum value used is the segment length of the current stream's content.
 *
 * @note The default value is 0.
 */
@property NSTimeInterval consecutiveAdBreakTolerance;

/**
 * Contains a dictionary of key value pairs that are set as custom HTTP request headers for the Session
 * initialisation request only.
 */
@property (nonnull) NSMutableDictionary* customHeaders;

/**
 * Sets the debug flags that enable categories of SDK trace statements, specified as an OR'ed list.
 * For example `[YOSessionProperties setDebugFlags:DEBUG_PARSING | DEBUG_POLLING];` causes the
 * SDK to emit only trace statements related to parsing and analytic polling.\n
 * Use the `DEBUG_ALL` flag to enable all trace statements.
 *
 * @param value OR'ed combination of debug flags.
 *
 * @note By default no flags are set.
 * @note The version of the SDK is always traced as part of initialisation.
 * @see YODebugFlags
 */
+ (void) setDebugFlags:(YODebugFlags)value;

@end
