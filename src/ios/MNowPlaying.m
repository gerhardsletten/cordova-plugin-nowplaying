#import "MNowPlaying.h"

@implementation MNowPlaying

- (void)pluginInitialize
{
    NSLog(@"NowPlaying plugin init.");
}

/**
 * Will set now playing info based on what keys are sent into method
 */
- (void)setNowPlaying:(CDVInvokedUrlCommand*)command
{
    MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];

    // If now arguments are passed clear out nowPlaying and return
    if ([command.arguments count] == 0) {
        center.nowPlayingInfo = nil;
        return;
    }

    // Parse json data and check that data is available
    NSString *jsonStr = [command.arguments objectAtIndex:0];
    NSDictionary *jsonObject;
    if (jsonStr != nil || ![jsonStr  isEqual: @""]) {
        NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    }

    // If the json object could not be parsed we exit early
    if (jsonObject == nil) {
        NSLog(@"Could not parse now playing json object");
        return;
    }

    // Create media dictionary from existing keys or create a new one, this way we can update single attributes if we want to
    NSMutableDictionary *mediaDict = (center.nowPlayingInfo != nil) ? [[NSMutableDictionary alloc] initWithDictionary: center.nowPlayingInfo] : [NSMutableDictionary dictionary];

    if ([jsonObject objectForKey: @"albumTitle"] != nil) {
        [mediaDict setValue:[jsonObject objectForKey: @"albumTitle"] forKey:MPMediaItemPropertyAlbumTitle];
    }

    if ([jsonObject objectForKey: @"trackCount"] != nil) {
        [mediaDict setValue:[jsonObject objectForKey: @"trackCount"] forKey:MPMediaItemPropertyAlbumTrackCount];
    }

    if ([jsonObject objectForKey: @"trackNumber"] != nil) {
        [mediaDict setValue:[jsonObject objectForKey: @"trackNumber"] forKey:MPMediaItemPropertyAlbumTrackNumber];
    }

    if ([jsonObject objectForKey: @"artist"] != nil) {
        [mediaDict setValue:[jsonObject objectForKey: @"artist"] forKey:MPMediaItemPropertyArtist];
    }

    if ([jsonObject objectForKey: @"composer"] != nil) {
        [mediaDict setValue:[jsonObject objectForKey: @"composer"] forKey:MPMediaItemPropertyComposer];
    }

    if ([jsonObject objectForKey: @"discCount"] != nil) {
        [mediaDict setValue:[jsonObject objectForKey: @"discCount"] forKey:MPMediaItemPropertyDiscCount];
    }

    if ([jsonObject objectForKey: @"discNumber"] != nil) {
        [mediaDict setValue:[jsonObject objectForKey: @"discNumber"] forKey:MPMediaItemPropertyDiscNumber];
    }

    if ([jsonObject objectForKey: @"genre"] != nil) {
        [mediaDict setValue:[jsonObject objectForKey: @"genre"] forKey:MPMediaItemPropertyGenre];
    }

    if ([jsonObject objectForKey: @"persistentID"] != nil) {
        [mediaDict setValue:[jsonObject objectForKey: @"persistentID"] forKey:MPMediaItemPropertyPersistentID];
    }

    if ([jsonObject objectForKey: @"playbackDuration"] != nil) {
        [mediaDict setValue:[jsonObject objectForKey: @"playbackDuration"] forKey:MPMediaItemPropertyPlaybackDuration];
    }

    if ([jsonObject objectForKey: @"title"] != nil) {
        [mediaDict setValue:[jsonObject objectForKey: @"title"] forKey:MPMediaItemPropertyTitle];
    }

    if ([jsonObject objectForKey: @"elapsedPlaybackTime"] != nil) {
        [mediaDict setValue:[jsonObject objectForKey: @"elapsedPlaybackTime"] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    }

    if ([jsonObject objectForKey: @"playbackRate"] != nil) {
        [mediaDict setValue:[jsonObject objectForKey: @"playbackRate"] forKey:MPNowPlayingInfoPropertyPlaybackRate];
    } else {
        // In iOS Simulator, always include the MPNowPlayingInfoPropertyPlaybackRate key in your nowPlayingInfo dictionary
        [mediaDict setValue:[NSNumber numberWithDouble:1] forKey:MPNowPlayingInfoPropertyPlaybackRate];
    }

    if ([jsonObject objectForKey: @"playbackQueueIndex"] != nil) {
        [mediaDict setValue:[jsonObject objectForKey: @"playbackQueueIndex"] forKey:MPNowPlayingInfoPropertyPlaybackQueueIndex];
    }

    if ([jsonObject objectForKey: @"playbackQueueCount"] != nil) {
        [mediaDict setValue:[jsonObject objectForKey: @"playbackQueueCount"] forKey:MPNowPlayingInfoPropertyPlaybackQueueCount];
    }

    if ([jsonObject objectForKey: @"chapterNumber"] != nil) {
        [mediaDict setValue:[jsonObject objectForKey: @"chapterNumber"] forKey:MPNowPlayingInfoPropertyChapterNumber];
    }

    if ([jsonObject objectForKey: @"chapterCount"] != nil) {
        [mediaDict setValue:[jsonObject objectForKey: @"chapterCount"] forKey:MPNowPlayingInfoPropertyChapterCount];
    }

    if ([jsonObject objectForKey: @"artwork"] != nil) {
        NSString *path = [jsonObject objectForKey: @"artwork"];
        UIImage *image = nil;
        // check whether artwork path is present
        if (![path isEqual: @""]) {
            NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *fullPath = [NSString stringWithFormat:@"%@%@", basePath, path];
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fullPath];
            if (fileExists) {
                image = [UIImage imageNamed:fullPath];
            }
        }
        // Check if image was available otherwise don't do anything
        if (image != nil) {
            MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:image.size requestHandler:^UIImage * _Nonnull(CGSize size) {
                UIGraphicsBeginImageContext(size);
                [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
                UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                return destImage;
            }];
            [mediaDict setValue:artwork forKey:MPMediaItemPropertyArtwork];
        }
    }
    center.nowPlayingInfo = mediaDict;
}

@end
