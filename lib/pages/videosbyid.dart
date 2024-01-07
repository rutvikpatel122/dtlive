import 'dart:async';
import 'dart:developer';

import 'package:portfolio/shimmer/shimmerutils.dart';
import 'package:portfolio/utils/dimens.dart';
import 'package:portfolio/utils/utils.dart';
import 'package:portfolio/webwidget/footerweb.dart';
import 'package:portfolio/widget/nodata.dart';
import 'package:portfolio/provider/videobyidprovider.dart';
import 'package:portfolio/utils/color.dart';
import 'package:portfolio/widget/mynetworkimg.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class VideosByID extends StatefulWidget {
  final String appBarTitle, layoutType;
  final int itemID, typeId;
  const VideosByID(
    this.itemID,
    this.typeId,
    this.appBarTitle,
    this.layoutType, {
    Key? key,
  }) : super(key: key);

  @override
  State<VideosByID> createState() => VideosByIDState();
}

class VideosByIDState extends State<VideosByID> {
  late VideoByIDProvider videoByIDProvider;

  @override
  void initState() {
    videoByIDProvider = Provider.of<VideoByIDProvider>(context, listen: false);
    super.initState();
    _getData();
  }

  _getData() async {
    if (widget.layoutType == "ByCategory") {
      await videoByIDProvider.getVideoByCategory(widget.itemID, widget.typeId);
    } else if (widget.layoutType == "ByLanguage") {
      await videoByIDProvider.getVideoByLanguage(widget.itemID, widget.typeId);
    }
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
    return Scaffold(
      backgroundColor: appBgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Utils.myAppBarWithBack(context, widget.appBarTitle, false),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                constraints: const BoxConstraints.expand(),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      videoByIDProvider.loading
                          ? ShimmerUtils.responsiveGrid(
                              context,
                              Dimens.heightLand,
                              Dimens.widthLand,
                              2,
                              kIsWeb ? 40 : 20)
                          : (videoByIDProvider.videoByIdModel.status == 200 &&
                                  videoByIDProvider.videoByIdModel.result !=
                                      null)
                              ? (videoByIDProvider
                                              .videoByIdModel.result?.length ??
                                          0) >
                                      0
                                  ? _buildVideoItem()
                                  : const NoData(
                                      title: '',
                                      subTitle: '',
                                    )
                              : const NoData(
                                  title: '',
                                  subTitle: '',
                                ),
                      const SizedBox(height: 20),

                      /* Web Footer */
                      (kIsWeb) ? const FooterWeb() : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoItem() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: ResponsiveGridList(
        minItemWidth: Dimens.widthLand,
        verticalGridSpacing: 8,
        horizontalGridSpacing: 8,
        minItemsPerRow: 2,
        maxItemsPerRow: 8,
        listViewBuilderOptions: ListViewBuilderOptions(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: List.generate(
          (videoByIDProvider.videoByIdModel.result?.length ?? 0),
          (position) {
            return InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () {
                log("Clicked on position ==> $position");
                Utils.openDetails(
                  context: context,
                  videoId:
                      videoByIDProvider.videoByIdModel.result?[position].id ??
                          0,
                  upcomingType: 0,
                  videoType: videoByIDProvider
                          .videoByIdModel.result?[position].videoType ??
                      0,
                  typeId: videoByIDProvider
                          .videoByIdModel.result?[position].typeId ??
                      0,
                );
              },
              child: Container(
                width: Dimens.widthLand,
                height: Dimens.heightLand,
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: MyNetworkImage(
                    imageUrl: videoByIDProvider
                            .videoByIdModel.result?[position].landscape
                            .toString() ??
                        "",
                    fit: BoxFit.cover,
                    imgHeight: MediaQuery.of(context).size.height,
                    imgWidth: MediaQuery.of(context).size.width,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
