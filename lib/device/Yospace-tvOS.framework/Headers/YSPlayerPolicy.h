/*
 * COPYRIGHT © 2018 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>

/** The YSPlayerPolicy protocol implements policy related to player and stream state.<br/>
    It is implemented by the YSSessionManager, which delegates calls to the policy.framework.
 */
@protocol YSPlayerPolicy <NSObject>

/** Returns to the client whether playback can start.
 
 @return YES if playback can start, NO otherwise.
 @since from 1.0
 */
- (BOOL) canStart;

/** Returns to the client whether playback can stop.
 
 @return YES if playback can stop, NO otherwise.
 @since from 1.0
 */
- (BOOL) canStop;

/** Returns to the client whether playback can pause.
 
 @return YES if playback can pause, NO otherwise.
 @since from 1.0
 */
- (BOOL) canPause;

/** Returns to the client whether playback can rewind.
 
 @return YES if playback can rewind, NO otherwise.
 @since from 1.4
 */
- (BOOL) canRewind;

/** Returns to the client whether the currently-playing advert can be skipped.
 
 @return delay in seconds before the advert can be skipped, or -1 otherwise.
 @since from 1.7
 */
- (NSTimeInterval) canSkip;

/** Returns to the client whether playback can seek from the current playhead position.
 
 @return YES if playback can seek, NO otherwise.
 @since from 1.0
 */
- (BOOL) canSeek;

/** Returns to the client the playhead position that the user can seek to.
 
 @param position the playhead position that the user wishes to seek to
 @return the actual playhead position that the user can seek to, based on the implemented policy.
 @since from 1.0
 */
- (NSTimeInterval) willSeekTo:(NSTimeInterval)position;

/** Returns to the client whether volume can be muted.
 
 @return YES if volume can be muted, NO otherwise.
 @since from 1.0
 */
- (BOOL) canMute;

/** Returns to the client whether full screen mode for the player can change.
 
 @param fullScreen The intended full screen mode
 @return YES if the intended full screen mode can change, NO otherwise.
 @since from 1.0
 */
- (BOOL) canChangeFullScreenMode:(BOOL)fullScreen;

/** Returns to the client whether a currently-displayed linear creative can be expanded.<br/>
 Note that this method is not applicable to non-linear creative.
 
 @return YES if the creative can be expanded, NO otherwise.
 @since from 1.0
 */
- (BOOL) canExpandCreative;

/** Returns to the client whether a currently-displayed linear creative can be collapsed.<br/>
 Note that this method is not applicable to non-linear creative.
 
 @return YES if the creative can be collapsed, NO otherwise.
 @since from 1.4
 */
- (BOOL) canCollapseCreative;

/** Returns to the client whether the user can click-through.
 
 @param url The click-through Url.
 @return YES if the user can click through, NO otherwise.
 @since from 1.0
 */
- (BOOL) canClickThrough:(NSURL* _Nonnull)url;

@end
