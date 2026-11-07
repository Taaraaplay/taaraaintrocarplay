#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define PREFS_DOMAIN @"com.you.carplayvideowallpaper"
#define DEFAULT_VIDEO_PATH @"/var/mobile/Media/CarPlayWallpaper.mp4"

static AVPlayer *videoPlayer = nil;
static AVPlayerLayer *playerLayer = nil;
static UIWindow *carPlayWindow = nil;

static NSUserDefaults *prefs(void) {
    return [[NSUserDefaults alloc] initWithSuiteName:PREFS_DOMAIN];
}
static NSString *currentVideoPath(void) {
    NSString *p = [prefs() stringForKey:@"VideoPath"];
    return (p.length > 0) ? p : DEFAULT_VIDEO_PATH;
}
static BOOL isEnabled(void) {
    id v = [prefs() objectForKey:@"Enabled"];
    return v ? [prefs() boolForKey:@"Enabled"] : YES;
}

static BOOL isCarPlayScreen(UIScreen *screen) {
    if (!screen || screen == [UIScreen mainScreen]) return NO;
    CGSize s = screen.bounds.size;
    CGFloat w = MAX(s.width, s.height), h = MIN(s.width, s.height);
    return ((w == 800 && h == 480) || (w == 1280 && h == 720) ||
            (w == 1920 && h == 720) || (w == 960 && h == 540));
}

static void stopVideo(void) {
    [videoPlayer pause];
    videoPlayer = nil;
    [playerLayer removeFromSuperlayer];
    playerLayer = nil;
    carPlayWindow.hidden = YES;
    carPlayWindow = nil;
}

static void playVideoOnScreen(UIScreen *screen) {
    stopVideo();
    if (!isEnabled()) return;

    NSString *path = currentVideoPath();
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSLog(@"[CPVW] Không tìm thấy video tại: %@", path);
        return;
    }

    carPlayWindow = [[UIWindow alloc] initWithFrame:screen.bounds];
    carPlayWindow.screen = screen;
    carPlayWindow.windowLevel = UIWindowLevelNormal + 1;
    carPlayWindow.backgroundColor = [UIColor blackColor];
    carPlayWindow.hidden = NO;

    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:path]];
    videoPlayer = [AVPlayer playerWithPlayerItem:item];
    videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;

    playerLayer = [AVPlayerLayer playerLayerWithPlayer:videoPlayer];
    playerLayer.frame = carPlayWindow.bounds;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [carPlayWindow.layer addSublayer:playerLayer];

    [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
        object:item queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n) {
            [videoPlayer seekToTime:kCMTimeZero];
            [videoPlayer play];
        }];

    [videoPlayer play];
    NSLog(@"[CPVW] Phát video: %@", path);
}

%ctor {
    NSLog(@"[CPVW] Tweak loaded");
    [[NSNotificationCenter defaultCenter] addObserverForName:UIScreenDidConnectNotification
        object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n) {
            if (isCarPlayScreen(n.object)) playVideoOnScreen(n.object);
        }];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIScreenDidDisconnectNotification
        object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n) {
            if (isCarPlayScreen(n.object)) stopVideo();
        }];
}
