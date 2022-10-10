/*
 * COPYRIGHT 2020,2022 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <Foundation/Foundation.h>

/**
 * @brief The YOPlaybackPolicyDelegate protocol declares a set of methods to provide policy related to playback.
 *
 * It is implemented by a YOSession-derived instance, which delegates calls to a policy adapter - if one
 * is attached. This allows the business logic of playback policy to be implemented in a single place.
 */
@protocol YOPlaybackPolicyDelegate <NSObject>

/**
 * Returns to the client whether playback can stop.
 *
 * @return `YES` if playback can stop, `NO` otherwise.
 */
- (BOOL) canStop;

/**
 * Returns to the client whether playback can pause.
 *
 * @return `YES` if playback can pause, `NO` otherwise.
 */
- (BOOL) canPause;

/**
 * Returns to the client whether the currently-playing advert can be skipped.
 *
 * @return delay in seconds before the advert can be skipped, or -1 otherwise.
 */
- (NSTimeInterval) canSkip;

/**
 * Returns to the client the playhead position that the user can seek to.
 *
 * @param position the playhead position that the user wishes to seek to.
 * @return the actual playhead position that the user can seek to, based on the implemented policy.
 */
- (NSTimeInterval) willSeekTo:(NSTimeInterval)position;

/**
 * Returns to the client whether volume can be muted or unmuted.
 *
 * @param mute The intended volume change: muted or unmuted.
 * @return `YES` if volume can be muted or unmuted, `NO` otherwise.
 */
- (BOOL) canChangeVolume:(BOOL)mute;

/**
 * Returns to the client whether full screen mode for the player can change.
 *
 * @param fullScreen The intended full screen mode.
 * @return `YES` if the intended full screen mode can change, `NO` otherwise.
 */
- (BOOL) canResize:(BOOL)fullScreen;

/**
 * Returns to the client whether a currently-displayed linear creative can be expanded.
 *
 * @param expand The intended full screen mode
 * @return `YES` if the creative can be expanded, `NO` otherwise.
 * @note This method is not applicable to NonLinear creative.
 */
- (BOOL) canResizeCreative:(BOOL)expand;

/**
 * Returns to the client whether the user can click-through.
 *
 * @param url The click-through URL.
 * @return `YES` if the user can click through, `NO` otherwise.
 */
- (BOOL) canClickThrough:(nonnull NSURL*)url;

@end
