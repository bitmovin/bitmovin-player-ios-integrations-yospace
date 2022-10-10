/*
 * COPYRIGHT 2020,2022 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#ifndef YOAnalyticEvents_h
#define YOAnalyticEvents_h

/*! \defgroup notif_defs Analytic Notifications
 *  This section lists the analytic notification names that client applications can observe to receive analytic events.
 *  Analytic events are broadcast through the default notification center.
 *
 *  Also listed are dictionary keys for those notifications that provide additional data through the user info property
 *  of the notification.

 *  Client applications should subscribe to events that they are interested in, for example:
 *  @code
 *  [[NSNotificationCenter defaultCenter] addObserver:self
 *                                           selector:@selector(adBreakDidStart:)
 *                                               name:YOAdvertBreakStartNotification
 *                                             object:nil];
 * @endcode
 */

/** \ingroup notif_defs
 *
 * Posted when playback of an ad break begins. The notification contains a single dictionary entry keyed on \ref YOAdBreakKey
 * that is the YOAdBreak object. For linear playback it is possible that the ad break is not known (i.e. that analytic data
 * has not yet been provided for the ad break), in this case the dictionary is empty. */
extern NSString* const YOAdvertBreakStartNotification;

/** \ingroup notif_defs
 
 Posted when playback of an ad break ends.
 */
extern NSString* const YOAdvertBreakEndNotification;

/** \ingroup notif_defs
 *
 * Posted when playback of an advert begins. The notification contains a single dictionary entry keyed on \ref YOAdvertKey that is the YOAdvert object.
 *
 * For linear playback only, the notification may be posted after playback of an advert actually begins - if advert data is received late
 * from the Yospace Central Streaming Manager. In this case a client application should check the advert start position against the playhead position
 * when the notification was received to determine how late the signal is.
 */
extern NSString* const YOAdvertStartNotification;

/** \ingroup notif_defs
 *
 * Posted when playback of an advert ends.
 */
extern NSString* const YOAdvertEndNotification;

/** \ingroup notif_defs
 *
 * Posted when an analytic payload is received from the Yospace Central Streaming Manager. For live playback this
 * indicates that an ad break is upcoming; for non-linear playback this indicates that a change to the timeline has occurred
 * and the client application should fetch the updated data from the non-linear Session. For any playback mode it may indicate also that one
 * or more non-linear ad breaks are available to be used.
 *
 * @see YOSessionVOD
 */
extern NSString* const YOAnalyticUpdateNotification;

/** \ingroup notif_defs
 *
 * Posted when an analytic tracking event occurs. The notification contains a single dictionary entry:
 * - \ref YOEventNameKey - an `NSString` that is the name of the event, which may be taken from either the event attribute of the `<Tracking>` element
 * .
 *
 * Possible events are:
 * - `loaded`, `start`, `firstQuartile`, `midpoint`, `thirdQuartile`, `complete`
 * - `pause`, `resume`, `rewind`, `skip`, `playerExpand`, `playerCollapse`, `mute`, `unmute`
 * - `ClickTracking`, `acceptInvitation`
 * .
 */
extern NSString* const YOTrackingEventNotification;

/** \ingroup notif_defs
 *
 * Posted when a Yospace Session has expired and is no longer valid. No further analytics will be raised after this event.
 * The client application should call \ref YOSession#shutdown in this case.
 *
 */
extern NSString* const YOSessionTimeoutNotification;

/** \ingroup notif_defs
 *
 * Posted when an ad break is scheduled to end earlier than previously advertised and therefore has been truncated. The notification
 * contains a single dictionary entry keyed on \ref YOAdBreakKey that is the truncated YOAdBreak object.
 *
 */
extern NSString* const YOAdBreakEarlyReturnNotification;

// dictionary keys

/** \ingroup notif_defs
 *
 * The ad break dictionary key for the \ref YOAdvertBreakStartNotification notification.
 */
extern NSString* const YOAdBreakKey;

/** \ingroup notif_defs
 *
 * The advert dictionary key for the \ref YOAdvertStartNotification notification.
 */
extern NSString* const YOAdvertKey;

/** \ingroup notif_defs
 *
 * The event name dictionary key for the \ref YOTrackingEventNotification notification.
 */
extern NSString* const YOEventNameKey;

#endif /* YOAnalyticEvents_h */
