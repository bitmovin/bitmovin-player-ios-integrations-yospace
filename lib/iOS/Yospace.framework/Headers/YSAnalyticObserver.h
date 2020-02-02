/*
 * COPYRIGHT © 2019 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>
#import "YSStream.h"
#import "YSAdBreak.h"
#import "YSAdvert.h"
#import "YSNonLinearCreative.h"
#import "YSIndustryIcon.h"

/** The YSAnalyticObserver protocol declares a set of callback methods to provide content and Advert analytics during playback.
 
 */
@protocol YSAnalyticObserver <NSObject>

@optional

/**---------------------------------------------------------------------------------------
 * @name Content Analytics
 *  ---------------------------------------------------------------------------------------
 */

/** Indicates that VOD or Non-linear Start Over video content began.
 
 @param playheadPosition The playhead position at the point content started.
 @since from 1.0
 */
- (void) contentDidStart:(NSTimeInterval)playheadPosition;

/** Indicates that VOD or Non-Linear Start Over video content passed from a content section to an ad section.
 
 @param playheadPosition The playhead position at the point content paused.
 @since from 1.0
 */
- (void) contentDidPause:(NSTimeInterval)playheadPosition;

/** Indicates that VOD or Non-Linear Start Over video content passed from an ad section to a content section.
 
 @param playheadPosition The playhead position at the point content resumed.
 @since from 1.0
 */
- (void) contentDidResume:(NSTimeInterval)playheadPosition;

/** Indicates that VOD or Non-Linear Start Over video content ended.
 
 @param playheadPosition The playhead position at the point content ended.
 @since from 1.0
 */
- (void) contentDidEnd:(NSTimeInterval)playheadPosition;

/**---------------------------------------------------------------------------------------
 * @name Ad Analytics
 *  ---------------------------------------------------------------------------------------
 */

/** Indicates that a linear creative tracking event for an advert occured. Valid events are defined by YSETrackingEvent and may be:<br/><br/>
 
    - <code>YSEImpressionEvent</code><br/>
    - time-based (e.g. <code>YSEMidpointEvent</code>, <code>YSECompleteEvent</code>) or<br/>
    - interaction based (e.g. <code>YSEMuteEvent</code>)
 
 @param event The linear creative tracking event type.
 @param advert The advert.
 @since from 1.0
 @see YSAdvert
 @see YSETrackingEvent
 */
- (void) trackingEventDidOccur:(YSETrackingEvent)event forAdvert:(id<YSAdvert> _Nonnull)advert;

/** Indicates that a nonlinear creative tracking event occured. Valid events are defined by YSETrackingEvent and may be
 <code>creativeViewEvent</code> or interaction-based (e.g. <code>fullscreenEvent</code>).
 
 @param event The tracking event type.
 @param nonlinearCreative The nonlinear creative.
 @since from 1.2
 @see YSNonLinearCreative
 @see YSETrackingEvent
 */
- (void) trackingEventDidOccur:(YSETrackingEvent)event forNonLinearCreative:(id<YSNonLinearCreative> _Nonnull)nonlinearCreative;

/** Indicates that the start of an advert break was reached.
 
 @param adBreak The Ad Break, which may be `nil` in live playback if the data for the ad break is not yet available, for example when a stream starts with pre-roll.
 @since from 1.0
 */
- (void) advertBreakDidStart:(id<YSAdBreak> _Nullable)adBreak;

/** Indicates that the end of an advert break was reached.
 
 @param adBreak The Ad Break.
 @since from 1.0
 */
- (void) advertBreakDidEnd:(id<YSAdBreak> _Nonnull)adBreak;

/** Indicates that an advert was reached.
 
 @param advert A YSAdvert containing advert analytic data.
 @return an array of YSNonLinearCreative identifiers (as `NSString` objects) that will be shown for this advert.
 @since from 1.0
 */
- (NSArray* _Nullable) advertDidStart:(id<YSAdvert> _Nonnull)advert;

/** Indicates that the end of an advert was reached.
 
 @param advert A YSAdvert containing advert analytic data.
 @since from 1.0
 */
- (void) advertDidEnd:(id<YSAdvert> _Nonnull)advert;

/** Indicates that a linear click-through event occured, for example the user clicked on the video advert.
 
 @param linearCreative A YSLinearCreative for the advert. The click-through URL is obtained from the linear creative element.
 @since from 1.2
 */
- (void) linearClickThroughDidOccur:(id<YSLinearCreative> _Nonnull)linearCreative;

/** Indicates that a non-linear click-through event occured i.e. that the user clicked on a graphic overlay or button.
 
 @param nonlinearCreative A YSNonLinearCreative for the advert.
 @since from 1.2
 */
- (void) nonlinearClickThroughDidOccur:(id<YSNonLinearCreative> _Nonnull)nonlinearCreative;

/** Indicates that an icon click-through event occured i.e. taht the user clicked on the displayed icon.
 
 @param icon A YSIndustryIcon representing the icon.
 @since from 1.2
 */
- (void) iconClickThroughDidOccur:(id<YSIndustryIcon> _Nonnull)icon;

/** Indicates that an industry icon was displayed on the advert.
 
 @param icon A YSIndustryIcon representing the icon.
 @since from 1.2
 */
- (void) iconViewDidOccur:(id<YSIndustryIcon> _Nonnull)icon;

/** Indicates that a VAST payload was received from the Central Streaming Manager during playback of a live stream in respect
    of upcoming adverts.
 
 @param vast the VAST payload
 @since from 1.0
 */
- (void) vastPayloadReceived:(NSString* _Nonnull)vast;

/** Indicates that a VMAP payload was received and processed from the Central Streaming Manager during playback of a Non-Linear Start-Over stream in respect
 of upcoming adverts. A client can read the timeline from the YSSessionManager in order to construct a visual timeline or use the raw vmap data provided
 
 @param vmap the VMAP payload
 @since from 1.0
 */
- (void) timelineUpdateReceived:(NSString* _Nonnull)vmap;

@end
