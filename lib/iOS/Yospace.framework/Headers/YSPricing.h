/*
 * COPYRIGHT © 2018 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>
#import "YSAdManagement.h"

/** The YSPricing protocol provides an interface to the pricing element of the advert's linear creative.
 */
@protocol YSPricing <NSObject>

/** Returns the value of the pricing element.
 
 @return The pricing value.
 @since from 1.2
 */
- (float) pricingValue;

/** Returns the pricing currency.
 
 @return The currency.
 @since from 1.2
 */
- (NSString* _Nonnull) pricingCurrency;

/** Returns the pricing model.
 
 @return An enumeration representing the pricing model.
 @see YSEPricingModel
 @since from 1.2
 */
- (YSEPricingModel) pricingModel;

@end
