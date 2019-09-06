/*
 * COPYRIGHT © 2019 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import "YSSessionManagerObserver.h"
#import "YSAnalyticObserver.h"
#import "YSSessionProperties.h"

#import "YSVideoPlayer.h"
#import "YSPlayerPolicy.h"
#import "YPPolicyHandling.h"
#import "YSPlaybackEventDelegate.h"

/** The YSSessionManager class represents a session with the CSM and provides the interface to the Ad Management SDK.
 */
@interface YSSessionManager : NSObject <YSPlayerPolicy, YSPlaybackEventDelegate>

/**
 Contains the initialisation state of the Session Manager. This is a read-only property.
 */
@property (nonatomic, readonly) YSEInitialisationState initialisationState;

/**
 Contains the initialisation result code of the Session Manager. This is a read-only property.
 */
@property (nonatomic, readonly) YSEInitialisationCode initialisationCode;

/**---------------------------------------------------------------------------------------
 * @name Creation
 *  ---------------------------------------------------------------------------------------
 */

/** Creates a YSSessionManager object, providing a URL to play a live video stream.
 
 Starts to create and initialise the Session Manager, passing a stream URL, a session-initialisation property object and a delegate to receive initialisation callbacks. The client can also pass in an arbitrary set of parameters to be sent in the request.
 
 When the YSSessionManager completes initialisation a delegate call to sessionDidInitialise:withStream: is made.
 
 @param url URL to the Yospace Central Streaming Manager.
 @param properties An initialisation properties object.
 @param delegate The object to receive Session Manager initialisation callbacks.
 @return nil or a reference to a YSSessionAdaper if initialising using the proxy method
 @since from 1.0
 @see YSSessionManagerObserver
 */
+ (id _Nullable) createForLive:(NSURL* _Nonnull)url properties:(YSSessionProperties* _Nonnull)properties delegate:(id<YSSessionManagerObserver> _Nonnull)delegate;

/** Creates a YSSessionManager object, providing a URL to play a LivePause-enabled video stream.
 
 Starts to create and initialise the Session Manager, passing a stream URL, a session-initialisation property object and a delegate to receive initialisation callbacks. The client can also pass in an arbitrary set of parameters to be sent in the request.
 
 When the YSSessionManager completes initialisation a delegate call to sessionDidInitialise:withStream: is made.
 
 @param url URL to the Yospace Central Streaming Manager.
 @param properties An initialisation properties object.
 @param delegate The object to receive Session Manager initialisation callbacks.
 @since from 1.6
 @see YSSessionManagerObserver
 */
+ (id _Nullable) createForLivePause:(NSURL* _Nonnull)url properties:(YSSessionProperties* _Nonnull)properties delegate:(id<YSSessionManagerObserver> _Nonnull)delegate;

/** Creates a YSSessionManager object, providing a URL to play a Non-Linear Start Over video stream.
 
 Starts to create and initialise the Session Manager, passing a stream URL, a session-initialisation property object and a delegate to receive initialisation callbacks. The client can also pass in an arbitrary set of parameters to be sent in the request.
 
 When the YSSessionManager completes initialisation a delegate call to sessionDidInitialise:withStream: is made.
 
 @param url URL to the Yospace Central Streaming Manager.
 @param properties An initialisation properties object.
 @param delegate The object to receive Session Manager initialisation callbacks.
 @since from 1.0
 @see YSSessionManagerObserver
 */
+ (void) createForNonLinearStartOver:(NSURL* _Nonnull)url properties:(YSSessionProperties* _Nonnull)properties delegate:(id<YSSessionManagerObserver> _Nonnull)delegate;

/** Creates a YSSessionManager object, providing a URL to play a VoD stream.
 
 Starts to create and initialise the Session Manager, passing the URL of a Session XML document and a delegate to receive initialisation callbacks.
 
 When the Session Manager completes initialisation a delegate call to sessionDidInitialise:withStream: is made.
 
 @param url The URL of the session XML document.
 @param properties An initialisation properties object.
 @param delegate The object to receive Session Manager initialisation callbacks.
 @since from 1.0
 @see YSSessionManagerObserver
 */
+ (void) createForVoD:(NSURL* _Nonnull)url properties:(YSSessionProperties* _Nonnull)properties delegate:(id<YSSessionManagerObserver> _Nonnull)delegate;

/** Shuts down the Session Manager and cleans up timers and observers.
 This method must be called on the Main Thread and when playback of the stream has stopped. 
 
 @since from 1.1
 */
- (void) shutdown;

/** Sets the video player, and associated asset, for the Session Manager to observe.
 
 @param player The new player instance to associate with the Session Manager.
 @param error The address of an uninitialised NSError object.
 @return <code>YES</code> if the player was set and observation started successfully, <code>NO</code> otherwise, in which case <code>error</code> contains the error information.
 @since from 1.0
 */
- (BOOL) setVideoPlayer:(id<YSVideoPlayer> _Nonnull)player error:(NSError  * _Nullable * _Nullable)error;

/** Sets the video player policy handler for the Session Manager to query for policy decisions.
 
 @param policyHandler The player policy handler.
 @since from 1.1
 */
- (void) setPlayerPolicyDelegate:(id<YPPolicyHandling> _Nonnull)policyHandler;

/** Suppresses or enables remote analytic tracking calls. Analytic calls are enabled by default.
 
 @param suppress If `YES` then analytics are suppressed, or enabled otherwise.
 @return NSArray of tracking events that were disabled in the current advert during the suppresion period or nil otherwise
 @since from 1.4
 */
- (NSArray* _Nullable) suppressAnalytics:(BOOL)suppress;

/**---------------------------------------------------------------------------------------
 * @name Subscription
 *  ---------------------------------------------------------------------------------------
 */

/** Subscribes the caller to analytic events.
 
 @param object An object that implements the YSAnalyticObserver protocol
 
 @since from 1.0
 @see YSAnalyticObserver
 */
- (void) subscribeToAnalyticEvents:(id<YSAnalyticObserver> _Nonnull)object;

/** Unsubscribes the caller from all events on all protocols.
 
 @param object An object that implements any of YSAnalyticsObserver and/or YSPlaybackObserver protocol
 and that previously subscribed to events
 
 @since from 1.0
 @see YSAnalyticObserver
 */
- (void) unsubscribeFromAnalyticEvents:(id<YSAnalyticObserver> _Nonnull)object;

@end
