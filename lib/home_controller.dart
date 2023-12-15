// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:battery_info/battery_info_plugin.dart';
import 'package:battery_info/enums/charging_status.dart';
import 'package:battery_info/model/android_battery_info.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:system_info2/system_info2.dart';
import 'package:wifi_info_plugin_plus/wifi_info_plugin_plus.dart';

class DockApp {
  IconData icon;
  String name;

  DockApp({required this.icon, required this.name});
}

Uint8List getImageBinary(dynamicList) {
  List<int> intList =
      dynamicList.cast<int>().toList(); //This is the magical line.
  Uint8List data = Uint8List.fromList(intList);
  return data;
}

class App {
  String name;
  String package;
  String? version;
  Uint8List? icon;

  App({required this.name, required this.package, this.version, this.icon});

  factory App.fromJson(Map<String, dynamic> json) => App(
        name: json['name'],
        package: json['package'],
        icon: getImageBinary(json['icon']),
        version: json['version'] ?? "",
      );

  App fromJson(Map<String, dynamic> json) => App(
        name: json['name'],
        package: json['package'],
        icon: getImageBinary(json['icon']),
        version: json['version'] ?? "",
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'package': package,
        'icon': icon,
        'version': version,
      };

  factory App.fromApplication(Application app) => App(
        name: app.appName,
        package: app.packageName,
        icon: app is ApplicationWithIcon ? app.icon : null,
        version: app.versionName ?? '-',
      );
}

class RgbColor {
  int red;
  int green;
  int blue;

  RgbColor({
    required this.red,
    required this.green,
    required this.blue,
  });

  factory RgbColor.fromJson(Map<String, dynamic> json) => RgbColor(
        red: json['red'],
        green: json['green'],
        blue: json['blue'],
      );

  RgbColor fromJson(Map<String, dynamic> json) => RgbColor(
        red: json['red'],
        green: json['green'],
        blue: json['blue'],
      );

  Map<String, dynamic> toJson() => {
        'red': red,
        'green': green,
        'blue': blue,
      };
}

Color ColorFromRGB(RgbColor color) {
  return Color.fromRGBO(color.red, color.green, color.blue, 1);
}

RgbColor RgbFromColor(Color color) {
  return RgbColor(red: color.red, green: color.green, blue: color.blue);
}

Map<String, RgbColor> defaultColors = {
  'background': RgbColor(red: 161, green: 245, blue: 159),
  'dockBackground': RgbColor(red: 0, green: 0, blue: 0),
  'border': RgbColor(red: 0, green: 0, blue: 0),
  'dockBorder': RgbColor(red: 255, green: 255, blue: 255),
  'labelColor': RgbColor(red: 0, green: 0, blue: 0),
  'dockLabelColor': RgbColor(red: 255, green: 255, blue: 255),
};

Map<String, double> defaultDoubles = {
  'labelSize': 20.0,
  'borderRadius': 12,
  'aspectRatio': 2.5,
};

Map<String, int> defaultInt = {
  'gridCount': 2,
};

class HomeController extends GetxController {
  LocalStroage storage = LocalStroage();
  Rx<RgbColor> background = (RgbColor(red: 161, green: 245, blue: 159)).obs;
  Rx<RgbColor> dockBackground = (RgbColor(red: 0, green: 0, blue: 0)).obs;
  Rx<RgbColor> border = (RgbColor(red: 0, green: 0, blue: 0)).obs;
  Rx<RgbColor> dockBorder = (RgbColor(red: 255, green: 255, blue: 255)).obs;
  Rx<RgbColor> labelColor = (RgbColor(red: 0, green: 0, blue: 0)).obs;
  Rx<RgbColor> dockLabelColor = (RgbColor(red: 255, green: 255, blue: 255)).obs;
  RxDouble labelSize = (20.0).obs;
  RxList<String> favorites = <String>[].obs;
  RxList<App> apps = <App>[].obs;
  List<App> forSearch = [];
  var loadingApps = false.obs;
  var searchPressed = false.obs;
  var battery = 0.obs;
  var charging = false.obs;
  var ip = ''.obs;
  RxDouble totalRam = (0.0).obs;
  RxDouble freeRaam = (0.0).obs;
  RxDouble borderRadius = (12.0).obs;
  RxInt gridCount = 2.obs;

