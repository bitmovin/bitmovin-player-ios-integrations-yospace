/*
 * COPYRIGHT 2020 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <Foundation/Foundation.h>
#import <YOAdManagement/YOAdManagementTypes.h>

@class YOTimedMetadata;

/**
 * @brief The YOPlaybackEventHandling protocol declares a set of callback methods to provide information about the state of playback.
 *
 * It is implemented by the Yospace Session: clients <b>must</b> call each method at the appropriate time in order for the Session
 * to broadcast analytics correctly.
 */
@protocol YOPlaybackEventHandling <NSObject>

/**
 * Indicates that a player event occurred. The event may also be specific to an advert,
 * for example 'advert was skipped'.
 *
 * @param event The playback event.
 * @param playhead The playhead position.
 * @see YOPlayerEvent
 */
- (void) playerEventDidOccur:(YOPlayerEvent)event playhead:(NSTimeInterval)playhead;

/**
 * Indicates that the playhead position changed.
 *
 * @param playhead The new playhead position.
 */
- (void) playheadDidChange:(NSTimeInterval)playhead;

/**
 * Indicates that timed metadata was collected from the stream.
 *
 * @param metadata The timed metadata that was read from the stream.
 * @see YOTimedMetadata
 */
- (void) timedMetadataWasCollected:(YOTimedMetadata*)metadata;

/** Indicates that the player viewport size changed.
 *
 * @param size The new player viewport size.
 * @see YOPlayerViewSize
 */
- (void) viewSizeDidChange:(YOPlayerViewSize)size;

/**
 * Indicates that the player volume was muted or unmuted.
 *
 * @param mute `YES` if the volume was muted, `NO` otherwise.
 */
- (void) volumeDidChange:(BOOL)mute;

@end
