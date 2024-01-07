import 'dart:developer';

import 'package:portfolio/shimmer/shimmerutils.dart';
import 'package:portfolio/utils/dimens.dart';
import 'package:portfolio/webwidget/footerweb.dart';
import 'package:portfolio/widget/nodata.dart';
import 'package:portfolio/provider/rentstoreprovider.dart';
import 'package:portfolio/utils/color.dart';
import 'package:portfolio/utils/constant.dart';
import 'package:portfolio/utils/utils.dart';
import 'package:portfolio/widget/mynetworkimg.dart';
import 'package:portfolio/widget/mytext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class RentStore extends StatefulWidget {
  const RentStore({Key? key}) : super(key: key);

  @override
  State<RentStore> createState() => RentStoreState();
}

class RentStoreState extends State<RentStore> {
  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    final rentStoreProvider =
        Provider.of<RentStoreProvider>(context, listen: false);
    await rentStoreProvider.getRentVideoList();
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || Constant.isTV) {
      return Scaffold(
        backgroundColor: appBgColor,
        body: SafeArea(
          child: _buildRentStore(),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: appBgColor,
        appBar: Utils.myAppBar(context, "stor", true),
        body: SafeArea(
          child: _buildRentStore(),
        ),
      );
    }
  }

  Widget _buildRentStore() {
    final rentStoreProvider =
        Provider.of<RentStoreProvider>(context, listen: false);
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints.expand(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: (rentStoreProvider.loading)
            ? ShimmerUtils.buildRentShimmer(
                context, Dimens.heightLand, Dimens.widthLand)
            : ((rentStoreProvider.rentModel.status == 200)
                ? Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildRentVideos(),
                      const SizedBox(height: 22),
                      _buildRentTVShows(),
                      const SizedBox(height: 20),

                      /* Web Footer */
                      kIsWeb ? const FooterWeb() : const SizedBox.shrink(),
                    ],
                  )
                : const NoData(title: '', subTitle: '')),
      ),
    );
  }

  Widget _buildRentVideos() {
    final rentStoreProvider =
        Provider.of<RentStoreProvider>(context, listen: false);
    if (rentStoreProvider.rentModel.video != null) {
      return Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(left: 20, right: 20),
            constraints: const BoxConstraints(minHeight: 30),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                FittedBox(
                  child: Container(
                    constraints:
                        const BoxConstraints(minHeight: 20, minWidth: 20),
                    padding: const EdgeInsets.all(3),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: complimentryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: MyText(
                      color: white,
                      text: Constant.currencySymbol,
                      textalign: TextAlign.center,
                      fontsizeNormal: 11,
                      fontsizeWeb: 12,
                      multilanguage: false,
                      maxline: 1,
                      fontweight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                MyText(
                  color: white,
                  text: "rentvideo",
                  multilanguage: true,
                  textalign: TextAlign.center,
                  fontsizeNormal: 14,
                  fontsizeWeb: 16,
                  maxline: 1,
                  fontweight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
                const SizedBox(width: 5),
                MyText(
                  color: otherColor,
                  text: "(${(rentStoreProvider.rentModel.video?.length ?? 0)}",
                  textalign: TextAlign.center,
                  multilanguage: false,
                  fontsizeNormal: 11,
                  fontsizeWeb: 12,
                  maxline: 1,
                  fontweight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
                const SizedBox(width: 5),
                MyText(
                  color: otherColor,
                  text: (rentStoreProvider.rentModel.video?.length ?? 0) <= 1
                      ? "video)"
                      : "videos)",
                  multilanguage: false,
                  textalign: TextAlign.center,
                  fontsizeNormal: 11,
                  fontsizeWeb: 12,
                  maxline: 1,
                  fontweight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: (rentStoreProvider.rentModel.video?.length ?? 0) == 1
                ? Dimens.heightLand
                : ((rentStoreProvider.rentModel.video?.length ?? 0) > 1 &&
                        (rentStoreProvider.rentModel.video?.length ?? 0) < 7)
                    ? (Dimens.heightLand * 2)
                    : (rentStoreProvider.rentModel.video?.length ?? 0) > 6
                        ? (Dimens.heightLand * 3)
                        : (Dimens.heightLand * 2),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: AlignedGridView.count(
                shrinkWrap: true,
                crossAxisCount: (rentStoreProvider.rentModel.video?.length ??
                            0) ==
                        1
                    ? 1
                    : ((rentStoreProvider.rentModel.video?.length ?? 0) > 1 &&
                            (rentStoreProvider.rentModel.video?.length ?? 0) <
                                7)
                        ? 2
                        : (rentStoreProvider.rentModel.video?.length ?? 0) > 6
                            ? 3
                            : 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                itemCount: (rentStoreProvider.rentModel.video?.length ?? 0),
                padding: const EdgeInsets.only(left: 20, right: 20),
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int position) {
                  return Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      focusColor: white,
                      borderRadius: BorderRadius.circular(4),
                      onTap: () {
                        log("Clicked on position ==> $position");
                        Utils.openDetails(
                          context: context,
                          videoId:
                              rentStoreProvider.rentModel.video?[position].id ??
                                  0,
                          upcomingType: 0,
                          videoType: rentStoreProvider
                                  .rentModel.video?[position].videoType ??
                              0,
                          typeId: rentStoreProvider
                                  .rentModel.video?[position].typeId ??
                              0,
                        );
                      },
                      child: Container(
                        padding: !(kIsWeb || Constant.isTV)
                            ? const EdgeInsets.all(0)
                            : const EdgeInsets.all(2.0),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Container(
                              width: Dimens.widthLand,
                              height: Dimens.heightLand,
                              alignment: Alignment.center,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: MyNetworkImage(
                                  imageUrl: rentStoreProvider
                                          .rentModel.video?[position].landscape
                                          .toString() ??
                                      "",
                                  fit: BoxFit.cover,
                                  imgHeight: MediaQuery.of(context).size.height,
                                  imgWidth: MediaQuery.of(context).size.width,
                                ),
                              ),
                            ),
                            FittedBox(
                              child: Container(
                                constraints: const BoxConstraints(
                                  minHeight: 15,
                                  minWidth: 30,
                                ),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(3),
                                      topRight: Radius.circular(4),
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(3)),
                                ),
                                child: MyText(
                                  color: black,
                                  text:
                                      "${Constant.currencySymbol} ${rentStoreProvider.rentModel.video?[position].rentPrice.toString() ?? "0"}",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: 10,
                                  fontsizeWeb: 12,
                                  fontweight: FontWeight.w700,
                                  maxline: 1,
                                  multilanguage: false,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    } else {
      return const NoData(title: '', subTitle: '');
    }
  }

  Widget _buildRentTVShows() {
    final rentStoreProvider =
        Provider.of<RentStoreProvider>(context, listen: false);
    if (rentStoreProvider.rentModel.tvshow != null) {
      return Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            constraints: const BoxConstraints(minHeight: 30),
            padding: const EdgeInsets.only(left: 20, right: 20),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                FittedBox(
                  child: Container(
                    constraints:
                        const BoxConstraints(minHeight: 20, minWidth: 20),
                    padding: const EdgeInsets.all(3),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: complimentryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: MyText(
                      color: white,
                      text: Constant.currencySymbol,
                      textalign: TextAlign.center,
                      multilanguage: false,
                      fontsizeNormal: 11,
                      fontsizeWeb: 12,
                      maxline: 1,
                      fontweight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                MyText(
                  color: white,
                  text: "rentshow",
                  textalign: TextAlign.center,
                  multilanguage: true,
                  fontsizeNormal: 14,
                  fontsizeWeb: 16,
                  maxline: 1,
                  fontweight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
                const SizedBox(width: 5),
                MyText(
                  color: otherColor,
                  text: "(${(rentStoreProvider.rentModel.tvshow?.length ?? 0)}",
                  textalign: TextAlign.center,
                  fontsizeNormal: 11,
                  fontsizeWeb: 12,
                  maxline: 1,
                  multilanguage: false,
                  fontweight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
                const SizedBox(width: 5),
                MyText(
                  color: otherColor,
                  text: (rentStoreProvider.rentModel.video?.length ?? 0) <= 1
                      ? "show)"
                      : "shows)",
                  textalign: TextAlign.center,
                  multilanguage: false,
                  fontsizeNormal: 11,
                  fontsizeWeb: 12,
                  maxline: 1,
                  fontweight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: (rentStoreProvider.rentModel.tvshow?.length ?? 0) == 1
                ? Dimens.heightLand
                : ((rentStoreProvider.rentModel.tvshow?.length ?? 0) > 1 &&
                        (rentStoreProvider.rentModel.tvshow?.length ?? 0) < 7)
                    ? (Dimens.heightLand * 2)
                    : (rentStoreProvider.rentModel.tvshow?.length ?? 0) > 6
                        ? (Dimens.heightLand * 3)
                        : (Dimens.heightLand * 2),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: AlignedGridView.count(
                shrinkWrap: true,
                crossAxisCount: (rentStoreProvider.rentModel.tvshow?.length ??
                            0) ==
                        1
                    ? 1
                    : ((rentStoreProvider.rentModel.tvshow?.length ?? 0) > 1 &&
                            (rentStoreProvider.rentModel.tvshow?.length ?? 0) <
                                7)
                        ? 2
                        : (rentStoreProvider.rentModel.tvshow?.length ?? 0) > 6
                            ? 3
                            : 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                itemCount: (rentStoreProvider.rentModel.tvshow?.length ?? 0),
                padding: const EdgeInsets.only(left: 20, right: 20),
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int position) {
                  return Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      focusColor: white,
                      borderRadius: BorderRadius.circular(4),
                      onTap: () {
                        log("Clicked on position ==> $position");
                        Utils.openDetails(
                          context: context,
                          videoId: rentStoreProvider
                                  .rentModel.tvshow?[position].id ??
                              0,
                          upcomingType: 0,
                          videoType: rentStoreProvider
                                  .rentModel.tvshow?[position].videoType ??
                              0,
                          typeId: rentStoreProvider
                                  .rentModel.tvshow?[position].typeId ??
                              0,
                        );
                      },
                      child: Container(
                        padding: !(kIsWeb || Constant.isTV)
                            ? const EdgeInsets.all(0)
                            : const EdgeInsets.all(2.0),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Container(
                              width: Dimens.widthLand,
                              height: Dimens.heightLand,
                              alignment: Alignment.center,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: MyNetworkImage(
                                  imageUrl: rentStoreProvider
                                          .rentModel.tvshow?[position].landscape
                                          .toString() ??
                                      "",
                                  fit: BoxFit.cover,
                                  imgHeight: MediaQuery.of(context).size.height,
                                  imgWidth: MediaQuery.of(context).size.width,
                                ),
                              ),
                            ),
                            FittedBox(
                              child: Container(
                                constraints: const BoxConstraints(
                                  minHeight: 15,
                                  minWidth: 30,
                                ),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(3),
                                      topRight: Radius.circular(4),
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(3)),
                                ),
                                child: MyText(
                                  color: black,
                                  text:
                                      "${Constant.currencySymbol} ${rentStoreProvider.rentModel.tvshow?[position].rentPrice.toString() ?? "0"}",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: 10,
                                  fontsizeWeb: 12,
                                  multilanguage: false,
                                  fontweight: FontWeight.w700,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    } else {
      return const NoData(title: '', subTitle: '');
    }
  }
}
