#import <Cordova/CDVPlugin.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>

@interface MNowPlaying : CDVPlugin {
}

- (void)setNowPlaying:(CDVInvokedUrlCommand*)command;

@end
