/*
 * COPYRIGHT 2020 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <Foundation/Foundation.h>

/**
 * @brief Represents a VAST property of an element in a VAST document.
 *
 * It is used by several Core objects as a container for the object's name-value pairs.\n
 * For a list of possible properties refer to the containing class.
 */
@interface YOVASTProperty : NSObject

/** Defines the name of the inline attribute. */
@property (nonnull, readonly) NSString* name;

/** Defines the value of the inline attribute. */
@property (nonnull, readonly) NSString* value;

/**
 * Returns a set of attribute key/value pairs for the inline property, if applicable.
 *
 * @return A dictionary of attributes as string pairs, which may be empty.
 */
- (nonnull NSDictionary*) attributes;

@end
