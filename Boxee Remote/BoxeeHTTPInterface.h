//
//  BoxeeHTTPInterface.h
//  Boxee Remote
//
//  Created by Kevin Vinck on 25/03/2011.
//  Copyright 2011 None. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaItem.h"
#import "AsyncUdpSocket.h"
#import "NSString+MD5.h"
#import "NSData+Base64.h"
#import "BoxeeServer.h"
#import "BoxeeServerParser.h"


@interface BoxeeHTTPInterface : NSObject <AsyncUdpSocketDelegate> {
    NSArray* m_MusicExtensionList;
    NSArray* m_VideosExtensionList;
    NSArray* m_PicturesExtensionList;
    NSMutableArray *boxeeServerList;
    MediaItemFactory* m_MediaItemFactory;
    NSString *serverIP;
    NSString *serverPort;
	NSString *serverPassword;
    BOOL isBoxeeBox;
    AsyncUdpSocket *pingSocket;
    AsyncUdpSocket *pingrecvSocket;
    AsyncUdpSocket *socket;
    AsyncUdpSocket *recvSocket;
    BOOL isConnected;

}

extern NSString * const DoneFindingServersNotification;
extern NSString * const FoundServerNotification;
extern NSString * const ConnectionLostNotification;
extern NSString * const PingTimedOutNotification;
extern NSString * const PingReceivedNotification;

+ (BoxeeHTTPInterface *) sharedInstance;

@property (nonatomic, retain) NSMutableArray *boxeeServerList;
@property (nonatomic, retain) NSString *serverIP;
@property (nonatomic, retain) NSString *serverPort;
@property (nonatomic, retain) NSString *serverPassword;
@property (nonatomic) BOOL isBoxeeBox;
@property (nonatomic) BOOL isConnected;

-(id)init;
- (void) showAlert:(NSString *)text;
-(void)discoverBoxeeServers;
-(void)lostServerConnection;
-(BoxeeServer *)initServerWithIP:(NSString *)ip port:(NSString *)port name:(NSString *)name httpAuthRequired:(BOOL)httpAuthRequired;
-(void)addServer:(BoxeeServer *)server toList:(NSMutableArray *)array;
-(NSArray*)getMusicExtensions;
-(NSArray*)getPictureExtensions;
-(NSArray*)getVideoExtensions;
-(NSArray*)getExtensions: (NSArray*)type;

// XBMC commands
-(void)sendKey:(int)buttonCode;
-(void)mute;
-(void)playFile:(NSString *)file inPlaylist:(NSString *)playlist;
-(void)addToPlaylist:(NSString *)file;
-(void)playNext;
-(void)playPrev;
-(void)pause;
-(void)zoom:(int)zoomLevel;
-(void)setVolume:(int)volume;
-(void)setSeekPosition:(int)pos;
-(int)getVolume;
-(NSData *)getFile:(NSString *)file;
-(BOOL) ping;
-(NSMutableDictionary *)getCurrentlyPlayingInfo;
-(NSArray *)getShares;
-(NSArray *)getSharesOfType:(NSString *)type;
-(NSArray *)getDirectory:(NSString *)dir;
-(void)activateWindow:(int)win;
-(void)action:(int)action;

//Database commands
-(BOOL)isDatabaseEnabled;
-(void)setupRemoteDatabaseMac;
-(void)setupRemoteDatabaseWin;
-(NSArray *)queryDatabase:(NSString *)query;
-(NSArray *)getTVShows;
-(NSArray *)getEpisodesForTVShow:(NSString *)show;
-(NSArray *)getMovies;
-(NSArray *)getInfoForMovie:(NSString *)movie;
-(NSArray *)getAlbums;
-(NSArray *)getSongsForAlbum:(NSString *)idAlbum;
-(NSArray *)getArtists;
-(NSArray *)getSongsForArtist:(NSString *)idArtist;
-(NSString *)getArtistWithID:(NSNumber *)aid;
-(NSString *)getAlbumWithID:(NSNumber *)aid;
-(NSDictionary *)getInfoForFile:(NSString *)filePath;
-(NSString *)getDirectorForVideo:(NSNumber *)vid;
-(NSString *)getArtworkForAlbum:(NSNumber *)aid;


// private
-(void)setServerIP:(NSString *)ip;
-(BOOL)isPasswordProtected;
-(NSString*)XboxIPAddress;
//-(BOOL)isNumeric:(NSString*)str;
//-(int)getLines: (NSString*) text lines: (NSMutableArray*)theLines;
-(NSURL*) getURLForCommand:(NSString *)cmd;
-(NSURL*) getURLForCommand:(NSString *)cmd parameters:(NSArray *) params;
-(NSString*) getPage: (NSURL*) urlString timeout: (double) timeoutVal;
-(int)getLines: (NSString*) text lines: (NSMutableArray*)theLines;
-(NSArray*)getFields: (NSString*) text withQuery: (NSString*)query;

@end

