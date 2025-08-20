//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-1998, 2000-2001, 2004  Steve Nygard

#import "NSString-Extensions.h"

@implementation NSString (CDExtensions)

+ (NSString *)stringWithFileSystemRepresentation:(const char *)str;
{
    // 2004-01-16: I'm don't understand why we need to pass in the length.
    return [[NSFileManager defaultManager] stringWithFileSystemRepresentation:str length:strlen(str)];
}

+ (NSString *)spacesIndentedToLevel:(NSUInteger)level;
{
    return [self spacesIndentedToLevel:level spacesPerLevel:4];
}

+ (NSString *)spacesIndentedToLevel:(NSUInteger)level spacesPerLevel:(NSUInteger)spacesPerLevel;
{
    NSString *spaces = @"                                        ";

    NSParameterAssert(spacesPerLevel <= [spaces length]);
    NSString *levelSpaces = [spaces substringToIndex:spacesPerLevel];

    NSMutableString *str = [NSMutableString string];
    for (NSUInteger l = 0; l < level; l++)
        [str appendString:levelSpaces];

    return str;
}

+ (NSString *)spacesOfLength:(NSUInteger)targetLength;
{
    NSString *spaces = @"                                        ";

    NSUInteger spacesLength = [spaces length];
    NSMutableString *str = [NSMutableString string];
    while (targetLength > spacesLength) {
        [str appendString:spaces];
        targetLength -= spacesLength;
    }

    [str appendString:[spaces substringToIndex:targetLength]];

    return str;
}

+ (NSString *)stringWithUnichar:(unichar)character;
{
    return [NSString stringWithCharacters:&character length:1];
}

- (BOOL)isFirstLetterUppercase;
{
    NSRange letterRange;

    letterRange = [self rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]];
    if (letterRange.length == 0)
        return NO;

    return [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[self characterAtIndex:letterRange.location]];
}

- (BOOL)hasPrefix:(NSString *)aString ignoreCase:(BOOL)shouldIgnoreCase;
{
    if (shouldIgnoreCase == NO)
        return [self hasPrefix:aString];

    NSRange range = [self rangeOfString:aString options:NSCaseInsensitiveSearch|NSAnchoredSearch];
    return range.location != NSNotFound;
}

+ (NSString *)stringWithASCIICString:(const char *)bytes;
{
    if (bytes == NULL)
        return nil;

    return [[NSString alloc] initWithBytes:bytes length:strlen(bytes) encoding:NSASCIIStringEncoding];
}

// TODO (2004-08-12): A class method would let us pad nil as well...
- (NSString *)leftJustifiedStringPaddedToLength:(NSUInteger)paddedLength;
{
    NSUInteger spaces = paddedLength - [self length];
    if (spaces <= 0)
        return self;

    return [self stringByAppendingString:[NSString spacesOfLength:spaces]];
}

- (NSString *)rightJustifiedStringPaddedToLength:(NSUInteger)paddedLength;
{
    NSUInteger spaces = paddedLength - [self length];
    if (spaces <= 0)
        return self;

    return [[NSString spacesOfLength:spaces] stringByAppendingString:self];
}

- (BOOL)startsWithLetter;
{
    if ([self length] == 0)
        return NO;

    return [[NSCharacterSet letterCharacterSet] characterIsMember:[self characterAtIndex:0]];
}

- (BOOL)isAllUpperCase;
{
    NSRange range = [self rangeOfCharacterFromSet:[[NSCharacterSet uppercaseLetterCharacterSet] invertedSet]];

    return range.location == NSNotFound;
}

- (BOOL)containsPrimaryStress;
{
    NSRange range = [self rangeOfString:@"'"];

    return range.location != NSNotFound;
}

// Returns the pronunciation with the first " converted to a ', or nil otherwise.
- (NSString *)convertedStress;
{
    NSRange range = [self rangeOfString:@"\""];
    if (range.location == NSNotFound)
        return nil;

    NSMutableString *str = [NSMutableString stringWithString:self];
    [str replaceCharactersInRange:range withString:@"'"];

    return [NSString stringWithString:str];
}

@end

@implementation NSMutableString (Extensions)

- (void)indentToLevel:(NSUInteger)level;
{
    [self appendString:[NSString spacesIndentedToLevel:level spacesPerLevel:2]];
}

@end
