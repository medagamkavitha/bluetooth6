//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMNamedObject.h"

#import "NSObject-Extensions.h"

@interface MMCategory : MMNamedObject <GSXMLArchiving>

@property (assign) BOOL isNative;

- (NSComparisonResult)compareByAscendingName:(MMCategory *)other;

@end
