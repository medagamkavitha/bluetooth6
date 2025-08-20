//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

#import "NSObject-Extensions.h"

@class EventList;

// TODO (2004-08-09): absoluteTime is derived from offsetTime and beatTime.  And beatTime is derived from ruleIndex and eventList.

@interface MMIntonationPoint : NSObject <GSXMLArchiving>

- (id)initWithXMLElement:(NSXMLElement *)element error:(NSError **)error;

@property (weak) EventList *eventList;

@property (nonatomic, assign) double semitone;
@property (nonatomic, assign) double offsetTime;
@property (nonatomic, assign) double slope;

@property (nonatomic, assign) NSInteger ruleIndex;

@property (nonatomic, readonly) double absoluteTime;
@property (nonatomic, readonly) double beatTime;

@property (nonatomic, assign) double semitoneInHertz;

- (void)incrementSemitone;
- (void)decrementSemitone;

- (void)incrementRuleIndex;
- (void)decrementRuleIndex;

- (NSComparisonResult)compareByAscendingAbsoluteTime:(MMIntonationPoint *)otherIntonationPoint;

@end

@protocol MMIntonationPointChanges
- (void)intonationPointDidChange:(MMIntonationPoint *)intonationPoint;
- (void)intonationPointTimeDidChange:(MMIntonationPoint *)intonationPoint;
@end

