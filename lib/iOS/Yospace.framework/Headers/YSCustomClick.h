/*
 * COPYRIGHT © 2019 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>

/** The YSCustomClick protocol provides an interface to a customClick element of the advert's linear creative.
 */
@protocol YSCustomClick <NSObject>

/** Returns the URL of the custom click element.
 
 @return The custom click URL.
 @since from 1.2
 */
- (NSURL* _Nonnull) customClickURL;

/** Returns the custom click identifier.
 
 @return The identifier.
 @since from 1.2
 */
- (NSString* _Nonnull) customClickIdentifier;

@end
