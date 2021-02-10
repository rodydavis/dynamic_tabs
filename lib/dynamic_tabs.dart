import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'data/classes/tab.dart';
import 'data/models/index.dart';
import 'ui/more_screen.dart';

export 'data/classes/tab.dart';

bool isDesktop() =>
    defaultTargetPlatform == TargetPlatform.macOS ||
    defaultTargetPlatform == TargetPlatform.linux ||
    defaultTargetPlatform == TargetPlatform.windows;

class DynamicTabScaffold extends StatelessWidget {
  const DynamicTabScaffold({
    required this.tabs,
    this.backgroundColor,
    this.persistIndex = false,
    this.iconSize,
    this.maxTabs = 4,
    this.tag = "",
    this.type = BottomNavigationBarType.fixed,
    this.moreTabPrimaryColor,
    this.moreTabAccentColor,
    this.masterDetailOnMoreTab = false,
    this.breakpoint = 720,
    this.selectedColor,
  })  : adaptive = false,
        routes = null,
        assert(tabs.length >= 2);

  const DynamicTabScaffold.adaptive({
    required this.tabs,
    this.backgroundColor,
    this.persistIndex = false,
    this.maxTabs = 4,
    this.tag = "",
    required this.routes,
    this.moreTabPrimaryColor,
    this.masterDetailOnMoreTab = false,
    this.breakpoint = 720,
    this.moreTabAccentColor,
    BottomNavigationBarType materialType = BottomNavigationBarType.fixed,
    double? materialIconSize,
    this.selectedColor,
  })  : adaptive = true,
        type = materialType,
        iconSize = materialIconSize,
        assert(tabs.length >= 2);

  final bool adaptive;
  final Color? backgroundColor;
  final double breakpoint;
  // Material Only
  final double? iconSize;

  final bool masterDetailOnMoreTab;
  final int maxTabs;
  final Color? moreTabAccentColor;
  // final Color unselectedItemColor;

  final Color? moreTabPrimaryColor;

  final bool persistIndex;
  final Map<String, WidgetBuilder>? routes;
  final Color? selectedColor;
  final List<DynamicTab> tabs;
  // Unique Tag for each set of dynamic tabs
  final String tag;

  // final Color fixedColor;
  final BottomNavigationBarType type;

  @override
  Widget build(BuildContext context) {
    final _state = TabState();
    _state.init(tag, tabs, max: maxTabs, persist: persistIndex);
    return TabProvider(
      state: _state,
      child: Builder(
        builder: (_) {
          if (adaptive && defaultTargetPlatform == TargetPlatform.iOS) {
            return CupertinoView(
              selectedColor: selectedColor,
              backgroundColor: backgroundColor,
              routes: routes,
              adaptive: adaptive,
              maxTabs: maxTabs,
              breakpoint: breakpoint,
              masterDetailOnMoreTab: masterDetailOnMoreTab,
              moreTabAccentColor: moreTabAccentColor,
              moreTabPrimaryColor: moreTabPrimaryColor,
            );
          }

          if (adaptive && isDesktop()) {
            return new DesktopView(
              routes: routes,
              breakpoint: breakpoint,
              masterDetailOnMoreTab: masterDetailOnMoreTab,
              adaptive: adaptive,
              moreTabAccentColor: moreTabAccentColor,
              moreTabPrimaryColor: moreTabPrimaryColor,
            );
          }

          return new MaterialView(
            routes: routes,
            breakpoint: breakpoint,
            masterDetailOnMoreTab: masterDetailOnMoreTab,
            adaptive: adaptive,
            moreTabAccentColor: moreTabAccentColor,
            moreTabPrimaryColor: moreTabPrimaryColor,
            selectedColor: selectedColor,
            maxTabs: maxTabs,
            backgroundColor: backgroundColor,
            type: type,
          );
        },
      ),
    );
  }
}

class MaterialView extends StatelessWidget {
  const MaterialView({
    Key? key,
    required this.routes,
    required this.adaptive,
    required this.moreTabAccentColor,
    required this.moreTabPrimaryColor,
    required this.selectedColor,
    required this.maxTabs,
    required this.backgroundColor,
    required this.type,
    required this.breakpoint,
    required this.masterDetailOnMoreTab,
  }) : super(key: key);

  final bool adaptive;
  final Color? backgroundColor;
  final int maxTabs;
  final Color? moreTabAccentColor;
  final Color? moreTabPrimaryColor;
  final Map? routes;
  final Color? selectedColor;
  final BottomNavigationBarType type;
  final bool masterDetailOnMoreTab;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final model = TabProvider.of(context)!.state;
        return Scaffold(
          body: ContentView(
            routes: routes as Map<String, Widget Function(BuildContext)>?,
            adaptive: adaptive,
            breakpoint: breakpoint,
            masterDetailOnMoreTab: masterDetailOnMoreTab,
            moreTabAccentColor: moreTabAccentColor,
            moreTabPrimaryColor: moreTabPrimaryColor,
          ),
          bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: selectedColor,
            items: model.showEditTab
                ? (model.mainTabs.map((t) => t.tab).toList()
                  ..add(BottomNavigationBarItem(
                    label: "More",
                    icon: Icon(Icons.more_horiz),
                  )))
                : model.allTabs.map((t) => t.tab).toList(),
            currentIndex: model.adjustedIndex,
            onTap: model.changeTab,
            fixedColor: backgroundColor ?? Theme.of(context).primaryColor,
            type: type,
            // unselectedItemColor: unselectedItemColor ?? Colors.grey,
          ),
        );
      },
    );
  }
}

