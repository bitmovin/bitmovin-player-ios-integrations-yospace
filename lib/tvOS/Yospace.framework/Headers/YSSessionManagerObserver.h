/*
 * COPYRIGHT © 2019 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>
#import "YSStream.h"

@class YSSessionManager;

/** The YSSessionManagerObserver protocol declares a set of callback methods to provide interaction with a client during initialisation and when a stream is playing. It should be implemented by a single client in the application to complete the initialisation setup handshake.
 
 */
@protocol YSSessionManagerObserver <NSObject>

/**---------------------------------------------------------------------------------------
 * @name Initialisation
 *  ---------------------------------------------------------------------------------------
 */

@required
/** Indicates that initialisation is complete.
 
 @param sessionManager Contains an initialised YSSessionManager object.
 @param stream A YSStream containing the details about the stream.
 
 @since from 1.0
 @see YSStream
 @see [createForLive:properties:delegate:]([YSSessionManager createForLive:properties:delegate:])
 @see [createForNonLinearStartOver:properties:delegate:]([YSSessionManager createForNonLinearStartOver:properties:delegate:])
 @see [createForVoD:properties:delegate:]([YSSessionManager createForVoD:properties:delegate:])
 */
- (void) sessionDidInitialise:(YSSessionManager* _Nonnull)sessionManager withStream:(id<YSStream> _Nonnull)stream;

/**---------------------------------------------------------------------------------------
 * @name Error management
 *  ---------------------------------------------------------------------------------------
 */

/** Indicates that an error occurred or an exception was thrown during an asynchronous operation.
 In particular this message is called
 - if initialisation fails at any point
 - if an exception is thrown by the framework that prevents analytics from continuing
 
 @param error Contains details about the error.
 @since from 1.0
 */
- (void) operationDidFailWithError:(NSError* _Nonnull)error;

@end
