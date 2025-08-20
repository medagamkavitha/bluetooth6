//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMNamedObject.h"

@class MMGroupedObject;

@interface MMGroup : MMNamedObject

- (id)initWithModel:(MModel *)model XMLElement:(NSXMLElement *)element error:(NSError **)error;

@property (nonatomic, readonly) NSArray *objects;

// These set the group (if possible) on objects added to the list
- (void)addObject:(MMGroupedObject *)object;
- (id)objectWithName:(NSString *)name;

- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(NSUInteger)level;

@end
