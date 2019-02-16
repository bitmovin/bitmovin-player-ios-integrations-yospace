/*
 * COPYRIGHT © 2018 YOSPACE TECHNOLOGIES LTD. ALL RIGHTS RESERVED.
 */

#import <Foundation/Foundation.h>

/** The YSTimedMetadata class represents timed metadata obtained from the stream.
 
 */
@interface YSTimedMetadata : NSObject

/**
 Holds the media Id declared in the YMID metadata field.
 */
@property (nonatomic, copy, nonnull) NSString* mediaId;

/**
 Holds the segment count declared in the YSEQ metadata field. The sequence is of the format n:m and segment count is m.
 */
@property (nonatomic) NSInteger segmentCount;

/**
 Holds the segment number declared in the YSEQ metadata field. The sequence is of the format n:m and segment number is n.
 */
@property (nonatomic) NSInteger segmentNumber;

/**
 Holds the position declared in the YTYP metadata field. The position may be S (start) M (mid) or E (end).
 */
@property (nonatomic, copy, nonnull) NSString* type;

/**
 Holds the offset from the beginning of the segment, declared in the YDUR metadata field.
 */
@property (nonatomic) NSTimeInterval offset;

/**
 Holds a timestamp representing when the metadata was received.
 */
@property (nonatomic, strong, nonnull) NSDate* timestamp;

/** Initialisation method, setting all of the metatdata properties.
 
 @param mediaId A string representation of the media Id
 @param segmentCount A string representation of the segment count
 @param segmentNumber A string representation of the segment number
 @param type A string representation of the type
 @param offset The offset of the metadata from the start of the segment
 @param timestamp The date that the metadata was received
 @return a YSTimedMetadata instance
 @since from 1.0
 */
- (nonnull instancetype) initWithMediaId:(NSString* _Nonnull)mediaId segmentCount:(NSInteger)segmentCount segmentNumber:(NSInteger)segmentNumber type:(NSString* _Nonnull)type offset:(NSTimeInterval)offset timestamp:(NSDate* _Nonnull)timestamp;

/** Initialisation method, setting all of the metatdata properties. This initialisation method takes a sequence string as parameter of the form `n:m` instead of the parsed and separated segment count and segment number.
 
 @param mediaId A string representation of the media Id
 @param sequence A string representation sequence, which must be of the form `n:m`
 @param type A string representation of the type
 @param offset The offset of the metadata from the start of the segment
 @param timestamp The date that the metadata was received
 @return a YSTimedMetadata instance
 @since from 1.0
 */
- (nonnull instancetype) initWithMediaId:(NSString* _Nonnull)mediaId sequence:(NSString* _Nonnull)sequence type:(NSString* _Nonnull)type offset:(NSTimeInterval)offset timestamp:(NSDate* _Nonnull)timestamp;

/** Sets the sequence values of the metadata - segment count and segment number - from a string representation of the sequence.
 
 @param sequence A string representation of the metatdata sequence.
 @return `YES` if the parameter represents a properly formatted sequence of the form `n:m`, `NO` otherwise
 @since from 1.0
 */
- (BOOL) setSequenceFromString:(NSString* _Nonnull)sequence;

/** Tests if the metadata is the same as the receiver.
 
 @param meta The metatdata under test.
 @return `YES` if the metadata is a duplicate of the receiver, `NO` otherwise
 @since from 1.0
 */
- (BOOL) isDuplicateMeta:(YSTimedMetadata* _Nonnull)meta;

@end