class DesktopView extends StatelessWidget {
  const DesktopView({
    Key? key,
    required this.routes,
    required this.adaptive,
    required this.moreTabAccentColor,
    required this.moreTabPrimaryColor,
    required this.breakpoint,
    required this.masterDetailOnMoreTab,
  }) : super(key: key);

  final bool adaptive;
  final Color? moreTabAccentColor;
  final Color? moreTabPrimaryColor;
  final Map? routes;
  final bool masterDetailOnMoreTab;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final model = TabProvider.of(context)!.state;
        return Scaffold(
          body: ContentView(
            routes: routes as Map<String, Widget Function(BuildContext)>?,
            adaptive: adaptive,
            breakpoint: breakpoint,
            masterDetailOnMoreTab: masterDetailOnMoreTab,
            moreTabAccentColor: moreTabAccentColor,
            moreTabPrimaryColor: moreTabPrimaryColor,
          ),
          drawer: Drawer(
            child: Container(
              child: SafeArea(
                child: Container(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        for (var i = 0; i < model.allTabs.length; i++) ...[
                          ListTile(
                            selected: i == model.currentIndex,
                            leading: model.allTabs[i].tab.icon,
                            title: Text(model.allTabs[i].tab.label ?? ''),
                            onTap: () {
                              model.changeTab(i);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CupertinoView extends StatelessWidget {
  const CupertinoView({
    Key? key,
    required this.selectedColor,
    required this.maxTabs,
    required this.backgroundColor,
    required this.adaptive,
    required this.routes,
    required this.moreTabAccentColor,
    required this.moreTabPrimaryColor,
    required this.breakpoint,
    required this.masterDetailOnMoreTab,
  }) : super(key: key);

  final bool adaptive;
  final Color? backgroundColor;
  final int maxTabs;
  final Color? moreTabAccentColor;
  final Color? moreTabPrimaryColor;
  final Map<String, WidgetBuilder>? routes;
  final Color? selectedColor;
  final bool masterDetailOnMoreTab;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final model = TabProvider.of(context)!.state;
        return CupertinoTabScaffold(
          tabBuilder: (BuildContext context, int index) {
            return ContentView(
              routes: routes,
              adaptive: adaptive,
              breakpoint: breakpoint,
              masterDetailOnMoreTab: masterDetailOnMoreTab,
              moreTabAccentColor: moreTabAccentColor,
              moreTabPrimaryColor: moreTabPrimaryColor,
            );
          },
          tabBar: CupertinoTabBar(
            activeColor: selectedColor,
            items: model.showEditTab
                ? (model.mainTabs.map((t) => t.tab).toList()
                  ..add(BottomNavigationBarItem(
                    label: "More",
                    icon: Icon(Icons.more_horiz),
                  )))
                : model.allTabs.map((t) => t.tab).toList(),
            currentIndex: model.adjustedIndex,
            onTap: model.changeTab,
            backgroundColor: backgroundColor,
          ),
        );
      },
    );
  }
}

class ContentView extends StatelessWidget {
  ContentView({
    required this.adaptive,
    required this.routes,
    required this.moreTabAccentColor,
    required this.moreTabPrimaryColor,
    required this.breakpoint,
    required this.masterDetailOnMoreTab,
  });

  final bool adaptive;
  final Color? moreTabAccentColor;
  final Color? moreTabPrimaryColor;
  final Map<String, WidgetBuilder>? routes;
  final bool masterDetailOnMoreTab;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final model = TabProvider.of(context)!.state;
        if (model.showEditTab && model.isMoreTab && !isDesktop()) {
          if (adaptive && defaultTargetPlatform == TargetPlatform.iOS) {
            return CupertinoTabView(
              routes: routes,
              builder: (BuildContext context) {
                if (masterDetailOnMoreTab) {
                  return MoreTab.fluid(
                    breakpoint: breakpoint,
                    adaptive: adaptive,
                    primaryColor: moreTabPrimaryColor,
                    accentColor: moreTabAccentColor,
                    navigator: Navigator.of(context),
                  );
                }
                return MoreTab(
                  adaptive: adaptive,
                  primaryColor: moreTabPrimaryColor,
                  accentColor: moreTabAccentColor,
                  navigator: Navigator.of(context),
                );
              },
            );
          }
          if (masterDetailOnMoreTab) {
            return MoreTab.fluid(
              primaryColor: moreTabPrimaryColor,
              accentColor: moreTabAccentColor,
              adaptive: adaptive,
              breakpoint: breakpoint,
              navigator: Navigator.of(context),
            );
          }
          return MoreTab(
            primaryColor: moreTabPrimaryColor,
            accentColor: moreTabAccentColor,
            adaptive: adaptive,
            navigator: Navigator.of(context),
          );
        }

        if (adaptive && defaultTargetPlatform == TargetPlatform.iOS) {
          return CupertinoTabView(
            routes: routes,
            builder: (BuildContext context) => Material(child: model.child),
          );
        }

        return model.child;
      },
    );
  }
}

class TabProvider extends InheritedWidget {
  const TabProvider({
    Key? key,
    required this.child,
    required this.state,
  }) : super(key: key, child: child);

  final Widget child;
  final TabState state;

  static TabProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TabProvider>();
  }

  @override
  bool updateShouldNotify(TabProvider oldWidget) {
    return this.state != oldWidget.state;
  }
}
