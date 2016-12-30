//
//  SendJsonToServerVC.m
//  GCDSocket-Manager
//
//  Created by MARVIS on 16/10/10.
//  Copyright © 2016年 MARVIS. All rights reserved.
//

#import "SendJsonToServerVC.h"
#import "MACommon.h"
#import "SendTerminal.h"

#define HOST_ADDRESS @"you server host url"

#define HOST_PORT 10910

@interface SendJsonToServerVC ()<SendTerminalDelegate>

- (IBAction)buttonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong) SendTerminal *sendTerminal;

@end

@implementation SendJsonToServerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sendTerminal = [[SendTerminal alloc] initWithRemoteAddress:HOST_ADDRESS onPort:HOST_PORT];
    self.sendTerminal.delegate = self;
}

- (void)dealloc{
    [self.sendTerminal disConnect];
}

- (IBAction)buttonClick:(id)sender {
    NSDictionary *dic = @{@"type" : @(3),
                          @"alias": @"101010",
                          @"module": @"live",
                          @"order": @"notify",
                          };
    NSData *dataStream = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    
    [self.sendTerminal sendOriginData:dataStream];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


#pragma mark - SendTerminalDelegate
#pragma mark
- (void)sendTerminal:(SendTerminal *)sendTer didReadData:(NSData *)data{
    NSString *revicedStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (revicedStr) {
        NSDictionary *resDic = [MACommon dictionaryWithJsonString:revicedStr];
        NSLog(@"responseDic---%@",resDic);
        
        self.textView.text = [NSString stringWithFormat:@"%@\n%@",self.textView.text,resDic];
    }

}








@end
