/*
* COPYRIGHT 2020 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
* The contents of this file are proprietary and confidential.
* Unauthorised copying of this file, via any medium is strictly prohibited.
*/

#import <Foundation/Foundation.h>
#import "YSAdManagement.h"
#import "YSUIProperties.h"
#import "YSXmlNode.h"

/** The YSCompanionCreative protocol provides an interface to an advert's companion creative object - if VAST is associated with the advert, and whose details are passed as a payload during analytic callbacks. There may be zero or more companion creatives associated with an advert.
  */
@protocol YSCompanionCreative <NSObject>

/** Returns the companion creative's identifier. This is the `id` attribute of the `<Companion>`.
 
 @return The identifier, or nil.
 @since from 1.12
 */
- (NSString* _Nullable) companionIdentifier;

/** Returns the creative's identifier.  This is the `id` attribute of the `<Creative>`.
 
 @return The identifier, or nil.
 @since from 1.12
 */
- (NSString* _Nullable) creativeIdentifier;

/** Returns the companion creative's sequence number. This is the `sequence` attribute of the `<Creative>`.
 
 @return The sequence number.
 @since from 1.12
 */
- (NSString* _Nullable) sequenceNumber;

/** Returns the companion creative's Ad identifier. This is the `AdID` attribute of the `<Creative>`.
 
 @return The Ad identifier, or nil.
 @since from 1.12
 */
- (NSString* _Nullable) adIdentifier;

/** Returns the companion creative's alternative text. This is the value of the `AltText` child element of the `<Companion>`.
 
 @return The alternative text, or nil.
 @since from 1.12
 */
- (NSString* _Nullable) alternativeText;

/** Returns the companion creative's Ad slot Id. This is the `adSlotId` attribute of the `<Companion>`.
 
 @return The Ad slot Id, or nil.
 @since from 1.12
 */
- (NSString* _Nullable) adSlotIdentifier;

/** Returns the companion creative's clickthrough URL.
 
 @return The clickthrough URL, or nil.
 @since from 1.12
 */
- (NSURL* _Nullable) clickThroughURL;

/** Returns the companion creative's user interface properties, which include dimension values.
 
 @return The user interface properties.
 @since from 1.12
 */
- (id<YSUIProperties> _Nonnull) userInterfaceProperties;

/** Returns any adParameters associated with this companion creative.<br/>
 Note that the string is always XML encoded.
 
 @return adParameters associated with this companion creative, or nil.
 @since from 1.12
 */
- (NSString* _Nullable) adParameters;

/** Returns the API Framework used by this companion creative, or nil if there is none.<br/>
 
 @return The API framework used this companion creative, or nil.
 @since from 1.12
 */
- (NSString* _Nullable) apiFramework;

/** Returns any companion creative extension data or nil if there is none.

@return A YSXmlNode representing the <Extensions> element. Children of this object represent the extension data
@see YSXmlNode
@since from 1.12
*/
- (id<YSXmlNode> _Nullable) extensions;

/** Returns the companion creative's source URL.
 
 @return The source URL.
 @since from 1.12
 */
- (NSURL* _Nonnull) creativeSource;

/** Returns the companion creative's pre-loaded resource, if pre-loading of VAST resources are enabled
 for this type. Pre-loading policy is defined in YSSessionProperties.
 
 @return The pre-loaded resource as an NSData or nil.
 @since from 1.12
 */
- (NSData* _Nullable) creativeElement;

@end
