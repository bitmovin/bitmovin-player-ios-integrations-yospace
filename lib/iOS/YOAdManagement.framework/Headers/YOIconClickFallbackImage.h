/*
 * COPYRIGHT 2020-2021 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <Foundation/Foundation.h>

@class YOVASTProperty;
@class YOResource;

/**
 * @brief Represents an iconclick fallback image object.
 *
 * Encapsulates the data from the `<IconClickFallbackImage>` element of a VAST document.\n
 * It is a graphic that is used when a target platform does not support HTML rendering: the information
 * is provided as an image instead.
 */
@interface YOIconClickFallbackImage : NSObject

/** Defines the alt text of the iconclick fallback image. */
@property (nullable, readonly) NSString* altText;

/**
 * Defines the static resource of the iconclick fallback image.
 *
 * @see YOResource
 */
@property (nullable, readonly) YOResource* resource;

/**
 * Returns the properties for the iconclick fallback image. The properties are represented as YOVASTProperty objects.
 * Possible properties are:
 * - width
 * - height
 * .
 *
 * @return An array of objects that represent the properties of the iconclick fallback image.
 * @see YOVASTProperty
 */
- (nonnull NSArray*) properties;

/**
 * Returns a named property for the iconclick fallback image if it exists. Possible properties are:
 * - width
 * - height
 * .
 *
 * @param name The property name.
 * @return The requested property or `nil` if it does not exist.
 * @see YOVASTProperty
 */
- (nullable YOVASTProperty*) property:(nonnull NSString*)name;

@end
