/*
 * COPYRIGHT 2020 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <Foundation/Foundation.h>

/**
 * @brief Encapsulates an advert's wrapper data, parsed from the Yospace extension data of a VAST document.
 *
 * An advert wrapper may contain a child wrapper, representing a the next level of advert wrapper data that
 * contributed to the final advert.
 */
@interface YOAdvertWrapper : NSObject

/** Defines the identifier of the advert. */
@property (nonnull, readonly) NSString* identifier;

/** Defines the creative identifier of the advert. */
@property (nullable, readonly) NSString* creativeId;

/** Defines the ad system of the advert. */
@property (nullable, readonly) NSString* adSystem;

/** Holds the advert's child, or `nil` if there is no child. */
@property (nullable, readonly) YOAdvertWrapper* lineage;

@end
