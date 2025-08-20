//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "PitchScale.h"
#import "tube.h"

#import "syn_structs.h"

/*  LOCAL DEFINES  ***********************************************************/

//#define VOLUME_MAX         60.0

#define LEGER_LINE_WIDTH   12.0

#define STAFF_MARGIN       10.0
#define STAFF_SPACE        6.0
#define STAFF_INCREMENT    (STAFF_SPACE/2.0)

#define NOTE_WIDTH         STAFF_SPACE
#define NOTE_HEIGHT        STAFF_SPACE

#define SHARP_MARGIN       7.0
#define SHARP_WIDTH        7.0
#define SHARP_HEIGHT       14.0

#define ARROW_MARGIN       8.0
#define ARROW_WIDTH        6.0
#define ARROW_HEIGHT       10.0

#define PSTOP_ARROW		   5
#define PSARROW_HEIGHT	   10

#define POSITION          0
#define SHARP             1
#define ERROR             (-1)
#define SUCCESS           0
#define NOTE_NUMBER_MIN   (-24)
#define NOTE_NUMBER_MAX   24


@implementation PitchScale
{
	float horizontalCenter;
    float verticalCenter;
    float sharpCenter;
    float arrowCenter;
	
    id background;
    id foreground;
	float notePosition;
	BOOL sharpNeeded;
	BOOL arrowNeeded;
	int upDown;
}

- (id)initWithFrame:(NSRect)frameRect;
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
		_yScaleDivs = PSY_SCALE_DIVS;
		_xScaleDivs = PSX_SCALE_DIVS;
		NSLog(@" X & Y divs are %f %f", _xScaleDivs, _yScaleDivs);
	}
    
    NSNotificationCenter *nc;
    nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(pitchChanged:) // Ditto for the pitch display
               name:@"pitchChanged"
             object:nil];
    NSLog(@"Added pitchScale as observer for pitchChanged");
	return self;
}

- (void)dealloc;
{
    [background release];
    [foreground release];
    
    [super dealloc];
}

#pragma mark -

- (void)drawRect:(NSRect)rect;
{
	NSRect viewRect = [self bounds];
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:viewRect];
	[self drawGrid];
}

- (NSPoint)graphOrigin;
{
	NSPoint graphOrigin = [self bounds].origin;
	graphOrigin.x += PSLEFT_MARGIN;
	graphOrigin.y += PSTOP_BOTTOM_MARGIN;
    return graphOrigin;
}

- (void)awakeFromNib;
{
	[self drawPitch:GLOT_PITCH_DEF Cents:((GLOT_PITCH_DEF - (int)GLOT_PITCH_DEF)*100) Volume:GLOT_VOL_DEF];
}

