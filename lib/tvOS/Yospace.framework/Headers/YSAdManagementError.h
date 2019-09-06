/*
 * COPYRIGHT © 2019 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#define YO_ADMANAGEMENT_ERROR_BASE 7000

static NSString* const YoExtraErrorKey = @"YoExtraErrorKey";

/** YSEAnalyticsErrorCode defines the error codes for Yospce errors that are raised in [YSSessionManagerObserver operationDidFailWithError:], or returned as an 'out'
    parameter to a method. Note that system errors may also be raised through [YSSessionManagerObserver operationDidFailWithError:].<br/><br/>
    `NSLocalizedFailureReasonErrorKey` always contains a localisable failure reason, which you can find in the `Localiszable.strings` exported with this SDK.
 */
typedef NS_ENUM(NSInteger, YSEAnalyticsErrorCode)
{
    /** The resource could not be retrieved from the URL or the response data is corrupt, invalid or empty.<br/>
        This error can occur during initialisation if the URL request receives a response but it is empty.<br/>
        `NSLocalizedDescriptionKey` contains the failing URL.<br/>
        `YoExtraErrorKey` is nil. */
    E_DOWNLOAD_FAILED             = 7002,
    /** The server did not provide the required response headers.<br/>
        This error can occur during initialisation if the Yospace headers are not present in the HTTP response. <br/>
        `NSLocalizedDescriptionKey` contains the failing URL.<br/>
        `YoExtraErrorKey` is nil. */
    E_HTTP_RESP_HTTPHEADERS       = 7004,
    /** XML is not UTF8 encoded: unable to parse data.<br/>
        This error can occur if the HTTP response body cannot be interpreted as a UTF8 string. <br/>
        `NSLocalizedDescriptionKey` contains the failing URL.<br/>
        `YoExtraErrorKey` is nil.*/
    E_INVALID_ENCODING            = 7005,
    /** Attempting to set the same player.
        This error can be returned from [YSSessionManager setVideoPlayer:error:] if the YSVideoPlayer instance passed in is the same as the existing instance.<br/>
        This error is never returned in [YSSessionManagerObserver operationDidFailWithError:].<br/>
        `NSLocalizedDescriptionKey` and `YoExtraErrorKey` are both nil.*/
    E_SET_SAME_PLAYER             = 7009,
    /** Invalid CSM URL, polling URL or unable to initialise a CSM session.<br/>
        This error can occur if a NSURLSession connection could not be established, or if the response code is outside the range 200-299.<br/>
        `NSLocalizedDescriptionKey` and `YoExtraErrorKey` are both nil.*/
    E_CONNECTION_INIT             = 7012,
    /** Unable to reach the master playlist, or the playlist could not be parsed.<br/>
        This error can occur for live playback only and if the app is not using proxy initialisation. If a CSM session is established the the YSSessionManager
        'pings' the master playlist to check it is valid. If a connection cannot be established, or the response code  is outside the range 200-299 then
        this error is raised.<br/>
        `NSLocalizedDescriptionKey` contains the failing URL.<br/>
        `YoExtraErrorKey` contains a string representation of the HTTP response, or nil if the connection could not be established.*/
    E_MASTERPLAYLIST_INIT         = 7013,
    /** An HTTP error was returned from redirect URL request.<br/>
        The SDK allows an app to specify, through YSSessionProperties, whether the URL passed into the SDK is known to redirect to a CSM URL.<br/>
        This error can occur if the HTTP response code from a redirect request URL is outside the range 200-299.<br/>
        `NSLocalizedDescriptionKey` contains the failing URL.<br/>
        `YoExtraErrorKey` contains a string representation of the HTTP response.*/
    E_REDIRECT_INIT               = 7015,
    /** The URL is not a Yospace CSM initialisation URL.<br/>
        This error can occur for Non-linear playback only, and is raised if the initialisation URL is not known to be a CSM URL.<br/>
        `NSLocalizedDescriptionKey` contains the failing URL.<br/>
        `YoExtraErrorKey` is nil.*/
    E_YOSPACE_URL                 = 7016,
};
