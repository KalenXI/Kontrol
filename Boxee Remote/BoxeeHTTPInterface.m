//
//  BoxeeHTTPInterface.m
//  Boxee Remote
//
//  Created by Kevin Vinck on 25/03/2011.
//  Copyright 2011 None. All rights reserved.
//

#import "BoxeeHTTPInterface.h"
#import <dispatch/dispatch.h>

static BoxeeHTTPInterface *sharedInstance = nil;
NSString * const DoneFindingServersNotification = @"DoneFindingServers";
NSString * const PingTimedOutNotification = @"PingTimedOut";
NSString * const PingReceivedNotification = @"PingReceived";
NSString * const FoundServerNotification = @"FoundServer";
NSString * const ConnectionLostNotification = @"LostConnection";

@implementation BoxeeHTTPInterface
@synthesize boxeeServerList,serverIP,serverPort,serverPassword,isConnected,useJSON;

dispatch_queue_t myQueue;

+ (BoxeeHTTPInterface *) sharedInstance {
    return ( sharedInstance ? sharedInstance : ( sharedInstance = [[self alloc] init] ) );
}

-(id)init{
    self = [super init];
    m_MediaItemFactory = nil;
    m_MusicExtensionList = nil;
    m_PicturesExtensionList = nil;
    m_VideosExtensionList = nil;
    isConnected = NO;
    myQueue = dispatch_queue_create("com.lastdit.kontrol", NULL);
    return self;    
	
}

- (void) showAlert:(NSString *)text {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:text delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

-(BOOL) ping {
	//NSLog(@"pinging server");
    NSString *response;
    response = [self getPage: [self getURLForCommand:@"GetCurrentlyPlaying"] timeout: 3.0];
	//NSLog(@"Ping response: %@",response);
    if (([response isEqualToString:@""]) || (response == nil)) {
		//NSLog(@"ping failed");
        return NO;
    } else {
		//NSLog(@"Ping sucessful.");
        return YES;
    }
    /*pingSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
	 pingrecvSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
	 [pingSocket setDelegate:self];
	 [pingSocket enableBroadcast:YES error:nil];
	 [pingSocket bindToPort:38400 error:nil];
	 [pingSocket connectToHost:serverIP onPort:2562 error:nil];
	 [pingrecvSocket enableBroadcast:YES error:nil];
	 [pingrecvSocket bindToPort:38400 error:nil];
	 [pingrecvSocket receiveWithTimeout:1 tag:1];
	 NSString *signature = @"BoxMoteb0xeeRem0tE!";
	 NSString *xml = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><BDP1 cmd=\"discover\" application=\"iphone_remote\" version=\"1.0\" challenge=\"BoxMote\" signature=\"%@\"/>",[signature MD5]];
	 NSData *data = [NSData dataWithData:[xml dataUsingEncoding:NSUTF8StringEncoding]];
	 [pingSocket sendData:data withTimeout:1 tag:1];
	 [pingSocket closeAfterSending];
	 [pingrecvSocket closeAfterReceiving];
	 //[pingrecvSocket release];*/
    //return YES;
}

-(void)discoverBoxeeServers {
    socket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    recvSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    [socket setDelegate:self];
    [socket enableBroadcast:YES error:nil];
    [socket bindToPort:38648 error:nil];
    [socket connectToHost:@"255.255.255.255" onPort:2562 error:nil];
    //[socket receiveWithTimeout:30 tag:0];
    [recvSocket enableBroadcast:YES error:nil];
    [recvSocket bindToPort:38648 error:nil];
    [recvSocket receiveWithTimeout:3 tag:0];
    NSString *signature = @"BoxMoteb0xeeRem0tE!";
    NSString *xml = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><BDP1 cmd=\"discover\" application=\"iphone_remote\" version=\"1.0\" challenge=\"BoxMote\" signature=\"%@\"/>",[signature MD5]];
	//NSLog(@"Sending string: %@",xml);
    NSData *data = [NSData dataWithData:[xml dataUsingEncoding:NSUTF8StringEncoding]];
    [socket sendData:data withTimeout:5 tag:0];
    [socket closeAfterSending];
    [recvSocket closeAfterReceiving];
    //NSLog(@"Releasing recvsocket");
    //[recvSocket release];
}

-(BOOL)isBoxeeBox {
    if ([[self getPage: [self getURLForCommand:@"getshares"] timeout: 5] isEqualToString:@"Error:Unknown command"]) {
        return YES;
    } else {
        return NO;
    }
}

