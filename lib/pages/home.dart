import 'dart:async';
import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dtlive/pages/videosbyid.dart';
import 'package:dtlive/provider/generalprovider.dart';
import 'package:dtlive/shimmer/shimmerutils.dart';
import 'package:dtlive/utils/sharedpre.dart';
import 'package:dtlive/webwidget/commonappbar.dart';
import 'package:dtlive/webwidget/footerweb.dart';

import 'package:dtlive/model/sectionlistmodel.dart';
import 'package:dtlive/model/sectiontypemodel.dart' as type;
import 'package:dtlive/model/sectionlistmodel.dart' as list;
import 'package:dtlive/model/sectionbannermodel.dart' as banner;
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/utils/dimens.dart';
import 'package:dtlive/widget/nodata.dart';
import 'package:dtlive/provider/homeprovider.dart';
import 'package:dtlive/provider/sectiondataprovider.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/widget/myimage.dart';
import 'package:dtlive/widget/mytext.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:dtlive/widget/mynetworkimg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Home extends StatefulWidget {
  final String? pageName;
  const Home({Key? key, required this.pageName}) : super(key: key);

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  late SectionDataProvider sectionDataProvider;
  final FirebaseAuth auth = FirebaseAuth.instance;
  SharedPre sharedPref = SharedPre();
  CarouselController carouselController = CarouselController();
  final tabScrollController = ScrollController();
  late ListObserverController observerController;
  late HomeProvider homeProvider;
  int? videoId, videoType, typeId;
  String? currentPage,
      langCatName,
      aboutUsUrl,
      privacyUrl,
      termsConditionUrl,
      refundPolicyUrl,
      mSearchText;

  _onItemTapped(String page) async {
    debugPrint("_onItemTapped -----------------> $page");
    if (page != "") {
      await setSelectedTab(-1);
    }
    setState(() {
      currentPage = page;
    });
  }

  @override
  void initState() {
    sectionDataProvider =
        Provider.of<SectionDataProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    observerController =
        ListObserverController(controller: tabScrollController);
    currentPage = widget.pageName ?? "";
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
    if (!kIsWeb) {
      OneSignal.shared.setNotificationOpenedHandler(_handleNotificationOpened);
    }
  }

  // What to do when the user opens/taps on a notification
  _handleNotificationOpened(OSNotificationOpenedResult result) {
    /* id, video_type, type_id */

    debugPrint(
        "setNotificationOpenedHandler additionalData ===> ${result.notification.additionalData.toString()}");
    debugPrint(
        "setNotificationOpenedHandler video_id ===> ${result.notification.additionalData?['id']}");
    debugPrint(
        "setNotificationOpenedHandler upcoming_type ===> ${result.notification.additionalData?['upcoming_type']}");
    debugPrint(
        "setNotificationOpenedHandler video_type ===> ${result.notification.additionalData?['video_type']}");
    debugPrint(
        "setNotificationOpenedHandler type_id ===> ${result.notification.additionalData?['type_id']}");

    if (result.notification.additionalData?['id'] != null &&
        result.notification.additionalData?['upcoming_type'] != null &&
        result.notification.additionalData?['video_type'] != null &&
        result.notification.additionalData?['type_id'] != null) {
      String? videoID =
          result.notification.additionalData?['id'].toString() ?? "";
      String? upcomingType =
          result.notification.additionalData?['upcoming_type'].toString() ?? "";
      String? videoType =
          result.notification.additionalData?['video_type'].toString() ?? "";
      String? typeID =
          result.notification.additionalData?['type_id'].toString() ?? "";
      log("videoID =======> $videoID");
      log("upcomingType ==> $upcomingType");
      log("videoType =====> $videoType");
      log("typeID ========> $typeID");

      Utils.openDetails(
        context: context,
        videoId: int.parse(videoID),
        upcomingType: int.parse(upcomingType),
        videoType: int.parse(videoType),
        typeId: int.parse(typeID),
      );
    }
  }

  _getData() async {
    final generalsetting = Provider.of<GeneralProvider>(context, listen: false);

    await homeProvider.setLoading(true);
    await homeProvider.getSectionType();

    if (!homeProvider.loading) {
      if (homeProvider.sectionTypeModel.status == 200 &&
          homeProvider.sectionTypeModel.result != null) {
        if ((homeProvider.sectionTypeModel.result?.length ?? 0) > 0) {
          if ((sectionDataProvider.sectionBannerModel.result?.length ?? 0) ==
                  0 ||
              (sectionDataProvider.sectionListModel.result?.length ?? 0) == 0) {
            getTabData(0, homeProvider.sectionTypeModel.result);
          }
        }
      }
    }
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
    generalsetting.getGeneralsetting();
    generalsetting.getPages();
    Utils.getCurrencySymbol();
  }

  Future<void> setSelectedTab(int tabPos) async {
    debugPrint("setSelectedTab tabPos ====> $tabPos");
    if (!mounted) return;
    await homeProvider.setSelectedTab(tabPos);
    debugPrint(
        "setSelectedTab selectedIndex ====> ${homeProvider.selectedIndex}");
    debugPrint(
        "setSelectedTab lastTabPosition ====> ${sectionDataProvider.lastTabPosition}");
    if (sectionDataProvider.lastTabPosition == tabPos) {
      return;
    } else {
      sectionDataProvider.setTabPosition(tabPos);
    }
  }

  Future<void> getTabData(
      int position, List<type.Result>? sectionTypeList) async {
    debugPrint("getTabData position ====> $position");
    await setSelectedTab(position);
    await sectionDataProvider.setLoading(true);
    await sectionDataProvider.getSectionBanner(
        position == 0 ? "0" : (sectionTypeList?[position - 1].id),
        position == 0 ? "1" : "2");
    await sectionDataProvider.getSectionList(
        position == 0 ? "0" : (sectionTypeList?[position - 1].id),
        position == 0 ? "1" : "2");
  }

  openDetailPage(String pageName, int videoId, int upcomingType, int videoType,
      int typeId) async {
    debugPrint("pageName =======> $pageName");
    debugPrint("videoId ========> $videoId");
    debugPrint("upcomingType ===> $upcomingType");
    debugPrint("videoType ======> $videoType");
    debugPrint("typeId =========> $typeId");
    if (pageName != "" && (kIsWeb || Constant.isTV)) {
      await setSelectedTab(-1);
    }
    if (!mounted) return;
    Utils.openDetails(
      context: context,
      videoId: videoId,
      upcomingType: upcomingType,
      videoType: videoType,
      typeId: typeId,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  _scrollToCurrent() {
    log("selectedIndex ======> ${homeProvider.selectedIndex.toDouble()}");
    observerController.animateTo(
      index: homeProvider.selectedIndex,
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      body: SafeArea(
        child: (kIsWeb || Constant.isTV)
            ? _webAppBarWithDetails()
            : _mobileAppBarWithDetails(),
      ),
    );
  }

  Widget _mobileAppBarWithDetails() {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: appBgColor,
              toolbarHeight: 65,
              title: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.center,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  splashColor: transparentColor,
                  highlightColor: transparentColor,
                  onTap: () async {
                    await getTabData(0, homeProvider.sectionTypeModel.result);
                  },
                  child:
                      MyImage(width: 80, height: 80, imagePath: "appicon.png"),
                ),
              ), // This is the title in the app bar.
              pinned: false,
              expandedHeight: 0,
              forceElevated: innerBoxIsScrolled,
            ),
          ),
        ];
      },
      body: homeProvider.loading
          ? ShimmerUtils.buildHomeMobileShimmer(context)
          : (homeProvider.sectionTypeModel.status == 200)
              ? (homeProvider.sectionTypeModel.result != null ||
                      (homeProvider.sectionTypeModel.result?.length ?? 0) > 0)
                  ? Stack(
                      children: [
                        tabItem(homeProvider.sectionTypeModel.result),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: Dimens.homeTabHeight,
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          color: black.withOpacity(0.8),
                          child: tabTitle(homeProvider.sectionTypeModel.result),
                        ),
                      ],
                    )
                  : const NoData(title: '', subTitle: '')
              : const NoData(title: '', subTitle: ''),
    );
  }

  Widget _webAppBarWithDetails() {
    if (homeProvider.loading) {
      return ShimmerUtils.buildHomeMobileShimmer(context);
    } else {
      if (homeProvider.sectionTypeModel.status == 200) {
        if (homeProvider.sectionTypeModel.result != null ||
            (homeProvider.sectionTypeModel.result?.length ?? 0) > 0) {
          return Stack(
            children: [
              // _clickToRedirect(pageName: currentPage ?? ""),
              tabItem(homeProvider.sectionTypeModel.result),
              const CommonAppBar(),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget tabTitle(List<type.Result>? sectionTypeList) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (tabScrollController.hasClients) {
        _scrollToCurrent();
      }
    });
    return ListViewObserver(
      controller: observerController,
      child: ListView.separated(
        itemCount: (sectionTypeList?.length ?? 0) + 1,
        shrinkWrap: true,
        controller: tabScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(13, 5, 13, 5),
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return Consumer<HomeProvider>(
            builder: (context, homeProvider, child) {
              return InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () async {
                  debugPrint("index ===========> $index");
                  if (kIsWeb) _onItemTapped("");
                  await getTabData(index, homeProvider.sectionTypeModel.result);
                },
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 32),
                  decoration: Utils.setBackground(
                    homeProvider.selectedIndex == index
                        ? white
                        : transparentColor,
                    20,
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                  child: MyText(
                    color: homeProvider.selectedIndex == index ? black : white,
                    multilanguage: false,
                    text: index == 0
                        ? "Home"
                        : index > 0
                            ? (sectionTypeList?[index - 1].name.toString() ??
                                "")
                            : "",
                    fontsizeNormal: 12,
                    fontweight: FontWeight.w700,
                    fontsizeWeb: 14,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.center,
                    fontstyle: FontStyle.normal,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget tabItem(List<type.Result>? sectionTypeList) {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints.expand(),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: Dimens.homeTabHeight),

            /* Banner */
            Consumer<SectionDataProvider>(
              builder: (context, sectionDataProvider, child) {
                if (sectionDataProvider.loadingBanner) {
                  if ((kIsWeb || Constant.isTV) &&
                      MediaQuery.of(context).size.width > 720) {
                    return ShimmerUtils.bannerWeb(context);
                  } else {
                    return ShimmerUtils.bannerMobile(context);
                  }
                } else {
                  if (sectionDataProvider.sectionBannerModel.status == 200 &&
                      sectionDataProvider.sectionBannerModel.result != null) {
                    if ((kIsWeb || Constant.isTV) &&
                        MediaQuery.of(context).size.width > 720) {
                      return _webHomeBanner(
                          sectionDataProvider.sectionBannerModel.result);
                    } else {
                      return _mobileHomeBanner(
                          sectionDataProvider.sectionBannerModel.result);
                    }
                  } else {
                    return const SizedBox.shrink();
                  }
                }
              },
            ),

            /* Continue Watching & Remaining Sections */
            Consumer<SectionDataProvider>(
              builder: (context, sectionDataProvider, child) {
                if (sectionDataProvider.loadingSection) {
                  return sectionShimmer();
                } else {
                  if (sectionDataProvider.sectionListModel.status == 200) {
                    return Column(
                      children: [
                        /* Continue Watching */
                        (sectionDataProvider
                                    .sectionListModel.continueWatching !=
                                null)
                            ? continueWatchingLayout(sectionDataProvider
                                .sectionListModel.continueWatching)
                            : const SizedBox.shrink(),

                        /* Remaining Sections */
                        (sectionDataProvider.sectionListModel.result != null)
                            ? setSectionByType(
                                sectionDataProvider.sectionListModel.result)
                            : const SizedBox.shrink(),
                      ],
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }
              },
            ),
            const SizedBox(height: 20),

            /* Web Footer */
            kIsWeb ? const FooterWeb() : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  /* Section Shimmer */
  Widget sectionShimmer() {
    return Column(
      children: [
        /* Continue Watching */
        if (Constant.userID != null && homeProvider.selectedIndex == 0)
          ShimmerUtils.continueWatching(context),

        /* Remaining Sections */
        ListView.builder(
          itemCount: 10, // itemCount must be greater than 5
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            if (index == 1) {
              return ShimmerUtils.setHomeSections(context, "potrait");
            } else if (index == 2) {
              return ShimmerUtils.setHomeSections(context, "square");
            } else if (index == 3) {
              return ShimmerUtils.setHomeSections(context, "langGen");
            } else {
              return ShimmerUtils.setHomeSections(context, "landscape");
            }
          },
        ),
      ],
    );
  }

  Widget _mobileHomeBanner(List<banner.Result>? sectionBannerList) {
    if ((sectionBannerList?.length ?? 0) > 0) {
      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: Dimens.homeBanner,
            child: CarouselSlider.builder(
              itemCount: (sectionBannerList?.length ?? 0),
              carouselController: carouselController,
              options: CarouselOptions(
                initialPage: 0,
                height: Dimens.homeBanner,
                enlargeCenterPage: false,
                autoPlay: true,
                autoPlayCurve: Curves.linear,
                enableInfiniteScroll: true,
                autoPlayInterval:
                    Duration(milliseconds: Constant.bannerDuration),
                autoPlayAnimationDuration:
                    Duration(milliseconds: Constant.animationDuration),
                viewportFraction: 1.0,
                onPageChanged: (val, _) async {
                  await sectionDataProvider.setCurrentBanner(val);
                },
              ),
              itemBuilder:
                  (BuildContext context, int index, int pageViewIndex) {
                return InkWell(
                  focusColor: white,
                  borderRadius: BorderRadius.circular(0),
                  onTap: () {
                    log("Clicked on index ==> $index");
                    openDetailPage(
                      (sectionBannerList?[index].videoType ?? 0) == 2
                          ? "showdetail"
                          : "videodetail",
                      sectionBannerList?[index].id ?? 0,
                      sectionBannerList?[index].upcomingType ?? 0,
                      sectionBannerList?[index].videoType ?? 0,
                      sectionBannerList?[index].typeId ?? 0,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Stack(
                      alignment: AlignmentDirectional.bottomCenter,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: Dimens.homeBanner,
                          child: MyNetworkImage(
                            imageUrl: sectionBannerList?[index].landscape ?? "",
                            fit: BoxFit.fill,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(0),
                          width: MediaQuery.of(context).size.width,
                          height: Dimens.homeBanner,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.center,
                              end: Alignment.bottomCenter,
                              colors: [
                                transparentColor,
                                transparentColor,
                                appBgColor,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 0,
            child: Consumer<SectionDataProvider>(
              builder: (context, sectionDataProvider, child) {
                return AnimatedSmoothIndicator(
                  count: (sectionBannerList?.length ?? 0),
                  activeIndex: sectionDataProvider.cBannerIndex ?? 0,
                  effect: const ScrollingDotsEffect(
                    spacing: 8,
                    radius: 4,
                    activeDotColor: dotsActiveColor,
                    dotColor: dotsDefaultColor,
                    dotHeight: 8,
                    dotWidth: 8,
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _webHomeBanner(List<banner.Result>? sectionBannerList) {
    if ((sectionBannerList?.length ?? 0) > 0) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: Dimens.homeWebBanner,
        child: CarouselSlider.builder(
          itemCount: (sectionBannerList?.length ?? 0),
          carouselController: carouselController,
          options: CarouselOptions(
            initialPage: 0,
            height: Dimens.homeWebBanner,
            enlargeCenterPage: false,
            autoPlay: true,
            autoPlayCurve: Curves.easeInOutQuart,
            enableInfiniteScroll: true,
            autoPlayInterval: Duration(milliseconds: Constant.bannerDuration),
            autoPlayAnimationDuration:
                Duration(milliseconds: Constant.animationDuration),
            viewportFraction: 0.95,
            onPageChanged: (val, _) async {
              await sectionDataProvider.setCurrentBanner(val);
            },
          ),
          itemBuilder: (BuildContext context, int index, int pageViewIndex) {
            return InkWell(
              focusColor: white,
              borderRadius: BorderRadius.circular(4),
              onTap: () {
                log("Clicked on index ==> $index");
                openDetailPage(
                  (sectionBannerList?[index].videoType ?? 0) == 2
                      ? "showdetail"
                      : "videodetail",
                  sectionBannerList?[index].id ?? 0,
                  sectionBannerList?[index].upcomingType ?? 0,
                  sectionBannerList?[index].videoType ?? 0,
                  sectionBannerList?[index].typeId ?? 0,
                );
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Stack(
                    alignment: AlignmentDirectional.centerEnd,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width *
                            (Dimens.webBannerImgPr),
                        height: Dimens.homeWebBanner,
                        child: MyNetworkImage(
                          imageUrl: sectionBannerList?[index].landscape ?? "",
                          fit: BoxFit.fill,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width,
                        height: Dimens.homeWebBanner,
                        alignment: Alignment.centerLeft,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              lightBlack,
                              lightBlack,
                              lightBlack,
                              lightBlack,
                              transparentColor,
                              transparentColor,
                              transparentColor,
                              transparentColor,
                              transparentColor,
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: Dimens.homeWebBanner,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width *
                                  (1.0 - Dimens.webBannerImgPr),
                              constraints: const BoxConstraints(minHeight: 0),
                              padding:
                                  const EdgeInsets.fromLTRB(35, 50, 55, 35),
                              alignment: Alignment.centerLeft,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    color: white,
                                    text: sectionBannerList?[index].name ?? "",
                                    textalign: TextAlign.start,
                                    fontsizeNormal: 14,
                                    fontsizeWeb: 25,
                                    fontweight: FontWeight.w700,
                                    multilanguage: false,
                                    maxline: 2,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  ),
                                  const SizedBox(height: 12),
                                  MyText(
                                    color: whiteLight,
                                    text: sectionBannerList?[index]
                                            .categoryName ??
                                        "",
                                    textalign: TextAlign.start,
                                    fontsizeNormal: 14,
                                    fontweight: FontWeight.w600,
                                    fontsizeWeb: 15,
                                    multilanguage: false,
                                    maxline: 2,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: MyText(
                                      color: whiteLight,
                                      text: sectionBannerList?[index]
                                              .description ??
                                          "",
                                      textalign: TextAlign.start,
                                      fontsizeNormal: 14,
                                      fontweight: FontWeight.w600,
                                      fontsizeWeb: 15,
                                      multilanguage: false,
                                      maxline:
                                          (MediaQuery.of(context).size.width <
                                                  1000)
                                              ? 2
                                              : 5,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget continueWatchingLayout(List<ContinueWatching>? continueWatchingList) {
    if ((continueWatchingList?.length ?? 0) > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: MyText(
              color: white,
              text: "continuewatching",
              multilanguage: true,
              textalign: TextAlign.center,
              fontsizeNormal: 14,
              fontsizeWeb: 16,
              fontweight: FontWeight.w600,
              maxline: 1,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: Dimens.heightContiLand,
            child: ListView.separated(
              itemCount: (continueWatchingList?.length ?? 0),
              shrinkWrap: true,
              padding: const EdgeInsets.only(left: 20, right: 20),
              scrollDirection: Axis.horizontal,
              physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
              separatorBuilder: (context, index) => const SizedBox(
                width: 5,
              ),
              itemBuilder: (BuildContext context, int index) {
                return Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    InkWell(
                      focusColor: white,
                      borderRadius: BorderRadius.circular(4),
                      onTap: () {
                        log("Clicked on index ==> $index");
                        openDetailPage(
                          (continueWatchingList?[index].videoType ?? 0) == 2
                              ? "showdetail"
                              : "videodetail",
                          (continueWatchingList?[index].videoType ?? 0) == 2
                              ? (continueWatchingList?[index].showId ?? 0)
                              : (continueWatchingList?[index].id ?? 0),
                          0,
                          continueWatchingList?[index].videoType ?? 0,
                          continueWatchingList?[index].typeId ?? 0,
                        );
                      },
                      child: Container(
                        width: Dimens.widthContiLand,
                        height: Dimens.heightContiLand,
                        alignment: Alignment.center,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: MyNetworkImage(
                            imageUrl:
                                continueWatchingList?[index].landscape ?? "",
                            fit: BoxFit.cover,
                            imgHeight: MediaQuery.of(context).size.height,
                            imgWidth: MediaQuery.of(context).size.width,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 10, bottom: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () async {
                              openPlayer(
                                  "ContinueWatch", index, continueWatchingList);
                            },
                            child: MyImage(
                              width: 30,
                              height: 30,
                              imagePath: "play.png",
                            ),
                          ),
                        ),
                        Container(
                          width: Dimens.widthContiLand,
                          constraints: const BoxConstraints(minWidth: 0),
                          padding: const EdgeInsets.all(3),
                          child: LinearPercentIndicator(
                            padding: const EdgeInsets.all(0),
                            barRadius: const Radius.circular(2),
                            lineHeight: 4,
                            percent: Utils.getPercentage(
                                continueWatchingList?[index].videoDuration ?? 0,
                                continueWatchingList?[index].stopTime ?? 0),
                            backgroundColor: secProgressColor,
                            progressColor: primaryColor,
                          ),
                        ),
                        (continueWatchingList?[index].releaseTag != null &&
                                (continueWatchingList?[index].releaseTag ?? "")
                                    .isNotEmpty)
                            ? Container(
                                decoration: const BoxDecoration(
                                  color: black,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(4),
                                    bottomRight: Radius.circular(4),
                                  ),
                                  shape: BoxShape.rectangle,
                                ),
                                alignment: Alignment.center,
                                width: Dimens.widthContiLand,
                                height: 15,
                                child: MyText(
                                  color: white,
                                  multilanguage: false,
                                  text:
                                      continueWatchingList?[index].releaseTag ??
                                          "",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: 6,
                                  fontweight: FontWeight.w700,
                                  fontsizeWeb: 10,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget setSectionByType(List<list.Result>? sectionList) {
    return ListView.builder(
      itemCount: sectionList?.length ?? 0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        if (sectionList?[index].data != null &&
            (sectionList?[index].data?.length ?? 0) > 0) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: MyText(
                  color: white,
                  text: sectionList?[index].title.toString() ?? "",
                  textalign: TextAlign.center,
                  fontsizeNormal: 14,
                  fontweight: FontWeight.w600,
                  fontsizeWeb: 16,
                  multilanguage: false,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: getRemainingDataHeight(
                  sectionList?[index].videoType.toString() ?? "",
                  sectionList?[index].screenLayout ?? "",
                ),
                child: setSectionData(sectionList: sectionList, index: index),
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget setSectionData(
      {required List<list.Result>? sectionList, required int index}) {
    /* video_type =>  1-video,  2-show,  3-language,  4-category */
    /* screen_layout =>  landscape, potrait, square */
    if ((sectionList?[index].videoType ?? 0) == 1) {
      if ((sectionList?[index].screenLayout ?? "") == "landscape") {
        return landscape(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "potrait") {
        return portrait(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "square") {
        return square(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else {
        return landscape(
            sectionList?[index].upcomingType, sectionList?[index].data);
      }
    } else if ((sectionList?[index].videoType ?? 0) == 2) {
      if ((sectionList?[index].screenLayout ?? "") == "landscape") {
        return landscape(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "potrait") {
        return portrait(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "square") {
        return square(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else {
        return landscape(
            sectionList?[index].upcomingType, sectionList?[index].data);
      }
    } else if ((sectionList?[index].videoType ?? 0) == 3) {
      return languageLayout(
          sectionList?[index].typeId ?? 0, sectionList?[index].data);
    } else if ((sectionList?[index].videoType ?? 0) == 4) {
      return genresLayout(
          sectionList?[index].typeId ?? 0, sectionList?[index].data);
    } else {
      if ((sectionList?[index].screenLayout ?? "") == "landscape") {
        return landscape(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "potrait") {
        return portrait(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "square") {
        return square(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else {
        return landscape(
            sectionList?[index].upcomingType, sectionList?[index].data);
      }
    }
  }

  double getRemainingDataHeight(String? videoType, String? layoutType) {
    if (videoType == "1" || videoType == "2") {
      if (layoutType == "landscape") {
        return Dimens.heightLand;
      } else if (layoutType == "potrait") {
        return Dimens.heightPort;
      } else if (layoutType == "square") {
        return Dimens.heightSquare;
      } else {
        return Dimens.heightLand;
      }
    } else if (videoType == "3" || videoType == "4") {
      return Dimens.heightLangGen;
    } else {
      if (layoutType == "landscape") {
        return Dimens.heightLand;
      } else if (layoutType == "potrait") {
        return Dimens.heightPort;
      } else if (layoutType == "square") {
        return Dimens.heightSquare;
      } else {
        return Dimens.heightLand;
      }
    }
  }

  Widget landscape(int? upcomingType, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightLand,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              log("Clicked on index ==> $index");
              openDetailPage(
                (sectionDataList?[index].videoType ?? 0) == 2
                    ? "showdetail"
                    : "videodetail",
                sectionDataList?[index].id ?? 0,
                upcomingType ?? 0,
                sectionDataList?[index].videoType ?? 0,
                sectionDataList?[index].typeId ?? 0,
              );
            },
            child: Container(
              width: Dimens.widthLand,
              height: Dimens.heightLand,
              alignment: Alignment.center,
              padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: MyNetworkImage(
                  imageUrl: sectionDataList?[index].landscape.toString() ?? "",
                  fit: BoxFit.cover,
                  imgHeight: MediaQuery.of(context).size.height,
                  imgWidth: MediaQuery.of(context).size.width,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget portrait(int? upcomingType, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightPort,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              log("Clicked on index ==> $index");
              openDetailPage(
                (sectionDataList?[index].videoType ?? 0) == 2
                    ? "showdetail"
                    : "videodetail",
                sectionDataList?[index].id ?? 0,
                upcomingType ?? 0,
                sectionDataList?[index].videoType ?? 0,
                sectionDataList?[index].typeId ?? 0,
              );
            },
            child: Container(
              width: Dimens.widthPort,
              height: Dimens.heightPort,
              padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: MyNetworkImage(
                  imageUrl: sectionDataList?[index].thumbnail.toString() ?? "",
                  fit: BoxFit.cover,
                  imgHeight: MediaQuery.of(context).size.height,
                  imgWidth: MediaQuery.of(context).size.width,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget square(int? upcomingType, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightSquare,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.only(left: 20, right: 20),
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              log("Clicked on index ==> $index");
              openDetailPage(
                (sectionDataList?[index].videoType ?? 0) == 2
                    ? "showdetail"
                    : "videodetail",
                sectionDataList?[index].id ?? 0,
                upcomingType ?? 0,
                sectionDataList?[index].videoType ?? 0,
                sectionDataList?[index].typeId ?? 0,
              );
            },
            child: Container(
              width: Dimens.widthSquare,
              height: Dimens.heightSquare,
              alignment: Alignment.center,
              padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: MyNetworkImage(
                  imageUrl: sectionDataList?[index].thumbnail.toString() ?? "",
                  fit: BoxFit.cover,
                  imgHeight: MediaQuery.of(context).size.height,
                  imgWidth: MediaQuery.of(context).size.width,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget languageLayout(int? typeId, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightLangGen,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              InkWell(
                focusColor: white,
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  log("Clicked on index ==> $index");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return VideosByID(
                          sectionDataList?[index].id ?? 0,
                          typeId ?? 0,
                          sectionDataList?[index].name ?? "",
                          "ByLanguage",
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  width: Dimens.widthLangGen,
                  height: Dimens.heightLangGen,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                  child: Stack(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: MyNetworkImage(
                          imageUrl:
                              sectionDataList?[index].image.toString() ?? "",
                          fit: BoxFit.fill,
                          imgHeight: MediaQuery.of(context).size.height,
                          imgWidth: MediaQuery.of(context).size.width,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width,
                        height: Dimens.heightLangGen,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.center,
                            end: Alignment.bottomCenter,
                            colors: [
                              transparentColor,
                              transparentColor,
                              appBgColor,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(3),
                child: MyText(
                  color: white,
                  text: sectionDataList?[index].name.toString() ?? "",
                  textalign: TextAlign.center,
                  fontsizeNormal: 14,
                  fontweight: FontWeight.w600,
                  fontsizeWeb: 15,
                  multilanguage: false,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget genresLayout(int? typeId, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightLangGen,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              InkWell(
                focusColor: white,
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  log("Clicked on index ==> $index");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return VideosByID(
                          sectionDataList?[index].id ?? 0,
                          typeId ?? 0,
                          sectionDataList?[index].name ?? "",
                          "ByCategory",
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  width: Dimens.widthLangGen,
                  height: Dimens.heightLangGen,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                  child: Stack(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: MyNetworkImage(
                          imageUrl:
                              sectionDataList?[index].image.toString() ?? "",
                          fit: BoxFit.fill,
                          imgHeight: MediaQuery.of(context).size.height,
                          imgWidth: MediaQuery.of(context).size.width,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width,
                        height: Dimens.heightLangGen,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.center,
                            end: Alignment.bottomCenter,
                            colors: [
                              transparentColor,
                              transparentColor,
                              appBgColor,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(3),
                child: MyText(
                  color: white,
                  text: sectionDataList?[index].name.toString() ?? "",
                  textalign: TextAlign.center,
                  fontsizeNormal: 14,
                  fontweight: FontWeight.w600,
                  fontsizeWeb: 15,
                  multilanguage: false,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /* ========= Open Player ========= */
  openPlayer(String playType, int index,
      List<ContinueWatching>? continueWatchingList) async {
    debugPrint("index ==========> $index");
    /* Set-up Quality URLs */
    Utils.setQualityURLs(
      video320: (continueWatchingList?[index].video320 ?? ""),
      video480: (continueWatchingList?[index].video480 ?? ""),
      video720: (continueWatchingList?[index].video720 ?? ""),
      video1080: (continueWatchingList?[index].video1080 ?? ""),
    );
    var isContinues = await Utils.openPlayer(
      context: context,
      playType:
          (continueWatchingList?[index].videoType ?? 0) == 2 ? "Show" : "Video",
      videoId: (continueWatchingList?[index].videoType ?? 0) == 2
          ? (continueWatchingList?[index].showId ?? 0)
          : (continueWatchingList?[index].id ?? 0),
      videoType: continueWatchingList?[index].videoType ?? 0,
      typeId: continueWatchingList?[index].typeId ?? 0,
      otherId: continueWatchingList?[index].typeId ?? 0,
      videoUrl: continueWatchingList?[index].video320 ?? "",
      trailerUrl: continueWatchingList?[index].trailerUrl ?? "",
      uploadType: continueWatchingList?[index].videoUploadType ?? "",
      videoThumb: continueWatchingList?[index].landscape ?? "",
      vStopTime: continueWatchingList?[index].stopTime ?? 0,
    );
    if (isContinues != null && isContinues == true) {
      getTabData(0, homeProvider.sectionTypeModel.result);
      Future.delayed(Duration.zero).then((value) {
        if (!mounted) return;
        setState(() {});
      });
    }
  }
  /* ========= Open Player ========= */
}
