//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMPoint.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "EventList.h"
#import "GSXMLFunctions.h"
#import "MMEquation.h"
#import "MMTransition.h"
#import "MMParameter.h"

#import "MModel.h"

@implementation MMPoint
{
    double _value;             // Value of the point
    double _freeTime;          // Free Floating time
    MMEquation *_timeEquation; // Time of the point
    NSUInteger _type;          // Which phone it is targeting
    BOOL _isPhantom;           // Phantom point for place marking purposes only
}

- (id)init;
{
    if ((self = [super init])) {
        _value = 0.0;
        _freeTime = 0.0;
        _timeEquation = nil;
        _isPhantom = NO;
        _type = MMPhoneType_Diphone;
    }

    return self;
}

- (id)initWithModel:(MModel *)model XMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    NSParameterAssert([@"point" isEqualToString:element.name]);

    if ((self = [super init])) {
        _value = 0.0;
        _freeTime = 0.0;
        _timeEquation = nil;
        _isPhantom = NO;
        _type = MMPhoneType_Diphone;

        NSString *str;

        str = [[element attributeForName:@"type"] stringValue];
        if (str != nil)
            [self setType:MMPhoneTypeFromString(str)];

        str = [[element attributeForName:@"value"] stringValue];
        if (str != nil)
            [self setValue:[str doubleValue]];

        str = [[element attributeForName:@"free-time"] stringValue];
        if (str != nil)
            [self setFreeTime:[str doubleValue]];

        str = [[element attributeForName:@"time-expression"] stringValue];
        if (str != nil) {
            MMEquation *anEquation = [model findEquationWithName:str];
            [self setTimeEquation:anEquation];
        }

        str = [[element attributeForName:@"is-phantom"] stringValue];
        if (str != nil)
            [self setIsPhantom:GSXMLBoolFromString(str)];

    }

    return self;
}

#pragma mark -

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> value: %g, freeTime: %g, timeEquation: %@, type: %lu, isPhantom: %d",
            NSStringFromClass([self class]), self, _value, _freeTime, _timeEquation, _type, _isPhantom];
}

#pragma mark -

- (double)cachedTime;
{
    if (_timeEquation != nil)
        return [_timeEquation cacheValue]; // TODO (2004-03-11): I think this is a little odd.

    return _freeTime;
}

- (void)calculatePointsWithPhonesInArray:(NSArray *)phones ruleSymbols:(MMFRuleSymbols *)ruleSymbols andCacheWithTag:(NSUInteger)newCacheTag andAddToDisplay:(NSMutableArray *)displayList;
{
    if (_timeEquation != nil)
        [_timeEquation evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols andCacheWithTag:newCacheTag];

    [displayList addObject:self];
}

- (double)calculatePointsWithPhonesInArray:(NSArray *)phones ruleSymbols:(MMFRuleSymbols *)ruleSymbols andCacheWithTag:(NSUInteger)newCacheTag
                                  baseline:(double)baseline delta:(double)delta parameter:(MMParameter *)parameter
                         andAddToEventList:(EventList *)eventList atIndex:(NSUInteger)index;
{
    double time = (_timeEquation != nil) ? [_timeEquation evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols andCacheWithTag:newCacheTag] : _freeTime;

    //NSLog(@"|%@| = %f tempos: %f %f %f %f", [[postures objectAtIndex:0] symbol], time, tempos[0], tempos[1],tempos[2],tempos[3]);

    double returnValue = baseline + ((_value / 100.0) * delta);

    //NSLog(@"Inserting event %d atTime %f  withValue %f", index, time, returnValue);

    if (returnValue < parameter.minimumValue)
        returnValue = parameter.minimumValue;
    if (returnValue > parameter.maximumValue)
        returnValue = parameter.maximumValue;

    if (!_isPhantom)
        [eventList insertEvent:index atTimeOffset:time withValue:returnValue];

    return returnValue;
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<point type=\"%@\" value=\"%g\"", MMStringFromPhoneType(_type), _value];
    if (_timeEquation == nil) {
        [resultString appendFormat:@" free-time=\"%g\"", _freeTime];
    } else {
        [resultString appendFormat:@" time-expression=\"%@\"", GSXMLAttributeString([_timeEquation name], NO)];
    }

    if (_isPhantom)
        [resultString appendFormat:@" is-phantom=\"%@\"", GSXMLBoolAttributeString(_isPhantom)];

    [resultString appendString:@"/>\n"];
}

- (NSComparisonResult)compareByAscendingCachedTime:(MMPoint *)other;
{
    NSParameterAssert(other != nil);
    double thisTime  = self.cachedTime;
    double otherTime = other.cachedTime;

    if (thisTime < otherTime) return NSOrderedAscending;
    if (thisTime > otherTime) return NSOrderedDescending;

    return NSOrderedSame;
}

@end
