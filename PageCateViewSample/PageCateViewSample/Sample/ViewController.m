//
//  ViewController.m
//  PageCateViewSample
//
//  Created by Ossey on 27/07/2017.
//  Copyright © 2017 Ossey. All rights reserved.
//

#import "ViewController.h"
#import "PageCateButtonView.h"
#import "PageContainerView.h"
#import "Sample1TableViewController.h"

@interface ViewController () <PageContainerViewDelegate, PageCateButtonViewDelegate>
@property (nonatomic, strong) PageCateButtonView *pageTitleView;
@property (nonatomic, strong) PageContainerView *pageContentView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupPageView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupPageView {
    
    
    /// pageContentView
    CGFloat contentViewHeight = self.view.frame.size.height - 108;
    
    self.pageContentView = [[PageContainerView alloc] initWithFrame:CGRectMake(0, 125, self.view.frame.size.width, contentViewHeight) delegate:self];
    [self.view addSubview:_pageContentView];

    
}


- (void)pageContainerView:(PageContainerView *)pageContentView didScrollWithProgress:(CGFloat)progress fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
}

- (UIView *)pageCateChannelViewForContainerView:(PageContainerView *)containerView forIndex:(NSInteger)index {
    
    return self.childViewControllers[index].view;
}

- (PageCateButtonView *)pageCateButtonViewForContainerView {
    return self.pageTitleView;
    
}

- (PageCateButtonView *)pageTitleView {
    if (!_pageTitleView) {
        NSMutableArray *vcs = @[].mutableCopy;
        NSMutableArray *buttonItems = @[].mutableCopy;
        NSInteger i = 0;
        do {
            Sample1TableViewController *vc = [[Sample1TableViewController alloc] init];
            [vcs addObject:vc];
            PageCateButtonItem *buttonItem = [PageCateButtonItem new];
            buttonItem.contentWidth = 60;
            buttonItem.title = [NSString stringWithFormat:@"list%ld", i];
            buttonItem.imageName = [NSString stringWithFormat:@"trip_sharing_%ld_publish_selected", i+1];
            [buttonItems addObject:buttonItem];
            [self addChildViewController:vc];
            i++;
        } while (i < 14);
        _pageTitleView = [[PageCateButtonView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 60)];
        [self.view addSubview:_pageTitleView];
        _pageTitleView.cateItems = buttonItems;
        _pageTitleView.underLineCanScroll = YES;
        _pageTitleView.selectedIndex = 1;

    }
    [self.view bringSubviewToFront:_pageTitleView];
    return _pageTitleView;
}


@end
