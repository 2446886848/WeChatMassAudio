#import <UIKit/UIKit.h>

@interface MassSendWrap : NSObject
@property(nonatomic) unsigned int m_uiMessageType; //34
@property(retain, nonatomic) NSArray *m_arrayToList; //[MMMassSendWriteMessageViewController getAllUsrName]
@property(retain, nonatomic) NSData *m_dtVoice;
@property(nonatomic) unsigned int m_uiVoiceTime;    //[AudioUtil calcVoiceTime:data.length VoiceFormat:4]
@property(nonatomic) unsigned int m_uiVoiceTmpID;   //[MMMassSendWriteMessageViewController valueForKey:@"_uiTmpRecordID"]
@property(nonatomic) unsigned int m_voiceFormat;    //4
@end

@interface MMMassSendWriteMessageViewController : UIViewController

- (NSArray *)getAllUsrName;
- (void)MassSend:(id)arg1;

- (void)oneKeySend;
- (void)noticeOneKeySend;

@end

@interface AudioUtil : NSObject

+ (unsigned int)calcVoiceTime:(unsigned int)arg1 VoiceFormat:(unsigned int)arg2;

@end

NSString *autoSendAudPath = @"/private/var/mobile/Library/";
static NSString *autoSendAudName = @"WeChat.aud";

%hook MMMassSendWriteMessageViewController

%new
- (void)oneKeySend
{
    //默认使用沙盒下Library/WeChat.aud 避免权限问题
    autoSendAudPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:autoSendAudPath]) {
        [fileManager createDirectoryAtPath:autoSendAudPath withIntermediateDirectories:YES attributes:nil error:NULL];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"%@目录不存在", autoSendAudPath] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    NSString *filePath = [autoSendAudPath stringByAppendingPathComponent:autoSendAudName];
    NSData *audioData = [NSData dataWithContentsOfFile:filePath];
    
    if (audioData.length == 0)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"%@文件不存在，或者文件访问权限没有被改成777", filePath] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    MassSendWrap *audioWrap = [[%c(MassSendWrap) alloc] init];
    audioWrap.m_uiMessageType = 34;
    audioWrap.m_arrayToList = [self getAllUsrName];
    audioWrap.m_dtVoice = audioData;
    audioWrap.m_uiVoiceTime = audioData.length / 2;//[%c(AudioUtil) calcVoiceTime:audioData.length VoiceFormat:4];
    audioWrap.m_uiVoiceTmpID = [[self valueForKey:@"_uiTmpRecordID"] unsignedIntValue];
    audioWrap.m_voiceFormat = 4;
    [self MassSend:audioWrap];
}

%new
- (void)noticeOneKeySend
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"是否一键发送" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"发送" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self oneKeySend];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)viewDidLoad
{
    %orig;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"一键发送" style:UIBarButtonItemStylePlain target:self action:@selector(noticeOneKeySend)];
}

%end
