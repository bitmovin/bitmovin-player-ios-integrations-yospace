/*
 * COPYRIGHT 2020-2021 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <Foundation/Foundation.h>

/**
 * The YOAdBreakEventHandling protocol declares a set of methods to allow clients to signal events so that the SDK
 * can fire analytics on behalf of the client.
 */
@protocol YOAdBreakEventHandling <NSObject>

/** Indicates that a tracking event occurred for a non-linear ad break. The SDK fires beacons for any `<Tracking>` URLs
 *  defined for the ad break.
 *  Clients should call this method in order to fire the appropriate tracking beacon, which may be `breakStart` or `breakEnd`.
 *  @note `error` event is not supported.
 *
 *  @param event The non-linear tracking event.
 *  @note Clients should call this method only for non-linear ad breaks. Calling this method on a linear ad break has no effect.
 */
- (void) nonLinearTrackingEventDidOccur:(nonnull NSString*)event;

@end
