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
 * @brief Represents a nonlinear creative object.
 *
 * Encapsulates the data from the `<NonLinear>` element of a VAST document.\n
 * It is usually a graphic that overlays a small portion of the advert's video and is normally clickable.
 *
 * @note The class implements YOCreativeEventHandling so that it can signal tracking events on behalf of a client.
 * Tracking events are signalled only when the creative is visible.
 *
 * @note Refer to the User Guide for details of the supported tracking events for this creative.
 */
@interface YONonLinearCreative : YOCreative <YOCreativeEventHandling>

/**
 Returns whether the nonlinear creative is visible.
 @return YES if the creative is visible NO otherwise.
 */
- (BOOL) isVisible;

/**
 * Returns the properties for the nonlinear creative. The properties are represented as YOVASTProperty objects. Possible properties are:
 * - id
 * - width
 * - height
 * - expandedWidth
 * - expandedHeight
 * - minimumSuggestedDuration
 * - scalable
 * - maintainAspect
 * - apiFramework
 * .
 * @return An array of objects that represent the properties of the nonlinear creative.
 * @see YOVASTProperty
 */
- (nonnull NSArray*) properties;

/**
 * Returns a named property for the nonlinear creative if it exists. Possible properties are:
 * - id
 * - width
 * - height
 * - expandedWidth
 * - expandedHeight
 * - minimumSuggestedDuration
 * - scalable
 * - maintainAspect
 * - apiFramework
 * .
 *
 * @param name The property name.
 * @return The requested property or `nil` if it does not exist.
 * @see YOVASTProperty
 */
- (nullable YOVASTProperty*) property:(nonnull NSString*)name;

/**
 * Returns the resources for the nonlinear creative. Each dictionary entry contains an array of resources (YOResource) keyed on the resource type (YOResourceType).\n
 * The resource type key is packaged in an NSNumber object, for example: `[NSNumber numberWithInt:YOStaticResource]`.\n
 * The three resource types are optional elements; the dictionary will contain between one and three entries.
 *
 * @return a dictionary containing resources for the nonlinear creative, keyed on the resource type.
 */
- (nonnull NSDictionary*) resources;

/**
 * Returns the resource of the requested type or `nil` if the nonlinear creative does not have that resource type.
 *
 * @param type The resource type.
 * @return A resource of the requested type, or `nil`.
 * @see YOResourceType
 * @see YOResource
 */
- (nullable YOResource*) resourceOfType:(YOResourceType) type;

@end
