/*
 * COPYRIGHT 2020 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <Foundation/Foundation.h>

/**
 * The YOVerificationEventHandling protocol declares a callback method to provide verification event information to an Ad Verification unit.\n
 * It is implemented by YOAdVerification and clients <b>must</b> call the method at the appropriate time in order for analytics
 * to be broadcast correctly.
 */
@protocol YOVerificationEventHandling <NSObject>

/**
 * Indicates that a verification event occurred for the element.\n
 * Clients should call this method in order to signal a verification event to the SDK.\n
 * Clients may require to set macro substitutions in the advert in advance of calling this method.
 *
 * @param event The event name.
 * @param reason The reason code as described in the VAST specification.
 */
- (void) verificationEventDidOccur:(nonnull NSString*)event reason:(NSInteger)reason;

@end
