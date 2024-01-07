import 'dart:developer';

import 'package:portfolio/model/sectiondetailmodel.dart';
import 'package:portfolio/pages/castdetails.dart';
import 'package:portfolio/utils/color.dart';
import 'package:portfolio/utils/constant.dart';
import 'package:portfolio/utils/dimens.dart';
import 'package:portfolio/widget/mytext.dart';
import 'package:portfolio/widget/myusernetworkimg.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class CastCrew extends StatefulWidget {
  final List<Cast>? castList;
  const CastCrew({required this.castList, Key? key}) : super(key: key);

  @override
  State<CastCrew> createState() => _CastCrewState();
}

class _CastCrewState extends State<CastCrew> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 25),
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: MyText(
            color: white,
            text: "castandcrew",
            multilanguage: true,
            textalign: TextAlign.start,
            fontsizeNormal: 15,
            fontweight: FontWeight.w600,
            fontsizeWeb: 16,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 10),
                child: MyText(
                  color: otherColor,
                  text: "detailsfrom",
                  multilanguage: true,
                  textalign: TextAlign.center,
                  fontsizeNormal: 12,
                  fontweight: FontWeight.w500,
                  fontsizeWeb: 14,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.fromLTRB(5, 1, 5, 1),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: otherColor,
                    width: .7,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  shape: BoxShape.rectangle,
                ),
                child: MyText(
                  color: otherColor,
                  text: "IMDb",
                  multilanguage: false,
                  textalign: TextAlign.center,
                  fontsizeNormal: 12,
                  fontweight: FontWeight.w700,
                  fontsizeWeb: 13,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildCAndCLayout(),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 0.7,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          color: primaryColor,
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildCAndCLayout() {
    if (widget.castList != null && (widget.castList?.length ?? 0) > 0) {
      return Container(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
        child: ResponsiveGridList(
          minItemWidth: (kIsWeb || Constant.isTV)
              ? Dimens.widthCastWeb
              : Dimens.widthCast,
          verticalGridSpacing: 8,
          horizontalGridSpacing: 6,
          minItemsPerRow: 3,
          maxItemsPerRow: 6,
          listViewBuilderOptions: ListViewBuilderOptions(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(
            (widget.castList?.length ?? 0),
            (position) {
              return InkWell(
                borderRadius: BorderRadius.circular(8),
                focusColor: white,
                onTap: () {
                  log("Item Clicked! => $position");
                  if (kIsWeb || Constant.isTV) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CastDetails(
                          castID:
                              widget.castList?[position].id.toString() ?? ""),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.antiAlias,
                    children: <Widget>[
                      SizedBox(
                        height: (kIsWeb || Constant.isTV)
                            ? Dimens.heightCastWeb
                            : Dimens.heightCast,
                        width: MediaQuery.of(context).size.width,
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(Dimens.cardRadius),
                          child: MyUserNetworkImage(
                            imageUrl: widget.castList?[position].image ?? "",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width,
                        height: (kIsWeb || Constant.isTV)
                            ? Dimens.heightCastWeb
                            : Dimens.heightCast,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.center,
                            end: Alignment.bottomCenter,
                            colors: [
                              transparentColor,
                              blackTransparent,
                              black,
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: MyText(
                          multilanguage: false,
                          text: widget.castList?[position].name ?? "",
                          fontstyle: FontStyle.normal,
                          fontsizeNormal: 12,
                          fontweight: FontWeight.w500,
                          fontsizeWeb: 14,
                          maxline: 3,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          color: white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
