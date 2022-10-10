/*
 * COPYRIGHT 2020-2022 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <Foundation/Foundation.h>
#import <YOAdManagement/YOAdManagementTypes.h>

/** The YOAdvertEventHandling protocol declares a set of methods to allow clients to signal events so that the SDK
 *  can fire analytics on behalf of the client.
 */
@protocol YOAdvertEventHandling <NSObject>

/** Indicates that an error occurred that is in the domain of the player / app. The SDK fires beacons for any `<Error>` URLs
 *  defined for the advert.
 *  @param errorCode the error code value that should be used in the ERRORCODE macro substitution, or zero if no substitution
 *  should be made.
 */
- (void) errorDidOccur:(NSInteger)errorCode;

/** Indicates that a viewable event occurred for a linear advert.
 *  Clients should call this method in order to fire the appropriate Viewable beacon.
 *
 *  @param event The event type.
 *  @see YOViewableEvent
 */
- (void) viewableEventDidOccur:(YOViewableEvent)event;

/** Indicates that an impression event occurred for a non-linear advert.
 *  Clients should call this method in order to fire impression beacons associated with the advert.
 *
 *  @note Clients should call this method only for adverts in a non-linear ad break. Calling this method
 *  on a linear advert has no effect.
 */
- (void) impressionEventDidOccur;

@end
