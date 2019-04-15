/*
 * COPYRIGHT © 2018 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>

/** The YSAdvertWrapper protocol provides an interface to an advert's wrapper data
 */
@protocol YSAdvertWrapper <NSObject>

/** Returns the advert identifier.
 
 @return The advert wrapper identifier.
 @since from 1.8
 */
- (NSString* _Nonnull) wrapperIdentifier;

/** Returns the advert identifier.
 
 @return The advert wrapper's creative identifier.
 @since from 1.8
 */
- (NSString* _Nonnull) wrapperCreativeIdentifier;

/** Returns the advert wrapper's ad system.
 
 @return The advert wrapper's adSystem.
 @since from 1.8
 */
- (NSString* _Nonnull) wrapperAdSystem;

/** Returns the advert wrapper's child wrapper or nil if there is none.
 
 @return The advert wrapper's child.
 @since from 1.8
 */
- (id<YSAdvertWrapper> _Nullable) wrapperChild;

@end
