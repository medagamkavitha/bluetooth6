//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

#import "NSObject-Extensions.h"

@class EventList, MMEquation, MModel, MMFRuleSymbols, MMParameter;

@interface MMPoint : NSObject <GSXMLArchiving>

- (id)initWithModel:(MModel *)model XMLElement:(NSXMLElement *)element error:(NSError **)error;

@property (assign) double value;

@property (strong) MMEquation *timeEquation;
@property (assign) double freeTime;

- (double)cachedTime;

@property (assign) NSUInteger type;
@property (assign) BOOL isPhantom;

- (void)calculatePointsWithPhonesInArray:(NSArray *)phones ruleSymbols:(MMFRuleSymbols *)ruleSymbols andCacheWithTag:(NSUInteger)newCacheTag andAddToDisplay:(NSMutableArray *)displayList;
- (double)calculatePointsWithPhonesInArray:(NSArray *)phones ruleSymbols:(MMFRuleSymbols *)ruleSymbols andCacheWithTag:(NSUInteger)newCacheTag
                                  baseline:(double)baseline delta:(double)delta parameter:(MMParameter *)parameter
                         andAddToEventList:(EventList *)eventList atIndex:(NSUInteger)index;

- (NSComparisonResult)compareByAscendingCachedTime:(MMPoint *)other;

@end
