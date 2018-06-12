#!/usr/bin/env python3

#jerking_uploader.py

__author__ = "happypenguin"
__license__ = "MIT"
__version__ = "2016-01-29"

#Requirements:
#beautifulsoup4>=4.3
#requests>2.7.0

import bs4 #python3-bs4
import requests #python3-requests
import time, calendar, optparse, random


MAIN_URL = 'https://jerking.empornium.ph'
POST_URL = 'https://jerking.empornium.ph/json'

def upload_file(file_name, session, auth_token):
    
    payload = {"action": "upload", "privacy": "public", "timestamp": calendar.timegm(time.gmtime()), "auth_token": auth_token}
    
    if file_name.startswith("http"):
        payload['source'] = file_name
        payload['type'] = "url"
        r = session.post(POST_URL, data=payload, verify=False)
    else:
        files = {"source": open(file_name, "rb")}
        payload['type'] = "file"
        r = session.post(POST_URL, files=files, data=payload, verify=False)

    return(r.json())

def main():
    usage = "%prog [options] pictures \n\nUpload script for https://jerking.empornium.ph"
    parser = optparse.OptionParser(usage)
    parser.add_option("-c", "--cover", action="store_true", dest="cover", help="Torrent Cover")
    parser.add_option("-l", "--large", action="store_true", dest="large", help="Large Screenshot/Forum Image")
    parser.add_option("-m", "--medium", action="store_true", dest="medium", help="Medium Linked Screenshot")
    parser.add_option("-s", "--small", action="store_true", dest="small", help="Small Linked Screenshot")
    parser.add_option("-a", "--avatar", action="store_true", dest="avatar", help="Avatar")
    parser.add_option("-n", "--no-newlines", action="store_true", dest="no_newlines", help="no newlines between links")

    (options, args) = parser.parse_args()

    if options.no_newlines:
        END = ' '
    else:
        END = '\n'
    
    with requests.Session() as session:
        r = session.get(MAIN_URL, verify=False)
        session.headers.update({'Accept': 'application/json'})
        soup = bs4.BeautifulSoup(r.text, "html5lib")
        auth_token = soup.find("input", {"name": "auth_token"})['value']
        
        for file_name in args:
            response = upload_file(file_name, session, auth_token)
            
            if options.cover or (not options.cover and not options.large and not options.medium and not options.small and not options.avatar):
                print(response['image']['url'], end=END)
            
            if options.large:
                print('[img]{0}[/img]'.format(response['image']['url']), end=END)
                
            if options.medium:
                print('[url={0}][img]{1}[/img][/url]'.format(response['image']['url_viewer'],response['image']['medium']['url']), end=END)
            
            if options.small:
                print('[url={0}][img]{1}[/img][/url]'.format(response['image']['url_viewer'],response['image']['thumb']['url']), end=END)

            if options.avatar:
                print(response['image']['thumb']['url'], end=END)    

        session.close()

        
if __name__ == "__main__":
    main()
