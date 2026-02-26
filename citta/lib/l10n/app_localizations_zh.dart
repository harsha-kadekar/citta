// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get actionCancel => '取消';

  @override
  String get actionSave => '保存';

  @override
  String get actionSkip => '跳过';

  @override
  String get actionContinue => '继续';

  @override
  String get actionDelete => '删除';

  @override
  String get actionAdd => '添加';

  @override
  String get actionBegin => '开始';

  @override
  String get navDhyana => '冥想';

  @override
  String get navHistory => '历史';

  @override
  String get navStats => '统计';

  @override
  String get navSettings => '设置';

  @override
  String get splashGreeting => '合十礼';

  @override
  String splashGreetingWithName(String name) {
    return '合十礼，$name';
  }

  @override
  String get splashTapToBegin => '点击开始';

  @override
  String get welcomeTitle => '欢迎使用 Citta';

  @override
  String get welcomeNameHint => '输入您的名字';

  @override
  String get homeBegin => '开始';

  @override
  String get homeCountdown => '倒计时';

  @override
  String get homeStopwatch => '秒表';

  @override
  String get homeMin => '分';

  @override
  String get historyTitle => '历史';

  @override
  String historySelected(int count) {
    return '已选择 $count 个';
  }

  @override
  String get historyDeleteTitle => '删除会话';

  @override
  String historyDeleteConfirm(int count) {
    return '删除 $count 个会话？此操作无法撤销。';
  }

  @override
  String get historyFilterAll => '全部';

  @override
  String get historyEmpty => '暂无会话';

  @override
  String get historyEmptyHint => '完成您的第一次冥想会话\n在此查看';

  @override
  String get statsTitle => '统计';

  @override
  String get statsToggleCalendar => '切换日历视图';

  @override
  String get statsCurrentStreak => '当前连续';

  @override
  String get statsLongestStreak => '最长连续';

  @override
  String get statsTotalSessions => '总会话数';

  @override
  String get statsAverage => '平均';

  @override
  String statsDays(num count) {
    return '$count天';
  }

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsProfile => '个人资料';

  @override
  String get settingsName => '名字';

  @override
  String get settingsNameNotSet => '未设置';

  @override
  String get settingsEditName => '编辑名字';

  @override
  String get settingsAppearance => '外观';

  @override
  String get settingsTheme => '主题';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeSystem => '系统';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsLanguageSystem => '系统默认';

  @override
  String get settingsTimer => '计时器';

  @override
  String get settingsDefaultMode => '默认模式';

  @override
  String get settingsDefaultDuration => '默认时长';

  @override
  String settingsDurationMinutes(int count) {
    return '$count 分钟';
  }

  @override
  String get settingsCountdown => '倒计时';

  @override
  String get settingsCountdownDesc => '设置时长，计时器倒数';

  @override
  String get settingsStopwatch => '秒表';

  @override
  String get settingsStopwatchDesc => '开放式，手动停止';

  @override
  String get settingsBellSounds => '铃声';

  @override
  String get settingsStartBell => '开始铃';

  @override
  String get settingsEndBell => '结束铃';

  @override
  String get settingsIntervalBell => '间隔铃';

  @override
  String get settingsBellNone => '无';

  @override
  String get settingsPickFromDevice => '从设备中选择...';

  @override
  String get settingsEnableInterval => '启用间隔铃';

  @override
  String settingsIntervalEvery(int count) {
    return '每 $count 分钟';
  }

  @override
  String get settingsOff => '关闭';

  @override
  String get settingsIntervalDuration => '间隔时长';

  @override
  String get settingsIntervalSound => '间隔声音';

  @override
  String get settingsBgMusic => '背景音乐';

  @override
  String get settingsMusicFile => '音乐文件';

  @override
  String get settingsMusicSelected => '已选择';

  @override
  String get settingsMusicNone => '无';

  @override
  String get settingsRemoveMusic => '删除背景音乐';

  @override
  String get settingsTags => '标签';

  @override
  String get settingsAddTag => '+ 添加';

  @override
  String get settingsAddTagTitle => '添加标签';

  @override
  String get settingsAddTagHint => '例如：专注';

  @override
  String get settingsQuotes => '语录';

  @override
  String get settingsAddCustomQuote => '添加自定义语录';

  @override
  String settingsUserQuotes(int count) {
    return '$count 条用户语录';
  }

  @override
  String get settingsData => '数据';

  @override
  String get settingsExport => '导出数据';

  @override
  String get settingsExportDesc => '以 JSON 格式分享您的会话和配置';

  @override
  String get settingsImport => '导入数据';

  @override
  String get settingsImportDesc => '从 Citta JSON 导出文件加载';

  @override
  String get settingsImportReplaceMsg => '替换所有现有数据，还是与当前数据合并？';

  @override
  String get settingsMerge => '合并';

  @override
  String get settingsReplaceAll => '全部替换';

  @override
  String get settingsImportSuccess => '数据导入成功';

  @override
  String get settingsImportError => '无效的导入文件';

  @override
  String settingsExportFailed(String error) {
    return '导出失败：$error';
  }

  @override
  String get notesTitle => '会话笔记';

  @override
  String get notesPrompt => '您的练习怎么样？';

  @override
  String get notesHint => '写下您的体验...（纯文本或 Markdown）';

  @override
  String notesWordCount(int count) {
    return '$count / 500 字';
  }

  @override
  String get notesTags => '标签';

  @override
  String get sessionComplete => '会话完成';

  @override
  String get sessionTitle => '会话';

  @override
  String get sessionCountdown => '倒计时';

  @override
  String get sessionStopwatch => '秒表';

  @override
  String get sessionCompleted => '已完成';

  @override
  String get sessionNotes => '笔记';

  @override
  String get sessionNoNotes => '此会话没有笔记';

  @override
  String get addQuoteTitle => '添加语录';

  @override
  String get addQuoteOriginalText => '原文 *';

  @override
  String get addQuoteOriginalHint => '以原始文字输入语录...';

  @override
  String get addQuoteLanguage => '语言';

  @override
  String get addQuoteTranslation => '英文翻译 *';

  @override
  String get addQuoteTranslationHint => '输入英文翻译...';

  @override
  String get addQuoteSource => '来源';

  @override
  String get addQuoteSourceHint => '例如：薄伽梵歌';

  @override
  String get addQuoteReference => '参考';

  @override
  String get addQuoteReferenceHint => '例如：第2章，第47节';

  @override
  String get addQuoteSave => '保存语录';

  @override
  String get addQuoteAdded => '语录已添加';

  @override
  String get langEnglish => '英语';

  @override
  String get langHindi => '印地语';

  @override
  String get langKannada => '卡纳达语';

  @override
  String get langSanskrit => '梵语';

  @override
  String get langTelugu => '泰卢固语';

  @override
  String get langTamil => '泰米尔语';

  @override
  String get langMalayalam => '马拉雅拉姆语';

  @override
  String get langFrench => '法语';

  @override
  String get langGerman => '德语';

  @override
  String get langJapanese => '日语';

  @override
  String get langHebrew => '希伯来语';

  @override
  String get langChinese => '中文';

  @override
  String get langMarathi => '马拉地语';

  @override
  String get langGujarati => '古吉拉特语';

  @override
  String get langOdia => '奥里亚语';

  @override
  String get langBengali => '孟加拉语';

  @override
  String get langTulu => '图卢语';

  @override
  String get langKonkani => '孔卡尼语';

  @override
  String get langUrdu => '乌尔都语';

  @override
  String get langItalian => '意大利语';

  @override
  String get langSpanish => '西班牙语';

  @override
  String get langArabic => '阿拉伯语';

  @override
  String get langRussian => '俄语';

  @override
  String get langPortuguese => '葡萄牙语';

  @override
  String get langMaithili => '迈蒂利语';

  @override
  String get langAssamese => '阿萨姆语';

  @override
  String get langPunjabi => '旁遮普语';

  @override
  String get langOther => '其他';

  @override
  String get preSessionSetup => '会话设置';

  @override
  String get timerPaused => '已暂停';
}
