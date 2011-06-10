//
//  ViewController.m
//  Created by http://github.com/iosdeveloper
//

#import "ViewController.h"
#import "ExpandyButton.h"

@implementation ViewController

- (void)toggleFlashlight:(id)sender {
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
	[device lockForConfiguration:nil];
	[device setTorchMode:[(ExpandyButton *)sender selectedItem]];
	[device unlockForConfiguration];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[self view] setBackgroundColor:[UIColor blackColor]];
	
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
	if ([device hasTorch]) {
        ExpandyButton *torchModeButton = [[[ExpandyButton alloc] initWithPoint:CGPointMake(20.0, 20.0)
																		 title:@"Flash"
																   buttonNames:[NSArray arrayWithObjects:@"Off", @"On", @"Auto", nil]
																  selectedItem:[device torchMode]] autorelease];
		[torchModeButton addTarget:self action:@selector(toggleFlashlight:) forControlEvents:UIControlEventValueChanged];
		[torchModeButton setHidden:NO];
        
		[[self view] addSubview:torchModeButton];
	}
}

@end