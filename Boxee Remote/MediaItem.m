//
//  MediaItem.m
//  Boxee Remote
//
//  Created by Kevin Vinck on 26/03/2011.
//  Copyright 2011 None. All rights reserved.
//

#import "MediaItem.h"
#import "BoxeeHTTPInterface.h"


@implementation MediaItem

@synthesize strTitle,strPath,strShowName,strDescription,iSeason,iEpisode,strDirector,strCover;

-(MediaItem*)initWithName:(NSString*)name path:(NSString*)path mediaType:(MediaType)mediaType
{
    self = [super init];
    //b_Name = [name retain];
    //b_Path = [path retain];
    b_MediaType = mediaType;
    return self;
}

-(MediaType)getType
{
    return b_MediaType;
}

/*-(UIImage*)getIcon
{
    switch(b_MediaType)
    {
        case kMusic:
            return [[IconManager sharedInstance] getMusicItemIcon];
        case kPicture:
            return [[IconManager sharedInstance] getPictureItemIcon];
        case kVideo:
            return [[IconManager sharedInstance] getVideoItemIcon];
        case kFolder:
            return [[IconManager sharedInstance] getFolderIcon];
        case kPlaylist:
            return [[IconManager sharedInstance] getPlaylistIcon];
        default:
            return nil;
    }
}*/

-(void)dealloc
{
    [strTitle release];
    [strPath release];
    [super dealloc];
}
@end

@implementation MediaItemFactory

-(id)initWithExtensions:(NSArray*)musicExtensions pictureExtensions:(NSArray*)pictureExtensions videoExtensions:(NSArray*)videoExtensions
{
    //NSLog(@"MediaItemFactory initWithExtensions");
    self = [super init];
    
    m_musicExtensions = [musicExtensions retain];
    m_pictureExtensions = [pictureExtensions retain];;
    m_videoExtensions = [videoExtensions retain];
    return self;
}

-(MediaItem*)createMediaItem:(NSString*)name path:(NSString*)path isFolder:(BOOL)isFolder
{
    MediaType type;
    NSString* extension = [self getFileExtension: path];
    if (isFolder)
    {
        if ([extension caseInsensitiveCompare: @".m3u"] == NSOrderedSame)
        {
            type = kPlaylist;
        }
        else
        {
            type = kFolder;
        }
    }
    else
    {
        //determine type from extension
        
        if ([self isInArray: extension array:m_musicExtensions])
        {
            type = kMusic;
        }
        else if ([self isInArray: extension array:m_pictureExtensions])
        {
            type = kPicture;
        }
        else if ([self isInArray: extension array:m_videoExtensions])
        {
            type = kVideo;
        }
        
        else
        {
            type = kUnknown;
        }
        
    }
    //return [[[MediaItem alloc] initWithNameAndPath: name path:path  mediaType:type] autorelease];
    return nil;
}

-(NSString*)getFileExtension:(NSString*)path
{
    // search for last "."
    NSRange range = [path rangeOfString:@"." options:NSBackwardsSearch];
    if (range.location == NSNotFound)
    {
        return @"";
    }
    NSString *extension = [path substringFromIndex:range.location];
    return extension;
}

-(BOOL)isInArray:(NSString*) value array:(NSArray*)array
{
    int i=0;
    for(i=0; i<[array count]; ++i)
    {
        NSString* arrayItem = [array objectAtIndex:i];
        if ([value caseInsensitiveCompare: arrayItem] == NSOrderedSame)
        {
            return YES;
        }
    }
    return NO;
}



- (void)dealloc
{
    [m_musicExtensions release];
    [m_pictureExtensions release];
    [m_videoExtensions release];
    [super dealloc];
}

@end
