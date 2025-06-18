// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Only Timetable';

  @override
  String get saved => '已儲存';

  @override
  String get nearby => '附近';

  @override
  String get settings => '設定';

  @override
  String get plugin => '插件';

  @override
  String get about => '關於';

  @override
  String get addPlugin => '新增插件';

  @override
  String get add => '新增';

  @override
  String get json => 'JSON';

  @override
  String get url => '網址';

  @override
  String get failed => '失敗';

  @override
  String get close => '關閉';

  @override
  String get noPluginAvailable => '沒有可用插件';

  @override
  String get noPluginAvailableDescription => '目前沒有可用的插件。請新增插件以繼續。';

  @override
  String get addLater => '稍後新增';

  @override
  String updatedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '更新於 $dateString';
  }

  @override
  String get neverUpdated => '從未更新';

  @override
  String get pluginInfo => '插件資訊';

  @override
  String get removePlugin => '移除插件';

  @override
  String get author => '作者';

  @override
  String get id => 'ID';

  @override
  String get name => '名稱';

  @override
  String get version => '版本';

  @override
  String get repository => '儲存庫';

  @override
  String get description => '描述';

  @override
  String get confirmation => '確認';

  @override
  String get confirm => '確定';

  @override
  String get cancel => '取消';

  @override
  String get removePluginConfirm => '你確定要移除此插件嗎？';

  @override
  String failedToUpdateRoutes(String pluginName) {
    return '無法為 $pluginName 更新路線。';
  }

  @override
  String get noRoutesFound => '找不到路線';

  @override
  String get viewAll => '檢視全部';

  @override
  String get loadMore => '載入更多';

  @override
  String get general => '一般';

  @override
  String get alwaysUseOSM => '總是使用 OpenStreetMap';

  @override
  String get routeHasNoStops => '此路線沒有站點。';

  @override
  String get routeHasNoValidStops => '此路線沒有有效站點。';

  @override
  String get failedToLoadRoute => '無法載入路線。';

  @override
  String mins(int minutes) {
    return '$minutes 分鐘';
  }

  @override
  String get noEtaAvailable => '沒有預計到達時間';

  @override
  String get loadingEta => '正在載入預計到達時間...';

  @override
  String get bookmark => '書籤';

  @override
  String get createBookmark => '建立書籤';

  @override
  String get bookmarkName => '書籤名稱';

  @override
  String get create => '建立';

  @override
  String get bookmarkNameRequired => '書籤名稱為必填項。';

  @override
  String get defaultBookmark => '預設';

  @override
  String get deleteBookmarkConfirm => '你確定要刪除此書籤嗎？';

  @override
  String get done => '完成';

  @override
  String get bookmarkAlreadyExists => '已存在同名書籤。';

  @override
  String get min => '分鐘';

  @override
  String get hour => '小時';

  @override
  String get license => '授權條款';

  @override
  String get themeMode => '主題模式';

  @override
  String get auto => '自動';

  @override
  String get light => '淺色';

  @override
  String get dark => '深色';

  @override
  String get language => '語言';

  @override
  String get primaryColor => '主色';

  @override
  String get colorPicker => '顏色選擇器';

  @override
  String get filter => '篩選';

  @override
  String get showRoutesFrom => '僅顯示路線來自：';

  @override
  String failedToUpdateEta(String routeId) {
    return '無法為 $routeId 更新預計到達時間。';
  }

  @override
  String routesUpdated(String pluginName) {
    return '$pluginName 的路線已更新。';
  }

  @override
  String get checkForUpdates => '檢查更新';

  @override
  String pluginUpToDate(String pluginName) {
    return '$pluginName 已是最新版本。';
  }

  @override
  String get failedToCheckForUpdates => '檢查更新失敗。';

  @override
  String pluginUpdated(String pluginName, String version) {
    return '已將 $pluginName 更新到 $version 版本。';
  }

  @override
  String get marketplace => '插件商店';

  @override
  String get details => '詳細';
}

