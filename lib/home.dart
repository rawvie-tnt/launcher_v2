import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import 'home_controller.dart';

Widget loadingIndicator() {
  return Lottie.asset(
    'assets/lottie/empty.json',
    height: 120,
    width: 120,
  );
}

class Home extends StatelessWidget {
  Home({super.key});
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Obx(
        () => Scaffold(
          backgroundColor: ColorFromRGB(controller.background.value),
          body: SafeArea(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StreamBuilder(
                            stream: Stream.periodic(const Duration(seconds: 1)),
                            builder: (context, snapshot) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('hh:mm a').format(
                                      DateTime.now(),
                                    ),
                                    style: TextStyle(
                                      fontFamily: 'Oddlini',
                                      fontSize: 28,
                                      color: ColorFromRGB(
                                        controller.labelColor.value,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    DateFormat.MMMMEEEEd()
                                        .format(DateTime.now()),
                                    style: TextStyle(
                                      fontFamily: 'Oddlini',
                                      fontSize: 12,
                                      color: ColorFromRGB(
                                        controller.labelColor.value,
                                      ),
                                    ),
                                  )
                                ],
                              );
                            },
                          ),
                          IconButton(
                            onPressed: () => controller.showSettings(),
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.settings,
                              color: ColorFromRGB(
                                controller.labelColor.value,
                              ),
                            ),
                            splashRadius: Material.defaultSplashRadius / 2,
                          )
                        ],
                      ),
                      TextField(
                        onChanged: (value) => controller.searchApp(value),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 12),
                          hintText: 'Search by Name',
                          hintStyle: TextStyle(
                            color: ColorFromRGB(controller.labelColor.value),
                            fontFamily: 'Oddlini',
                            fontSize: 10,
                          ),
                          isDense: true,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: ColorFromRGB(controller.border.value),
                              width: 1,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: ColorFromRGB(controller.border.value),
                              width: 1,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                            fontSize: 14, fontFamily: 'Oddlini'),
                      ),
                      Flexible(
                        child: controller.loadingApps.value
                            ? Center(
                                child: loadingIndicator(),
                              )
                            : GridView.count(
                                crossAxisCount: controller.gridCount.value,
                                physics: const BouncingScrollPhysics(),
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                shrinkWrap: true,
                                childAspectRatio:
                                    5 / controller.gridCount.value,
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 100),
                                children: controller.apps.map(
                                  (app) {
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(
                                          controller.borderRadius.value),
                                      onTap: () =>
                                          DeviceApps.openApp(app.package),
                                      onLongPress: () =>
                                          controller.handleLongPress(app),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Container(
                                          height: 100,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              controller.borderRadius.value,
                                            ),
                                            border: Border.all(
                                              color: ColorFromRGB(
                                                controller.border.value,
                                              ),
                                              width: 1.2,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5.0,
                                            ),
                                            child:
                                                controller.gridCount.value > 3
                                                    ? GridAppVertical(
                                                        app: app,
                                                        labelColor: controller
                                                            .labelColor.value,
                                                        labelSize: controller
                                                            .labelSize.value,
                                                      )
                                                    : GridApp(
                                                        app: app,
                                                        labelColor: controller
                                                            .labelColor.value,
                                                        labelSize: controller
                                                            .labelSize.value,
                                                      ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
                DraggableScrollableSheet(
                  maxChildSize: 0.6,
                  initialChildSize: 0.1,
                  minChildSize: 0.1,
                  snapSizes: const [0.1, 0.6],
                  snap: true,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Obx(
                      () => Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: ColorFromRGB(controller.dockBackground.value),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            topRight: Radius.circular(14),
                          ),
                        ),
                        child: CustomScrollView(
                          controller: scrollController,
                          slivers: <Widget>[
                            SliverAppBar(
                              toolbarHeight: 70,
                              pinned: true,
                              backgroundColor:
                                  ColorFromRGB(controller.dockBackground.value),
                              actions: [
                                Obx(
                                  () => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Battery ${controller.battery.value}% ${controller.charging.value ? '(Charging)' : ''}',
                                          style: TextStyle(
                                            fontFamily: 'Oddlini',
                                            color: ColorFromRGB(
                                              controller.dockLabelColor.value,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          controller.ip.value,
                                          style: TextStyle(
                                            fontFamily: 'Oddlini',
                                            color: ColorFromRGB(
                                              controller.dockLabelColor.value,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'RAM ${controller.totalRam.value.toStringAsFixed(0)} (free ${controller.freeRaam.value.toStringAsFixed(1)}) GB',
                                          style: TextStyle(
                                            fontFamily: 'Oddlini',
                                            color: ColorFromRGB(
                                              controller.dockLabelColor.value,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                              title: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () => controller.launchPhone(),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white),
                                          padding: const EdgeInsets.all(8),
                                          margin:
                                              const EdgeInsets.only(right: 5),
                                          child: const Icon(
                                            Icons.call_rounded,
                                            color: Colors.black,
                                            size: 30,
                                          ),
                                        ),
                                        const Text(
                                          'Phone\n&Contacts',
                                          style:
                                              TextStyle(fontFamily: "Oddlini"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(14.0),
                                child: Text(
                                  'Favourites',
                                  style: TextStyle(
                                    fontFamily: 'Oddlini',
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            Obx(
                              () => controller.loadingApps.value
                                  ? SliverToBoxAdapter(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          top: Get.height * 0.12,
                                        ),
                                        child: Center(
                                          child: loadingIndicator(),
                                        ),
                                      ),
                                    )
                                  : controller.favorites.value.isEmpty
                                      ? SliverToBoxAdapter(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              top: Get.height * 0.12,
                                            ),
                                            child: Center(
                                              child: Column(
                                                children: [
                                                  LottieBuilder.asset(
                                                    'assets/lottie/empty.json',
                                                  ),
                                                  const Text(
                                                    'No items added to favourite',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: 'Oddlini',
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : SliverPadding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          sliver: SliverGrid.count(
                                            crossAxisCount:
                                                controller.gridCount.value,
                                            mainAxisSpacing: 10,
                                            crossAxisSpacing: 10,
                                            childAspectRatio:
                                                5 / controller.gridCount.value,
                                            children:
                                                controller.favorites.value.map(
                                              (name) {
                                                var app = controller
                                                    .getAppFromPackage(name);
                                                if (app != null) {
                                                  return InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      controller
                                                          .borderRadius.value,
                                                    ),
                                                    onTap: () =>
                                                        DeviceApps.openApp(
                                                      app.package,
                                                    ),
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: Container(
                                                        height: 100,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            controller
                                                                .borderRadius
                                                                .value,
                                                          ),
                                                          border: Border.all(
                                                            color: ColorFromRGB(
                                                              controller
                                                                  .dockBorder
                                                                  .value,
                                                            ),
                                                            width: 1.2,
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      5.0),
                                                          child: controller
                                                                      .gridCount
                                                                      .value >
                                                                  3
                                                              ? GridAppVertical(
                                                                  app: app,
                                                                  labelColor:
                                                                      controller
                                                                          .dockLabelColor
                                                                          .value,
                                                                  labelSize:
                                                                      controller
                                                                          .labelSize
                                                                          .value,
                                                                )
                                                              : GridApp(
                                                                  app: app,
                                                                  labelColor:
                                                                      controller
                                                                          .dockLabelColor
                                                                          .value,
                                                                  labelSize:
                                                                      controller
                                                                          .labelSize
                                                                          .value,
                                                                ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  return Container();
                                                }
                                              },
                                            ).toList(),
                                          ),
                                        ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GridApp extends StatelessWidget {
  final App app;
  final RgbColor labelColor;
  final double labelSize;
  const GridApp(
      {super.key,
      required this.app,
      required this.labelColor,
      required this.labelSize});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        app.icon != null
            ? Image.memory(
                app.icon!,
                height: 38,
                width: 38,
                gaplessPlayback: true,
              )
            : const Icon(
                FontAwesomeIcons.android,
              ),
        const SizedBox(
          width: 5,
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                app.name,
                style: TextStyle(
                  color: ColorFromRGB(
                    labelColor,
                  ),
                  fontFamily: 'Oddlini',
                  fontSize: labelSize,
                ),
              ),
              Text(
                app.version ?? '-',
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ColorFromRGB(
                    labelColor,
                  ),
                  fontFamily: 'Oddlini',
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        // Spacer()
      ],
    );
  }
}

class GridAppVertical extends StatelessWidget {
  final App app;
  final RgbColor labelColor;
  final double labelSize;
  const GridAppVertical(
      {super.key,
      required this.app,
      required this.labelColor,
      required this.labelSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 5,
        ),
        app.icon != null
            ? Image.memory(
                app.icon!,
                height: 30,
                width: 30,
                gaplessPlayback: true,
              )
            : const Icon(
                FontAwesomeIcons.android,
              ),
        const SizedBox(
          width: 3,
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                app.name,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ColorFromRGB(
                    labelColor,
                  ),
                  fontFamily: 'Oddlini',
                  fontSize: labelSize,
                ),
              ),
              Text(
                app.version ?? '-',
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ColorFromRGB(
                    labelColor,
                  ),
                  fontFamily: 'Oddlini',
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        // Spacer()
      ],
    );
  }
}
