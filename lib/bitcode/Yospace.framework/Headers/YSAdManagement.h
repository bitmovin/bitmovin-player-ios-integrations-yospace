/*
 * COPYRIGHT © 2018 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>

/** YSEInitialisationState defines the initialisation state for the YSSessionManager object.
 */
typedef NS_ENUM(NSInteger, YSEInitialisationState)
{
    /** The Session is not initialised */
    YSENotInitialised,
    /** The Session is initialised */
    YSEInitialisedWithAnalytics,
    /** The Session did not initialise: analytics are not available */
    YSEInitialisedNoAnalytics
};

/** YSEInitialisationState defines the initialisation state for the YSSessionManager object.
 */
typedef NS_ENUM(NSInteger, YSEInitialisationCode)
{
    /** Yospace initialisation result code: OK. */
    YSEStatusOK,
    /** Yospace initialisation result code: failed to establish an HTTP connection. */
    YSEConectionError,
    /** Yospace initialisation result code: failed to complete connection or read the HTTP response before a timeout occurred. */
    YSEConnectionTimeout,
    /** Yospace initialisation result code: The request URL is malformed. */
    YSEMalformedURL,
    /** Yospace initialisation result code: the Primary URL passed in YSSessionProperties is not a Yospace initialisation URL. */
    YSENonYospaceURL,
    /** Yospace initialisation result code: the stream is not configured for LivePause playback; LivePause feature is not available. */
    YSENoLivePause,
    /** Yospace initialisation result code: the URL returned in YSStream streamSource is the secondary (non-Yospace) URL. */
    YSEUsingSecondary
};

/** YSETrackingEvent defines the supported tracking event types. These are a superset of enumerations in the VAST and VMAP specification.
 */
typedef NS_ENUM(NSInteger, YSETrackingEvent)
{
    /** General tracking event type */
    YSEGeneralTrackingEvent,
    /** Impression tracking event type */
    YSEImpressionEvent,
    /** Creative view event type */
    YSECreativeViewEvent,
    /** Start tracking event type */
    YSEStartEvent,
    /** Midpoint tracking event type */
    YSEMidpointEvent,
    /** First quartile tracking event type */
    YSEFirstQuartileEvent,
    /** Third quartile tracking event type */
    YSEThirdQuartileEvent,
    /** Complete tracking event type */
    YSECompleteEvent,
    /** Mute tracking event type */
    YSEMuteEvent,
    /** Unmute tracking event type */
    YSEUnmuteEvent,
    /** Pause tracking event type */
    YSEPauseEvent,
    /** Rewind tracking event type */
    YSERewindEvent,
    /** Resume tracking event type */
    YSEResumeEvent,
    /** Full screen tracking event type */
    YSEFullscreenEvent,
    /** Exit full screen tracking event type */
    YSEExitfullscreenEvent,
    /** Expand tracking event type */
    YSEExpandEvent,
    /** Collapse tracking event type */
    YSECollapseEvent,
    /** Accept invitation linear tracking event type */
    YSEAcceptInvitationLinearEvent,
    /** Close linear tracking event type */
    YSECloseLinearEvent,
    /** skip tracking event type */
    YSESkipEvent,
    /** progress tracking event type */
    YSEProgressEvent,
    /** Accept invitation tracking event type */
    YSEAcceptInvitationEvent,
    /** Close tracking event type */
    YSECloseEvent,
    /** Click tracking event type */
    YSEClickTrackingEvent,
    /** Nonlinear click tracking event type */
    YSENonLinearClickTrackingEvent,
    /** Icon click tracking event type */
    YSEIconClickTrackingEvent,
    /** Icon view tracking event type */
    YSEIconViewTrackingEvent,
};

/** YSEAdBreakPosition defines the possible locations in the stream for an Ad break.
 */
typedef NS_ENUM(NSInteger, YSEAdBreakPosition)
{
    /** midiroll position */
    YSEMidrollPosition,
    /** pre-roll position */
    YSEPrerollPosition,
    /** post-roll position */
    YSEPostrollPosition
};

/** YSEPricingModel defines the possible pricing models for an Advert's pricing property.
 */
typedef NS_ENUM(NSInteger, YSEPricingModel)
{
    /** cost-per-click pricing model */
    YSECostPerClick,
    /** cost-per-mile pricing model */
    YSECostPerMile,
    /** cost-per-engagement pricing model */
    YSECostPerEngagement,
    /** cpst-per-view pricing model */
    YSE_CostPerView,
    /** unknown pricing model */
    YSEUnknown_model = 100
};

/** YSEPlaybackMode defines the possible modes that the Session Manager runs in.
 */
typedef NS_ENUM(NSInteger, YSEPlaybackMode){
    /** Video on demand playback mode */
    YSEVideoOnDemandMode,
    /** Live playback mode */
    YSELiveMode,
    /** Nonlinear Startover playback mode */
    YSENonlinearStartoverMode,
    /** Live Pause playback mode */
    YSELivePauseMode
};
