/*
 * COPYRIGHT 2020,2022 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <Foundation/Foundation.h>
#import <YOAdManagement/YOAdManagementTypes.h>

/** 
 * @brief Represents a resource object for a Linear, NonLinear or Companion creative, or for an Industry Icon.
 *
 * Encapsulates the data from the `<Resource>` element of a VAST document.\n
 * It represents one of the following VAST resource types:
 * - StaticResource
 * - HTMLResource
 * - IFrameResource
 * .
 */
@interface YOResource : NSObject

/**
 * Defines the MIME type of the resource if it is of type `YOStaticResource`, `nil` otherwise.
 *
 * @see YOResourceType
 */
@property (nullable, readonly) NSString* creativeType;

/**
 * Contains the string data of the resource if it is of type `YOHTMLResource`, the URL to the resource otherwise.
 * 
 * @see YOResourceType
 */
@property (nullable, readonly) NSString* stringData;

/**
 * Contains the byte data of the resource if both of the following are true
 * - it is of type `YOStaticResource` or `YOIFrameResource`
 * - prefetching of resources is enabled through YOSessionProperties
 * .
 * The byte data is `nil` otherwise.
 *
 * @see YOResourceType
 */
@property (nullable, readonly) NSData* byteData;

/**
 * Defines whether the HTML stringData property is XML encoded if it is of type `YOHTMLResource`. For other
 * resource types the value is always `NO`.
 *
 * @see YOResourceType
 */
@property (readonly, getter=isEncoded) BOOL encoded;

/**
 * Defines the type for the resource.
 *
 * @see YOResourceType
 */
@property (readonly) YOResourceType type;

@end
