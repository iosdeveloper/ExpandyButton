
/*
 </codex>
 */

#import "ExpandyButton.h"
#import <QuartzCore/QuartzCore.h>

// Measurements
static Boolean gInitMeasurements = false;
static CGFloat gWidth = 47.f;
static CGFloat gFrameHeight = 32.f;
static CGFloat gTitleXOrigin = 8.f;
static CGFloat gTitleYOrigin = 9.f;
static CGFloat gTitleHeight = 15.f;
static CGFloat gTitleWidth = 35.f;
static CGFloat gButtonHeight = 26.f;
static CGFloat gLabelHeight = 39.f;
static CGFloat gLabelXOrigin = 45.f;
static CGFloat gLabelYOrigin = -3.f;
static CGFloat gDefaultButtonWidth = 44.f;
static CGFloat gFontSize = 12.f;

// HUD Appearance
static CGFloat gLayerWhite = 1.f;
static CGFloat gLayerAlpha = .2f;
static CGFloat gBorderWhite = .0f;
static CGFloat gBorderAlpha = 1.f;
static CGFloat gBorderWidth = 1.f;


@interface ExpandyButton ()

@property (nonatomic,assign) BOOL expanded;
@property (nonatomic,assign) CGRect frameExpanded;
@property (nonatomic,assign) CGRect frameShrunk;
@property (nonatomic,assign) CGFloat buttonWidth;
@property (nonatomic,retain) UILabel *titleLabel;
@property (nonatomic,retain) NSArray *labels;

@end

@implementation ExpandyButton

@synthesize expanded = _expanded;
@synthesize frameExpanded = _frameExpanded;
@synthesize frameShrunk = _frameShrunk;
@synthesize buttonWidth = _buttonWidth;
@synthesize titleLabel = _titleLabel;
@synthesize labels = _labels;
@dynamic selectedItem;

- (id)initWithPoint:(CGPoint)point title:(NSString *)title buttonNames:(NSArray *)buttonNames selectedItem:(NSInteger)selectedItem
{
	if (!gInitMeasurements) {
		gInitMeasurements = true;
		const Boolean isIPad = ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone);
		if (isIPad) {
			gWidth = 93.f;
			gFrameHeight = 64.f;
			gTitleXOrigin = 16.f;
			gTitleYOrigin = 18.f;
			gTitleHeight = 30.f;
			gTitleWidth = 75.f;
			gButtonHeight = 52.f;
			gLabelHeight = 78.f;
			gLabelXOrigin = 86.f;
			gLabelYOrigin = -6.f;
			gDefaultButtonWidth = 100.f;
			gFontSize = 24.f;
			
			gBorderWidth = 2.f;				
		}	
	}

	
    CGRect frameShrunk = CGRectMake(point.x, point.y, gWidth + gDefaultButtonWidth, gFrameHeight);
    CGRect frameExpanded = CGRectMake(point.x, point.y, gWidth + gDefaultButtonWidth * [buttonNames count], gFrameHeight);
    if ((self = [super initWithFrame:frameShrunk])) {
        [self setFrameShrunk:frameShrunk];
        [self setFrameExpanded:frameExpanded];
        [self setButtonWidth:gDefaultButtonWidth];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(gTitleXOrigin, gTitleYOrigin, gTitleWidth, gTitleHeight)];
        [titleLabel setText:title];
        [titleLabel setFont:[UIFont systemFontOfSize:gFontSize]];
        [titleLabel setTextColor:[UIColor blackColor]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:titleLabel];
        [self setTitleLabel:titleLabel];
		[titleLabel release];
        
        NSMutableArray *labels = [[NSMutableArray alloc] initWithCapacity:3];
        NSInteger index = 0;
        UILabel *label;
        for (NSString *buttonName in buttonNames) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(gLabelXOrigin + (gDefaultButtonWidth * index), gLabelYOrigin, gDefaultButtonWidth, gButtonHeight)];
            [label setText:buttonName];
            [label setFont:[UIFont systemFontOfSize:gFontSize]];
            [label setTextColor:[UIColor blackColor]];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setTextAlignment:UITextAlignmentCenter];
            [self addSubview:label];
            [labels addObject:label];
            [label release];
            index += 1;
        }
        
        [self setLabels:labels];
        [labels release];
        
        [self addTarget:self action:@selector(chooseLabel:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self setBackgroundColor:[UIColor clearColor]];
        
        CALayer *layer = [self layer];
        [layer setBackgroundColor:[[UIColor colorWithWhite:gLayerWhite alpha:gLayerAlpha] CGColor]];
        [layer setBorderWidth:gBorderWidth];
        [layer setBorderColor:[[UIColor colorWithWhite:gBorderWhite alpha:gBorderAlpha] CGColor]];
        [layer setCornerRadius:15.f];
        
        [self setExpanded:YES];
		[self setHidden:YES];
        
        [self setSelectedItem:selectedItem];
    }
    return self;    
}

