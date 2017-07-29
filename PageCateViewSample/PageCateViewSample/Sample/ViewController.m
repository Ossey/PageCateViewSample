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
#import "Masonry.h"

@interface ViewController () <PageContainerViewDelegate, PageCateButtonViewDelegate>
@property (nonatomic, strong) PageCateButtonView *cateButtonView;
@property (nonatomic, strong) PageContainerView *pageContentView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupPageView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"test" style:UIBarButtonItemStylePlain target:self action:@selector(testAction)];
}

- (void)testAction {
    [_cateButtonView setSizeToFltWhenScreenNotPaved:!_cateButtonView.sizeToFltWhenScreenNotPaved];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
  
}


- (void)setupPageView {
    
    
    self.pageContentView = [[PageContainerView alloc] init];
    self.pageContentView.delegate = self;
    [self.view addSubview:_pageContentView];
    [_pageContentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_cateButtonView.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    self.pageContentView.rootViewController = self;
    NSMutableArray *vcs = @[].mutableCopy;
    NSInteger i = 0;
    do {
        Sample1TableViewController *vc = [[Sample1TableViewController alloc] init];
        [vcs addObject:vc];
        i++;
    } while (i < 3);
    self.pageContentView.childViewControllers = vcs;
    
    self.cateButtonView.selectedIndex = 1;
}


- (void)pageContainerView:(PageContainerView *)pageContentView didScrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress {

}


- (PageCateButtonView *)pageCateButtonViewForContainerView {
    return self.cateButtonView;
    
}

- (PageCateButtonView *)cateButtonView {
    if (!_cateButtonView) {
        
        NSMutableArray *buttonItems = @[].mutableCopy;
        NSInteger i = 0;
        do {
            PageCateButtonItem *buttonItem = [PageCateButtonItem new];
            buttonItem.contentWidth = 60;
            buttonItem.title = [NSString stringWithFormat:@"list%ld", i];
            buttonItem.imageName = [NSString stringWithFormat:@"trip_sharing_%ld_publish_selected", i+1];
            [buttonItems addObject:buttonItem];
            i++;
        } while (i < 3);
        _cateButtonView = [[PageCateButtonView alloc] init];
        [self.view addSubview:_cateButtonView];
        _cateButtonView.buttonItems = buttonItems;
        _cateButtonView.underLineCanScroll = YES;
        PageCateButtonItem *item = [PageCateButtonItem new];
        item.title = @"right";
        [item.button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        item.button.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.2];
        _cateButtonView.rightItem = item;
        
        CGFloat cateButtonViewTop = self.navigationController.isNavigationBarHidden ? 0 : 64;
        [_cateButtonView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.mas_equalTo(cateButtonViewTop);
            make.height.mas_equalTo(60);
        }];
        
    }
    [self.view bringSubviewToFront:_cateButtonView];
    return _cateButtonView;
}


@end
