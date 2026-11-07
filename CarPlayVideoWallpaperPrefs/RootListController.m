#import "RootListController.h"
#import <Preferences/PSSpecifier.h>
#import <AVKit/AVKit.h>
#import <spawn.h>

#define PREFS_DOMAIN @"com.you.carplayvideowallpaper"

@implementation RootListController

- (NSArray *)specifiers {
    if (!_specifiers)
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSUserDefaults *d = [[NSUserDefaults alloc] initWithSuiteName:PREFS_DOMAIN];
    id v = [d objectForKey:[specifier propertyForKey:@"key"]];
    return v ?: [specifier propertyForKey:@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSUserDefaults *d = [[NSUserDefaults alloc] initWithSuiteName:PREFS_DOMAIN];
    [d setObject:value forKey:[specifier propertyForKey:@"key"]];
    [d synchronize];
}

- (void)respring:(id)sender {
    pid_t pid;
    const char *args[] = { "killall", "-9", "SpringBoard", NULL };
    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char *const *)args, NULL);
}

- (void)previewVideo:(id)sender {
    NSUserDefaults *d = [[NSUserDefaults alloc] initWithSuiteName:PREFS_DOMAIN];
    NSString *path = [d stringForKey:@"VideoPath"];
    if (path.length == 0) path = @"/var/mobile/Media/CarPlayWallpaper.mp4";

    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        UIAlertController *a = [UIAlertController
            alertControllerWithTitle:@"Không tìm thấy video"
            message:[NSString stringWithFormat:@"Không có file:\n%@", path]
            preferredStyle:UIAlertControllerStyleAlert];
        [a addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:a animated:YES completion:nil];
        return;
    }

    AVPlayerViewController *vc = [[AVPlayerViewController alloc] init];
    vc.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:path]];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:^{ [vc.player play]; }];
}

@end
