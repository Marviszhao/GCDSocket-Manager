//
//  ViewController.m
//  GCDSocket-Manager
//
//  Created by MARVIS on 16/9/23.
//  Copyright © 2016年 MARVIS. All rights reserved.
//

#import "ViewController.h"
#import "QRSCanVC.h"
#import "ReceiveQRUIVC.h"
#import "SendJsonToServerVC.h"

@interface ViewController ()
- (IBAction)buttonClick:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)buttonClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    switch (btn.tag) {
        case 100:{//生成二维码
            ReceiveQRUIVC *receQRUIVC = [[ReceiveQRUIVC alloc] init];
            [self.navigationController pushViewController:receQRUIVC animated:YES];
        }
        break;
        case 101:{//扫描二维码
            QRSCanVC *scanVC = [[QRSCanVC alloc] init];
            UINavigationController *scanNav = [[UINavigationController alloc] initWithRootViewController:scanVC];
            [self presentViewController:scanNav animated:YES completion:nil];
        }
        break;
        case 102:{//链接新心动服务器
            SendJsonToServerVC *jsonVC = [[SendJsonToServerVC alloc] init];
            [self.navigationController pushViewController:jsonVC animated:YES];
        }
            break;
            
        default:
        break;
    }
    
}
@end
