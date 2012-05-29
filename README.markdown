GPageFlipper
==============
GPageFlipper is modify from AFKPageFlipper (https://github.com/mtabini/AFKPageFlipper).

* Because it needs a new DataSource:

----
    @protocol GPageFlipperDataSource
        - (UIView *) currentViewToInitFlipper:(GPageFlipper *) pageFlipper;
        - (UIView *) nextView:(UIView *) currentView inFlipper:(GPageFlipper *) pageFlipper;
        - (UIView *) prevView:(UIView *) currentView inFlipper:(GPageFlipper *) pageFlipper;
    @end


* Not the AFKPageFlipper's DataSource

----
    @protocol AFKPageFlipperDataSource
        - (NSInteger) numberOfPagesForPageFlipper:(AFKPageFlipper *) pageFlipper;
        - (UIView *) viewForPage:(NSInteger) page inFlipper:(AFKPageFlipper *) pageFlipper;
    @end


Enjoty it.





