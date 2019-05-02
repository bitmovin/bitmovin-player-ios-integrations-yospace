/*
 * COPYRIGHT © 2019 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>
#import "YSAdManagement.h"

/** The YSIndustryIcon protocol provides an interface to an industry-initiative icon associated with the parent object - the advert's linear creative.
    The application is responsible for loading the resource from the iconSource URL (unless it is an `HTMLResource`); this is in line
    with the VAST spec: "...the video player should not prefetch the icon resource until the resource can be  displayed. Prefetching
    the icon resource may cause the icon provider to falsely record an  icon view when the icon may not have been displayed.".
    The application may also invoke and display the Url resource in click-through URL, if present.<br/>
    Note that if the icon's resource is `HTMLResource` then the string is always XML-encoded.
 */
@protocol YSIndustryIcon <NSObject>

/** Returns an identifier assigned bythe SDK to the icon. This is to enable the SDK to fire notifications on its behalf.
 
 @return The icon identifier.
 @since from 1.2
 */
- (NSInteger) iconIdentifier;

/** Returns the industry initiative that the icon supports.
 
 @return The icon program.
 @since from 1.2
 */
- (NSString* _Nonnull) iconProgram;

/** Returns the icon's width in pixels.
 
 @return The icon width.
 @since from 1.2
 */
- (NSInteger) iconWidth;

/** Returns the icon's height in pixels.
 
 @return The icon height.
 @since from 1.2
 */
- (NSInteger) iconHeight;

/** Returns the icon's x position, which may be one of ([0-9]*|left|right).
 
 @return The icon x position.
 @since from 1.2
 */
- (NSString*_Nonnull) iconXPosition;

/** Returns the icon's y position, which may be one of ([0-9]*|top|bottom).
 
 @return The icon y position.
 @since from 1.2
 */
- (NSString* _Nonnull) iconYPosition;

/** Returns the start time at which the player should display the icon. Expressed in standard time format hh:mm:ss.mmm.
 
 @return The icon display time offset from the advert start, or nil if not present.
 @since from 1.2
 */
- (NSString* _Nullable) iconOffset;

/** Returns the duration for which the player must display the icon. Expressed in standard time format hh:mm:ss.mmm.
 
 @return The icon display duration or nil if not present.
 @since from 1.2
 */
- (NSString* _Nullable) iconDuration;

/** Returns the method to use for communication with the icon element
 
 @return The icon APIFramework or nil if not present.
 @since from 1.2
 */
- (NSString* _Nullable) iconApiFramework;

/** Returns the click-through URL for the icon.
 
 @return The clickthrough URL or nil if not present.
 @since from 1.2
 */
- (NSURL* _Nullable) iconClickThroughUrl;

/** Returns the source URL for the icon for <StaticResource> or <iFrameResource> resource types.<br/>
    Returns nil if the resource is <HTMLResource>.
 
 @return The icon source URL or nil.
 @since from 1.2
 */
- (NSURL* _Nullable) iconSource;

/** Returns an XML encoded string representation if the resource is <HTMLResource>.<br/>
    Returns nil for <StaticResource> or <iFrameResource> resource types.
 
 @return The icon HTML source as an XML encoded string or nil.
 @since from 1.2
 */
- (NSString* _Nullable) iconStringData;

@end
