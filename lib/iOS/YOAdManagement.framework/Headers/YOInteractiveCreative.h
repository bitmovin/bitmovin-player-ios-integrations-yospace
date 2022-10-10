/*
 * COPYRIGHT 2022 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <Foundation/Foundation.h>
#import <YOAdManagement/YOCreativeEventHandling.h>

@class YOTrackingReport;
@class YOVASTProperty;

/**
 * @brief Represents an interactive creative object.
 *
 * Encapsulates the data from the `<InteractiveCreativeFile>` element of a VAST document.\n
 * It is used to provide a more interactive experience using additional creative functionality by making
 * use of a vendor's interactive APIs.
 *
 * @note The class implements YOCreativeEventHandling so that it can signal tracking events on behalf of a client.
 * Tracking events are signalled only when the creative is visible.
 *
 * @note Refer to the User Guide for details of the supported tracking events for this creative.
 */
@interface YOInteractiveCreative : NSObject <YOCreativeEventHandling>

/** Defines the source URL of the interactive creative. */
@property (nonnull, readonly) NSString* source;

/** Defines the duration of the advert media for the interactive creative, in seconds. */
@property (nonatomic, readonly) NSTimeInterval advertDuration;

/**
 Returns whether the interactive creative is visible.
 @return YES if the creative is visible NO otherwise.
 */
- (BOOL) isVisible;

/**
 * Defines the ad parameters of the interactive creative.
 *
 * @see YOVASTProperty
 */
@property (nullable, readonly) YOVASTProperty* adParameters;

/**
 * Returns the nonlinear creatives associated with the interactive creative. A nonlinear creative is related if its `apiFramework` property
 * is not empty and is the same as the interactive creative.
 *
 * @return An array of NonLinear creatives
 * @see YONonLinearCreative
 */
- (nullable NSArray*) nonLinearCreatives;

/**
 * Returns the properties for the interactive creative. The properties are represented as YOVASTProperty objects. Possible properties are:
 * - type
 * - apiFramework
 * - variableDuration
 * .
 * @return An array of objects that represent the properties of the interactive creative.
 * @see YOVASTProperty
 */
- (nonnull NSArray*) properties;

/**
 * Returns a named property for the interactive creative if it exists. Possible properties are
 * - type
 * - apiFramework
 * - variableDuration
 * .
 *
 * @param name The property name.
 * @return The requested roperty or `nil` if it does not exist.
 * @see YOVASTProperty
 */
- (nullable YOVASTProperty*) property:(nonnull NSString*)name;

@end
