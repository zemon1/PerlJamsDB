import MySQLdb, os, sys, urllib2, json, eyeD3
import subprocess as sub

def walker(root):
    
    fileHash = {}
    
    for (dirpath, dirnames, filenames) in os.walk(root):
            for filename in filenames:
                path, extension = os.path.splitext(filename)
                if extension == ".mp3":
                    print filename
                    #print path
                    #print root
                    #print extension
                    #print os.path.abspath(os.path.join(dirpath, filename)).split(root)[1]
                    thePath = os.path.abspath(os.path.join(dirpath, filename))
                    
                    #'lastfm-fpclient -nometadata ' + thePath
                    fingerPrintId = ""
                    f=os.popen("lastfm-fpclient -nometadata \"" +  thePath + "\"")
                    for i in f.readlines():
                             fingerPrintId = i.split(" ")[0]
                    try:
                        fingerPrintId = int(fingerPrintId)
                        fileHash[thePath] = fingerPrintId
                    
                    except Exception:
                        pass
                    
    return fileHash


def getInfo(hashMap):
    songs = []
    albumHash = {}
     
    apiKey = "fa01536e58ada86f1e25b1313956739d"
    fingerprint = ""
    
    for key, value in hashMap.items():
        newMap = {}

        
        #newMap[''] = rootQuery['']
        try:
            response = urllib2.urlopen("http://ws.audioscrobbler.com/2.0/?format=json&method=track.getfingerprintmetadata&fingerprintid=" + str(value) + "&api_key=" + apiKey)
            theResp = json.loads(response.read())
            
            print theResp, "\n\n"

            rootQuery = theResp['tracks']['track'][0]

            newMap['songName'] = rootQuery['name']
            newMap['songMbid'] = rootQuery['mbid']
            newMap['length'] = rootQuery['duration']
            newMap['artist'] = rootQuery['artist']['name']
            newMap['artistMbid'] = rootQuery['artist']['mbid']
            albumHash[newMap['artist']]
        except KeyError:
            albumHash[newMap['artist']] = {}    
        
        response = urllib2.urlopen("http://ws.audioscrobbler.com/2.0/?format=json&method=track.getInfo&mbid=" + newMap['songMbid']  + "&api_key=" + apiKey)
        theResp = json.loads(response.read())
        #print theResp, "\n"
        
        rootQuery = theResp['track']
        #newMap['album'] = rootQuery['album']['title']
        newMap['albumMbid'] = ""
        newMap['trackNum'] = ""
        newMap['url'] = key
        newMap['fileType'] = "mp3"
        newMap['album'] = ""

        #newMap['name'] = rootQuery['name']

        if eyeD3.isMp3File(key):
             audioFile = eyeD3.Mp3AudioFile(key)
             tag = audioFile.getTag() 
             album = tag.getAlbum()
             #if(newMap['songName'].lower() == "merry-go-round"):
             #   print "\n\n\n\n\n\n\n\n\n\n\n", newMap, "\n\n\n\n\n\n\n\n\n\n\n\n"
             try:
                try:
                    newMap['album'] = rootQuery['album']['title']
                    newMap['albumMbid'] = rootQuery['album']['mbid']
                    newMap['trackNum'] = rootQuery['album']['@attr']['position']
                    
                    albumHash[newMap['artist']][newMap['album']] = newMap['albumMbid']
                except Exception:
                    raise KeyError
             except KeyError:
                #print "In"
                try:
                    response = urllib2.urlopen("http://ws.audioscrobbler.com/2.0/?format=json&method=album.getInfo&artist=" + newMap['artist']  + "&album=" + album  + "&api_key=" + apiKey)
                    theResp = json.loads(response.read())
                    rootQuery = theResp['album']
                    newMap['album'] = rootQuery['name']
                    newMap['albumMbid'] = rootQuery['mbid']
                    for item in rootQuery['tracks']['track']:
                        if(item['name'] == newMap['songName']):
                            newMap['trackNum'] = item['@attr']['rank']
                    
                    #albumHash[newMap['artist']][newMap['album']] = newMap['albumMbid']
                    #try:
                    #except KeyError:
                    #    albumHash[newMap['artist']][newMap['album']] = newMap['albumMbid']
                        
                    
                except Exception:
                    pass
        if(newMap['album'] == ""):
            newMap['album'] = album
        print newMap, "\n"      
        songs.append(newMap)

    
    return [songs, albumHash]

def databaseInserts(songs, artists, db):
    cursor = db.cursor()

    cursor.execute("""SELECT * FROM Artist""")
    
    print "DBI"
    print cursor.fetchall()
    cursor.close()


    print "DBI"



if __name__ == "__main__":
    
    hashMap = walker("/home/music/Music (V0)/Red Jumpsuit Apparatus/")
    
    songs = getInfo(hashMap)
    
    for item in songs[0]:
        print item
    print "\n\n\n"
    for key, value in songs[1].items():
        print key, " - ", value

    db=MySQLdb.connect("localhost","perljams","Mus1cDatabase","PerlJams1")
    
    databaseInserts(songs[0], songs[1], db)

    cursor = db.cursor()

    q = cursor.execute("""SELECT * FROM Artist""")

    #q = db.query("""SELECT * FROM Artist""")
    print cursor.fetchall()
    cursor.close()

    #http://ws.audioscrobbler.com/2.0/?format=json&method=track.getfingerprintmetadata&fingerprintid=1234&api_key=b25b959554ed7...

