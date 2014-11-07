#!/usr/bin/env python3
import subprocess
import lxml.html
import argparse
RSS_DIR = '/home/allenwhale/.feed'
TITLE_FILE = RSS_DIR+'/title'
TEMP_FILE = RSS_DIR+'/.tmp'
class RSS:
    def __init__(self, url):
        assert(url != "")
        self.url = url
        self.title = 'None'
        self.desc = 'None'
        try:
            main = lxml.html.parse(self.url)
            if main.xpath("/html/body/rss"):
                self.title = str(main.xpath("/html/body/rss/channel/title")[0].text)
                self.desc = str(main.xpath("/html/body/rss/channel/description")[0].text)
                self.items = list(zip(
                    [ str(x.text).replace('\"','\\\\\\\"') for x in main.xpath("/html/body/rss/channel/item[*]/title") ],
                    [ str(x.text).replace('\"','\\\\\\\"') for x in main.xpath('/html/body/rss/channel/item[*]/guid') ],
                    [ str(x.text).replace('\"','\\\\\\\"') for x in main.xpath("/html/body/rss/channel/item[*]/description") ]))
            elif main.xpath("/html/body/feed"):
                self.title = str(main.xpath("/html/body/feed/title")[0].text)
                self.desc = str(main.xpath("/html/body/feed/subtitle")[0].text)
                self.items = list(zip(
                    [ str(x.text).replace('\"','\\\\\\\"') for x in main.xpath("/html/body/feed/entry[*]/title") ],
                    [ str(x.text).replace('\"','\\\\\\\"') for x in main.xpath('/html/body/feed/entry[*]/origlink') ],
                    [ str(x.text).replace('\"','\\\\\\\"') for x in main.xpath("/html/body/feed/entry[*]/content") ]))
            else:
                pass

        except:
            f = open(TEMP_FILE,'w')
            f.write("wrong")
            f.close()
            raise RuntimeError

    def get_title(self):
        return self.title

    def get_desc(self):
        return self.desc

    def get_items(self):
        return self.items

def write_title(title_list):
    f = open(TITLE_FILE,"w")
    for i in title_list:
        s = i[0]+"\n"+i[1]+'\n'
        f.write(s)
    f.close()
    return None
def write_items(title,items):
    f = open(RSS_DIR+'/'+title,'w')
    for i in items:
        s = i[0]+'\n'+i[1]+'\n'+i[2]+'\n'
        f.write(s)
    f.close();
    return None
def get_title_list():
    f = open(TITLE_FILE,"r")
    title_list = []
    tmp = None
    for i in f:
        if tmp==None:
            tmp = (i.replace('\n',''),None)
        else:
            tmp = (tmp[0],i.replace('\n',''))
            title_list.append(tmp)
            tmp = None
    return title_list
def add_feed(url):
    rss = RSS(url)
    title = rss.get_title()
    #items = rss.get_items()
    title_list = get_title_list()
    for i in title_list:
        if i[0]==title:
            return 'Exist'
    title_list.append((title,url))
    write_title(title_list)
    #write_items(title,items)
    return None
def update_feed(url, title):
    title_list = get_title_list()
    if (title,url) not in title_list:
        return 'NExist'
    rss = RSS(url)
    items = rss.get_items()
    write_items(title,items)
    return None
def delete_feed(title):
    title_list = get_title_list()
    new_title_list = []
    for i in title_list:
        if i[0]!=title:
            new_title_list.append(i)
    write_title(new_title_list)
    subprocess.call(['rm','-rf',RSS_DIR+'/'+title])
    return None

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='RSS fetcher')
    parser.add_argument('--add', '-a' ,  type=str,  help='add feed  url')
    parser.add_argument('--update', '-u', nargs=2, help='update "url" "title"' )
    parser.add_argument('--delete', '-d', type=str, help='delete the feed "title"' )
    args = parser.parse_args()
    f = open(TEMP_FILE,'w')
    if args.add:
        res = add_feed(args.add)
        if res:
            f.write(res)
    elif args.update:
        res = update_feed(args.update[0], args.update[1])
        if res:
            f.write(res)
    elif args.delete:
        res = delete_feed(args.delete)
        if res:
            f.write(res)
    else:
        pass
    f.close()

