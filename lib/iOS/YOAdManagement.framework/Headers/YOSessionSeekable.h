/*
 * COPYRIGHT 2021 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <YOAdManagement/YOSession.h>

/**
 * Abstract Session implementation representing any seekable stream
 */
@interface YOSessionSeekable : YOSession

/** Defines the duration of the stream. */
@property (readonly) NSTimeInterval duration;

/**
 * Sets all adverts inactive in all ad breaks prior to the given playhead position. If the playhead
 * is within an advert then that advert is NOT marked as inactive. This method allows client applications
 * to seek to a position before playback begins.
 *
 * @param playhead The playhead position, in seconds.
 */
- (void) setAdBreaksInactivePriorTo:(NSTimeInterval)playhead;

@end
