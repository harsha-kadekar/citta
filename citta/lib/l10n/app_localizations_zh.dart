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
  String get firstTimeSetupSubtitle => '开始之前，我们先设置几项内容。';

  @override
  String get firstTimeSetupThemeSectionTitle => '选择你的主题';

  @override
  String get firstTimeSetupEncryptionAlreadyEnabledNotice => '你的反思记录已启用加密。';

  @override
  String get firstTimeSetupContinueButton => '开始使用';

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
  String get settingsColorPalette => '配色方案';

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
  String get settingsExportChooseTitle => '导出数据';

  @override
  String get settingsExportChooseMsg => '导出为普通 JSON，还是加密？';

  @override
  String get settingsExportChoosePlain => '普通 JSON';

  @override
  String get settingsExportChooseEncrypted => '加密';

  @override
  String get settingsImportEncryptedTitle => '加密导出';

  @override
  String get settingsImportEncryptedSubtitle => '请输入用于加密此导出文件的密码或恢复密钥。';

  @override
  String get settingsImportEncryptedInputLabel => '密码或恢复密钥';

  @override
  String get settingsImportEncryptedSubmitButton => '解锁';

  @override
  String get settingsImportEncryptedErrorEmpty => '请输入密码或恢复密钥';

  @override
  String get settingsImportEncryptedErrorWrong => '密码或恢复密钥不正确，请重试。';

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
  String sessionDateAt(String date, String time) {
    return '$date $time';
  }

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

  @override
  String get encryptionToggleTitle => '加密我的反思记录';

  @override
  String get encryptionToggleSubtitle => '使用密码保护此设备上的会话';

  @override
  String get encryptionPasswordLabel => '密码';

  @override
  String get encryptionConfirmPasswordLabel => '确认密码';

  @override
  String get encryptionEnableButton => '启用加密';

  @override
  String get encryptionErrorEmpty => '请输入密码';

  @override
  String encryptionErrorTooShort(int minLength) {
    return '密码至少需要 $minLength 个字符';
  }

  @override
  String get encryptionErrorMismatch => '两次输入的密码不一致';

  @override
  String get encryptionErrorGeneric => '无法启用加密，请重试。';

  @override
  String get recoveryKeyScreenTitle => '保存你的恢复密钥';

  @override
  String get recoveryKeyWarning => '如果你忘记了密码，这是恢复数据的唯一方法。如果两者都丢失，你的数据将永久无法恢复。';

  @override
  String get recoveryKeyCopyButton => '复制';

  @override
  String get recoveryKeyShareButton => '分享';

  @override
  String get recoveryKeyAckLabel => '我已将恢复密钥保存在安全的地方';

  @override
  String get recoveryKeyContinueButton => '继续';

  @override
  String get recoveryKeyErrorGeneric => '无法生成恢复密钥，请重试。';

  @override
  String get unlockTitle => '解锁 Citta';

  @override
  String get unlockSubtitle => '请输入密码或恢复密钥以访问你的反思记录。';

  @override
  String get unlockInputLabel => '密码或恢复密钥';

  @override
  String get unlockSubmitButton => '解锁';

  @override
  String get unlockErrorEmpty => '请输入密码或恢复密钥';

  @override
  String get unlockErrorGeneric => '密码或恢复密钥不正确，请重试。';

  @override
  String get unlockErrorCorrupted => '无法读取你的加密数据，数据可能已损坏。';

  @override
  String get settingsEncryptionTitle => '加密';

  @override
  String get settingsEncryptionSubtitleEnabled => '你的会话已在此设备上加密';

  @override
  String get settingsEncryptionSubtitleDisabled => '使用密码保护你的会话';

  @override
  String get enableEncryptionScreenTitle => '启用加密';

  @override
  String get settingsEncryptionDisableConfirmTitle => '要禁用加密吗？';

  @override
  String get settingsEncryptionDisableConfirmMessage => '你的会话将再次以明文形式存储在此设备上。';

  @override
  String get settingsEncryptionDisableConfirmButton => '禁用';

  @override
  String get settingsEncryptionDisableError => '无法禁用加密，请重试。';

  @override
  String get settingsChangePasswordTitle => '修改密码';

  @override
  String get settingsChangePasswordSubtitle => '更新保护你会话的密码';

  @override
  String get changePasswordScreenTitle => '修改密码';

  @override
  String get changePasswordCurrentLabel => '当前密码';

  @override
  String get changePasswordNewLabel => '新密码';

  @override
  String get changePasswordConfirmLabel => '确认新密码';

  @override
  String get changePasswordSubmitButton => '修改密码';

  @override
  String get changePasswordErrorEmpty => '请输入当前密码和新密码';

  @override
  String changePasswordErrorTooShort(int minLength) {
    return '新密码至少需要 $minLength 个字符';
  }

  @override
  String get changePasswordErrorMismatch => '两次输入的新密码不一致';

  @override
  String get changePasswordErrorWrongCurrent => '当前密码不正确';

  @override
  String get changePasswordErrorGeneric => '无法修改密码，请重试。';

  @override
  String get changePasswordSuccess => '密码修改成功';
}
