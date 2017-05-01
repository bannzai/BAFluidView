//The MIT License (MIT)
//
//Copyright (c) 2014 Bryan Antigua <antigua.b@gmail.com>
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

#import "BAViewController.h"
#import "BAFluidView.h"
#import "UIColor+ColorWithHex.h"
#import <CoreMotion/CoreMotion.h>

@interface BAViewController ()

@property (strong,nonatomic) UIDynamicAnimator *animator;

@property (assign,nonatomic) BOOL firstTimeLoading;

@property(strong,nonatomic) CMMotionManager *motionManager;

@end

@implementation BAViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.firstTimeLoading = YES;
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
}

- (void)viewDidLayoutSubviews {
    
    if (self.firstTimeLoading) {
        self.firstTimeLoading = NO;
        self.exampleContainerView = [self nextBAFluidViewExample];
        [self.view insertSubview:self.exampleContainerView belowSubview:self.swipeForNextExampleLabel];
    }

}

#pragma mark - Gestures

- (void)changeTitleColor:(UIColor*)color {
    
    //better contrast
    for (UILabel* label in self.titleLabels) {
        [label setTextColor:color];
    }
}

-(BAFluidView*) nextBAFluidViewExample {
    BAFluidView *fluidView;
    
    if(self.motionManager){
        //stop motion manager if on
        [self.motionManager stopAccelerometerUpdates];
        self.motionManager = nil;
    }
    {
        self.motionManager = [[CMMotionManager alloc] init];
        
        if (self.motionManager.deviceMotionAvailable) {
            self.motionManager.deviceMotionUpdateInterval = 0.3f;
            [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                                    withHandler:^(CMDeviceMotion *data, NSError *error) {
                                                        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
                                                        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:
                                                                                  data forKey:@"data"];
                                                        [nc postNotificationName:kBAFluidViewCMMotionUpdate object:self userInfo:userInfo];
                                                    }];
        }
        
        fluidView = [[BAFluidView alloc] initWithFrame:self.view.frame startElevation:@0.5];
        fluidView.strokeColor = [UIColor whiteColor];
        fluidView.fillColor = [UIColor colorWithHex:0x2e353d];
        [fluidView keepStationary];
        [fluidView startAnimation];
        [fluidView startTiltAnimation];
        [self changeTitleColor:[UIColor blueColor]];
        
        UILabel *tiltLabel = [[UILabel alloc] init];
        tiltLabel.font =[UIFont fontWithName:@"LoveloBlack" size:36];
        tiltLabel.text = @"Tilt Phone!";
        tiltLabel.textColor = [UIColor whiteColor];
        [fluidView addSubview:tiltLabel];
        
        tiltLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [fluidView addConstraint:[NSLayoutConstraint constraintWithItem:tiltLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:fluidView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [fluidView addConstraint:[NSLayoutConstraint constraintWithItem:tiltLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:fluidView attribute:NSLayoutAttributeTop multiplier:1.0 constant:80]];
        return fluidView;
    }
    
    
    return nil;
}

@end
