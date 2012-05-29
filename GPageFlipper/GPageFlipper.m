//
//  GPageFlipper.m
//  GPageFlipper
//
//  Created by gelosie.wang@gmail.com on 12-5-28.
//  Copyright (c) 2012年 gelosie.wang@gmail.com. All rights reserved.
//

#import "GPageFlipper.h"

#pragma mark - UIView helper

@interface UIView(RenderShots) 
- (UIImage *) saveRenderShots;
@end


@implementation UIView(RenderShots)
- (UIImage *) saveRenderShots {
    CGFloat oldAlpha = self.alpha;
    self.alpha = 1;
    UIGraphicsBeginImageContext(self.bounds.size);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    self.alpha = oldAlpha;
	return resultingImage;
}
@end


#pragma mark - GPageFlipper private method
@interface GPageFlipper (PrivateGPageFlipper)
- (void) asynLoadInvisibleView;
- (void) loadInvisibleView;

- (void) initFlip;
- (void) setFlipProgress:(float) progress setDelegate:(BOOL) setDelegate animate:(BOOL) animate;
- (void) cleanupFlip;
- (void) flipPage;

- (void) swiped:(UISwipeGestureRecognizer *)recognizer;
- (void) tapped:(UITapGestureRecognizer *) recognizer;
@end

#pragma mark - GPageFlipper implementation

@implementation GPageFlipper
@synthesize delegate;
@synthesize dataSource;
@synthesize disabled;

+ (Class) layerClass {
	return [CATransformLayer class];
}

- (id)initWithFrame:(CGRect) frame forView:(UIView *) initView
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
		UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
        leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
        rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:tapRecognizer];
        [self addGestureRecognizer:leftSwipeRecognizer];
        [self addGestureRecognizer:rightSwipeRecognizer];
        
        animating = NO;
        disabled = NO;
        loadedView = NO;
        
        currentView = initView;
        [self addSubview:currentView];
    }
    return self;
}


- (void) tapped:(UITapGestureRecognizer *) recognizer
{
    if (animating || self.disabled) {
		return;
	}
	NSLog(@"----------taped");
	if (recognizer.state == UIGestureRecognizerStateRecognized) {
		if ([recognizer locationInView:self].x < (self.bounds.size.width - self.bounds.origin.x) / 2) {
            flipDirection = GPageFlipperDirectionRight;
            if (prevView == nil) {
                return;
            }
		} else {
            flipDirection = GPageFlipperDirectionLeft;
            if (nextView == nil) {
                return;
            }
		}
	}
    animating = YES;
    [self initFlip];
    [self performSelector:@selector(flipPage) withObject:nil afterDelay:0.001];
}


-(void)swiped:(UISwipeGestureRecognizer *)recognizer{
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        
    }else if(recognizer.direction == UISwipeGestureRecognizerDirectionRight){
        
    }
}

- (void) setDataSource:(id<GPageFlipperDataSource>)aDataSource
{
    dataSource = aDataSource;
    [self asynLoadInvisibleView];
    
}

- (void) asynLoadInvisibleView
{
    loadedView = NO;
    [self performSelectorInBackground:@selector(loadInvisibleView) withObject:nil];
}

- (void) loadInvisibleView
{
    loadedView = NO;
    if (dataSource != nil) {
        prevView = [dataSource prevView:currentView inFlipper:self];
        if (prevView != nil) {
            prevView.alpha = 0.0;
            [self addSubview:prevView];
        }
        nextView = [dataSource nextView:currentView inFlipper:self];
        if (nextView != nil) {
            nextView.alpha = 0.0;
            [self addSubview:nextView];
        }
    }
    loadedView = YES;
}


