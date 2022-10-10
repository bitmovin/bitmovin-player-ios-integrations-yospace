/*
 * COPYRIGHT 2020-2022 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <Foundation/Foundation.h>
#import <YOAdManagement/YOAdManagementTypes.h>

@class YOSessionProperties;

/**
 * @brief Provides the means for a client to initialise the SDK for Live and DVR Live playback using Proxied Initialisation by
 * intercepting requests for the master video manifest.
 *
 * The proxy records key / value information from the file,
 * which is used by the SDK to initialise.
 */
@interface YOSessionFactory : NSObject

/**
 * Class method that creates a YOSessionFactory instance to initiate Proxied Initialisation using the parameters specified.
 *
 * @param url A Yospace access request URL
 * @param mode The playback mode to intialise with. Supported modes are: `YOLiveMode` and `YODVRLiveMode`.
 * @param properties An initialisation properties object.
 * @param handler The completion handler to call when the initialisation request is complete. This handler is called on the application's main thread.
 * @return The playback URL that the caller must pass to the video player to begin playback.
 * @see YOPlaybackMode
 * @see YOSessionProperties
 */
+ (nullable NSString*) create:(nonnull NSString*)url mode:(YOPlaybackMode)mode properties:(nullable YOSessionProperties*)properties completionHandler:(nonnull completionHandler)handler;

/**
 * Shuts down all outstanding proxy requests that are handled by the SessionFactory.\n
 * This method must be called if \ref YOSessionProperties#keepProxyAlive is set to `YES`.
 *
 * @see YOSessionProperties#keepProxyAlive
 */
+ (void) shutdown;

/**
 * Shuts down an outstanding proxy request that is identified by the token passed in.\n
 * This method must be called if \ref YOSessionProperties#keepProxyAlive is set to `YES`.
 *
 * @param token the unique token representing the proxy initialisation request
 * @see YOSessionProperties#keepProxyAlive
 */
+ (void) shutdown:(nonnull NSString*)token;

/**
 * Returns a unique initialisation token that can be used to identify the Session instance in
 * an initialisation completion callback.\n
 * This method can be used when instantiating multiple concurrent sessions.
 *
 * @param url the playback URL that was returned by the Session factory
 * @return the token as a string or nil if the URL provided is not valid
 *
 * @see YOSession#token
 */
+ (nullable NSString*) tokenForUrl:(nonnull NSString*)url;

@end
