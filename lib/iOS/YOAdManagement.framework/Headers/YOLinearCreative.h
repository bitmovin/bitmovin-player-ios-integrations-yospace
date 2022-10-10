/*
 * COPYRIGHT 2020-2022 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <Foundation/Foundation.h>
#import <YOAdManagement/YOCreative.h>

/**
 * @brief Represents a linear creative object.
 *
 * Encapsulates the data from the `<Linear>` element of a VAST document and represents the actual
 * video content of an advert.\n
 * The creative may contain one or more industry icons that can be overlaid on top of the video
 * to provide some extended functionality for the advert.
 *
 * @note The class implements YOCreativeEventHandling so that it can signal tracking events on behalf of a client.
 * Tracking events are signalled only when the creative is visible.
 *
 * @note Refer to the User Guide for details of the supported tracking events for this creative.
 */
@interface YOLinearCreative : YOCreative <YOCreativeEventHandling>

/** Contains a list of custom click URLs for the linear creative. */
@property (nullable, readonly) NSArray* customClickUrls;

@end
