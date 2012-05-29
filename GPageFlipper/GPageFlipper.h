//
//  GPageFlipper.h
//  GPageFlipper
//
//  Created by gelosie.wang@gmail.com on 12-5-28.
//  Copyright (c) 2012年 gelosie.wang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
	GPageFlipperDirectionLeft,
	GPageFlipperDirectionRight,
} GPageFlipperDirection;

@class GPageFlipper;

@protocol GPageFlipperDataSource
- (UIView *) nextView:(UIView *) currentView inFlipper:(GPageFlipper *) pageFlipper;
- (UIView *) prevView:(UIView *) currentView inFlipper:(GPageFlipper *) pageFlipper;

@end

@protocol GPageFlipperDelegate <NSObject>

@end


@interface GPageFlipper : UIView
{ 
    GPageFlipperDirection flipDirection;
    
    UIView *currentView;
    UIView *nextView;
    UIView *prevView;
    
    CALayer *backgroundAnimationLayer;
    CALayer *flipAnimationLayer;
    
    BOOL animating;
    BOOL loadedView;
    
    float startFlipAngle;
	float endFlipAngle;
	float currentAngle;
}

@property (nonatomic, assign, setter = setDataSource:) id<GPageFlipperDataSource> dataSource;
@property (nonatomic, assign) id<GPageFlipperDelegate> delegate;
@property (nonatomic,assign) BOOL disabled;

- (id)initWithView:(UIView *) initView;

@end

