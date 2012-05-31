//
//  RootController.m
//  GPageFlipper
//
//  Created by gelosie.wang@gmail.com on 12-5-28.
//  Copyright (c) 2012年 gelosie.wang@gmail.com. All rights reserved.
//

#import "RootController.h"
#import "ColorView.h"

@implementation RootController
@synthesize flipper;

- (id) init {
	if ((self = [super init])) {

	}
	
	return self;
}


- (void)dealloc {
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
	flipper = [[GPageFlipper alloc]initWithFrame:CGRectMake(100.0, 100.0, 300.0, 300.0)];
	flipper.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	flipper.dataSource = self;
    //[flipper loadInvisibleView];
	[self.view addSubview:flipper];
    
    ColorView *iv = [[ColorView alloc]initWithFrame:flipper.bounds];
    [iv  setIndex : 0];
    [flipper setCurrentView:iv animated:YES];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (UIView *) nextView:(UIView *) currentView inFlipper:(GPageFlipper *) pageFlipper
{
    NSInteger i = ((ColorView *)currentView).index;
    i++;
    ColorView *cv = [[ColorView alloc]initWithFrame:pageFlipper.bounds];
    [cv  setIndex :i];
    return  cv;
}

- (UIView *) prevView:(UIView *) currentView inFlipper:(GPageFlipper *) pageFlipper
{
    NSInteger i = ((ColorView *)currentView).index;
    if (i <= 0) {
        return nil;
    }
    i--;
    ColorView *cv = [[ColorView alloc]initWithFrame:pageFlipper.bounds];
    [cv  setIndex :i];
    return  cv;
}


@end
