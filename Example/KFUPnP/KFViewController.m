//
//  KFViewController.m
//  KFUPnP
//
//  Created by AlbertBoy on 09/11/2019.
//  Copyright (c) 2019 AlbertBoy. All rights reserved.
//

#import "KFViewController.h"
#import "DLNASearchVC.h"

@interface KFViewController ()

@end

@implementation KFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = UIColor.whiteColor;
    [self sendTestRequest];
    
    UIButton *nextBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [nextBtn setFrame:CGRectMake(100, 100, 80, 40)];
    [nextBtn setTitle:@"next" forState:(UIControlStateNormal)];
    [nextBtn setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
    [nextBtn addTarget:self action:@selector(goDLNA:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:nextBtn];
}

- (void)goDLNA:(UIButton *)sender {
    DLNASearchVC *dlna = [[DLNASearchVC alloc]init];
    [self.navigationController pushViewController:dlna animated:YES];
}

/**
 DLNA功能只有在用户允许了网络权限后才能使用
 */
-(void)sendTestRequest{
    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    NSMutableURLRequest *requst = [[NSMutableURLRequest alloc]initWithURL:url];
    requst.HTTPMethod = @"GET";
    requst.timeoutInterval = 5;
    
    [NSURLConnection sendAsynchronousRequest:requst queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (!connectionError.description) {
            NSLog(@"网络正常");
        }else{
            NSLog(@"=========>网络异常");
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
