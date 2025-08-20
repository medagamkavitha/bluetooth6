//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MMGlottalPulseShape_Pulse = 0,
    MMGlottalPulseShape_Sine  = 1,
} MMGlottalPulseShape;

typedef enum : NSUInteger {
    MMSamplingRate_22050 = 0,
    MMSamplingRate_44100 = 1,
} MMSamplingRate;

typedef enum : NSUInteger {
    MMChannels_Mono   = 0,
    MMChannels_Stereo = 1,
} MMChannels;

@class STLogger;

@interface MMSynthesisParameters : NSObject

- (void)restoreDefaultValues;
- (void)saveAsDefaults;

@property (assign) double masterVolume;
@property (assign) double vocalTractLength;
@property (assign) double temperature;
@property (assign) double balance;
@property (assign) double breathiness;
@property (assign) double lossFactor;
@property (assign) double pitch;
@property (assign) double throatCutoff;
@property (assign) double throatVolume;
@property (assign) double apertureScaling;
@property (assign) double mouthCoef;
@property (assign) double noseCoef;
@property (assign) double mixOffset;
@property (assign) double n1;
@property (assign) double n2;
@property (assign) double n3;
@property (assign) double n4;
@property (assign) double n5;
@property (assign) double tp;
@property (assign) double tnMin;
@property (assign) double tnMax;
@property (assign) MMGlottalPulseShape glottalPulseShape;
@property (assign) BOOL shouldUseNoiseModulation;
@property (assign) MMSamplingRate samplingRate;
@property (assign) MMChannels outputChannels;

@property (nonatomic, readonly) double sampleRate;

@property (nonatomic, readonly) NSString *parameterString;

- (BOOL)writeToURL:(NSURL *)url error:(NSError **)error;
- (void)logToLogger:(STLogger *)logger;

@end