- (void)drawGrid;
{
	// Draw in best fit grid markers
	
	NSRect bounds = [self bounds];
    NSPoint graphOrigin = [self graphOrigin];
	float sectionHeight = (bounds.size.height - graphOrigin.y - PSTOP_BOTTOM_MARGIN)/_yScaleDivs;
	float sectionWidth = (bounds.size.width - graphOrigin.x - PSRIGHT_MARGIN/_xScaleDivs);
	
    [[NSColor blackColor] set];
	
	//	First Y-axis grid lines
		
    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:2];
	for (NSUInteger index = 0; index <= _yScaleDivs; index++) {
        NSPoint aPoint;
		aPoint.x = graphOrigin.x;
		if (index==0||index==1||index==7||index==13||index==14) aPoint.x += sectionWidth/4;
		aPoint.y = graphOrigin.y + index * sectionHeight;
        [bezierPath moveToPoint:aPoint];
		aPoint.x = (bounds.size.width - PSRIGHT_MARGIN);
		if (index==0||index==1||index==7||index==13||index==14)
        aPoint.x = (bounds.size.width - PSRIGHT_MARGIN)* 0.75;
        [bezierPath lineToPoint:aPoint];
		
    }
	
	NSRect noteRect;
	noteRect.size.height = sectionHeight * 1;
	noteRect.size.width = sectionHeight * 1.6;
	noteRect.origin.x = (bounds.size.width - noteRect.size.width)/2;
	noteRect.origin.y = ((bounds.size.height/2) + (bounds.size.height - PSTOP_BOTTOM_MARGIN * 2) * notePosition) - noteRect.size.height/2;
	[bezierPath appendBezierPathWithOvalInRect:noteRect];
	[bezierPath fill];	
    [bezierPath stroke];
	[bezierPath release];
	
	// Check if cents-related arrow required to indicate displacement of note higher or lower

	if (arrowNeeded == NO) {
    } else {
		bezierPath = [[NSBezierPath alloc] init];
		
		// Set the arrow tip of down arrow
		noteRect.size.height = sectionHeight * 1.3;
		noteRect.size.width = sectionHeight * 0.8;
		noteRect.origin.x = 3 * (bounds.size.width - noteRect.size.width)/4;
		noteRect.origin.y = ((bounds.size.height/2) + (bounds.size.height - PSTOP_BOTTOM_MARGIN * 2) * notePosition) - noteRect.size.height/2;
	
		if (upDown == 0)
			[bezierPath moveToPoint:NSMakePoint(noteRect.origin.x + noteRect.size.width / 2, noteRect.origin.y)];
        else
            [bezierPath moveToPoint:NSMakePoint(noteRect.origin.x + noteRect.size.width / 2, noteRect.origin.y + noteRect.size.height)];

		// Set the arrow top left corner
		if (upDown == 0)
			[bezierPath lineToPoint:NSMakePoint(noteRect.origin.x, noteRect.origin.y + noteRect.size.height)];
        else
            [bezierPath lineToPoint:NSMakePoint(noteRect.origin.x, noteRect.origin.y)];
		// Set the arrow top right corner
		if (upDown == 0)
			[bezierPath lineToPoint:NSMakePoint(noteRect.origin.x + noteRect.size.width, noteRect.origin.y + noteRect.size.height)];
        else
            [bezierPath lineToPoint:NSMakePoint(noteRect.origin.x + noteRect.size.width, noteRect.origin.y)];
		[bezierPath closePath];
		[bezierPath setLineWidth:1.0];
		[bezierPath setLineCapStyle:NSButtLineCapStyle];
		//[noteRect setLineJointStyle:NSRoundLineJointStyle];
		[bezierPath stroke];
		[bezierPath fill];
		[bezierPath release];
    }
    
	// Check if we need to add a sharp sign and draw one if so
	
	if (sharpNeeded == NO) {
    } else {
		bezierPath = [[NSBezierPath alloc] init];
		// Set a box to draw it in
		noteRect.size.height = sectionHeight * 2;
		noteRect.size.width = sectionHeight * 1;
		noteRect.origin.x = (bounds.size.width - noteRect.size.width) / 4;
		noteRect.origin.y = (bounds.size.height / 2 + (bounds.size.height - PSTOP_BOTTOM_MARGIN * 2) * notePosition) - noteRect.size.height / 2;
		
		// Set left vertical line
		[bezierPath moveToPoint:NSMakePoint(noteRect.origin.x + noteRect.size.width/4, noteRect.origin.y)];
		[bezierPath lineToPoint:NSMakePoint(noteRect.origin.x + noteRect.size.width/4, noteRect.origin.y + noteRect.size.height)];
		
		// Set right vertical line
		[bezierPath moveToPoint:NSMakePoint(noteRect.origin.x + 3 * noteRect.size.width/4, noteRect.origin.y)];
		[bezierPath lineToPoint:NSMakePoint(noteRect.origin.x + 3 * noteRect.size.width/4, noteRect.origin.y + noteRect.size.height)];
		
		[bezierPath setLineWidth:1.0];
		[bezierPath stroke];
		[bezierPath release];
		
		bezierPath = [[NSBezierPath alloc] init];


		float tilt = sectionHeight / 5;
		[bezierPath setLineWidth:3];
		
		// Set bottom horizontal line
		[bezierPath moveToPoint:NSMakePoint(noteRect.origin.x, noteRect.origin.y + noteRect.size.height / 2 - 2 * tilt)];
		[bezierPath lineToPoint:NSMakePoint(noteRect.origin.x + noteRect.size.width, noteRect.origin.y + noteRect.size.height / 2 - tilt)];
		
		// Set top horizontal line
		[bezierPath moveToPoint:NSMakePoint(noteRect.origin.x, noteRect.origin.y + noteRect.size.height / 2 + tilt)];
		[bezierPath lineToPoint:NSMakePoint(noteRect.origin.x + noteRect.size.width, noteRect.origin.y + noteRect.size.height / 2 + 2 * tilt)];

		
		[bezierPath stroke];
		[bezierPath fill];
		[bezierPath release];
	}
 	
	
	
}	



