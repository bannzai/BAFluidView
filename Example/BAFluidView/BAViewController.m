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

@property (nonatomic) NSMutableArray<UIView *> *views;

@end

@implementation BAViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.firstTimeLoading = YES;
    
    self.views = [NSMutableArray new];
    
self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];

}

- (void)viewDidLayoutSubviews {
    
    if (self.firstTimeLoading) {
        self.firstTimeLoading = NO;
        NSArray *edges = @[@100, @50, @30, @100, @80, @90, @200, @70, @60, @20];
        for (int i = 0; i < edges.count; i++) {
            CGFloat edge = ((NSNumber *)edges[i]).floatValue;
            UIView *view = [self nextBAFluidViewExample:edge];
            [self.view addSubview:view];
            [self.views addObject:view];
        }
        [self configureAnimator];
    }
    
}

- (void)configureAnimator {
    UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:self.views];
    [_animator addBehavior:gravityBehavior];
    
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:self.views];
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;
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
    }
}

-(UIView*) nextBAFluidViewExample:(CGFloat)edge {
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
        
        
        fluidView = [[BAFluidView alloc] initWithFrame:CGRectMake(edge, edge, edge, edge) startElevation:@0.5];
        fluidView.strokeColor = [UIColor redColor];
        fluidView.fillColor = [UIColor blueColor];
        [fluidView keepStationary];
        [fluidView startAnimation];
        [fluidView startTiltAnimation];
        fluidView.layer.borderWidth = 1;
        fluidView.layer.borderColor = UIColor.blackColor.CGColor;
//        fluidView.layer.cornerRadius = edge / 2;
        [self changeTitleColor:[UIColor greenColor]];
        
        
        UILabel *tiltLabel = [[UILabel alloc] init];
        tiltLabel.font =[UIFont fontWithName:@"LoveloBlack" size:36];
        tiltLabel.text = @"Tilt Phone!";
        tiltLabel.textColor = [UIColor whiteColor];
        [fluidView addSubview:tiltLabel];
        
        tiltLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [fluidView addConstraint:[NSLayoutConstraint constraintWithItem:tiltLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:fluidView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [fluidView addConstraint:[NSLayoutConstraint constraintWithItem:tiltLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:fluidView attribute:NSLayoutAttributeTop multiplier:1.0 constant:edge / 3]];
        return fluidView;
    }
    
    
    return nil;
}

@end