- (id)initWithPoint:(CGPoint)point title:(NSString *)title buttonNames:(NSArray *)buttonNames
{
    return [self initWithPoint:point title:title buttonNames:buttonNames selectedItem:0];
}

- (void)chooseLabel:(id)sender forEvent:(UIEvent *)event
{
    [UIView beginAnimations:nil context:NULL];
    if ([self expanded] == NO) {
        [self setExpanded:YES];
        
        NSInteger index = 0;
        for (UILabel *label in [self labels]) {
            if (index == [self selectedItem]) {
                [label setFont:[UIFont boldSystemFontOfSize:gFontSize]];
            } else {
                [label setTextColor:[UIColor colorWithWhite:0.f alpha:.8f]];
            }
            [label setFrame:CGRectMake(gLabelXOrigin + ([self buttonWidth] * index), gLabelYOrigin, [self buttonWidth], gLabelHeight)];
            index += 1;
        }
        
        [[self layer] setFrame:[self frameExpanded]];
    } else {
        BOOL inside = NO;
        
        NSInteger index = 0;
        for (UILabel *label in [self labels]) {
            if ([label pointInside:[[[event allTouches] anyObject] locationInView:label] withEvent:event]) {
                [label setFrame:CGRectMake(gLabelXOrigin, gLabelYOrigin, [self buttonWidth], gLabelHeight)];
                inside = YES;
                break;
            }
            index += 1;
        }
        
        if (inside) {
            [self setSelectedItem:index];
        }
    }
    [UIView commitAnimations];
}

- (NSInteger)selectedItem
{
    return _selectedItem;
}

- (void)setSelectedItem:(NSInteger)selectedItem
{
    if (selectedItem < [[self labels] count]) {
        CGRect leftShrink = CGRectMake(gLabelXOrigin, gLabelYOrigin, 0.f, gLabelHeight);
        CGRect rightShrink = CGRectMake(gLabelXOrigin + [self buttonWidth], gLabelYOrigin, 0.f, gLabelHeight);
        CGRect middleExpanded = CGRectMake(gLabelXOrigin, gLabelYOrigin, [self buttonWidth], gLabelHeight);
        NSInteger count = 0;    
        BOOL expanded = [self expanded];
        
        if (expanded) {
            [UIView beginAnimations:nil context:NULL];
        }
        
        for (UILabel *label in [self labels]) {
            if (count < selectedItem) {
                [label setFrame:leftShrink];
                [label setFont:[UIFont systemFontOfSize:gFontSize]];
            } else if (count > selectedItem) {
                [label setFrame:rightShrink];
                [label setFont:[UIFont systemFontOfSize:gFontSize]];
            } else if (count == selectedItem) {
                [label setFrame:middleExpanded];
                [label setFont:[UIFont systemFontOfSize:gFontSize]];
                [label setTextColor:[UIColor blackColor]];
            }
            count += 1;
        }
        
        if (expanded) {
            [[self layer] setFrame:[self frameShrunk]];
            [UIView commitAnimations];
            [self setExpanded:NO];
        }
        
        if (_selectedItem != selectedItem) {
            _selectedItem = selectedItem;
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }        
    }
}

- (void)dealloc {
    [self setTitleLabel:nil];
    [self setLabels:nil];
    [super dealloc];
}


@end
