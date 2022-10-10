/*
 * COPYRIGHT 2020-2022 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <Foundation/Foundation.h>

/**
 * The YOCreativeEventHandling protocol declares a set of callback methods to provide event information to a Creative or Industry Icon.\n
 * It is implemented by YOLinearCreative, YONonLinearCreative, YOCompanionCreative, YOInteractiveCreative and YOIndustryIcon
 * and clients <b>must</b> call each method at the appropriate time in order for analytics to be signalled correctly.
 */
@protocol YOCreativeEventHandling <NSObject>

/** Indicates that the user clicked on the element. If a `ClickTracking` event is defined in the VAST document for the Creative
 *  then the SDK will fire that tracking beacon.
 */
- (void) clickThroughDidOccur;

/** Indicates that a tracking event occurred for the element.
 *
 * If the event is defined in the `<Tracking>` element for the Creative then the SDK will fire that tracking beacon.
 * For a list of supported events, please refer to the Creative that implements this protocol.
 *
 * @param event The tracking event name, or a tracking URL.
 * @note This handler should be raised only for events that are not directly supported through any other API.
 */
- (void) trackingEventDidOccur:(nonnull NSString*)event;

/** Defines whether the creative is visible.
 * For a list of supported events, please refer to the Creative that implements this protocol.
 * @param visible Describes whether the creative is visible.
 * @note Tracking events are fired only for creatives that are visible.
 * @note Does not apply to Linear creative.
 */
- (void) setVisible:(BOOL)visible;

@end
