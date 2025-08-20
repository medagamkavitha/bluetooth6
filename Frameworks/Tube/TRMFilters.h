//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

typedef struct {
    // Bandpass filter memory
    double bpAlpha;
    double bpBeta;
    double bpGamma;
    
    // Filter memory
    double xn1;
    double xn2;
    double yn1;
    double yn2;
} TRMBandPassFilter;

void TRMBandPassFilter_CalculateCoefficients(TRMBandPassFilter *filter, int32_t sampleRate, double centerFrequency, double bandwidth);
double TRMBandPassFilter_FilterInput(TRMBandPassFilter *filter, double input);

typedef struct {
    // Coefficients
    double a10;
    double b11;
    double a20;
    double a21;
    double b21;
    
    // Reflection filter memory
    double reflectionY;
    
    // Radiation filter memory
    double radiationX;
    double radiationY;
} TRMRadiationReflectionFilter;

void TRMRadiationReflectionFilter_InitWithCoefficient(TRMRadiationReflectionFilter *filter, double coeff);
double TRMRadiationReflectionFilter_ReflectionFilterInput(TRMRadiationReflectionFilter *filter, double input);
double TRMRadiationReflectionFilter_RadiationFilterInput(TRMRadiationReflectionFilter *filter, double input);

// Throat lowpass filter memory
typedef struct {
    // Coefficients
    double tb1;
    double ta0;
    
    // Filter memory
    double y;
} TRMLowPassFilter;

void TRMLowPassFilter_CalculateCoefficients(TRMLowPassFilter *filter, int32_t sampleRate, double cutoff);
double TRMLowPassFilter_FilterInput(TRMLowPassFilter *filter, double input);

typedef struct {
    // Filter memory
    double x;
} TRMLowPassFilter2;

double TRMLowPassFilter2_FilterInput(TRMLowPassFilter2 *filter, double input);
