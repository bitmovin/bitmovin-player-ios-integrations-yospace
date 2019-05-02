/*
 * COPYRIGHT © 2019 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>

/** The YSPlaybackEventDelegate protocol declares a set of callback methods to provide information about the
 state of playback, and to receive analytics related to that state.<br/>
 It is implemented by the Yospace Session Manager and UI clients <b>must</b> call each method at the appropriate time
 in order for the Session Manager to broadcast analytics correctly.
 
 */
@protocol YSPlaybackEventDelegate <NSObject>

/** Indicates that playback in full screen changed.
 
 @param isFullScreen Indicates whether playback went to full screen.
 @since from 1.0
 */
- (void) fullScreenModeDidChange:(BOOL)isFullScreen;

/** Indicates that the user started seeking using the scrubber control. This method <b>must</b> be called on touch down event on a scrubber control (<code>UIControlEventTouchDown</code>)
 and <b>must</b> be paired with a call to [seekDidEnd]([YSPlaybackEventDelegate seekDidEnd:]). A client application should call [canSeek]([YSPlayerPolicy canSeek]) on the YSPlayerPolicy protocol prior to calling this method in order to find out if seeking is allowed at the current position of the playhead.
 
 @param playhead The current playhead position.
 @since from 1.0
 @see [seekDidEnd]([YSPlaybackEventDelegate seekDidEnd:])
 */
- (void) seekDidStart:(NSTimeInterval)playhead;

/** Indicates that the user finished seeking with the scrubber control. This method <b>must</b> be called on touch up event on a scrubber control (<code>UIControlEventTouchUp|UIControlEventTouchUpOutside</code>) or touch cancel (<code>UIControlEventTouchCancel</code>) and <b>must</b> be paired with a call to [seekDidStart]([YSPlaybackEventDelegate seekDidStart:]). A client application should call [willSeekTo]([YSPlayerPolicy willSeekTo:]) on the YSPlayerPolicy protocol prior to calling this method in order to obtain the actual playhead position it is allowed to scrub to based on the policy.
 
 @param playhead The position of the playhead when the scrubber was released
 @since from 1.0
 @see [seekDidStart]([YSPlaybackEventDelegate seekDidStart:])
 */
- (void) seekDidEnd:(NSTimeInterval)playhead;

/** Indicates that a linear event occurred. Any `<Tracking>` event URL whose event type matches the string passed in are fired by the framework.<br/>
 An event string may be one defined in the VAST spec for example expand, collapse, rewind, but may also be a custom event that is defined in the VAST document.
 
 @param event The tracking event type
 @since from 1.4
 */
- (void) linearEventDidOccur:(NSString* _Nonnull)event;

/** Indicates that a nonlinear event occurred. Any `<Tracking>` event URL whose event type matches the string passed in are fired by the framework.<br/>
 An event string may be one defined in the VAST spec for example expand, collapse, acceptInvitation, but may also be a custom event that is defined in the VAST document.
 
 @param event The tracking event type.
 @param identifier The NonLinear Creative's nonlinearIdentifier.
 @since from 1.4
 */
- (void) nonlinearEvent:(NSString* _Nonnull)event didOccur:(NSString* _Nonnull)identifier;

/** Indicates that a linear click-through event occurred. Any `<LinearClickTracking>` URLs associated with this Linear Creative are fired by the framework.
 
 @since from 1.2
 */
- (void) linearClickThroughDidOccur;

/** Indicates that a non-linear click-through event occurred - that the user clicked on a graphic overlay, button or other nonlinear resource. Any `<NonLinearClickTracking>` URLs associated with this Nonlinear Creative are fired by the framework.
 
 @param identifier The NonLinear Creative's nonlinearIdentifier.
 @since from 1.2
 */
- (void) nonlinearClickThroughDidOccur:(NSString* _Nonnull)identifier;

/** Indicates that a linear creative's icon click-through event occurred - that the user clicked on an industry icon. Any `<IconClickTracking>` URLs associated with this icon are fired by the framework.
 
 @param identifier The industry icon's iconIdentifier.
 @since from 1.2
 */
- (void) iconClickThroughDidOccur:(NSInteger)identifier;

/** Indicates that a linear creative's icon was displayed as an overlay on the advert. Any `<IconViewTracking>` URLs
    associated with this icon are fired by the framework.
 
 @param identifier The industry icon's iconIdentifier.
 @since from 1.2
 */
- (void) iconViewDidOccur:(NSInteger)identifier;

@end