- (void) initFlip {
    
	
	// Create screenshots of view
    UIImage *currentImage = nil;
	UIImage *newImage = nil;
	if (flipDirection == GPageFlipperDirectionLeft) {
        currentImage = [currentView saveRenderShots];
        newImage = [nextView saveRenderShots];
    }else{
        currentImage = [currentView saveRenderShots];
        newImage = [prevView saveRenderShots];
    }
	
	
	
	// Hide existing views
	
	currentView.alpha = 0;
	nextView.alpha = 0;
	
	// Create representational layers
	
	CGRect rect = self.bounds;
	rect.size.width /= 2;
	
	backgroundAnimationLayer = [CALayer layer];
	backgroundAnimationLayer.frame = self.bounds;
	backgroundAnimationLayer.zPosition = -300000;
	
	CALayer *leftLayer = [CALayer layer];
	leftLayer.frame = rect;
	leftLayer.masksToBounds = YES;
	leftLayer.contentsGravity = kCAGravityLeft;
	
	[backgroundAnimationLayer addSublayer:leftLayer];
	
	rect.origin.x = rect.size.width;
	
	CALayer *rightLayer = [CALayer layer];
	rightLayer.frame = rect;
	rightLayer.masksToBounds = YES;
	rightLayer.contentsGravity = kCAGravityRight;
	
	[backgroundAnimationLayer addSublayer:rightLayer];
	
	if (flipDirection == GPageFlipperDirectionRight) {
		leftLayer.contents = (id) [newImage CGImage];
		rightLayer.contents = (id) [currentImage CGImage];
	} else {
		leftLayer.contents = (id) [currentImage CGImage];
		rightLayer.contents = (id) [newImage CGImage];
	}
    
	[self.layer addSublayer:backgroundAnimationLayer];
	
	rect.origin.x = 0;
	
	flipAnimationLayer = [CATransformLayer layer];
	flipAnimationLayer.anchorPoint = CGPointMake(1.0, 0.5);
	flipAnimationLayer.frame = rect;
	
	[self.layer addSublayer:flipAnimationLayer];
	
	CALayer *backLayer = [CALayer layer];
	backLayer.frame = flipAnimationLayer.bounds;
	backLayer.doubleSided = NO;
	backLayer.masksToBounds = YES;
	
	[flipAnimationLayer addSublayer:backLayer];
	
	CALayer *frontLayer = [CALayer layer];
	frontLayer.frame = flipAnimationLayer.bounds;
	frontLayer.doubleSided = NO;
	frontLayer.masksToBounds = YES;
	frontLayer.transform = CATransform3DMakeRotation(M_PI, 0, 1.0, 0);
	
	[flipAnimationLayer addSublayer:frontLayer];
	
	if (flipDirection == GPageFlipperDirectionRight) {
		backLayer.contents = (id) [currentImage CGImage];
		backLayer.contentsGravity = kCAGravityLeft;
		
		frontLayer.contents = (id) [newImage CGImage];
		frontLayer.contentsGravity = kCAGravityRight;
		
		CATransform3D transform = CATransform3DMakeRotation(0.0, 0.0, 1.0, 0.0);
		transform.m34 = 1.0f / 2500.0f;
		
		flipAnimationLayer.transform = transform;
		
		currentAngle = startFlipAngle = 0;
		endFlipAngle = -M_PI;
	} else {
		backLayer.contentsGravity = kCAGravityLeft;
		backLayer.contents = (id) [newImage CGImage];
		
		frontLayer.contents = (id) [currentImage CGImage];
		frontLayer.contentsGravity = kCAGravityRight;
		
		CATransform3D transform = CATransform3DMakeRotation(-M_PI / 1.1, 0.0, 1.0, 0.0);
		transform.m34 = -1.0f / 2500.0f;
		
		flipAnimationLayer.transform = transform;
		
		currentAngle = startFlipAngle = -M_PI;
		endFlipAngle = 0;
	}
}



- (void) setFlipProgress:(float) progress setDelegate:(BOOL) setDelegate animate:(BOOL) animate {
    if (animate) {
        animating = YES;
    }
    
	float newAngle = startFlipAngle + progress * (endFlipAngle - startFlipAngle);
	
	float duration = animate ? 0.5 * fabs((newAngle - currentAngle) / (endFlipAngle - startFlipAngle)) : 0;
	
	currentAngle = newAngle;
	
	CATransform3D endTransform = CATransform3DIdentity;
	endTransform.m34 = 1.0f / 2500.0f;
	endTransform = CATransform3DRotate(endTransform, newAngle, 0.0, 1.0, 0.0);	
	
	[flipAnimationLayer removeAllAnimations];
	[self setUserInteractionEnabled:NO];
    
	[CATransaction begin];
	[CATransaction setAnimationDuration:duration];
	
	flipAnimationLayer.transform = endTransform;
	
	[CATransaction commit];
	
	if (setDelegate) {
		[self performSelector:@selector(cleanupFlip) withObject:nil afterDelay:duration];
	}
	
}

- (void) flipPage {
	[self setFlipProgress:1.0 setDelegate:YES animate:YES];
}

- (void) cleanupFlip 
{
	[backgroundAnimationLayer removeFromSuperlayer];
	[flipAnimationLayer removeFromSuperlayer];
	
	backgroundAnimationLayer = nil;
	flipAnimationLayer = nil;
	
	animating = NO;
	
    if (flipDirection == GPageFlipperDirectionLeft) {
        currentView.alpha = 0.0;
        nextView.alpha = 1.0;
        
        if (prevView != nil) {
            [prevView removeFromSuperview];
        }
        
        prevView = nil;
        prevView = currentView;
        currentView = nextView;
        nextView = [dataSource nextView:currentView inFlipper:self];
        if (nextView != nil) {
            nextView.alpha = 0.0;
            [self addSubview:nextView];
        }
        
    }else{
        currentView.alpha = 0.0;
        prevView.alpha = 1.0;
        if (nextView != nil) {
            [nextView removeFromSuperview];
        }
        
        nextView = nil;
        nextView = currentView;
        currentView = prevView;
        prevView = [dataSource prevView:currentView inFlipper:self];
        if (prevView != nil) {
            prevView.alpha = 0.0;
            [self addSubview:prevView];
        }
        
    }
    
    
    
	[self setUserInteractionEnabled:YES];
    
    
}


@end
