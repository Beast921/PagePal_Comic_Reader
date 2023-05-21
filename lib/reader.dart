import 'package:flutter/material.dart';
import 'bato.dart';
import 'package:test_shit/chapter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class Reader extends StatefulWidget {
  const Reader(this.chapters, this.chapIndex, this.mangaName, {Key? key}) : super(key: key);
  final List<Chapter> chapters;
  final int chapIndex;
  final String mangaName;

  @override
  State<Reader> createState() => _ReaderState();
}

class _ReaderState extends State<Reader> {
  List<Chapter> chapters = [];
  int chapIndex = 0;
  String mangaName = '';
  // _ReaderState({required this.chapters, required this.chapIndex, required this.mangaName});

  String chapName = '';
  PageController pageController = PageController();
  int pageIndex = 0, totalPages = 0;
  bool showNav = false, loadingChap = true, webtoon = false, reverse = false, vertical = false;
  List<String> images = [];
  double _scale = 1.0;
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    getImgs();
  }

  Future<void> getImgs() async {
    mangaName = widget.mangaName;
    chapIndex = widget.chapIndex;
    chapters = widget.chapters;
    chapName = chapters[chapIndex].name;
    pageController = PageController(initialPage: pageIndex);
    images = await Bato.fetchImages(widget.chapters[widget.chapIndex].url);
    totalPages = images.length;
    loadingChap = false;
    pageController.addListener(onPageViewScroll);
    _controller.addListener(_scrollListener);
    setState(() {});
  }

  void onPageViewScroll() async {
    // int index = pageController.page?.round() ?? -1;
    if(pageController.hasClients){
      if(pageController.position.pixels < pageController.position.minScrollExtent) {
        if(chapIndex < chapters.length - 1) {
          chapIndex++;
          pageIndex = 0;
          chapName = chapters[chapIndex].name;
          loadingChap = true;
          setState(() {});
          images = await Bato.fetchImages(chapters[chapIndex].url);
          totalPages = images.length;
          pageIndex - images.length - 1;
          loadingChap = false;
          pageController.jumpToPage(images.length - 1);
          setState(() {});
        }
      }
      if(pageController.position.pixels > pageController.position.maxScrollExtent) {
        if(chapIndex > 0) {
          chapIndex--;
          pageIndex = 0;
          chapName = chapters[chapIndex].name;
          loadingChap = true;
          setState(() {});
          images = await Bato.fetchImages(chapters[chapIndex].url);
          totalPages = images.length;
          loadingChap = false;
          pageController.jumpToPage(pageIndex);
          setState(() {});
        }
      }
    } else {
      pageController = PageController(initialPage: pageIndex);
    }
  }

  void _scrollListener() {
    // final pixels = _controller.position.pixels;
    // final height = _controller.position.maxScrollExtent -
    //     _controller.position.minScrollExtent;
    // final itemHeight = height / (images.length-1);
    // final index = (pixels / itemHeight).floor();
    // setState(() {
    //   pageIndex = index;
    // });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    pageController.dispose();
    _controller.removeListener(_scrollListener);
    _controller.dispose();
    super.dispose();
  }

  _launchURL() async {
    var url = chapters[chapIndex].url;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _handleDoubleTap() {
    setState(() {
      _scale = (_scale == 1.0) ? 3.0 : 1.0;
    });
  }

  loadNewChap() async {
    loadingChap = true;
    chapName = chapters[chapIndex].name;
    setState(() {});
    images = await Bato.fetchImages(chapters[chapIndex].url);
    totalPages = images.length;
    loadingChap = false;
    setState(() {});
  }

  _showPopupMenu(Offset offset) async {
    double right = offset.dx;
    double top = offset.dy;
    await showMenu(
      context: context,
      color: const Color(0xA6081B50),
      position: RelativeRect.fromDirectional(textDirection: Directionality.of(context), start: right-100, top: top, end: right, bottom: top+80),
      items: [
        const PopupMenuItem<int>(
            value: 0,
            child: Text('Left to right', style: TextStyle(color: Color(0xECEEF3FF)))
        ),
        const PopupMenuItem<int>(
            value: 1,
            child: Text('Right to left', style: TextStyle(color: Color(0xECEEF3FF)))
        ),
        const PopupMenuItem<int>(
            value: 2,
            child: Text('Vertical', style: TextStyle(color: Color(0xECEEF3FF)))
        ),
        const PopupMenuItem<int>(
            value: 3,
            child: Text('Webtoon', style: TextStyle(color: Color(0xECEEF3FF)))
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      changeReader(value ?? -1);
    });
  }

  changeReader(int value){
    String floatStr = '';
    if(value == 0){
      webtoon = false;
      reverse = false;
      vertical = false;
      floatStr = 'Left to Right';
    }
    if(value == 1){
      webtoon = false;
      reverse = true;
      vertical = false;
      floatStr = 'Right to Left';
    }
    if(value == 2){
      webtoon = false;
      reverse = false;
      vertical = true;
      floatStr = 'Vertical';
    }
    else if(value == 3){
      webtoon = true;
      reverse = false;
      vertical = false;
      floatStr = 'Webtoon';
    }
    setState(() {});
    // Fluttertoast.showToast(
    //     msg: floatStr,
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.CENTER,
    //     timeInSecForIosWeb: 1,
    //     textColor: Colors.white,
    //     fontSize: 16.0
    // );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky, overlays: [ SystemUiOverlay.top ]);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF000000),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            setState(() {
              showNav = !showNav;
            });
          },
          child: Stack(
            children: [
              Visibility(
                visible: !loadingChap,
                child: InteractiveViewer(
                  scaleEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 5.0,
                  child: webtoon
                  ? ListView.builder(
                    controller: _controller,
                    padding: EdgeInsets.zero, // Set padding to zero to remove the gap
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return Image.network(images[index], fit: BoxFit.fitWidth);
                    },
                  )
                  : PageView.builder(
                  controller: pageController,
                  reverse: reverse,
                  scrollDirection: vertical ? Axis.vertical : Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onDoubleTap: _handleDoubleTap,
                      child: Center(
                        child: Transform.scale(
                          scale: _scale,
                          child: Image.network(
                            images[index],
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace){
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Could not load image.',
                                      style: TextStyle(color: Color(0xECEEF3FF), fontSize: 20.0),
                                    ),
                                    MaterialButton(
                                      onPressed: () { setState(() {}); },
                                      color: const Color(0xFF153D91),
                                      shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(22.0) ),
                                      clipBehavior: Clip.antiAlias,
                                      child: const Text(
                                        'Try Again',
                                        style: TextStyle(color: Color(0xECEEF3FF)),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: const Color(0xFF093E9F),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  onPageChanged: (index) {
                    setState(() {
                      pageIndex = index;
                    });
                  },
                ),
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: loadingChap
                    ? const Text(
                  '0/0',
                  style: TextStyle(color: Color(0xECEEF3FF), fontSize: 14.0),
                )
                    : Text(
                  '${pageIndex+1}/$totalPages',
                  style: const TextStyle(
                      color: Color(0xECEEF3FF),
                      fontSize: 14.0,
                  ),
                ),
              ),
              SizedBox(
                height: kToolbarHeight,
                child: AnimatedOpacity(
                  opacity: showNav ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: AppBar(
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mangaName,
                          style: const TextStyle(color: Color(0xECEEF3FF), fontSize: 20.0),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          chapName,
                          style: const TextStyle(color: Color(0xECEEF3FF), fontSize: 14.0),
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                    backgroundColor: const Color(0xA6081B50),
                    leading: const BackButton(color: Color(0xECEEF3FF)),
                    actions: [
                      GestureDetector(
                        onTapUp: (TapUpDetails detail) { _showPopupMenu(detail.globalPosition); },
                        child: const Icon(Icons.phonelink_setup, color: Color(0xECEEF3FF),),
                      ),
                      IconButton(
                        onPressed: () => { _launchURL() },
                        tooltip: 'Webview',
                        color: const Color(0xECEEF3FF),
                        icon: const Icon(Icons.public),
                      )
                    ],
                  )
                ),
              ),
              Positioned(
                right: 0,
                left: 0,
                bottom: 0,
                child: Container(
                  height: kToolbarHeight,
                  alignment: Alignment.bottomCenter,
                  child: AnimatedOpacity(
                    opacity: showNav ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 10),
                        MaterialButton(
                          onPressed: () {
                            if(reverse) {
                              if(chapIndex < chapters.length - 1) {
                                chapIndex--;
                                loadNewChap();
                              }
                            } else {
                              if(chapIndex > 0){
                                chapIndex++;
                                loadNewChap();
                              }
                            }
                          },
                          color: const Color(0xFF1C1C1C),
                          textColor: Colors.white,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(10),
                          child: const Icon(Icons.skip_previous, size: 20.0),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: loadingChap || webtoon
                              ? const SizedBox()
                              : Directionality(
                            textDirection: reverse ? TextDirection.rtl : TextDirection.ltr,
                                child: Slider(
                            value: (pageIndex + 1).toDouble(),
                            min: 1,
                            max: totalPages.toDouble(),
                            onChanged: (index) {
                                pageIndex = index.toInt() - 1;
                                webtoon
                                ? _controller.animateTo(pageIndex.toDouble() * totalPages * totalPages,duration: const Duration(milliseconds: 500), curve: Curves.ease,)
                                : pageController.jumpToPage(pageIndex);
                                setState(() {});
                            },
                          ),
                              ),
                        ),
                        const SizedBox(width: 8),
                        MaterialButton(
                          onPressed: () {
                            if(reverse) {
                              if(chapIndex > 0){
                                chapIndex++;
                                loadNewChap();
                              }
                            } else {
                              if(chapIndex < chapters.length - 1) {
                                chapIndex--;
                                loadNewChap();
                              }
                            }
                          },
                          color: const Color(0xFF1C1C1C),
                          textColor: Colors.white,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(10),
                          child: const Icon(Icons.skip_next, size: 20.0),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
              ),
              loadingChap ? const Center(
                child: CircularProgressIndicator(),
              ) : const SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }
}