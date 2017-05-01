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

@interface BAContainerView : UIView

@end

@implementation BAContainerView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
}

@end

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
        for (int i; i < 10; i++) {
            self.exampleContainerView = [self nextBAFluidViewExample];
            [self.view addSubview:self.exampleContainerView];
            [self configureAnimator];
            [self.view insertSubview:self.exampleContainerView belowSubview:self.swipeForNextExampleLabel];
        }
    }
    
}

- (void)configureAnimator {
    UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.exampleContainerView]];
    [_animator addBehavior:gravityBehavior];
    
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.exampleContainerView]];
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    [collisionBehavior addBoundaryWithIdentifier:@"collistionPoint" fromPoint:CGPointMake(0, 100) toPoint:CGPointMake(100, 50)];
    [_animator addBehavior:collisionBehavior];
    
}

#pragma mark - Gestures

- (void)moveForContainerView:(CMAccelerometerData *)data {
    if (!data) {
        return;
    }
    
    for (UIDynamicBehavior *behavior in _animator.behaviors) {
        if (![behavior isMemberOfClass:[UIGravityBehavior class]]) {
            continue;
        }
        
        UIGravityBehavior *gravityBehavior = (UIGravityBehavior *)behavior;
        gravityBehavior.gravityDirection = CGVectorMake(data.acceleration.x, -data.acceleration.y);
    }
    
}

//- (void)moveForContainerView:(CMGyroData *)data {
//    if (!data) {
//        return;
//    }
//    
//    for (UIDynamicBehavior *behavior in _animator.behaviors) {
//        if (![behavior isMemberOfClass:[UIGravityBehavior class]]) {
//            continue;
//        }
//        
//        UIGravityBehavior *gravityBehavior = (UIGravityBehavior *)behavior;
//        gravityBehavior.gravityDirection = CGVectorMake(data.rotationRate.x, data.rotationRate.y);
//    }
//    
//}


- (void)changeTitleColor:(UIColor*)color {
    
    //better contrast
    for (UILabel* label in self.titleLabels) {
        [label setTextColor:color];
        label.textColor = UIColor.clearColor;
    }
}

-(UIView*) nextBAFluidViewExample {
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
            
//            [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue]
//                                            withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
//                                                
//                                                [self moveForContainerView:gyroData];
//            }];
            
            
            [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                                     withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
                                                         [self moveForContainerView:accelerometerData];
                                                     }
             ];
        }
        
        
        CGFloat edge = 200;
        
        BAContainerView *containerView = [[BAContainerView alloc] initWithFrame:CGRectMake(0, 0, edge, edge)];
        
        fluidView = [[BAFluidView alloc] initWithFrame:CGRectMake(0, 0, edge, edge) startElevation:@0.5];
        fluidView.strokeColor = [UIColor redColor];
        fluidView.fillColor = [UIColor blueColor];
        [fluidView keepStationary];
        [fluidView startAnimation];
        [fluidView startTiltAnimation];
        fluidView.layer.borderWidth = 1;
        fluidView.layer.borderColor = UIColor.blackColor.CGColor;
        fluidView.layer.cornerRadius = edge / 2;
        [self changeTitleColor:[UIColor greenColor]];
        
        [containerView addSubview:fluidView];
        
        UILabel *tiltLabel = [[UILabel alloc] init];
        tiltLabel.font =[UIFont fontWithName:@"LoveloBlack" size:36];
        tiltLabel.text = @"Tilt Phone!";
        tiltLabel.textColor = [UIColor whiteColor];
        [containerView addSubview:tiltLabel];
        
        tiltLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [containerView addConstraint:[NSLayoutConstraint constraintWithItem:tiltLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:fluidView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [containerView addConstraint:[NSLayoutConstraint constraintWithItem:tiltLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:fluidView attribute:NSLayoutAttributeTop multiplier:1.0 constant:80]];
        return containerView;
    }
    
    
    return nil;
}

@end