-(void)lostServerConnection {
    isConnected = NO;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:ConnectionLostNotification object:self];
}

-(void)addServer:(BoxeeServer *)server toList:(NSMutableArray *)array {
    [array addObject:server];
}

-(BoxeeServer *)initServerWithIP:(NSString *)ip port:(NSString *)port name:(NSString *)name httpAuthRequired:(BOOL)httpAuthRequired {
    BoxeeServer *server = [[BoxeeServer alloc] init];
    server.hostIP = ip;
    server.hostPort = port;
    server.hostName = name;
    server.httpAuthRequired = httpAuthRequired;
    return server;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    //NSLog(@"Sent data with tag: %ld",tag);
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    //NSLog(@"Didn't send the data :(");
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port {
    
    //NSLog(@"Data received with tag: %ld on port %i",tag,port);
	//NSLog(@"Received data: %@",[NSString stringWithUTF8String:[data bytes]]);
    
    if (sock == recvSocket) {
        //NSLog(@"Server request received.");
        BoxeeServerParser *parser = [[BoxeeServerParser alloc] init];
        
        if ([parser parseData:data]) {
            if (boxeeServerList == nil) {
                boxeeServerList = [[NSMutableArray alloc] init];
            }
            BoxeeServer *newServer = [self initServerWithIP:host port:parser.httpPort name:parser.name httpAuthRequired:parser.httpAuthRequired];
            [boxeeServerList addObject:newServer];
            //NSLog(@"Added new server at %@",newServer.hostIP);
            //NSLog(@"Server array: %@",boxeeServerList);
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:FoundServerNotification object:self];
        }
        //NSLog(@"Releasing parser");
        
        [parser release];
    } else if (sock == pingrecvSocket) {
        //NSLog(@"Ping response received.");
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:PingReceivedNotification object:self];
        return YES;
    }
    return NO;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error {
    //NSLog(@"Recieve timed out.");
    if (sock == recvSocket) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:DoneFindingServersNotification object:self];
    } else if (sock == pingrecvSocket) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:PingTimedOutNotification object:self];
        //NSLog(@"Ping response timed out.");
    }
}

- (void)onUdpSocketDidClose:(AsyncUdpSocket *)sock {
    //NSLog(@"Socket released");
}

-(MediaItemFactory*)getMediaItemFactory
{
    if (m_MediaItemFactory == nil)
    {
        m_MediaItemFactory = [[MediaItemFactory alloc] initWithExtensions: [self getMusicExtensions] pictureExtensions:[self getPictureExtensions] videoExtensions:[self getVideoExtensions]];
    }
    return m_MediaItemFactory;
}


-(void)sendKey:(int)buttonCode {
    //NSLog(@"Sending key %i",buttonCode);
    NSURL *sendURL = [self getURLForCommand:@"SendKey" parameters:[NSArray arrayWithObject:[NSString stringWithFormat:@"%i", buttonCode]]];
    [self getPage:sendURL timeout:3.0];
}

-(void)mute {
    NSURL *sendURL = [self getURLForCommand:@"Mute"];
    [self getPage:sendURL timeout:3.0];
}

-(void)playFile:(NSString *)file inPlaylist:(NSString *)playlist {
    NSURL *sendURL;
    if (playlist != nil) {
        sendURL = [self getURLForCommand:@"PlayFile" parameters:[NSArray arrayWithObjects:file, playlist, nil]];
    } else {
        sendURL = [self getURLForCommand:@"PlayFile" parameters:[NSArray arrayWithObject:file]];
        //NSLog(@"File: %@",file);
    }
    [self getPage:sendURL timeout:30];
}

-(void)addToPlaylist:(NSString *)file {
    NSURL *sendURL;
    sendURL = [self getURLForCommand:@"AddToPlaylist" parameters:[NSArray arrayWithObject:file]];
    [self getPage:sendURL timeout:3.0];
}

-(void)playNext {
    //NSLog(@"Sending playNext command.");
    NSURL *sendURL = [self getURLForCommand:@"PlayNext"];
    [self getPage:sendURL timeout:3.0];
}

-(void)playPrev {
    //NSLog(@"Sending playPrev command.");
    NSURL *sendURL = [self getURLForCommand:@"PlayPrev"];
    [self getPage:sendURL timeout:3.0];
}

-(void)pause {
    //NSLog(@"Sending pause command.");
    NSURL *sendURL = [self getURLForCommand:@"Pause"];
    [self getPage:sendURL timeout:3.0];
}

