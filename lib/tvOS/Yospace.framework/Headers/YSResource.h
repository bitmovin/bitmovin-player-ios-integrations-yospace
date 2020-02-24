/*
 * COPYRIGHT © 2019 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>
#import "YSAdManagement.h"

/** The YSResource protocol provides an interface to a resource of the advert's nonlinear creative or its Industry Icon.
 */
@protocol YSResource <NSObject>

/** Returns the URL to the resource if the type is YSEStaticResource or YSEIFrameResource,
    or nil if the type is YSEHTMLResource.
 
 @return The URL to the resource.
 @since from 1.9
 */
- (NSString* _Nullable) sourceUrl;

/** Returns the string data to the resource if the type is YSEHTMLResource,
 or nil if the type is YSEStaticResource or YSEIFrameResource.

 @return The string data of the resource.
 @since from 1.9
 */
- (NSString* _Nullable) stringData;

/** Returns the byte data to the resource if the type is YSEStaticResource or YSEIFrameResource
 and the resource has been pre-fetched, or nil if the type is YSEHTMLResource.
 
 @return The byte data of the resource.
 @since from 1.9
 */
- (NSData* _Nullable) byteData;

/** Returns the resource type.
 
 @return The type of the resource.
 @since from 1.9
 */
- (YSEResourceType) resourceType;

/** Returns the MIME type if this is a static resource, nil otherwise.
 
 @return The MIME type of the resource.
 @since from 1.9
 */
- (NSString* _Nullable) creativeType;

/** Returns whether this HTML resource is encoded, always false if the resource is not HTML.
 
 @return whether the HTML resource is encoded
 @since from 1.9
 */
- (BOOL) isEncoded;

@end
