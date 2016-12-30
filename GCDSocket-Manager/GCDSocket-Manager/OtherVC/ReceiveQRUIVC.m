//
//  ReceiveQRUIVC.m
//  GCDSocket-Manager
//
//  Created by MARVIS on 16/9/30.
//  Copyright © 2016年 MARVIS. All rights reserved.
//

#import "ReceiveQRUIVC.h"
#import "ReceiveTerminal.h"
#import "DeviceInfo.h"

@interface ReceiveQRUIVC ()<ReceiveTerminalDelegate>
    
@property (nonatomic, weak) IBOutlet UILabel *IPPortLab;
    
@property (nonatomic, weak) IBOutlet UIImageView *QRImgView;
    
@property (nonatomic, weak) IBOutlet UIImageView *receiveImgView;
    
@property (nonatomic, strong) ReceiveTerminal *receTerminal;
    
@end

@implementation ReceiveQRUIVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    
    static NSString *ipAddr = nil;
    if (ipAddr == nil) {
        ipAddr = [DeviceInfo IPAddress];
    }
    
    NSUInteger port = arc4random() % 1000 + 1000;
    NSString *IPProtStr = [NSString stringWithFormat:@"%@:%lu",ipAddr,(unsigned long)port];
    self.IPPortLab.text = IPProtStr;
    [self generateQRCodeWithStr:IPProtStr];
    
    self.receTerminal = [[ReceiveTerminal alloc] initWithPort:port];
    
    self.receTerminal.delegate = self;
    
}
    
- (void)cancelAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
    
- (void)generateQRCodeWithStr:(NSString *)IPProtStr{
    if (![IPProtStr isEqualToString:@""]) {
        NSData *data = [IPProtStr dataUsingEncoding:NSUTF8StringEncoding];
        
        CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        [filter setValue:data forKey:@"inputMessage"];
        CIImage *outputImage = filter.outputImage;
        
        CGFloat scale = CGRectGetWidth(self.QRImgView.bounds) / CGRectGetWidth(outputImage.extent);
        CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
        CIImage *transformImage = [outputImage imageByApplyingTransform:transform];
        
        self.QRImgView.image = [UIImage imageWithCIImage:transformImage];
    } else {
        NSLog(@"QRCodeString is empty.");
    }

}
    
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
    
#pragma mark -  ReceiveTerminalDelegate
#pragma mark
- (void)receiver:(ReceiveTerminal *)receTerminal didReceiveData:(NSData *)data num:(NSInteger)i{
    self.receiveImgView.image = [UIImage imageWithData:data];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
