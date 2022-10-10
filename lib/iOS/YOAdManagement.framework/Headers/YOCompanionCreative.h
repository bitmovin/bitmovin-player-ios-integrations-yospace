/*
 * COPYRIGHT 2020-2022 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <Foundation/Foundation.h>
#import <YOAdManagement/YOCreative.h>

@class YOVASTProperty;
@class YOResource;

/**
 * @brief Represents a companion creative object.
 *
 * Encapsulates the data from the `<Companion>` element of a VAST document.\n
 * It is usually a creative that is displayed outside of the video player's rendering view.
 *
 * @note A Companion may contain one or more resources and/or tracking events. In the case that it contains only tracking events,
 *       the Companion can be obtained from its parent advert by requesting Companions with resource type YOUnknownResource.
 *
 * @note The class implements YOCreativeEventHandling so that it can signal tracking events on behalf of a client.
 * Tracking events are signalled only when the creative is visible.
 *
 * @note Refer to the User Guide for details of the supported tracking events for this creative.
 */
@interface YOCompanionCreative : YOCreative <YOCreativeEventHandling>

/**
 Returns whether the companion creative is visible.
 @return YES if the creative is visible NO otherwise.
 */
- (BOOL) isVisible;

/** Defines the alt text of the companion. */
@property (nullable, readonly) NSString* altText;

/**
 * Returns the properties for the companion creative. The properties are represented as YOVASTProperty objects. Possible properties are
 * - id
 * - width
 * - height
 * - assetWidth
 * - assetHeight
 * - expandedWidth
 * - expandedHeight
 * - adSlotId
 * - pxratio
 * - apiFramework
 * - renderingMode
 * .
 *
 * @return an array of objects that represent the properties of the companion creative.
 * @see YOVASTProperty
 */
- (nonnull NSArray*) properties;

/**
 * Returns a named property for the companion creative if it exists. Possible properties are
 * - id
 * - width
 * - height
 * - assetWidth
 * - assetHeight
 * - expandedWidth
 * - expandedHeight
 * - adSlotId
 * - pxratio
 * - apiFramework
 * - renderingMode
 * .
 *
 * @param name The property name.
 * @return The requested property or `nil` if it does not exist.
 * @see YOVASTProperty
 */
- (nullable YOVASTProperty*) property:(nonnull NSString*)name;

/**
 * Returns the resources for the companion creative. Each dictionary entry contains an array of resources keyed on the resource type (YOResourceType).\n
 * The resource type key is packaged in an NSNumber object, for example: `[NSNumber numberWithInt:YOStaticResource]`.\n
 * The three resource types are optional elements; the dictionary will contain between one and three entries.\n
 *
 * @return a dictionary containing resources for the companion, keyed on the resource type.
 * @see YOResource
 */
- (nonnull NSDictionary*) resources;

/**
 * Returns the resource of the requested type or `nil` if the companion does not have that resource type.
 *
 * @param type The resource Type.
 * @return A resource of the requested type, or `nil`.
 * @see YOResourceType
 * @see YOResource
 */
- (nullable YOResource*) resourceOfType:(YOResourceType) type;

@end