-(void)zoom:(int)zoomLevel {
    
}

-(void)setVolume:(int)volume {
    //NSLog(@"Setting volume to %i",volume);
    NSURL *sendURL = [self getURLForCommand:@"SetVolume" parameters:[NSArray arrayWithObject:[NSString stringWithFormat:@"%i",volume]]];
    [self getPage:sendURL timeout:3.0];
}

-(void)setSeekPosition:(int)pos {
    //NSLog(@"Setting position to %i",pos);
    NSURL *sendURL = [self getURLForCommand:@"SeekPercentage" parameters:[NSArray arrayWithObject:[NSString stringWithFormat:@"%i",pos]]];
    [self getPage:sendURL timeout:3.0];
}

-(int)getVolume {
    //NSLog(@"getVolume");
    NSURL *sendURL = [self getURLForCommand:@"GetVolume"];
    NSMutableArray *returnLines = [[NSMutableArray alloc] initWithCapacity:1];
    [self getLines:[self getPage:sendURL timeout:1.0] lines:returnLines];
    int volume;
    if ([returnLines count] > 0) {
        volume = [[returnLines objectAtIndex:0] intValue];
    } else {
        volume = 0;
    }
    //NSLog(@"Volume is %i",volume);
    //NSLog(@"Returning volume.");
    return volume;
}

-(NSData *)getFile:(NSString *)file {
    //NSLog(@"Getting file: %@",file);
    //NSURL *sendURL = [self getURLForCommand:@"FileDownload" parameters:[NSArray arrayWithObjects:file,@"base",nil]];
    NSURL *sendURL = [self getURLForCommand:@"FileDownload" parameters:[NSArray arrayWithObject:[NSString stringWithFormat:@"%@;bare",file]]];
    NSString *fileDataString = [self getPage:sendURL timeout:5.0];
    NSData *fileData = [NSData dataFromBase64String:fileDataString];
    return fileData;
}

-(NSArray*)getMusicExtensions
{
    if (m_MusicExtensionList == nil)
    {
        m_MusicExtensionList = [[self getExtensions:[NSArray arrayWithObject:@"music"]] retain];
    }
    return m_MusicExtensionList;
    
}

-(NSArray*)getVideoExtensions
{
    if (m_VideosExtensionList == nil)
    {
        m_VideosExtensionList = [[self getExtensions:[NSArray arrayWithObject:@"video"]] retain];
    }
    return m_VideosExtensionList;
}

-(NSArray*)getPictureExtensions
{
    if (m_PicturesExtensionList == nil)
    {
        m_PicturesExtensionList = [[self getExtensions:[NSArray arrayWithObject:@"picture"]] retain];
    }
    return m_PicturesExtensionList;
}

-(NSArray*)getExtensions: (NSArray*)type
{
    //NSLog(@"getExtensions: %@", type);
    // type = "music" | "video" | "Picture"
    int i,j;
    NSMutableArray *theLines = [[NSMutableArray alloc] initWithCapacity:10];
    //NSLog(@"getExtensions: 1");
    NSString* extCmd = [NSString stringWithFormat:@"%@extensions", type];
    //NSLog(@"getExtensions: 2  %@", extCmd);
    //NSArray *paramArray = [NSArray arrayWithObjects: @"getoption", extCmd];
    NSMutableArray *paramArray = [[NSMutableArray alloc] initWithCapacity:2];
    [paramArray addObject: @"getoption"];
    [paramArray addObject: extCmd];
    //NSLog(@"getExtensions: 3");
    [self getLines: [self getPage: [self getURLForCommand:@"config" parameters: paramArray] timeout: 5] lines: theLines];
    //NSLog(@"Releasing paramarray");
    [paramArray release];
    //NSLog(@"getExtensions: 4");
    NSMutableArray *tempExtList = [[NSMutableArray alloc] initWithCapacity:10];
    //NSLog(@"getExtensions: 5");
    for (i=0; i<[theLines count]; ++i)
    {
        NSArray *splitExtList = [[theLines objectAtIndex:i] componentsSeparatedByString:@"|"];
        for(j=0; j<[splitExtList count]; ++j)
        {
            [tempExtList addObject: [splitExtList objectAtIndex: j]];
        }
    }
    NSArray* returnArray = [NSArray arrayWithArray:tempExtList];
    //NSLog(@"Releasing tempextlist");
    [tempExtList release];
    //NSLog(@"getExtensions: done");
    return returnArray;
}


