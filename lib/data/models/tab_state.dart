import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/tab.dart';

class TabState extends ChangeNotifier {
  int _currentIndex = 0;
  List<DynamicTab>? _items;
  int _maxTabs = 4;
  bool _persistIndex = false;
  late SharedPreferences _storage;

  int get currentIndex => _currentIndex;

  bool get persistIndex => _persistIndex;

  int get maxTabs => _maxTabs;

  void init(
    String tag,
    List<DynamicTab> values, {
    bool persist = false,
    int max = 4,
  }) async {
    _items = values;
    _persistIndex = persist;
    _maxTabs = max;
    notifyListeners();

    _storage = await SharedPreferences.getInstance();

    _loadSavedTabs();
    _loadIndex();
  }

  bool get isMoreTab => _currentIndex >= _maxTabs;
  bool get showEditTab => (_items?.length ?? 0) > _maxTabs;
  Widget get child => _items![_currentIndex].child;

  void changeMaxTabs(int value) {
    assert(value >= 2);
    _maxTabs = value;
    notifyListeners();
  }

  List<DynamicTab> get mainTabs => allTabs.take(_maxTabs).toList();
  List<DynamicTab> get extraTabs => allTabs.skip(_maxTabs).toList();
  List<DynamicTab> get allTabs => _items ?? [];

  int get adjustedIndex => isMoreTab ? maxTabs : _currentIndex;
  int get subIndex => isMoreTab ? _currentIndex - _maxTabs : _currentIndex;

  void _loadSavedTabs() async {
    List<String> _list = [];
    try {
      final _data = _storage.getStringList(tabsKey);
      if (_data != null) {
        _list = List.from(_data);
      }
    } catch (e) {
      print("Couldn't read tabs: $e");
    }
    if (_list.length == _items!.length) {
      changeTabOrder(_list);
    }
  }

  void changeTabOrder(List<String> _list) {
    List<String> _tabs = _list;
    if (_tabs != null && _tabs.isNotEmpty) {
      List<DynamicTab> _newOrder = [];
      for (var item in _tabs) {
        _newOrder.add(_items!.firstWhere((t) => t.tag == item));
      }
      _items = _newOrder;
      notifyListeners();
    }
    _saveNewTabs();
  }

  void _saveNewTabs() async {
    final _list = _items!.map((t) => t.tag).toList();
    await _storage.setStringList(tabsKey, _list);
  }

  void changeTab(int value) {
    _currentIndex = value;
    notifyListeners();
    _saveIndex();
  }

  void _loadIndex() {
    if (_persistIndex) {
      int _index = _storage.getInt(navKey);
      if (_index != null) {
        if (_index > _maxTabs) {
          _index = 0;
        }
        _currentIndex = _index;
        notifyListeners();
      }
      _saveIndex();
    }
  }

  void _saveIndex() {
    _storage.setInt(navKey, _currentIndex);
  }

  void reset() {
    _storage.clear();
    changeTabOrder(_items!.map((t) => t.tag).toList());
    _currentIndex = 0;
    _saveIndex();
  }

  String get navKey => 'nav-key';

  String get tabsKey => 'tabs-key';

  List<BottomNavigationBarItem> get tabs => showEditTab
      ? <BottomNavigationBarItem>[
          ...mainTabs.map((e) => e.tab).toList(),
          const BottomNavigationBarItem(
            label: 'More',
            icon: Icon(Icons.more_horiz),
          )
        ]
      : <BottomNavigationBarItem>[...allTabs.map((e) => e.tab).toList()];
}
