/*
 * COPYRIGHT 2020-2022 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <Foundation/Foundation.h>
#import <YOAdManagement/YOAdBreakEventHandling.h>
#import <YOAdManagement/YOAdManagementTypes.h>

@class YOXmlNode;

/**
 * @brief Represents an ad break object.
 *
 * The ad break encapsulates the data from the `<vmap:AdBreak>` element of a VMAP document: its
 * attributes, adverts and positional information.
 * Through YOAdBreakEventHandling it supports the ability for a client app to signal non-linear events.
 */
@interface YOAdBreak : NSObject <YOAdBreakEventHandling>

/** Defines the identifier of the ad break. */
@property (nullable, readonly) NSString* identifier;

/** Defines the start time of the ad break, in seconds. */
@property (readonly) NSTimeInterval start;

/** Defines the duration of the ad break, in seconds. */
@property (readonly) NSTimeInterval duration;

/** Defines the position of the ad break, which may be one of:
 * - preroll
 * - midroll
 * - postroll
 * - unknown
 * .
 */
@property (nonnull, readonly) NSString* position;

/** Defines the type of the ad break, as defined by the IAB VMAP specification. */
@property (readonly) YOAdBreakType breakType;

/**
 * Defines the XML extension data for the ad break.
 *
 * @see YOXmlNode
 */
@property (nullable, readonly) YOXmlNode* extensions;

/**
 * Contains the adverts for the ad break.
 *
 * @see YOAdvert
 */
@property (nonnull, readonly) NSMutableArray* adverts;

/**
 * Declares whether the ad break is active, that is, whether any of its adverts have not yet been played.
 *
 * @return `YES` if the ad break is active, `NO` otherwise.
 */
- (BOOL) isActive;

/**
 * Sets the ad break inactive by setting all of its adverts inactive.\n
 * The SDK will not signal analytics for inactive adverts.
 */
- (void) setInactive;

/**
 * Returns the amount of natural time remaining for the ad break from the given playhead position.\n
 * The value returned has a maximum value of the advert duration and a minimum value of zero.
 *
 * @param playhead The playhead position, in seconds.
 * @return The amount of time remaining, in seconds.
 */
- (NSTimeInterval) remainingTime:(NSTimeInterval)playhead;

@end