-(NSArray *)getShares {
    //NSLog(@"getShares");
    int i;
    NSMutableArray *theLines = [[NSMutableArray alloc] init];
    if ([self getLines: [self getPage: [self getURLForCommand:@"getshares"] timeout: 5] lines: theLines]) {
        //NSLog(@"Lines: %@",theLines);
        NSMutableArray *mediaItems = [[NSMutableArray alloc] init];
        for (i=0; i<[theLines count]; ++i)
        {
            NSArray* items = [[theLines objectAtIndex:i] componentsSeparatedByString:@";"];
            //Format: type;name;location
            [mediaItems addObject:items];
        }
        NSArray *returnArray = [NSArray arrayWithArray:mediaItems];
        [theLines release];
        [mediaItems release];
        
        return returnArray;
    } else {
        //[self showAlert:@"getShares: Could not extract lines from response."];
        return nil;
    }
	
}

-(NSArray *)getSharesOfType:(NSString *)type {
    //NSLog(@"getShares");
    int i;
    NSMutableArray *theLines = [[NSMutableArray alloc] initWithCapacity:10];
    if ([self getLines: [self getPage: [self getURLForCommand:@"getshares" parameters:[NSArray arrayWithObject:type]] timeout: 5] lines: theLines]) {
        //[self getLines: [self getPage: [self getURLForCommand:@"getshares" parameters:[NSArray arrayWithObject:type]] timeout: 5] lines: theLines]
        NSMutableArray *mediaItems = [[NSMutableArray alloc] initWithCapacity:10];
        for (i=0; i<[theLines count]; ++i)
        {
            NSArray* items = [[theLines objectAtIndex:i] componentsSeparatedByString:@";"];
            //Format: type;name;location
            [mediaItems addObject:items];
        }
        NSArray *returnArray = [NSArray arrayWithArray:mediaItems];
        //NSLog(@"Releasing thelines");
        [theLines release];
        //NSLog(@"Releasing mediaitems");
        [mediaItems release];
        //NSLog(@"getShares done");
		
        return returnArray;
    } else {
        //[self showAlert:@"getSharesOfType: Could not extract lines from response."];
        return nil;
    }
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

-(NSArray *)getDirectory:(NSString *)dir {
    //NSLog(@"getdirectory");
    int i;
    NSMutableArray *theLines = [[NSMutableArray alloc] initWithCapacity:10];
    if ([self getLines: [self getPage: [self getURLForCommand:@"getdirectory" parameters:[NSArray arrayWithObject:dir]] timeout: 5] lines: theLines]) {
        NSMutableArray *mediaItems = [[NSMutableArray alloc] initWithCapacity:10];
        for (i=0; i<[theLines count]; ++i)
        {
            NSArray *items = [[theLines objectAtIndex:i] componentsSeparatedByString:@"/"];
            if ([items count] == 1) {
                items = [[theLines objectAtIndex:i] componentsSeparatedByString:@"\\"];
            }
            //NSLog(@"Items: %@",items);
            NSMutableArray *mediaItem = [[NSMutableArray alloc] initWithCapacity:2];
            
            NSArray *supportedExt = [NSArray arrayWithObjects:@"avi",@"mpeg",@"wmv",@"asf",
                                     @"flv",@"mkv",@"mov",@"mp4",@"m4a",@"aac",
                                     @"nut",@"ogg",@"ogm",@"rm",@"ram",@"rv",@"ra",
                                     @"rmvb",@"3gp",@"vivo",@"pva",@"nuv",@"nsv",
                                     @"nsa",@"fli",@"flc",@"iso",@"dvr-ms",@"mpg", nil];
			
            if ([[items objectAtIndex:[items count]-1] isEqualToString:@""]) {
                //NSLog(@"This is a folder!");
                [mediaItem addObject:[theLines objectAtIndex:i]];
                [mediaItem addObject:[items objectAtIndex:[items count]-2]];
                [mediaItem addObject:@"tFolder"];
            } else {
                //NSLog(@"This is a file!");
                NSString *ext = [[[items objectAtIndex:[items count]-1] componentsSeparatedByString:@"."] objectAtIndex:1];
                if ([self isInArray:ext array:supportedExt]) {
                    [mediaItem addObject:[theLines objectAtIndex:i]];
                    [mediaItem addObject:[items objectAtIndex:[items count]-1]];
                    [mediaItem addObject:@"tFile"];
                }
            }
			if ([mediaItem count] > 2) {
                [mediaItems addObject:mediaItem];
                //NSLog(@"Added media item.");
            }
            //NSLog(@"Releasing mediaitem");
            [mediaItem release];
        }
        NSArray *returnArray = [NSArray arrayWithArray:mediaItems];
        //NSLog(@"Releasing thelines");
        [theLines release];
        //NSLog(@"Releasing mediaitems");
        [mediaItems release];
        //NSLog(@"getShares done");
		
        return returnArray;
    } else {
        [self showAlert:@"Directory offline."];
        return nil;
    }
}

-(NSMutableDictionary *)getCurrentlyPlayingInfo {
    int i;
    //NSLog(@"getCurrentlyPlayingInfo");
    NSMutableDictionary *itemInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    NSMutableArray *theLines = [[NSMutableArray alloc] initWithCapacity:10];
    //NSMutableArray *paramArray = [[NSMutableArray alloc] initWithCapacity:1];
    //[paramArray addObject:@"q:\\web\\thumb.jpg"];
    if ([self getLines: [self getPage: [self getURLForCommand:@"GetCurrentlyPlaying"] timeout: 1.0] lines: theLines]) {
		//NSLog(@"Releasing paramarray");
		//[paramArray release];
		for (i=0; i<[theLines count]; ++i)
		{
			int p = (int)[[theLines objectAtIndex:i] rangeOfString:@":"].location;
			if (p!=NSNotFound)
            {
                [itemInfo setValue:[[theLines objectAtIndex:i] substringFromIndex:p+1] forKey:[[theLines objectAtIndex:i] substringToIndex:p]];
            }
        }
        //NSLog(@"Releasing thelines");
        [theLines release];
        //NSLog(@"Returning getCurrenlyPlayingInfo");
        return [itemInfo autorelease];
    } else {
        //[self showAlert:@"getCurrentlyPlayingInfo: Unable to read lines from response"];
        return nil;
    }
}

// private
-(NSString*) encodeURL: (NSString*)urlString {
    NSString *encodedURL = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return encodedURL;   
}

-(NSString*)XboxIPAddress {
    return [NSString stringWithFormat:@"boxee:%@@%@:%@",serverPassword,serverIP,serverPort];
    //return @"poisontooth.com:8800";
}

-(NSString*)createURLBase
{
    NSString *s = [NSString stringWithFormat:@"http://%@/xbmcCmds/xbmcHttp?command=", [self XboxIPAddress]];
    return s;
}

#pragma mark Database Commands

-(BOOL)isDatabaseEnabled {
	//NSLog(@"Checking if database is enabled.");
    NSString *query = @"select idSeries,strTitle,strBoxeeId,strCover,strDescription,strGenre,iYear from series";
    NSURL *sendURL = [self getURLForCommand:@"queryvideodatabase" parameters:[NSArray arrayWithObject:query]];
    NSString *response = [self getPage:sendURL timeout:5.0];
    if ([response rangeOfString:@"error or missing database"].location != NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}

-(void)setupRemoteDatabaseMac {
    NSURL *sendURL = [self getURLForCommand:@"FileDownloadFromInternet" parameters:[NSArray arrayWithObject:@"http://lastedit.com/kontrol/macsetup.sh;/tmp/macsetup.sh"]];
    [self getPage:sendURL timeout:5.0];
    sendURL = [self getURLForCommand:@"FileDownloadFromInternet" parameters:[NSArray arrayWithObject:@"http://lastedit.com/kontrol/runmacsetup.txt;/tmp/runmacsetup.py"]];
    [self getPage:sendURL timeout:5.0];
    sendURL = [self getURLForCommand:@"ExecBuiltIn" parameters:[NSArray arrayWithObject:@"RunScript(/tmp/runmacsetup.py)"]];
    [self getPage:sendURL timeout:5.0];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Restart Boxee" message:@"Changes applied. Boxee must be manually restarted for these changes to take effect." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

-(void)setupRemoteDatabaseWin {
    NSURL *sendURL = [self getURLForCommand:@"FileDownloadFromInternet" parameters:[NSArray arrayWithObject:@"http://lastedit.com/kontrol/winsetup.txt;special://masterprofile/profiles/winsetup.py"]];
    [self getPage:sendURL timeout:5.0];
    sendURL = [self getURLForCommand:@"ExecBuiltIn" parameters:[NSArray arrayWithObject:@"RunScript(special://masterprofile/profiles/winsetup.py)"]];
    [self getPage:sendURL timeout:5.0];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Restart Boxee" message:@"Changes applied. Boxee must be manually restarted for these changes to take effect." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    //NSLog(@"Releasing alert");
    [alert release];
}

-(NSArray *)queryDatabase:(NSString *)query {
    //NSLog(@"Sending query: %@",query);
    NSURL *sendURL = [self getURLForCommand:@"queryvideodatabase" parameters:[NSArray arrayWithObject:query]];
    NSArray *fields = [self getFields:[self getPage:sendURL timeout:5.0] withQuery:query];
    if ([fields count] > 0) {
        //[fields count] > 0
        return fields;
    } else {
        //[self showAlert:@"queryDatabase: Unable to parse fields from response."];
        return nil;
    }
}

-(NSArray *)getTVShows {
    return [self queryDatabase:@"select idSeries,strTitle,strBoxeeId,strCover,strDescription,strGenre,iYear from series"];
}

-(NSArray *)getEpisodesForTVShow:(NSString *)show {
    NSMutableString *escapedShow = [NSMutableString stringWithString:show];
    
    [escapedShow replaceOccurrencesOfString:@"'" withString:@"''" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [show length])];
    NSArray *showIDArray = [self queryDatabase:[NSString stringWithFormat:@"select strBoxeeId from series WHERE strTitle='%@'",escapedShow]];
    
    if ([showIDArray count] > 0) {
        NSString *showID = [[showIDArray objectAtIndex:0] valueForKey:@"strBoxeeId"];
        return [self queryDatabase:[NSString stringWithFormat:@"select idVideo,strPath,strTitle,strBoxeeId,strSeriesId,iSeason,iEpisode,strDescription,strCover,strGenre,iRating,strIMDBKey from video_files WHERE strSeriesId='%@'",showID]];
    } else {
        return nil;
    }
}

-(NSArray *)getMovies {
    return [self queryDatabase:@"select idVideo,strPath,strTitle,strBoxeeId,iSeason,iEpisode,strDescription,strCover,strGenre,iRating,strIMDBKey from video_files WHERE iEpisode=-1"];
}

-(NSArray *)getAlbums {
    return [self queryDatabase:@"select idAlbum,strTitle,strPath,iNumTracks,idArtist,strArtwork,strDescription,strGenre,iYear,iRating from albums"];
}

-(NSArray *)getSongsForAlbum:(NSString *)idAlbum {
    return [self queryDatabase:[NSString stringWithFormat:@"select idAudio,strPath,strTitle,idAlbum,idArtist,iTrackNumber from audio_files WHERE idAlbum=%@",idAlbum]];
}

-(NSArray *)getArtists {
    return [self queryDatabase:@"select strName,idArtist from artists"];
}

-(NSArray *)getSongsForArtist:(NSString *)idArtist {
    return [self queryDatabase:[NSString stringWithFormat:@"select idAudio,strPath,strTitle,idAlbum,idArtist,iTrackNumber from audio_files WHERE idArtist=%@",idArtist]];
}

-(NSArray *)getInfoForMovie:(NSString *)movie {
    return nil;
}

-(NSString *)getArtistWithID:(NSNumber *)aid {
    NSArray *artistName = [self queryDatabase:[NSString stringWithFormat:@"select strName from artists WHERE idArtist='%@'",aid]];
    //NSLog(@"artist name: %@",artistName);
    return [[artistName objectAtIndex:0] valueForKey:@"strName"];
}

-(NSString *)getAlbumWithID:(NSNumber *)aid {
    NSArray *albumName = [self queryDatabase:[NSString stringWithFormat:@"select strTitle from albums WHERE idAlbum='%@'",aid]];
    
    return [[albumName objectAtIndex:0] valueForKey:@"strTitle"];
}

-(NSString *)getArtworkForAlbum:(NSNumber *)aid {
    NSArray *artistName = [self queryDatabase:[NSString stringWithFormat:@"select strArtwork from albums WHERE idAlbum='%@'",aid]];
    //NSLog(@"strArtwork: %@",[[artistName objectAtIndex:0] valueForKey:@"strArtwork"]);
    return [[artistName objectAtIndex:0] valueForKey:@"strArtwork"];
}

-(NSDictionary *)getInfoForFile:(NSString *)filePath {
    
    //[filePath replaceOccurrencesOfString:@"'" withString:@"''" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [filePath length])];
    
    NSMutableString *escapedFilePath = [NSMutableString stringWithString:filePath];
    
    [escapedFilePath replaceOccurrencesOfString:@"'" withString:@"''" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escapedFilePath length])];
    
    NSArray *fileInfo = [self queryDatabase:[NSString stringWithFormat:@"select idVideo,strPath,strTitle,strBoxeeId,strSeriesId,iSeason,iEpisode,strDescription,strCover,strGenre,iRating,strIMDBKey from video_files WHERE strPath='%@'",escapedFilePath]];
    
    //NSLog(@"fileInfo array: %@",fileInfo);
    
    if ([fileInfo count] > 0) {
        return [fileInfo objectAtIndex:0];
    } else {
        return nil;
    }
}

