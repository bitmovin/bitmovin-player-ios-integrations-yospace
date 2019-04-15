/*
 * COPYRIGHT © 2018 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>

/** This file defines the notifications that the player must raise during stream playback.
 */

/** Posted when the stream is ready for playback.
 */
static NSString* const YoPlaybackReadyNotification           = @"YoPlaybackReadyNotification";

/** Posted when the playback started at a certain point.
 
 The notification's object is the playhead position (`kYoPlayheadKey`) as an NSTimeInterval.
 */
static NSString* const YoPlaybackStartedNotification         = @"YoPlaybackStartedNotification";

/** Posted when playback ended at a certain point.
 
 The notification has 2 objects: the playhead position (`kYoPlayheadKey`) as an NSTimeInterval
 and a boolean (`kYoCompletedKey`), which is true if the stream played to completion.
 */
static NSString* const YoPlaybackEndedNotification           = @"YoPlaybackEndedNotification";

/** Posted when playback paused at a certain point.
 
 The notification's object is the playhead position (`kYoPlayheadKey`) as an NSTimeInterval.
 */
static NSString* const YoPlaybackPausedNotification          = @"YoPlaybackPausedNotification";

/** Posted when playback resumed after pausing at a certain point.
 
 The notification's object is the playhead position (`kYoPlayheadKey`) as an NSTimeInterval.
 */
static NSString* const YoPlaybackResumedNotification         = @"YoPlaybackResumedNotification";

/** Posted when a playback error occured.
 
 The notification's object is an NSError instance (`KYoErrorKey`) that describes the error that occured.
 */
static NSString* const YoPlaybackErrorNotification           = @"YoPlaybackErrorNotification";

/** Posted when playback stalled at a certain point.
 
 The notification's object is the playhead position (`kYoPlayheadKey`) as an NSTimeInterval.
 */
static NSString* const YoPlaybackStalledNotification         = @"YoPlaybackStalledNotification";

/** Posted when playback continued after stalling at a certain point.
 
 The notification's object is the playhead position (`kYoPlayheadKey`) as an NSTimeInterval.
 */
static NSString* const YoPlaybackContinuedNotification       = @"YoPlaybackContinuedNotification";

/** Posted when playback volume became muted or unmuted.
 
 The notification's object is a boolean (`KYoMutedKey`) whose value is true if the volume is muted.
 */
static NSString* const YoPlaybackVolumeChangedNotification   = @"YoPlaybackVolumeChangedNotification";

/** Posted when new metadata arrives in the stream.

 The notification's object is a YSTimedMetadata (`kYoMetadataKey`).
 */
static NSString* const YoTimedMetadataNotification           = @"YoTimedMetadataNotification";

/** dictionary keys */
static NSString* const kYoPlayheadKey                        = @"kYoPlayheadKey";

static NSString* const kYoCompletedKey                       = @"kYoCompletedKey";

static NSString* const kYoMutedKey                           = @"kYoMutedKey";

static NSString* const kYoErrorKey                           = @"kYoErrorKey";

static NSString* const kYoMetadataKey                        = @"kYoMetadataKey";

