import json, re, sys, xml.etree.ElementTree as ET

NS = {
    "a": "http://www.w3.org/2005/Atom",
    "yt": "http://www.youtube.com/xml/schemas/2015",
    "media": "http://search.yahoo.com/mrss/",
}

root = ET.parse(sys.argv[1]).getroot()
videos = []
for e in root.findall("a:entry", NS):
    vid = e.findtext("yt:videoId", "", NS)
    title = (e.findtext("a:title", "", NS) or "").strip()
    group = e.find("media:group", NS)
    thumb = ""
    if group is not None:
        t = group.find("media:thumbnail", NS)
        if t is not None:
            thumb = t.get("url", "")
    if not (vid and title):
        continue
    # Collapse sharded hosts (i1/i3/i4) so the preconnect covers every thumb.
    thumb = re.sub(r"^https://i\d\.ytimg\.com/", "https://i.ytimg.com/", thumb)

    videos.append({
        "id": vid,
        "title": title,
        "url": "https://www.youtube.com/watch?v=" + vid,
        "published": e.findtext("a:published", "", NS),
        # Derive hqdefault if the feed omits the element.
        "thumbnail": thumb or f"https://i.ytimg.com/vi/{vid}/hqdefault.jpg",
    })

if not videos:
    sys.exit("feed parsed but contained no usable entries")


with open(sys.argv[2], "w", encoding="utf-8") as f:
    json.dump(videos, f, indent=2, ensure_ascii=False)
    f.write("\n")
print(f"wrote {len(videos)} videos to {sys.argv[2]}")