-(NSString *)getDirectorForVideo:(NSNumber *)vid {
    NSArray *directorToVidArray = [self queryDatabase:[NSString stringWithFormat:@"select idDirector from director_to_video WHERE idVideo='%@'",vid]];
    NSNumber *directorid = [NSNumber numberWithInt:[[[directorToVidArray objectAtIndex:0] valueForKey:@"idDirector"] intValue]];
    NSArray *directorArray = [self queryDatabase:[NSString stringWithFormat:@"select strName from directors WHERE idDirector='%@'",directorid]];
    
    if ([directorArray count] > 0)
        return [[directorArray objectAtIndex:0] valueForKey:@"strName"];
    else
        return nil;
}

-(void)activateWindow:(int)win {
    NSURL *sendURL;
    sendURL = [self getURLForCommand:@"ExecBuiltIn" parameters:[NSArray arrayWithObject:[NSString stringWithFormat:@"ActivateWindow(%i)",win]]];
    [self getPage:sendURL timeout:5.0];
}

-(void)action:(int)action {
    NSURL *sendURL;
    sendURL = [self getURLForCommand:@"Action" parameters:[NSArray arrayWithObject:[NSString stringWithFormat:@"%i",action]]];
    [self getPage:sendURL timeout:5.0];
}

#pragma mark Data Retreival

