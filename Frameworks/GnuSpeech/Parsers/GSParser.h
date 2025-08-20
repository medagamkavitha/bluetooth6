//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

extern NSString *GSParserSyntaxErrorException;

@interface GSParser : NSObject

@property (readonly) NSScanner *scanner;
@property (strong) NSString *symbolString;
@property (assign) NSUInteger startOfTokenLocation;

- (id)parseString:(NSString *)aString;
- (id)beginParseString;

// Error reporting
- (NSRange)errorRange;
- (NSString *)errorMessage;
- (void)appendErrorFormat:(NSString *)format, ...;

@end
