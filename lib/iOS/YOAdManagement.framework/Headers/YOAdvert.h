/*
 * COPYRIGHT 2020-2022 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <Foundation/Foundation.h>
#import <YOAdManagement/YOAdvertEventHandling.h>
#import <YOAdManagement/YOAdManagementTypes.h>

@class YOLinearCreative;
@class YOAdvertWrapper;
@class YOIndustryIcon;
@class YOXmlNode;
@class YOVASTProperty;
@class YOInteractiveCreative;

/**
 * @brief Represents an advert object.
 *
 * The advert encapsulates the data from the `<Ad>` and `<inline>` element of a VAST document: its
 * attributes, creatives and positional information.
 * Through YOAdvertEventHandling it supports the ability for a client app to signal error, viewable and impression events.
*/
@interface YOAdvert : NSObject <YOAdvertEventHandling>

/** Defines the start time of the advert, in seconds. */
@property (readonly) NSTimeInterval start;

/** Defines the identifier of the advert. */
@property (nonnull, readonly) NSString* identifier;

/** Defines the Yospace identifier associated with the ingested advert media. */
@property (nonnull, readonly) NSString* mediaIdentifier;

/** Defines the adType of the advert. */
@property (nullable, readonly) NSString* adType;

/** Defines the duration of the advert, in seconds. */
@property (readonly) NSTimeInterval duration;

/** Defines whether the advert has been watched to completion. */
@property (readonly) BOOL isActive;

/** Defines whether the advert represents filler content. */
@property (readonly) BOOL isFiller;

/**
 * Contains an interactive creative for the advert or `nil` if the advert is not an interactive media.
 *
 * @see YOInteractiveCreative
 */
@property (nullable, readonly) YOInteractiveCreative* interactiveCreative;

/**
 * Contains an object representing the advert's wrapper data as a one-way 'linked list', which may be nil.
 *
 * @see YOAdvertWrapper
 */
@property (nullable, readonly) YOAdvertWrapper* lineage;

/** Defines the sequence of the advert. */
@property (readonly) NSInteger sequence;

/** Defines the delay in seconds before the advert can be skipped, or -1 if the advert is not skippable. */
@property (readonly) NSTimeInterval skipOffset;

/**
 * Contains a list of zero or more industry icons for the advert.
 *
 * @see YOIndustryIcon
 */
@property (nonnull, readonly) NSArray* industryIcons;

/**
 * Defines the XML extension data for the advert.
 *
 * @see YOXmlNode
 */
@property (nullable, readonly) YOXmlNode* extensions;

/**
 * Defines the linear creative for the advert.
 *
 * @see YOLinearCreative
 */
@property (nonnull, readonly) YOLinearCreative* linearCreative;

/**
 * Contains the inline properties for the advert. The properties are represented as YOVASTProperty objects. Possible properties are:
 * - AdSystem (Defines the source ad server of the advert)
 * - AdTitle (Defines the common name of the advert)
 * - AdServingId (Defines an identifier used to compare impression-level data across systems)
 * - Category (Defines the category of the advert content)
 * - Description (Defines a longer description of the advert)
 * - Advertiser (Defines the advertiser name)
 * - Pricing (Defines the pricing element of the advert)
 * - Survey (Defines a URI to any resource file having to do with collecting survey data)
 * - Expires (Defines the number of seconds in which the ad is valid for execution)
 * .
 * @see YOVASTProperty
 */
@property (nonnull, readonly) NSArray* properties;

/**
 * Returns a named inline property for the advert if it exists. Possible properties are:
 * - AdSystem (Defines the source ad server of the advert)
 * - AdTitle (Defines the common name of the advert)
 * - AdServingId (Defines an identifier used to compare impression-level data across systems)
 * - Category (Defines the category of the advert content)
 * - Description (Defines a longer description of the advert)
 * - Advertiser (Defines the advertiser name)
 * - Pricing (Defines the pricing element of the advert)
 * - Survey (Defines a URI to any resource file having to do with collecting survey data)
 * - Expires (Defines the number of seconds in which the ad is valid for execution)
 * .
 * @param name The name of the property.
 * @return The requested property or `nil`.
 * @see YOVASTProperty
 */
- (nullable YOVASTProperty*) property:(nonnull NSString*)name;

/**
 * Returns the NonLinear creatives for this advert that are of a specific resource type.
 *
 * @param type The resource type.
 * @return An array of NonLinear Creative or `nil` if the requested type does not exist.
 * @see YOResourceType
 * @see YONonLinearCreative
 */
- (nullable NSArray*) nonLinearCreatives:(YOResourceType)type;

/**
 * Returns the companion creatives for this advert that are of a specific resource type.
 *
 * @param type The resource type.
 * @return An array of YOCompanionCreative or `nil` if the requested type does not exist.
 * @note Use YOUnknownResource to obtain YOCompanionCreative that contain tracking events but no YOResource.
 * @see YOResourceType
 * @see YOCompanionCreative
 */
- (nullable NSArray*) companionAds:(YOResourceType)type;

/**
 * Returns an array of verification objects used to execute third-party measurement code for an advert.
 *
 * @return An array of ad verification objects, which may be empty
 * @see YOAdVerification
 */
- (nonnull NSArray*) adVerifications;

/**
 * Returns the amount of natural time remaining for the advert from the given playhead position.\n
 * The value returned has a maximum value of the advert duration and a minimum value of zero.
 *
 * @param playhead The playhead position, in seconds.
 * @return The amount of time remaining, in seconds.
 */
- (NSTimeInterval) remainingTime:(NSTimeInterval)playhead;
/**
 * Adds an entry to the client macro substitutions dictionary such that any tracking URL containing
 * a macro matching the key will be substituted with the entry's value.\n
 * For example and entry of key: `CLIENTUA` and value: `clientUserAgent` replaces the querystring parameter cua=[CLIENTUA]
 * or cua=%5BCLIENTUA%5D with `cua=%5BclientUserAgent%5D`.\n
 * See the VAST specification for a list of client macros. Note that server-side macros are replaced by the CSM and that the
 * SDK replaces dynamic macros such as `CONTENTPLAYHEAD` and `ASSETURI`.
 *
 * @param value The macro substitution value.
 * @param key The macro name.
 */
- (void) addMacroSubstitution:(nonnull NSString*)value forKey:(nonnull NSString*)key;

/**
 * Removes the specified macro substitution if present.
 *
 * @param key The macro name.
 */
- (void) removeMacroSubstitution:(nonnull NSString*)key;

/**
 * Returns the dictionary of macro substitutions.
 *
 * @return A dictionary of macro strings.
 */
- (nonnull NSDictionary*) macroSubstitutions;

@end