- (void)drawPitch:(int)pitch Cents:(int)cents Volume:(float)volume;
{
	NSLog(@"pitchscale:drawPitch %d, %d, %f", pitch, cents, volume);
	int position, sharp, makeNotePosition();
    /*  GET THE POSITION OF THE NOTE ON THE SCALE  */
	if (makeNotePosition(pitch, &position, &sharp) == ERROR) {
		NSBeep();
		return;
	}
	notePosition = (float)(position)/28;
	NSLog(@" position, note position %d %f", position, notePosition);
	
	if (sharp == 0)
		sharpNeeded = NO;
    else
        sharpNeeded = YES;
    
    if (cents == 0) {
        arrowNeeded = NO;
        //NSLog(@"Arrow not needed"); **** 
    } else {
        arrowNeeded = YES;
        if (cents > 0)
            upDown = 1;
        else
            upDown = 0;
        //NSLog(@"Arrow needed, cents, upDown %d %d", cents, upDown); **** 
    }
	
	
    //  DISPLAY THE NOTE, SHARP, AND ARROW  
	[self setNeedsDisplay:YES]; 
}





/******************************************************************************
*
*	function:	notePosition
*
*	purpose:	Returns the staff position and sharp flag for the
*                       given note number (semitone scale with middle C equal
*                       to 0).
*			
*       arguments:      noteNumber, position, sharp
*
******************************************************************************/

int makeNotePosition(int noteNumber, int *position, int *sharp)
{
    static int matrix[NOTE_NUMBER_MAX * 2 + 1][2] = {
	{-14,0}, {-14,1}, {-13,0}, {-13,1}, {-12,0}, {-11,0}, {-11,1},
	{-10,0}, {-10,1}, {-9, 0}, {-9, 1}, {-8, 0}, {-7, 0}, {-7, 1},
	{-6, 0}, {-6, 1}, {-5, 0}, {-4, 0}, {-4, 1}, {-3, 0}, {-3, 1},
	{-2, 0}, {-2, 1}, {-1, 0}, {0,  0}, {0,  1}, {1,  0}, {1,  1},
	{2,  0}, {3,  0}, {3,  1}, {4,  0}, {4,  1}, {5,  0}, {5,  1},
	{6,  0}, {7,  0}, {7,  1}, {8,  0}, {8,  1}, {9,  0}, {10, 0},
	{10, 1}, {11, 0}, {11, 1}, {12, 0}, {12, 1}, {13, 0}, {14, 0}
    };
	
    /*  MAKE SURE NOTE NUMBER IN RANGE  */
    if ((noteNumber < NOTE_NUMBER_MIN) || (noteNumber > NOTE_NUMBER_MAX)) {
		*position = *sharp = 0;
		return (ERROR);
    }
	
    /*  ADJUST NOTE NUMBER SO THAT MATRIX CAN BE INDEXED PROPERLY  */
    noteNumber += NOTE_NUMBER_MAX;
	
    /*  SET POSITION AND SHARP VALUES  */
    *position = matrix[noteNumber][POSITION];
    *sharp = matrix[noteNumber][SHARP];
	
    return (SUCCESS);
}	 


- (void)pitchChanged:(NSNotification *)note;
{
    int sectionId;
	float radius;
	NSLog(@"Pitch change notification received and being acted on");
	//sectionId = [[[note userInfo] objectForKey:@"sliderId"] shortValue];
	//radius = [[[note userInfo] objectForKey:@"radius"] floatValue];
	//NSLog(@"In sliderMoved id is %d and radius is %f", sectionId, radius);
    double pitch = *((double *) getGlotPitch());
    double cents = (int)((pitch - (int)pitch)/100);
    double volume = *((double *) getGlotVol());
    [self drawPitch:pitch Cents:cents Volume:volume];

}


@end
