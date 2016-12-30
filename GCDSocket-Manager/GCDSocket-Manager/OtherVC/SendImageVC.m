//
//  SendImageVC.m
//  GCDSocket-Manager
//
//  Created by MARVIS on 16/10/8.
//  Copyright © 2016年 MARVIS. All rights reserved.
//

#import "SendImageVC.h"
#import "UIImage+Helper.h"
#import "HTFileManager.h"
#import "SendTerminal.h"

#define kPhotoWidth 640.0f
#define kTempAvatorImgName @"userPic"

@interface SendImageVC ()<
UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate
>

@property (nonatomic, strong) SendTerminal *sendTerminal;

@property (strong, nonatomic)  UIImageView *avatorImgView;
@property (strong, nonatomic) UIActionSheet *avatorActionSheet;
@property (strong, nonatomic) UIImagePickerController *avatorImagePickController;
- (IBAction)buttonClick:(id)sender;


@end

@implementation SendImageVC

-(instancetype)initWithAddressAndPort:(NSString *)addProt{
    self = [super init];
    if (self) {
        NSArray *addressArr = [addProt componentsSeparatedByString:@":"];
        self.sendTerminal = [[SendTerminal alloc] initWithRemoteAddress:addressArr.firstObject onPort:[addressArr.lastObject integerValue]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *componentString = [kTempAvatorImgName stringByAppendingPathComponent:@"15729215172"];
    NSLog(@"componentString-->>>%@\n--------------------------ArchiveFilePath-----------------%@\n---------------------------------------------------------------------------",componentString,[HTFileManager getArchiveFilePath:componentString]);
    
    
    self.avatorImgView = [[UIImageView alloc] init];
    self.avatorImgView.bounds = CGRectMake(0, 0, 100, 100);
    
    NSString *imgPath = [HTFileManager getArchiveFilePath:kTempAvatorImgName];
    imgPath = [imgPath stringByAppendingPathComponent:@"15729215172"];
    NSLog(@"ArchiveFilePath-----------------%@\n",imgPath);
    if ([[NSFileManager defaultManager]fileExistsAtPath:imgPath]) {
        //实践证明沙盒上的程序每次运行其沙盒路径都是会变化的，所以不能保存图片的据对路径用以在下次进入时进行界面展示
        self.avatorImgView.image =  [UIImage imageWithContentsOfFile:imgPath];
        
        //两种方式都会加载出图片
        NSData *data = [NSData dataWithContentsOfFile:imgPath];
        UIImage *newImg = [UIImage imageWithData:data];
        self.avatorImgView.image = newImg;
    }
    
    
    [self addTapGesturesWithView:self.avatorImgView target:self selector:@selector(handleSelectedAvator:)];
    [self.view addSubview:self.avatorImgView];
    
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    //**********************设置cornerRadius 属性必须连带设置 clipsToBounds 为YES****************
//    self.avatorImgView.clipsToBounds = YES;
//    self.avatorImgView.layer.cornerRadius = 50;
    self.avatorImgView.backgroundColor = [UIColor cyanColor];
    self.avatorImgView.center = self.view.center;
}


- (IBAction)buttonClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
        case 100:{//发送
            if (self.avatorImgView.image == nil) {
                NSLog(@"图片数据为空发送异常！！！");
                return;
            }
            [self.sendTerminal sendOriginData:UIImagePNGRepresentation(self.avatorImgView.image)];
        }
            break;
        case 101:{//断开连接
            [self.sendTerminal disConnect];
        }
            break;
        case 102:{//重新连接
            [self.sendTerminal reConnect];
        }
            break;
            
        default:
            break;
    }
    
    
}

- (void)addTapGesturesWithView:(UIView*)view target:(id)target selector:(SEL)selector {
    view.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    [tapGesture setNumberOfTapsRequired:1];
    [view addGestureRecognizer:tapGesture];
}

- (void)handleSelectedAvator:(UITapGestureRecognizer *)gesture {
    if (!_avatorActionSheet ) {
#if TARGET_IPHONE_SIMULATOR
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择图片来源"
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"相册", nil];
        self.avatorActionSheet = actionSheet;
#elif TARGET_OS_IPHONE
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择图片来源"
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:@"相机"
                                                        otherButtonTitles:@"相册", nil];
        self.avatorActionSheet = actionSheet;
#endif
        
    }
    [_avatorActionSheet showInView:self.view];
    
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Clicked button at index:%li", (long)buttonIndex);
    
    if (buttonIndex == actionSheet.cancelButtonIndex) return;
    
    switch (buttonIndex) {
        case 0: // Camera
            [self imagePickerForCamera];
            break;
        case 1: // Album
            [self imagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
            
        default:
            break;
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo {
    [self performSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSLog(@"%@",error.localizedDescription);
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self performSelector:@selector(imagePickerDismissController:) withObject:picker afterDelay:1.0f];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    NSLog(@"--->%f %f", image.size.width, image.size.height);
    
    CGFloat imgHeight = kPhotoWidth * image.size.height / image.size.width;
    UIImage *scalingImage = [image reSizeImage:CGSizeMake(kPhotoWidth, imgHeight)];
    NSLog(@"--->%f %f", scalingImage.size.width, scalingImage.size.height);
    
    [NSThread detachNewThreadSelector:@selector(saveToLocal:) toTarget:self withObject:scalingImage];
    //    [self saveToLocal:scalingImage];
    // Update avator image view
    //    [_avatorImgView setImage:scalingImage];
    /*
     if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
     [NSThread detachNewThreadSelector:@selector(saveToPhotoLibrary:) toTarget:self withObject:image];
     }
     */
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self performSelector:@selector(imagePickerDismissController:) withObject:picker afterDelay:1.0f];
}

- (void)imagePickerDismissController:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

- (void)imagePickerForCamera {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self imagePickerWithSourceType:sourceType];
}

- (void)imagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    if (!_avatorImagePickController) {
        UIImagePickerController *imgPickerController = [[UIImagePickerController alloc] init];
        imgPickerController.delegate = self;
        imgPickerController.allowsEditing = YES;
        self.avatorImagePickController = imgPickerController;
    }
    
    _avatorImagePickController.sourceType = sourceType;
    [self presentViewController:_avatorImagePickController animated:YES completion:nil];
}

- (void)saveToLocal:(UIImage *)image {
    NSString *imgPath = [HTFileManager setArchiveFilePath:kTempAvatorImgName];
    imgPath  = [imgPath stringByAppendingPathComponent:@"15729215172"];
    // Write to file.
    //    [UIImagePNGRepresentation(image) writeToFile:imgPath atomically:YES];
    BOOL isSuccess =  [UIImageJPEGRepresentation(image, 0.8) writeToFile:imgPath atomically:YES];
    NSLog(@"用户存储图像信息成功---%d",isSuccess);
    if (isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *imgPath = [HTFileManager getArchiveFilePath:kTempAvatorImgName];
            imgPath = [imgPath stringByAppendingPathComponent:@"15729215172"];
            self.avatorImgView.image =  [UIImage imageWithContentsOfFile:imgPath];
        });
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
