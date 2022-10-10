/*
 * COPYRIGHT 2020 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 * The contents of this file are proprietary and confidential.
 * Unauthorised copying of this file, via any medium is strictly prohibited.
 */

#import <Foundation/Foundation.h>

/** Encapsulation of a timed metadata payload, which is delivered as ID3 or EMSG in a stream. */
@interface YOTimedMetadata : NSObject

/** Holds the media Id declared in the YMID metadata field. */
@property (nonnull, readonly) NSString* mediaId;

/** Holds the segment count declared in the YSEQ metadata field. The sequence is of the format n:m where segment count is m. */
@property (readonly) NSUInteger segmentCount;

/** Holds the segment number declared in the YSEQ metadata field. The sequence is of the format n:m where segment number is n. */
@property (readonly) NSUInteger segmentNumber;

/** Holds the position declared in the YTYP metadata field. The position may be S (start) M (mid) or E (end). */
@property (nonnull, readonly) NSString* type;

/** Holds the offset, in seconds, from the beginning of the segment, declared in the YDUR metadata field. */
@property (readonly) NSTimeInterval offset;

/** Holds the playhead position, in seconds, of this timed metadata in the stream. */
@property (readonly) NSTimeInterval playhead;

/**
 * Tests if the timed metadata is the same as the receiver.
 *
 * @param meta The metatdata under test.
 * @return `YES` if the metadata is a duplicate of the receiver, `NO` otherwise.
 */
- (BOOL) isDuplicate:(nonnull YOTimedMetadata*)meta;

/**
 * Creates and returns an instance of YOTimedMetadata initialised with the provided properties.
 * If any of the properties are empty or invalid then this method returns nil.
 *
 * @param mediaId A string representation of the media Id.
 * @param sequence A string representation sequence, which must be of the form `n:m`.
 * @param type A string representation of the type.
 * @param offset The offset of the metadata from the start of the segment.
 * @param playhead The playhead position corresponding to the metadata's position in the stream.
 * @return A timed metadata instance or `nil`.
 */
+ (nullable instancetype) createWithMediaId:(nonnull NSString*)mediaId sequence:(nonnull NSString*)sequence type:(nonnull NSString*)type offset:(nonnull NSString*)offset playhead:(NSTimeInterval)playhead;

@end
