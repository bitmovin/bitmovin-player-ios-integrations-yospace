/*
 * COPYRIGHT 2020-2021 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <Foundation/Foundation.h>
#import <YOAdManagement/YOVerificationEventHandling.h>

@class YOVASTProperty;
@class YOResource;

/**
 * @brief Represents an ad verification object.
 *
 * Encapsulates the data from the `<AdVerification>` element of a VAST document: its
 * attributes, parameters and resources.
 * Through YOVerificationEventHandling it supports the ability for a client app to signal verification events.
*/
@interface YOAdVerification : NSObject <YOVerificationEventHandling>

/** Defines the vendor of the AdVerification. */
@property (nullable, readonly) NSString* vendor;

/** Defines the verificationParameters of the AdVerification. */
@property (nullable, readonly) NSString* verificationParameters;

/**
 * Contains the resources for the ad verification object. The resources are represented as YOVASTProperty objects.\n
 * Each resource will be either an ExecutableResource or JavaScriptResource as defined by the VAST specification.\n
 * An ExecutableResource contains up to two attributes in the VASTProperty object: apiFramework and type.\n
 * A JavaScriptResource contains up tp two attributes in the VASTProperty object: apiFramework and browserOptional.
 *
 * @return An array of resources for this ad verification object.
 * @see YOVASTProperty
 */
- (nonnull NSArray*) resources;

@end
