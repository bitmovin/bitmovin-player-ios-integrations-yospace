/*
 * COPYRIGHT 2020 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <Foundation/Foundation.h>

/**
 * @brief Represents an XML node.
 *
 * Encapsulates the data of an XML node: its attributes, inner text and children.
 */
@interface YOXmlNode : NSObject

/** Defines the common name of the element. */
@property (nonnull, readonly) NSString* name;

/** Defines the namespace URI of the element. */
@property (nonnull, readonly) NSString* namespaceUri;

/** Defines the qualified name of the element. */
@property (nonnull, readonly) NSString* qualifiedName;

/** Contains the attributes of the element, keyed on name. */
@property (nonnull, readonly) NSDictionary* attributes;

/** Defines the inner text the element. */
@property (nonnull, readonly) NSString* innerText;

/**
 * Returns the value of the requested attribute or 'nil' if the attibute does not exist.
 *
 * @param name The attribute name.
 * @return An string representing the attribute's value.
 */
- (nullable NSString*) attribute:(nonnull NSString*)name;

/**
 * Returns the child nodes of the element, or `nil` if there are none.
 *
 * @return an array of child nodes, or `nil`.
 */
- (nullable NSArray*) childNodes;

@end
