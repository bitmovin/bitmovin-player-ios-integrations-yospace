/*
 * COPYRIGHT 2020-2022 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#ifndef AdManagementTypes_h
#define AdManagementTypes_h

@class YOSession;

/*! \defgroup typedef_defs TypeDefs
 *  This section lists the typedefs that are used during interaction with the SDK.
 */

/** \ingroup typedef_defs
 *
 * Type definition for the completion handler for Session initialisation */
typedef void (^completionHandler)(YOSession* _Nonnull session);

/*! \defgroup enum_defs Enumerations
 *  This section lists the public enumerations that are used during interaction with the SDK.
 */

/*! \defgroup const_defs Result Codes
 *  This section lists the possible SDK-defined failure result codes in the case that the SDK initialisation is not successful.
 *  These result code values are negative.
 *
 *  The result code may also be zero (success), or an HTTP response code outside the range 200-299.
 */

/** \ingroup enum_defs
 *
 * YOSessionResult defines the initialisation result for the Yospace Session.
 */
typedef NS_ENUM(NSInteger, YOSessionResult)
{
    /** The Session is not initialised. */
    YONotInitialised,
    /** The Session is initialised. */
    YOInitialised,
    /** The Session will not provide analytics and playback cannot proceed. */
    YOFailed,
    /** The Session will not provide analytics but playback may be possible. */
    YONoAnalytics,
    /** The Session has expired and is no longer valid. */
    YOTimeout
};

/** \ingroup const_defs
 *
 * Yospace initialisation result code: failed to establish an HTTP connection. */
#define YOCONNECTION_ERROR -1
/** \ingroup const_defs
 *
 * Yospace initialisation result code: failed to complete connection or read the HTTP response before a timeout occurred. */
#define YOCONNECTION_TIMEOUT -2
/** \ingroup const_defs
 *
 * Yospace initialisation result code: The request URL is malformed. */
#define YOMALFORMED_URL -3
/** \ingroup const_defs
 *
 * Yospace initialisation result code: the stream is not configured for DVR Live playback; DVR Live feature is not available. */
#define YONO_DVRLIVE -11
/** \ingroup const_defs
 *
 * Yospace initialisation result code: the proxy could not service the request. */
#define YOPROXY_ERROR -12
/** \ingroup const_defs
 *
 * Yospace initialisation result code: the manifest is corrupt or of an unknown format. */
#define YOUNKNOWN_FORMAT -20
/** \ingroup const_defs
 *
 * Yospace initialisation result code: the host provided a fallback URL instead of a manifest. */
#define YOFALLBACK_URL -21
/** \ingroup const_defs
 *
 * Indication that the Session's DVR play window is invalid. */
#define YOINVALID_WINDOW -1.0

/** \ingroup enum_defs
 *
 * YOPlaybackMode defines the possible modes that the SDK runs in.
 */
typedef NS_ENUM(NSInteger, YOPlaybackMode) {
    /** Video on demand playback mode */
    YOVODMode,
    /** Live playback mode */
    YOLiveMode,
    /** DVR Live playback mode */
    YODVRLiveMode,
};

/** \ingroup enum_defs
 *
 * YOAdBreakType defines the possible ad break types as defined by the IAB VMAP specification.
 */
typedef NS_ENUM(NSInteger, YOAdBreakType) {
    /** linear type */
    YOLinearType,
    /** nonlinear type */
    YONonLinearType,
    /** display type */
    YODisplayType,
};

/** \ingroup enum_defs
 *
 * YOPlaybackEvent defines the possible playback events that may be raised to the SDK. It is used for event tracking.
 */
typedef NS_ENUM(NSInteger, YOPlayerEvent) {
    /** Indicates that playback started. */
    YOPlaybackStartEvent,
    /** Indicates that playback stopped. */
    YOPlaybackStopEvent,
    /** Indicates that playback paused. */
    YOPlaybackPauseEvent,
    /** Indicates that playback resumed after pausing. */
    YOPlaybackResumeEvent,
    /** Indicates that playback stalled, possibly as a result of buffering. */
    YOPlaybackStallEvent,
    /** Indicates that playback continued after stalling. */
    YOPlaybackContinueEvent,
    /** Indicates that a rewind operation was initiated within the advert. */
    YOAdvertRewindEvent,
    /** Indicates that a playback seek operation was initiated within the advert. */
    YOPlaybackSeekEvent,
    /** Indicates that a playback skip operation was initiated for a skippable advert. */
    YOAdvertSkipEvent
};

/** \ingroup enum_defs
 *
 * YOResourceType defines the resource type for a Nonlinear or Industry Icon resource.
 */
typedef NS_ENUM(NSUInteger, YOResourceType) {
    /** static resource */
    YOStaticResource,
    /** html resource */
    YOHTMLResource,
    /** iframe resource */
    YOIFrameResource,
    /** unknown resource: used only to obtain Companions from the Advert that have tracking but no Resource */
    YOUnknownResource
};

/** \ingroup enum_defs
 *
 * YOPlayerViewSize defines the possible player viewport sizes. It is used for event tracking.
 * @deprecated YOMaximised and YOMinimised will be removed in v3.5.0.
 *
 */
typedef NS_ENUM(NSInteger, YOPlayerViewSize) {
    /** The player viewport was expanded to a larger size. */
    YOExpanded,
    /** The player viewport was collapsed to a smaller size. */
    YOCollapsed
};

/** \ingroup enum_defs
 *
 * YOViewableEvent defines the possible viewable events for an ad.
 */
typedef NS_ENUM(NSInteger, YOViewableEvent) {
    /** Indicates that an advert is viewable. */
    YOViewable,
    /** Indicates that an advert is not viewable. */
    YONotViewable,
    /** Indicates that the viewable state of an ad is undetermined. */
    YOViewUndetermined
};

/** \ingroup enum_defs
 *
 * YODebugFlags defines the set of switches that control debug trace output for aspects of SDK behaviour.
 */
typedef NS_ENUM(NSInteger, YODebugFlags) {
    /** when set, traces playback events */
    DEBUG_PLAYBACK         = 1,
    /** when set, traces SDK lifecycle */
    DEBUG_LIFECYCLE        = (1 << 1),
    /** when set, traces CSM VMAP polling events */
    DEBUG_POLLING          = (1 << 2),
    /** when set, traces VMAP and VAST tracking reports */
    DEBUG_REPORTS          = (1 << 3),
    /** when set, traces state machine state */
    DEBUG_STATE_MACHINE    = (1 << 4),
    /** when set, traces HTTP requests and responses */
    DEBUG_HTTP_REQUESTS    = (1 << 5),
    /** when set, traces VAST and VMAP parsing logic */
    DEBUG_PARSING          = (1 << 6),
    /** when set, traces validation statements */
    DEBUG_VALIDATION       = (1 << 7),
    /** when set, enables all trace options */
    DEBUG_ALL              = INT_MAX
};

extern YODebugFlags debugFlags;

/** \ingroup enum_defs
 *
 * YOEventCategories defines the set of event categories used for suppression of analytics.
 * @see YOSessionProperties#excludeFromSuppression
 */
typedef NS_ENUM(NSInteger, YOEventCategories) {
    /** Ad break events defined in the VMAP specification */
    YOBreakEvents    = 1,
    /** timeline events ('quartiles') defined in the VAST specification */
    YOTimelineEvents = (1 << 1),
};

#endif /* AdManagementTypes_h */

