//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMIntonation.h"

#import "MMIntonationParameters.h"
#import "MMToneGroup.h"

static NSDictionary *toneGroupIntonationParameterArrays;

@implementation MMIntonation
{
    MMIntonationParameters *_manualIntonationParameters;
}

+ (void)initialize;
{
    if (self == [MMIntonation class]) {
        NSURL *url = [[NSBundle bundleForClass:self] URLForResource:@"intonation" withExtension:@"xml"];

        NSError *error;
        NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:url options:0 error:&error];
        if (document == nil) {
            NSLog(@"Error: Unable to load intonation paramters from %@: %@", url, error);
        } else {
            NSError *xpathError;
            NSArray *toneGroupElements = [document nodesForXPath:@"/intonation/tone-groups/tone-group" error:&xpathError];
            if (toneGroupElements == nil) {
                NSLog(@"Error: %@", xpathError);
            } else {
                // This is a dictionary of arrays of MMIntonationParameters, keyed by @(toneGroupType).
                NSMutableDictionary *toneGroupIntonationParametersByType = [[NSMutableDictionary alloc] init];

                for (NSXMLElement *node in toneGroupElements) {
                    NSXMLNode *nameAttribute = [node attributeForName:@"name"];
                    if (nameAttribute != nil) {
                        NSMutableArray *parameters = [[NSMutableArray alloc] init];

                        NSError *e2;
                        NSArray *intonationParameterElements = [node nodesForXPath:@"intonation-parameters" error:&e2];
                        if (intonationParameterElements == nil) {
                            NSLog(@"Error: %@", e2);
                        } else {
                            for (NSXMLElement *intonationParametersElement in intonationParameterElements) {
                                MMIntonationParameters *intonationParameters = [[MMIntonationParameters alloc] init];
                                // TODO: (2015-07-08) Make sure all five attributes are there first.
                                intonationParameters.notionalPitch             = [intonationParametersElement attributeForName:@"notional-pitch"].stringValue.floatValue;
                                intonationParameters.pretonicPitchRange        = [intonationParametersElement attributeForName:@"pretonic-pitch-range"].stringValue.floatValue;
                                intonationParameters.pretonicPerturbationRange = [intonationParametersElement attributeForName:@"pretonic-perturbation-range"].stringValue.floatValue;
                                intonationParameters.tonicPitchRange           = [intonationParametersElement attributeForName:@"tonic-pitch-range"].stringValue.floatValue;
                                intonationParameters.tonicPerturbationRange    = [intonationParametersElement attributeForName:@"tonic-perturbation-range"].stringValue.floatValue;
                                [parameters addObject:intonationParameters];
                            }
                        }

                        if (MMToneGroupTypeFromString(nameAttribute.stringValue) != MMToneGroupType_Unknown) {
                            toneGroupIntonationParametersByType[ nameAttribute.stringValue ] = [parameters copy];
                        } else {
                            NSLog(@"Error: Unknown tone group type: %@", nameAttribute.stringValue);
                        }
                    }
                }

                toneGroupIntonationParameterArrays = [toneGroupIntonationParametersByType copy];
                //NSLog(@"toneGroupIntonationParameterArrays:\n%@", toneGroupIntonationParameterArrays);
            }
        }
    }
}

- (id)init;
{
    if ((self = [super init])) {
        _shouldUseMacroIntonation  = YES;
        _shouldUseMicroIntonation  = YES;
        _shouldUseSmoothIntonation = YES;

        _shouldUseDrift = YES;
        _driftDeviation = 1.0;
        _driftCutoff    = 4;

        _tempo = 1.0;

        _shouldRandomlyPerturb                  = YES;
        _shouldRandomlySelectFromToneGroup      = YES;
        _shouldUseToneGroupIntonationParameters = YES;

        _manualIntonationParameters = [[MMIntonationParameters alloc] init];
    }
    
    return self;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> shouldRandomlyPerturb: %d, shouldRandomlySelectFromToneGroup: %d, shouldUseToneGroupIntonationParameters: %d, manualIntonationParameters: %@",
            NSStringFromClass([self class]), self,
            self.shouldRandomlyPerturb, self.shouldRandomlySelectFromToneGroup, self.shouldUseToneGroupIntonationParameters,
            self.manualIntonationParameters];
}

#pragma mark -

- (MMIntonationParameters *)intonationParametersForToneGroup:(MMToneGroup *)toneGroup;
{
    //NSLog(@"%s, toneGroup: %@", __PRETTY_FUNCTION__, toneGroup);
    if (!self.shouldUseToneGroupIntonationParameters) {
        return self.manualIntonationParameters;
    }

    NSArray *array = toneGroupIntonationParameterArrays[ MMToneGroupTypeName(toneGroup.type) ];
    NSParameterAssert(array != nil);
    NSParameterAssert([array count] > 0);
    if ([array count] == 1 || !self.shouldRandomlySelectFromToneGroup) {
        //NSLog(@"non-random for tone group, iparm: %@", array[0]);
        return array[0];
    }

    NSUInteger index = random() % [array count];
    //NSLog(@"randomizing within tone group, iparm: %@", array[index]);
    return array[index];
}

@end
