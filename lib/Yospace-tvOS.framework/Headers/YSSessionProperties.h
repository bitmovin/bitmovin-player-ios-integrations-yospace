/*
 * COPYRIGHT © 2018 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>
#import "YSDebugFlags.h"


/** The YSSessionProperties class is used to provide custom properties to the Session Manager at initialisation.
 
 */
@interface YSSessionProperties : NSObject <NSCopying>

/**
 Defines the receiver's timeout interval for HTTP requests for session initialisation and CSM polling.<br/>
 If during a connection attempt the request remains idle for longer than this value, the request is considered to have timed out.<br/>
 The default value is 15 seconds.
 */
@property (nonatomic) NSTimeInterval timeout;

/**
 An optional URL to a secondary non-Yospace stream. This URL will be returned in the event that the attempt to initialise the SDK
 using the primary URL fails. Note that this property is only relevant for direct initialisation and will be ignored if using proxy initialisation.
 */
@property (nonatomic, copy) NSURL* secondaryURL;

/**
 If not nil or empty, contains one or more NSString objects, interpreted as regular expressions, used to determine whether a string that defines a URL in a received VAST document should be ignored. If the string is matched then the corresponding event, clickthrough or resource will not be created for the corresponding advert.
 */
@property (nonatomic, copy) NSArray* vastUrlIgnorePatterns;

/**
 Defines whether the URL passed into the SDK is known to redirect to a CSM URL. If true, the SDK obtains the actual redirect URL from the Location header in the 302 response and uses that to initialise.
 This property is relevant only for direct initialisation of the SDK, as such if it is set then property `useProxy` is ignored.
 */
@property (nonatomic) BOOL isRedirectURL;// __attribute__((deprecated("This property will be removed in a forthcoming release.")));

/**
 Defines whether the initialisation process should use a proxy object, which intercepts the master playlist to retrieve Yospace session information. If this property is `NO` then the Session Manager makes an additional specific call to the CSM to retrieve this information.
 */
@property (nonatomic) BOOL useProxy;// __attribute__((deprecated("This property will not be required in a forthcoming release, proxy initialisation will be explicit through the API.")));

/**
 Defines whether to keep the proxy component alive after the master manifest is read. The default behaviour is to shutdown the proxy. This property is relevant only for Live and LivePause playback streams.
 */
@property (nonatomic) BOOL keepProxyAlive;

/**
 Defines whether the SDK will poll for VAST over HTTP Secure regardless of the scheme used in the playback URL.
 */
@property (nonatomic) BOOL forceHttpsPolling;

/**
 If present, defines the HTTP user-agent to be used by the Session Manager when firing remote analytics tracking events.
 */
@property (nonatomic, copy) NSString* analyticsUserAgent;

/**
 Describes whether to prefetch static resources defined in the VAST for this advert.
 Prefetching resources allows the application to use or display the resource as soon
 as the advert starts without the application having to fetch it first.
 If the fetch is successful then resource is available from the Resource property of
 the NonLinearCreative associated with the Advert.
 */
@property (nonatomic) BOOL prefetchStaticResources;

/**
 Describes whether to prefetch IFrame resources defined in the VAST for this advert.
 Prefetching resources allows the application to use or display the resource as soon
 as the advert starts without the application having to fetch it first.
 If the fetch is successful then resource is available from the Resource property of
 the NonLinearCreative associated with the Advert.
 */
@property (nonatomic) BOOL prefetchIFrameResources;

/**
 Describes whether to prefetch Industry Icons defined in the VAST for this advert.
 Prefetching resources allows the application to use or display the resource as soon
 as the advert starts without the application having to fetch it first.
 If the fetch is successful then resource is available from the LinearCreative
 associated with the Advert.

 Note that the VAST specification recommends that icons are not prefetched in case a
 vendor falsely records an icon view, when the icon may not be displayed.
 */
@property (nonatomic) BOOL prefetchIndustryIcons;

/**
 If present, defines the HTTP user-agent to be used by the Session Manager when initiating a redirect request as part of initialisation.
 */
@property (nonatomic, copy) NSString* redirectUserAgent;// __attribute__((deprecated("This property will removed in a forthcoming release.")));

/**
 Defines the segment length (playlist `target duration`) for adverts in a stream. This is usually the same as the stream.
 This value must be set in order for analytics to function properly when using filler in advert breaks.
 The default value is 11 seconds.
 */
@property (nonatomic) NSInteger targetDuration;// __attribute__((deprecated("Advert segment lengths will be retrieved through the network in a future release.")));

/**
 Defines a set of debug flags that control aspects of logging output.<br/>
 The SDK is initialised with a 'sensible' default set, which can be overridden by calling this method.<br/>
 New values must by OR'ed together e.g. ```[props setDebugFlags:DEBUG_PARSING | DEBUG_VAST_POLLING];```
 
 @param value OR'ed combination of debug flags
 */
+(void) setDebugFlags:(YSEDebugFlags)value;

/**
 Defines a set of debug flags, in addition to the default set, that control aspects of logging output.<br/>
 The SDK is initialised with a 'sensible' default set, which can augmented by calling this method.<br/>
 New values must by OR'ed together e.g. ```[props addDebugFlags:DEBUG_PARSING | DEBUG_VAST_POLLING];```
 
 @param value OR'ed combination of debug flags
 */
+(void) addDebugFlags:(YSEDebugFlags)value;

@end
