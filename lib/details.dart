import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'bato.dart';
import 'package:test_shit/chapter.dart';
import 'package:test_shit/manga.dart';
import 'chap_list_builder.dart';
import 'http_request.dart';
import 'package:url_launcher/url_launcher.dart';
import 'db_helper.dart';

class Details extends StatefulWidget {
  final String url;
  final int? mId;
  const Details(this.url, {this.mId, Key? key}) : super(key: key);

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {

  bool loaded = false;
  int? mId;
  int? fav;
  Manga? manga;
  List<Chapter> chapters = [];
  String? status, source;

  @override
  void initState() {
    super.initState();
    mId = widget.mId;
    retrieveDetails();
  }

  @override
  void dispose() async {
    super.dispose();
    DBStuff d = DBStuff();
    if(manga?.favourite == 1 && fav == 0){
      manga = await d.addFavourite(manga!, chapters);
    } else if(manga?.favourite == 0 && fav == 1) {
      manga = await d.removeFavorite(manga!);
    }
  }

  void retrieveDetails() async{
    DBStuff d = DBStuff();
    if(mId != null){
      manga = await d.getDetails(mId!);
      chapters = await d.getChapters(mId!);
    } else {
      manga = await d.getDetailsByUrl(widget.url);
      if(manga != null){
        chapters = await d.getChapters(manga?.mangaId ?? -1);
        if(chapters.isEmpty) {
          final html = await HttpService.get(widget.url) ?? '';
          chapters = Bato.chapterDetails(html);
        }
      } else {
        final html = await HttpService.get(widget.url) ?? '';
        manga = Bato.mangaDetails(html, widget.url);
        chapters = Bato.chapterDetails(html);
      }
    }
    fav = manga?.favourite;
    status = manga?.status;
    source = manga?.source;
    loaded = true;
    setState(() {});
  }

  _launchURL() async {
    var url = manga?.url ?? '';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  toggleFav() async {
    if(manga?.favourite == 0){
      manga?.favourite = 1;
    } else {
      manga?.favourite = 0;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0x1A021CFF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () { Share.share('Read at ${manga?.url as String}'); },
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Download',
          ),
        ],
        leading: const BackButton()
      ),
      body:  SafeArea(
        child: loaded
            ? Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 15.0, right: 10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Image.network(
                        manga?.thumbnailUrl as String,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, Object exception, StackTrace? s) { return const SizedBox.shrink(); },
                      ),
                    ),
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 5.0, top: 2.5, bottom: 2.5, right: 10.0),
                          child: Text(
                            manga?.title as String,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                              fontSize: 22.0,
                            ),
                            softWrap: false,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 5.0, top: 2.5, bottom: 2.5, right: 10.0),
                          child: Text(
                            (manga?.author as List<String>).join(', '),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontWeight: FontWeight.normal,
                              fontSize: 14.0,
                            ),
                            softWrap: false,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 5.0, top: 2.5, bottom: 2.5, right: 10.0),
                          child: Text(
                            '$status • $source',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontWeight: FontWeight.normal,
                              fontSize: 14.0,
                            ),
                            softWrap: false,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  const SizedBox(width: 10,),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () async { await toggleFav(); },
                      icon: manga?.favourite==0
                      ? const Icon(
                        Icons.favorite_border_outlined,
                        size: 20.0,
                      )
                      : const Icon(
                        Icons.favorite,
                        size: 20.0,
                      ),
                      label: manga?.favourite==0
                        ? const Text('Add to library')
                        : const Text('Remove from library'),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            // side: const BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                      child: TextButton.icon(
                        onPressed: () => { _launchURL() },
                        icon: const Icon(
                          Icons.public,
                          size: 20.0,
                        ),
                        label: const Text('Webview'),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              // side: const BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
                      )
                  ),
                  const SizedBox(width: 10,),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    '${chapters.length} chapters',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  padding: const EdgeInsets.only(right: 10.0),
                  icon: const Icon(Icons.sort, color: Colors.white54),
                ),
              ],
            ),
            Expanded(
              child: ChapListBuilder(chapters: chapters, mangaName: manga?.title ?? '',),
            ),
          ],
        )
        : const Center(child: CircularProgressIndicator(color: Color(0xFF093E9F),))
      ),
    );
  }
}