/// The translations for Chinese, as used in China (`zh_CN`).
class AppLocalizationsZhCn extends AppLocalizationsZh {
  AppLocalizationsZhCn() : super('zh_CN');

  @override
  String get appName => 'Only Timetable';

  @override
  String get saved => '已保存';

  @override
  String get nearby => '附近';

  @override
  String get settings => '设置';

  @override
  String get plugin => '插件';

  @override
  String get about => '关于';

  @override
  String get addPlugin => '添加插件';

  @override
  String get add => '添加';

  @override
  String get json => 'JSON';

  @override
  String get url => '网址';

  @override
  String get failed => '失败';

  @override
  String get close => '关闭';

  @override
  String get noPluginAvailable => '没有可用插件';

  @override
  String get noPluginAvailableDescription => '当前没有可用插件。请添加插件以继续。';

  @override
  String get addLater => '稍后添加';

  @override
  String updatedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '更新于 $dateString';
  }

  @override
  String get neverUpdated => '从未更新';

  @override
  String get pluginInfo => '插件信息';

  @override
  String get removePlugin => '移除插件';

  @override
  String get author => '作者';

  @override
  String get id => 'ID';

  @override
  String get name => '名称';

  @override
  String get version => '版本';

  @override
  String get repository => '仓库';

  @override
  String get description => '描述';

  @override
  String get confirmation => '确认';

  @override
  String get confirm => '确定';

  @override
  String get cancel => '取消';

  @override
  String get removePluginConfirm => '你确定要移除此插件吗？';

  @override
  String failedToUpdateRoutes(String pluginName) {
    return '无法为 $pluginName 更新线路。';
  }

  @override
  String get noRoutesFound => '未找到线路';

  @override
  String get viewAll => '查看全部';

  @override
  String get loadMore => '加载更多';

  @override
  String get general => '通用';

  @override
  String get alwaysUseOSM => '总是使用 OpenStreetMap';

  @override
  String get routeHasNoStops => '该线路没有站点。';

  @override
  String get routeHasNoValidStops => '该线路没有有效站点。';

  @override
  String get failedToLoadRoute => '无法加载线路。';

  @override
  String mins(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String get noEtaAvailable => '没有预计到达时间';

  @override
  String get loadingEta => '正在加载预计到达时间...';

  @override
  String get bookmark => '书签';

  @override
  String get createBookmark => '创建书签';

  @override
  String get bookmarkName => '书签名称';

  @override
  String get create => '创建';

  @override
  String get bookmarkNameRequired => '书签名称为必填项。';

  @override
  String get defaultBookmark => '默认';

  @override
  String get deleteBookmarkConfirm => '你确定要删除此书签吗？';

  @override
  String get done => '完成';

  @override
  String get bookmarkAlreadyExists => '已存在同名书签。';

  @override
  String get min => '分钟';

  @override
  String get hour => '小時';

  @override
  String get license => '许可证';

  @override
  String get themeMode => '主题模式';

  @override
  String get auto => '自动';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get language => '语言';

  @override
  String get primaryColor => '主色';

  @override
  String get colorPicker => '颜色选择器';

  @override
  String get filter => '筛选';

  @override
  String get showRoutesFrom => '仅显示线路来自：';

  @override
  String failedToUpdateEta(String routeId) {
    return 'Failed to update ETA for $routeId.';
  }

  @override
  String routesUpdated(String pluginName) {
    return '已为 $pluginName 更新线路。';
  }

  @override
  String get checkForUpdates => '检查更新';

  @override
  String pluginUpToDate(String pluginName) {
    return '$pluginName 已是最新版本。';
  }

  @override
  String get failedToCheckForUpdates => '检查更新失败。';

  @override
  String pluginUpdated(String pluginName, String version) {
    return '已将 $pluginName 更新到 $version 版本。';
  }

  @override
  String get marketplace => '插件商店';

  @override
  String get details => '详细';
}
