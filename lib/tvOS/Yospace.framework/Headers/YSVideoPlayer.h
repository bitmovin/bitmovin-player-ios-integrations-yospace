/*
 * COPYRIGHT © 2019 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>
#import "YSPlayerEvents.h"

@class UIView;

/** The YSVideoPlayer protocol implements the common parts of a video player - play, stop and properties such as duration and rate.<br/>
    It is implemented by a client application and passed to the YSSessionManager object, which is a passive receiver of its events and read-only properties.<br/>
 
The minimum implementation required for the SDK to function correctly is:<br/>
1. implementation of its read-only properties<br/>
2. propagation of all events defined in YSPlayerEvents.h
 */
@protocol YSVideoPlayer <NSObject>

@required
/** Holds the current playhead position.
 */
@property (readonly) NSTimeInterval currentTime;

/** Holds the stream duration, or 0 if the stream is live.
 */
@property (readonly) NSTimeInterval duration;

/** Holds the current playback rate.
 */
@property (nonatomic) float rate;

@optional

/** Holds the current volume.
 */
@property (nonatomic) float volume;

/** Initialises a video player object with a stream source.
 
 @param source the source Url
 @return the initialiased YSVideoPlayer object
 @since from 1.0
 */
- (id _Nonnull) initWithStreamSource:(NSURL* _Nonnull)source;

/** Sets the view on which the video will render.
 
 @param view The view to render the video to
 @since from 1.0
 */
- (void) setCanvas:(UIView* _Nonnull)view;

/** Starts to play the stream.
 
 @since from 1.0
 */
- (void) play;

/** Stops the stream and releases resources.
 
 @since from 1.0
 */
- (void) stop;

/** Pauses the stream.
 
 @since from 1.0
 */
- (void) pause;

/** Moves the playhead to the requested position.
 
 @param playhead The position to seek to
 @param completionHandler A completion block to invoke when the seek operation has either been completed or been interrupted.
 The block takes one argument - `finished` - that indicates whether the seek operation completed.
 @since from 1.0
 */
- (void) seekToTime:(NSTimeInterval)playhead completionHandler:(void (^ _Nonnull)(BOOL finished))completionHandler;


@end
