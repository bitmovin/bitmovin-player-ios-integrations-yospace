/*
 * COPYRIGHT © 2018 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>
#import "YSInteractiveUnit.h"

/** The YSLinearCreative protocol provides an interface to an advert's linear creative object - if VAST is associated with the advert, and whose details are passed as a payload during analytic callbacks.
 
 */
@protocol YSLinearCreative <NSObject>

/** Returns the linear creative's identifier.
 
 @return The identifier.
 @since from 1.0
 */
- (NSString* _Nullable) linearIdentifier;

/** Returns the linear creative's sequence number.
 
 @return The sequence identifier.
 @since from 1.0
 */

- (NSString* _Nullable) linearSequenceIdentifier;

/** Returns the nonlinear creative's Ad identifier.
 
 @return The Ad identifier.
 @since from 1.0
 */
- (NSString*_Nullable) linearAdIdentifier;

/** Returns the linear creative's clickthrough URL.
 
 @return The clickthrough URL.
 @since from 1.0
 */
- (NSURL* _Nullable) linearClickthroughURL;

/** Returns the linear creative's custom click URL elements.
 
 @return The custom click URLs.
 @since from 1.2
 */
- (NSArray* _Nullable) customClickURLs;

/** Returns an array of zero or more industry icons associated with this linear creative.
 
 @return an NSArray of YOIndustryIcon associated with this linear creative.
 @since from 1.2
 */
- (NSArray* _Nonnull) linearIndustryIcons;

/** Returns an interactive unit for this linear creative, or nil if there is none.
 
 @return A YSInteractiveUnit object, or nil if the linear creative does not have an interactive unit.
 @since from 1.4
 */
- (id<YSInteractiveUnit> _Nullable) interactiveUnit;

/** Returns the value of `skipoffset` defined in the VAST for this linear creative, or -1 if it not defined;
 
 @return the skip offset.
 @since from 1.7
 */
- (NSTimeInterval) linearSkipOffset;

@end
