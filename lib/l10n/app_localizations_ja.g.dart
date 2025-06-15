// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'オンリータイムテーブル';

  @override
  String get saved => '保存済み';

  @override
  String get nearby => '近く';

  @override
  String get settings => '設定';

  @override
  String get plugin => 'プラグイン';

  @override
  String get about => 'アプリについて';

  @override
  String get addPlugin => 'プラグインを追加';

  @override
  String get add => '追加';

  @override
  String get json => 'JSON';

  @override
  String get url => 'URL';

  @override
  String get failed => '失敗しました';

  @override
  String get close => '閉じる';

  @override
  String get noPluginAvailable => 'プラグインなし';

  @override
  String get noPluginAvailableDescription =>
      '利用可能なプラグインがありません。続行するにはプラグインを追加してください。';

  @override
  String get addLater => '後で追加';

  @override
  String updatedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString に更新';
  }

  @override
  String get neverUpdated => '一度も更新されていません';

  @override
  String get pluginInfo => 'プラグイン情報';

  @override
  String get removePlugin => 'プラグインを削除';

  @override
  String get author => '作者';

  @override
  String get id => 'ID';

  @override
  String get name => '名前';

  @override
  String get version => 'バージョン';

  @override
  String get repository => 'リポジトリ';

  @override
  String get description => '説明';

  @override
  String get confirmation => '確認';

  @override
  String get confirm => '確認';

  @override
  String get cancel => 'キャンセル';

  @override
  String get removePluginConfirm => 'このプラグインを削除してもよろしいですか？';

  @override
  String failedToUpdateRoutes(String pluginName) {
    return '$pluginName のルート更新に失敗しました。';
  }

  @override
  String get noRoutesFound => 'ルートが見つかりません';

  @override
  String get viewAll => 'すべて表示';

  @override
  String get loadMore => 'さらに読み込む';

  @override
  String get general => '一般';

  @override
  String get alwaysUseOSM => '常にOpenStreetMapを使用';

  @override
  String get routeHasNoStops => 'このルートには停留所がありません。';

  @override
  String get routeHasNoValidStops => 'このルートには有効な停留所がありません。';

  @override
  String get failedToLoadRoute => 'ルートの読み込みに失敗しました。';

  @override
  String mins(int minutes) {
    return '$minutes 分';
  }

  @override
  String get noEtaAvailable => '到着予想時刻はありません';

  @override
  String get loadingEta => '到着予想時刻を読み込み中...';

  @override
  String get bookmark => 'ブックマーク';

  @override
  String get createBookmark => 'ブックマークを作成';

  @override
  String get bookmarkName => 'ブックマーク名';

  @override
  String get create => '作成';

  @override
  String get bookmarkNameRequired => 'ブックマーク名は必須です。';

  @override
  String get defaultBookmark => 'デフォルト';

  @override
  String get deleteBookmarkConfirm => 'このブックマークを削除してもよろしいですか？';

  @override
  String get done => '完了';

  @override
  String get bookmarkAlreadyExists => 'この名前のブックマークは既に存在します。';

  @override
  String get min => '分';

  @override
  String get hour => '時間';

  @override
  String get license => 'ライセンス';

  @override
  String get themeMode => 'テーマモード';

  @override
  String get auto => '自動';

  @override
  String get light => 'ライト';

  @override
  String get dark => 'ダーク';

  @override
  String get language => '言語';

  @override
  String get primaryColor => 'テーマカラー';

  @override
  String get colorPicker => 'カラーピッカー';

  @override
  String get filter => 'フィルター';

  @override
  String get showRoutesFrom => '表示するルート元：';

  @override
  String failedToUpdateEta(String routeId) {
    return '$routeId の到着予想時刻の更新に失敗しました。';
  }

  @override
  String routesUpdated(String pluginName) {
    return '$pluginName のルートが更新されました。';
  }
}