-(BOOL)isPasswordProtected {
    NSURL *sendURL = [self getURLForCommand:@"GetVolume"];
    NSString *page = [self getPage:sendURL timeout:1.0];
    if ([page rangeOfString:@"Access Error: Unauthorized"].location != NSNotFound) {
        return YES;
    } else {
        return NO;
    }
}

-(NSURL*) getURLForCommand:(NSString *)cmd {
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [self createURLBase], cmd];
    //NSLog(@"URL: %@",urlString);
    return [NSURL URLWithString:urlString];
}

-(NSURL*) getURLForCommand:(NSString *)cmd parameters:(NSArray *) params {
    NSString *paramString = @"";
    if ([params count] > 0) {
        int i;
        NSString *initString = @"&parameter=";
        for (i=0; i<[params count]; i++) {
            paramString = [NSString stringWithFormat:@"%@%@%@", paramString, initString, [self encodeURL:[params objectAtIndex: i]]];
        }
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", [self createURLBase], cmd, paramString];
    //NSLog(@"urlString: %@",urlString);
    return [NSURL URLWithString:urlString];
}

-(NSString*) getPage: (NSURL*) url timeout: (double) timeoutVal {
    
	//NSLog(@"Getting page: %@",url);
    NSURLRequest* request = [NSURLRequest requestWithURL: url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:timeoutVal];
	
    NSError *error;
    NSData *responseData;
    NSURLResponse *response;
    responseData = [ NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response error:&error];
	
    NSString *page;             
	//NSLog(@"Loading response data...");
	// convert tostring
	page = [[[NSString alloc] initWithData: responseData encoding:NSUTF8StringEncoding] autorelease];
	//NSLog(@"Response data loaded...");
    if ([page rangeOfString:@"Error:Unknown command"].location != NSNotFound) {
        //[self showAlert:@"Error: Unknown command."];
        return @"Error:Unknown command";
    }
    if ([page rangeOfString:@"Access Error: Unauthorized"].location != NSNotFound) {
        //[self showAlert:@"Access Error: Unauthorized"];
        return @"Access Error: Unauthorized";
    }
    //NSLog(@"Response data: %@",page);
    return page;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
}

-(int)getLines: (NSString*) text lines: (NSMutableArray*)theLines
{
    // Note: uncomment this to see the text
	//NSLog(@"getLines:  %@", text);
    if (text != nil) {
        if ([text rangeOfString:@"Error"].location != NSNotFound) {
            //[self showAlert:text];
            return 0;
        }
		int p, p1;
		NSString* tmp;
		p = (int)[text rangeOfString:@"<li>"].location;
		while((p!=NSNotFound))
		{
			NSString *s = [NSString stringWithFormat:@"%C", 0xa];
			p1 = (int)[text rangeOfString:s options:NSLiteralSearch range: NSMakeRange(p, [text length] - p)].location;
			if (p1 == NSNotFound)
			{
				p1 = [text length];
			}
			tmp = [text substringWithRange:NSMakeRange(p+4,p1-p-4)];
			if ([[tmp substringWithRange:NSMakeRange([tmp length]-1,1)] compare: @">"] == NSOrderedSame)
			{
				p = [tmp rangeOfString:@"<" options:NSBackwardsSearch ].location;
				if (p != NSNotFound)
				{
					tmp = [tmp substringWithRange:NSMakeRange(0, p)];
				}
			}
			//NSLog(@"found a line: %@", tmp);
			[theLines addObject: tmp];
			p = (int)[text rangeOfString:@"<li>" options:NSCaseInsensitiveSearch range: NSMakeRange(p1, [text length] - p1)].location;
		}
		//NSLog(@"getLines:  %@",theLines);
		//[theLines removeAllObjects];
		return ([theLines count] > 0);
    } else {
        return 0;
    }
}

-(NSArray*)getFields:(NSString *)text withQuery:(NSString *)query
{
    // Note: uncomment this to see the text
    //NSLog(@"getLines:  %@", text);
    if (text != nil) {
		int p, p1;
		NSString* tmp;
		
		NSMutableArray *dataLines = [[NSMutableArray alloc] init];
		NSMutableDictionary *dataLine = [[NSMutableDictionary alloc] init];
		NSMutableArray *fieldArray = [[NSMutableArray alloc] init];
		
		p = (int)[text rangeOfString:@"<field>"].location;
		while ((p != NSNotFound)) {
			p1 = (int)[text rangeOfString:@"</field>" options:NSLiteralSearch range:NSMakeRange(p, [text length] - p)].location;
			tmp = [text substringWithRange:NSMakeRange(p+7, p1-p-7)];
			//NSLog(@"Found a field: %@",tmp);
			[fieldArray addObject:tmp];
			p = (int)[text rangeOfString:@"<field>" options:NSCaseInsensitiveSearch range:NSMakeRange(p1, [text length] - p1)].location;
		}
		
		p = (int)[query rangeOfString:@"select "].location;
		p1 = (int)[query rangeOfString:@" from" options:NSLiteralSearch range:NSMakeRange(p, [query length] - p)].location;
		tmp = [query substringWithRange:NSMakeRange(p+7, p1-p-7)];
		//NSLog(@"Query fields: %@",tmp);
		
		NSArray *queryFields = [tmp componentsSeparatedByString:@","];
		//NSLog(@"Query fields: %@",queryFields);
		
		int f;
		int qField = 0;
		//NSLog(@"Number of fields: %i",[fieldArray count]);
		//NSLog(@"Number of queries: %i",[queryFields count]);
		for (f=0;f<[fieldArray count];f++) {
			//NSLog(@"Adding field %i for query %i",f,qField);
			NSString *field = [fieldArray objectAtIndex:f];
			NSString *fieldName = [queryFields objectAtIndex:qField];
			if (dataLine == nil) {
				dataLine = [[NSMutableDictionary alloc] init];
			}
			if ([fieldName rangeOfString:@"str"].location == 0) {
				[dataLine setValue:field forKey:fieldName];
			} else if ([fieldName rangeOfString:@"i"].location == 0) {
				[dataLine setValue:[NSNumber numberWithInt:[field intValue]] forKey:fieldName];
			} else {
				[dataLine setValue:field forKey:fieldName];
			}
			qField++;
			if (qField == ([queryFields count])) {
				//NSLog(@"Reached end of line");
				//NSLog(@"Line: %@",dataLine);
				qField = 0;
				[dataLines addObject:dataLine];
				//NSLog(@"Releasing dataline.");
				[dataLine release];
				dataLine = nil;
			}
			//[field autorelease];
			//[fieldName autorelease];
		}
		//[dataLines removeAllObjects];
		return [dataLines autorelease];
    } else {
        return nil;
    }
}

@end
