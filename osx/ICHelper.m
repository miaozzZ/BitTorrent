//
//  ICHelper.m
//  BitTorrent
//
//  Created by Dr. Burris T. Ewell on Sat Jul 27 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "ICHelper.h"
#import <Cocoa/Cocoa.h>

#define EXTENSION "\ptorrent"
#define APP "\pBitTorrent"
#define MIMETYPE "\papplication/x-bittorrent"

#define CREATOR 'BCBC'
#define MFILETYPE 'BTMF'

@implementation ICHelper

- (id) init {
    [super init];
    ICStart(&ici, CREATOR);
    return self;
}

- (void) dealloc {
    [super dealloc];
    ICStop(ici);
}
- (id) installICHandler:sender
{
    OSStatus err;
    Handle handle = NewHandle(0);
    ICAttr attr;
    ICMapEntry map;
    
	err = ICFindPrefHandle(ici, "\pMapping", &attr, handle);
	err = ICMapEntriesFilename(ici, handle, "\pfoo.torrent", 
                                &map);
	if (err == icPrefNotFoundErr) {
	    NSRunAlertPanel(NSLocalizedString(@"Quit Internet Explorer", @"explanation of helper registration"), NSLocalizedString(@"BitTorrent cannot register as a helper application while Internet Explorer is running.  This only needs to be done once.  Please make sure Internet Explorer is not running before clicking OK.", @"shut down internet explorer request"), nil, nil, nil);
	    map.totalLength = kICMapFixedLength + PLstrlen(EXTENSION) + PLstrlen(APP) * 3 + PLstrlen(MIMETYPE);
	    map.fixedLength = kICMapFixedLength;
	    map.version = 3;
	    map.fileType = MFILETYPE;
	    map.fileCreator = CREATOR;
	    map.postCreator = CREATOR;
	    map.flags = kICMapBinaryMask |  kICMapDataForkMask | kICMapPostMask;
	    PLstrcpy(map.extension, EXTENSION);
	    PLstrcpy(map.creatorAppName, APP);
	    PLstrcpy(map.postAppName, APP);
	    PLstrcpy(map.MIMEType, MIMETYPE);
	    PLstrcpy(map.entryName, APP);
	    	    
	    err = ICBegin(ici, icReadWritePerm);
	    err = ICAddMapEntry(ici, handle, &map);
	    err = ICSetPrefHandle(ici, "\pMapping", attr, handle);
	    err = ICEnd(ici);
	}
    return self;
}

- (NSString *)downloadDir {
    OSStatus err;
    ICAttr attr;
    char buf[1024], path[256];
    long size = 1024;
    ICFileSpec *f;
    FSRef fsRef;
    
    err = ICGetPref (ici, kICDownloadFolder, &attr, &buf, &size);
    f = (ICFileSpec *)buf;
    
    err = FSpMakeFSRef(&f->fss, &fsRef);
    err =FSRefMakePath(&fsRef, path, 256);
    
    return [NSString stringWithCString:path];
}
@end
