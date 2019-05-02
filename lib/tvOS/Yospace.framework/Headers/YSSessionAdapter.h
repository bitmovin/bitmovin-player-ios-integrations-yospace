/*
 * COPYRIGHT © 2019 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>

/** The YSSessionAdapter protocol provides initialisation of the Session Manager when it is not possible
 to identify the Yospace CSM URL associated with a stream to be played. This can typically happen for example
 when certain DRM solutions are being employed. In this case the master playlist URL is retrieved from the 
 third party library before being passed as a parameter to the create method of YSSessionManager, which returns
 an instance of this protocol. The URL to be provided to the player is then retrieved from this protocol.
 
 */
@protocol YSSessionAdapter <NSObject>

/**
 Get the proxied URL to be passed to the Player
 @return The proxied URL
 @since from 1.0
 */
- (NSURL*)playerURL;

@end
