//
//  MediaItem.h
//  Boxee Remote
//
//  Created by Kevin Vinck on 26/03/2011.
//  Copyright 2011 None. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kFolder,
    kMusic,
    kVideo,
    kPicture,
    kPlaylist,
    kUnknown
} MediaType;


@interface MediaItem : NSObject {
    NSString *strTitle;
    NSString *strShowName;
    NSString *strDescription;
    NSNumber *iSeason;
    NSNumber *iEpisode;
    NSString *strPath;
    NSString *strDirector;
    NSString *strCover;
    MediaType b_MediaType;
}

-(MediaItem*)initWithName: (NSString*)name path:(NSString*)path mediaType:(MediaType)mediaType;
-(MediaType)getType;
//-(UIImage*)getIcon;
-(void)dealloc;

@property (nonatomic, retain) NSString *strTitle;
@property (nonatomic, retain) NSString *strPath;
@property (nonatomic, retain) NSString *strShowName;
@property (nonatomic, retain) NSString *strDescription;
@property (nonatomic, retain) NSString *strCover;
@property (nonatomic, retain) NSNumber *iSeason;
@property (nonatomic, retain) NSNumber *iEpisode;
@property (nonatomic, retain) NSString *strDirector;

@end

@interface MediaItemFactory : NSObject
{
    NSArray* m_musicExtensions;
    NSArray* m_pictureExtensions;
    NSArray* m_videoExtensions;
}

-(id)initWithExtensions:(NSArray*)musicExtensions pictureExtensions:(NSArray*)pictureExtensions videoExtensions:(NSArray*)videoExtensions;
-(MediaItem*)createMediaItem:(NSString*)name path:(NSString*)path isFolder:(BOOL)isFolder;
-(BOOL)isInArray:(NSString*) value array:(NSArray*)array;
-(NSString*)getFileExtension:(NSString*)path;
-(void)dealloc;

@end

