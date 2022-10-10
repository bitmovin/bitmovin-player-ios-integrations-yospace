/*
 * COPYRIGHT 2020-2022 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <Foundation/Foundation.h>
#import <YOAdManagement/YOCreativeEventHandling.h>
#import <YOAdManagement/YOAdManagementTypes.h>

@class YOVASTProperty;
@class YOResource;

/**
 * @brief Represents an industry icon object.
 *
 * Encapsulates the data from the `<Icon>` element of a VAST document.\n
 * It is a graphic that overlays a small portion of the advert's video and is sometimes clickable.
 *
 * @note The class implements YOCreativeEventHandling so that it can signal tracking events on behalf of a client.
 * Tracking events are signalled only when the industry icon is visible.
 *
 * @note Refer to the User Guide for details of the supported tracking events for this industry icon.
 */
@interface YOIndustryIcon : NSObject <YOCreativeEventHandling>

/**
 Returns whether the industry icon is visible.
 @return YES if the industry icon is visible NO otherwise.
 */
- (BOOL) isVisible;

/**
 * Defines the URL to open as a destination page when the user clicks on the industry icon or `nil` if the icon has no clickthrough URL.
 *
 * @return A string representing the clickthrough URL, or `nil`.
 */
- (nullable NSString*) clickThroughUrl;

/**
 * Returns the properties for the industry icon. The properties are represented as YOVASTProperty objects. Possible properties are:
 * - program
 * - width
 * - height
 * - xPosition
 * - yPosition
 * - offset
 * - duration
 * - apiFramework
 * .
 *
 * @return An array of objects that represent the properties of the icon.
 * @see YOVASTProperty
 */
- (nonnull NSArray*) properties;

/**
 * Returns a named property for the industry icon if it exists. Possible properties are
 * - program
 * - width
 * - height
 * - xPosition
 * - yPosition
 * - offset
 * - duration
 * - apiFramework
 * .
 *
 * @param name The property name.
 * @return The requested property or `nil` if it does not exist.
 * @see YOVASTProperty
 */
- (nullable YOVASTProperty*) property:(nonnull NSString*)name;

/**
 * Returns the resources for the industry icon. Each dictionary entry contains an array of resources (YOResource) keyed on the resource type (YOResourceType).\n
 * The resource type key is packaged in an NSNumber object, for example: `[NSNumber numberWithInt:YOStaticResource]`.\n
 * The three resource types are optional elements; the dictionary will contain between one and three entries.\n
 *
 * @return a dictionary containing resources for the icon, keyed on the resource type.
 * @see YOResourceType
 * @see YOResource
 */
- (nonnull NSDictionary*) resources;

/**
 * Returns the resource of the requested type or `nil` if the industry icon does not have that resource type.
 *
 * @param type The resource type
 * @return A resource of the requested type, or `nil`.
 * @see YOResourceType
 * @see YOResource
 */
- (nullable YOResource*) resourceOfType:(YOResourceType)type;

/**
 * Contains an array of iconclick fallback images for this industry icon.
 *
 * @return An array of icon click fallback images, which may be empty.
 * @see YOIconClickFallbackImage
 */
- (nonnull NSArray*) clickFallbackImages;

@end