  saveSettingsToStorage() {
    storage.setColor(background.value, 'background');
    storage.setColor(dockBackground.value, 'dockBackground');
    storage.setColor(border.value, 'border');
    storage.setColor(dockBorder.value, 'dockBorder');
    storage.setColor(labelColor.value, 'labelColor');
    storage.setColor(dockLabelColor.value, 'dockLabelColor');
    storage.setDouble(labelSize.value, 'labelSize');
    storage.setDouble(borderRadius.value, 'borderRadius');
    storage.setInt(gridCount.value, 'gridCount');
  }

  getWifi() async {
    WifiInfoPlugin.wifiDetails.then((value) {
      ip.value = value?.ipAddress ?? "0.0.0.0";
    });
  }

  double convertBytesToGB(x) {
    return x / pow(10, 9);
  }

  Timer? timer;

  getStroage() async {
    totalRam.value = convertBytesToGB(SysInfo.getTotalPhysicalMemory());
    freeRaam.value = convertBytesToGB(
        SysInfo.getFreePhysicalMemory() + SysInfo.getFreeVirtualMemory());
  }

  List<String> mapToListString(List toBeMapped) {
    return toBeMapped.map((x) => x.toString()).toList();
  }

  @override
  void onInit() async {
    background.value = storage.getColor('background');
    dockBackground.value = storage.getColor('dockBackground');
    border.value = storage.getColor('border');
    dockBorder.value = storage.getColor('dockBorder');
    labelColor.value = storage.getColor('labelColor');
    dockLabelColor.value = storage.getColor('dockLabelColor');
    borderRadius.value = storage.getDouble('borderRadius');
    labelSize.value = storage.getDouble('labelSize');
    favorites.value = mapToListString(storage.getFavourites());
    gridCount.value = storage.getInt('gridCount');

    getStroage();
    getWifi();
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      getStroage();
      getWifi();
    });
    BatteryInfoPlugin()
        .androidBatteryInfoStream
        .listen((AndroidBatteryInfo? batteryInfo) {
      if (batteryInfo != null) {
        battery.value = batteryInfo.batteryLevel!;
        charging.value = batteryInfo.chargingStatus == ChargingStatus.Charging;
      }
    });

    var appsInStorage = storage.getApps();
    if (appsInStorage.isNotEmpty) {
      for (var app in appsInStorage) {
        if (app is App) {
          apps.add(app);
          forSearch.add(app);
        } else {
          apps.add(App.fromJson(app));
          forSearch.add(App.fromJson(app));
        }
      }
    } else {
      await loadApps();
    }
    apps.sort((a, b) => a.name.compareTo(b.name));
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
    timer?.cancel();
  }

  loadApps() async {
    loadingApps.value = true;
    var availableApps = await DeviceApps.getInstalledApplications(
      onlyAppsWithLaunchIntent: true,
      includeSystemApps: true,
      includeAppIcons: true,
    );
    apps.value = availableApps.map((e) => App.fromApplication(e)).toList();
    forSearch = availableApps.map((e) => App.fromApplication(e)).toList();
    storage.setApps(apps);
    loadingApps.value = false;
    apps.sort((a, b) => a.name.compareTo(b.name));
  }

  showSearch() {
    searchPressed.value = !searchPressed.value;
    searchApp('');
  }

  addAppToFavourites(String package) {
    favorites.add(package);
    storage.setFavourites(favorites.value);
    Get.back();
  }

  removeAppFromFavourites(String package) {
    favorites.remove(package);
    storage.setFavourites(favorites.value);
    Get.back();
  }

  searchApp(String text) {
    var result = forSearch
        .where((element) =>
            element.name.toLowerCase().contains(text.toLowerCase()))
        .toList();
    apps.value = result;
    apps.sort((a, b) => a.name.compareTo(b.name));
  }

  launcFromDock(String name) {
    try {
      String? package = forSearch
          .firstWhere((element) => element.name.toLowerCase().contains(name))
          .package;
      DeviceApps.openApp(package);
    } catch (e) {
      print(e);
    }
  }

  launchPhone() {
    try {
      String? package = forSearch
          .firstWhere((element) =>
              element.name.toLowerCase().contains('dialer') ||
              element.name.toLowerCase().contains('phone'))
          .package;
      DeviceApps.openApp(package);
    } catch (e) {
      print(e);
    }
  }

  App? getAppFromPackage(String package) {
    var app = forSearch.firstWhere((element) => element.package == package);
    return app;
  }

  showColorPicker(pickerColor, onChanged, saveInStorage) {
    Get.defaultDialog(
      radius: borderRadius.value,
      title: 'Pick a color!',
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: pickerColor,
          onColorChanged: onChanged,
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black),
          ),
          child: const SizedBox(
            width: double.infinity,
            child: Center(child: Text('Got it')),
          ),
          onPressed: () {
            saveInStorage();
            Get.back();
          },
        ),
      ],
    );
  }

  resetSettings() {
    background.value = RgbColor(red: 161, green: 245, blue: 159);
    dockBackground.value = RgbColor(red: 0, green: 0, blue: 0);
    border.value = RgbColor(red: 0, green: 0, blue: 0);
    dockBorder.value = RgbColor(red: 255, green: 255, blue: 255);
    labelColor.value = RgbColor(red: 0, green: 0, blue: 0);
    dockLabelColor.value = RgbColor(red: 255, green: 255, blue: 255);
    labelSize.value = 20.0;
    borderRadius.value = 12;
    gridCount.value = 2;
    saveSettingsToStorage();
    Get.back();
  }

  resetDiaglog() {
    Get.defaultDialog(
      title: 'Reset Settings',
      titleStyle: const TextStyle(fontFamily: 'Oddlini'),
      content: const Text(
        'Are you sure you want to reset the setting back to default?',
        style: TextStyle(
          fontFamily: 'Oddlini',
          fontSize: 15,
        ),
        textAlign: TextAlign.center,
      ),
      contentPadding: const EdgeInsets.all(10),
      textConfirm: 'Yes',
      textCancel: 'No',
      confirmTextColor: Colors.white,
      radius: borderRadius.value,
      onConfirm: () => resetSettings(),
    );
  }

  addToFavDialog(App app) {
    Get.defaultDialog(
      title: 'Add to Favourite',
      titleStyle: const TextStyle(fontFamily: 'Oddlini'),
      content: Text(
        'Are you sure you want to add ${app.name} to your favourites',
        style: const TextStyle(
          fontFamily: 'Oddlini',
          fontSize: 15,
        ),
        textAlign: TextAlign.center,
      ),
      contentPadding: const EdgeInsets.all(10),
      textConfirm: 'Yes',
      textCancel: 'No',
      confirmTextColor: Colors.white,
      radius: borderRadius.value,
      onConfirm: () => addAppToFavourites(app.package),
    );
  }

  removeFromFavDialog(App app) {
    Get.defaultDialog(
      title: 'Remove from Favourite',
      titleStyle: const TextStyle(fontFamily: 'Oddlini'),
      content: Text(
        'Are you sure you want to remove ${app.name} from your favourites',
        style: const TextStyle(
          fontFamily: 'Oddlini',
          fontSize: 15,
        ),
        textAlign: TextAlign.center,
      ),
      contentPadding: const EdgeInsets.all(10),
      textConfirm: 'Yes',
      textCancel: 'No',
      confirmTextColor: Colors.white,
      radius: borderRadius.value,
      onConfirm: () => removeAppFromFavourites(app.package),
    );
  }

  handleLongPress(App app) {
    if (favorites.contains(app.package)) {
      removeFromFavDialog(app);
    } else {
      addToFavDialog(app);
    }
  }

  showSettings() {
    Get.bottomSheet(
        Container(
          padding: const EdgeInsets.all(18),
          constraints: BoxConstraints(maxHeight: Get.height * 0.8),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Oddlini',
                        fontSize: 25,
                      ),
                    ),
                    InkWell(
                      onTap: () => resetDiaglog(),
                      child: const Text(
                        'Reset to Default',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Oddlini',
                          fontSize: 12,
                        ),
                      ),
                    )
                  ],
                ),
                Flexible(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorFromRGB(background.value),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black,
                                ),
                                padding: const EdgeInsets.all(16),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'Morbin Time',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Oddlini',
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          settingTitle('Border Radius'),
                          settingTitle(borderRadius.toStringAsFixed(0)),
                        ],
                      ),
                      Slider(
                        value: borderRadius.value,
                        thumbColor: Colors.white,
                        activeColor: Colors.white,
                        inactiveColor: ColorFromRGB(background.value),
                        min: 0,
                        max: 100,
                        onChanged: (value) {
                          borderRadius.value = value;
                        },
                        onChangeEnd: (value) =>
                            storage.setDouble(value, 'borderRadius'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          settingTitle('Label Size'),
                          settingTitle(labelSize.toStringAsFixed(0)),
                        ],
                      ),
                      Slider(
                        value: labelSize.value,
                        thumbColor: Colors.white,
                        activeColor: Colors.white,
                        inactiveColor: ColorFromRGB(background.value),
                        min: 10,
                        max: 20,
                        onChanged: (value) {
                          labelSize.value = value;
                        },
                        onChangeEnd: (value) =>
                            storage.setDouble(value, 'labelSize'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          settingTitle('Grid Count'),
                          settingTitle(gridCount.toStringAsFixed(0)),
                        ],
                      ),
                      Slider(
                        value: double.parse(gridCount.value.toString()),
                        thumbColor: Colors.white,
                        activeColor: Colors.white,
                        inactiveColor: ColorFromRGB(background.value),
                        min: 1,
                        max: 5,
                        onChanged: (value) {
                          gridCount.value = value.toInt();
                        },
                        onChangeEnd: (value) =>
                            storage.setInt(value.toInt(), 'gridCount'),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      settingTitle('Home'),
                      settingSubTitle('Background Color'),
                      colorPicker(
                        ColorFromRGB(background.value),
                        (Color color) {
                          background.value = RgbFromColor(color);
                        },
                        () => storage.setColor(background.value, 'background'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      settingSubTitle('Border Color'),
                      colorPicker(
                        ColorFromRGB(border.value),
                        (Color color) {
                          border.value = RgbFromColor(color);
                        },
                        () => storage.setColor(border.value, 'border'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      settingSubTitle('Label Color'),
                      colorPicker(
                        ColorFromRGB(labelColor.value),
                        (Color color) => labelColor.value = RgbFromColor(color),
                        () {
                          storage.setColor(labelColor.value, 'labelColor');
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Dock',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Oddlini',
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      settingSubTitle('Background Color'),
                      colorPicker(
                        ColorFromRGB(dockBackground.value),
                        (Color color) {
                          dockBackground.value = RgbFromColor(color);
                        },
                        () => storage.setColor(
                            dockBackground.value, 'dockBackground'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      settingSubTitle('Border Color'),
                      colorPicker(
                        ColorFromRGB(dockBorder.value),
                        (Color color) {
                          dockBorder.value = RgbFromColor(color);
                        },
                        () => storage.setColor(dockBorder.value, 'dockBorder'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      settingSubTitle('Label Color'),
                      colorPicker(
                        ColorFromRGB(dockLabelColor.value),
                        (Color color) {
                          dockLabelColor.value = RgbFromColor(color);
                        },
                        () => storage.setColor(
                            dockLabelColor.value, 'dockLabelColor'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.white)),
                        onPressed: () {
                          loadApps();
                          Get.back();
                        },
                        child: const SizedBox(
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              'Reload Apps',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Oddlini',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.black,
        clipBehavior: Clip.hardEdge,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        isScrollControlled: true,
        ignoreSafeArea: false);
  }

  Padding settingSubTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Oddlini',
          fontSize: 15,
        ),
      ),
    );
  }

  Padding settingTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Oddlini',
          fontSize: 20,
        ),
      ),
    );
  }

  InkWell colorPicker(Color color, onChange, saveInStorage) {
    return InkWell(
      borderRadius: BorderRadius.circular(borderRadius.value),
      onTap: () => showColorPicker(color, onChange, saveInStorage),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius.value),
        clipBehavior: Clip.hardEdge,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(borderRadius.value),
          ),
          height: 35,
          width: double.infinity,
        ),
      ),
    );
  }
}

class LocalStroage {
  final box = GetStorage();

  setColor(RgbColor color, String key) => box.write(key, color);

  RgbColor getColor(key) {
    if (box.read(key) != null) {
      return RgbColor.fromJson(box.read(key));
    } else {
      return defaultColors[key]!;
    }
  }

  setDouble(double value, String key) => box.write(key, value);

  double getDouble(String key) {
    var value = box.read(key);
    if (value != null) {
      return double.tryParse(box.read(key).toString()) ?? defaultDoubles[key]!;
    } else {
      return defaultDoubles[key]!;
    }
  }

  setInt(int value, String key) => box.write(key, value);

  int getInt(String key) => box.read(key) ?? defaultInt[key]!;

  setApps(List<App> apps) => box.write('apps', apps);

  List<dynamic> getApps() => box.read('apps') ?? [];

  setFavourites(List<String> favourites) => box.write('favourites', favourites);

  getFavourites() => box.read('favourites') ?? [];
}
