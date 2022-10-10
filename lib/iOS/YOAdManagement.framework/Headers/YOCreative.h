/*
 * COPYRIGHT 2020 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <Foundation/Foundation.h>
#import <YOAdManagement/YOCreativeEventHandling.h>
#import <YOAdManagement/YOAdManagementTypes.h>

@class YOXmlNode;
@class YOVASTProperty;

/**
 * @brief Represents a creative object.
 *
 * Encapsulates the data from the `<Creative>` element of a VAST document and is the base class for three types:
 * - `Linear` - the creative that represents the linear portion of an advert i.e. the actual video content.
 * - `NonLinear` - the creative that is usually a graphic that overlays a small portion of the advert's video and is normally clickable.
 * - `Companion` - the creative that is normally presented outside the video player.
 * .
*/
@interface YOCreative : NSObject

/** Defines the identifier of the creative. */
@property (nullable, readonly) NSString* creativeIdentifier;

/** Defines the advert identifier of the creative. */
@property (nullable, readonly) NSString* advertIdentifier;

/**
 * Defines the ad parameters of the creative.
 *
 * @see YOVASTProperty
 */
@property (nullable, readonly) YOVASTProperty* adParameters;

/** Defines the sequence of the creative. */
@property (readonly) NSInteger sequence;

/**
 * Defines the XML extension data for the creative.
 *
 * @see YOXmlNode
 */
@property (nullable, readonly) YOXmlNode* extensions;

/**
 * Returns the clickthrough URL for this creative.
 *
 * @return A string representing the clickthrough URL, or `nil` if one is not defined.
 */
- (nullable NSString*) clickthroughUrl;

/**
 * Returns an array of universal AdIds for this creative as YOVASTProperty objects.
 *
 * @return An array of universal AdIds as strings.
 */
- (nonnull NSArray*) universalAdIds;

@end
