/*
 * COPYRIGHT © 2019 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>
#import "YSAdManagement.h"

/** The YSXmlNode protocol provides an interface to an Xml node, which represents a portion of an 
    XML tree, for example the <Extension> node of a VAST document.
 */
@protocol YSXmlNode <NSObject>

/** Returns the local name of the element.
 
 @return The element name.
 @since from 1.9
 */
- (NSString* _Nonnull) localName;

/** Returns the local name of the element.
 
 @return The qualified element name.
 @since from 1.9
 */
- (NSString* _Nonnull) qualifiedName;

/** Returns the local name of the element.
 
 @return The namespace in which the element is defined.
 @since from 1.9
 */
- (NSString* _Nonnull) namespaceUri;

/** Returns the attributes of the element, keyed on name.
 
 @return The attributes.
 @since from 1.9
 */
- (NSDictionary* _Nonnull) attributes;

/** Returns the inner text of the element.
 
 @return the inner text of the element or nil.
 @since from 1.9
 */
- (NSString* _Nullable) text;

/** Returns an array of child elements for this element.
 
 @return an array of zero or more YSXmlNode elements.
 @since from 1.9
 */
- (NSArray* _Nonnull) children;

@end
