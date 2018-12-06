/*
 * COPYRIGHT © 2018 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>

#ifndef YSDebugFlags_h
#define YSDebugFlags_h

/** YSEDebugFlags defines the set of switches that control debug trace output for aspects of SDK behaviour.
 */
typedef NS_ENUM(NSInteger, YSEDebugFlags) {
    /** when set, draws a border round pre-loaded graphics to aid placement */
    DEBUG_BORDERS          = (1 << 0),
    /** when set, traces playback events (paused, resumed, VoD time) */
    DEBUG_PLAYBACK         = (1 << 1),
    /** when set, traces SDK lifecycle */
    DEBUG_LIFECYCLE        = (1 << 2),
    /** when set, traces raw XML responses (VAST and VMAP) */
    DEBUG_XML              = (1 << 3),
    /** when set, traces CSM VAST polling events */
    DEBUG_VAST_POLLING     = (1 << 4),
    /** when set, traces CSM VMAP polling events */
    DEBUG_VMAP_POLLING     = (1 << 5),
    /** when set, traces VAST tracking reports */
    DEBUG_REPORTS          = (1 << 6),
    /** when set, traces ID3 tag state machine state for live playback */
    DEBUG_ID3TAG           = (1 << 7),
    /** when set, traces raw ID3 tag data */
    DEBUG_ID3TAG_RAW       = (1 << 8),
    /** when set, traces SDK initialisation */
    DEBUG_SERVER_INIT      = (1 << 9),
    /** when set, traces VAST click through events */
    DEBUG_CLICK_EVENTS     = (1 << 10),
    /** when set, traces HTTP requests and responses */
    DEBUG_HTTP_REQUESTS    = (1 << 11),
    /** when set, traces client notification events */
    DEBUG_PUBNSUB          = (1 << 12),
    /** when set, traces VAST and VMAP parsing logic */
    DEBUG_PARSING          = (1 << 13),
    /** when set, traces advert management logic */
    DEBUG_ADVERT_MGMT      = (1 << 14),
    /** when set, traces state machine state for VoD and Nonlinear Startover */
    DEBUG_HEARTBEAT_STATE  = (1 << 15),
    /** when set, traces playhead position for VoD and Nonlinear Startover */
    DEBUG_PLAYHEAD_POLLING = (1 << 16),
    /** when set, traces SDK initialisation with proxy events */
    DEBUG_PROXY_INIT       = (1 << 17),
    /** when set, traces state machine state for filler content */
    DEBUG_FILLER           = (1 << 18),
    /** when set, traces Live Pause polling events */
    DEBUG_PAUSE_POLLING    = (1 << 19),
    /** when set, traces watchdog timer events */
    DEBUG_WATCHDOG         = (1 << 20),
    /** when set, enables all trace options */
    DEBUG_ALL              = ~(-1 << 21)
};

extern YSEDebugFlags debugFlags;

#endif /* YSDebugFlags_h */
