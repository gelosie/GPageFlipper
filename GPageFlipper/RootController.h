//
//  RootController.h
//  GPageFlipper
//
//  Created by gelosie.wang@gmail.com on 12-5-28.
//  Copyright (c) 2012年 gelosie.wang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPageFlipper.h"

@interface RootController : UIViewController<GPageFlipperDataSource>

@property (retain, nonatomic) GPageFlipper *flipper;

@end
