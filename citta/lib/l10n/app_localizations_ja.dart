// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get actionCancel => 'キャンセル';

  @override
  String get actionSave => '保存';

  @override
  String get actionSkip => 'スキップ';

  @override
  String get actionContinue => '続ける';

  @override
  String get actionDelete => '削除';

  @override
  String get actionAdd => '追加';

  @override
  String get actionBegin => '開始';

  @override
  String get navDhyana => '瞑想';

  @override
  String get navHistory => '履歴';

  @override
  String get navStats => '統計';

  @override
  String get navSettings => '設定';

  @override
  String get splashGreeting => 'ナマスカラ';

  @override
  String splashGreetingWithName(String name) {
    return 'ナマスカラ、$name';
  }

  @override
  String get splashTapToBegin => 'タップして始める';

  @override
  String get welcomeTitle => 'Cittaへようこそ';

  @override
  String get welcomeNameHint => 'お名前を入力してください';

  @override
  String get firstTimeSetupSubtitle => '始める前に、いくつか設定しましょう。';

  @override
  String get firstTimeSetupThemeSectionTitle => 'テーマを選択';

  @override
  String get firstTimeSetupEncryptionAlreadyEnabledNotice =>
      'あなたの振り返りの暗号化はすでに有効になっています。';

  @override
  String get firstTimeSetupContinueButton => 'はじめる';

  @override
  String get homeBegin => '開始';

  @override
  String get homeCountdown => 'カウントダウン';

  @override
  String get homeStopwatch => 'ストップウォッチ';

  @override
  String get homeMin => '分';

  @override
  String get historyTitle => '履歴';

  @override
  String historySelected(int count) {
    return '$count件選択';
  }

  @override
  String get historyDeleteTitle => 'セッションを削除';

  @override
  String historyDeleteConfirm(int count) {
    return '$count件のセッションを削除しますか？この操作は元に戻せません。';
  }

  @override
  String get historyFilterAll => 'すべて';

  @override
  String get historyEmpty => 'まだセッションがありません';

  @override
  String get historyEmptyHint => '最初の瞑想セッションを完了して\nここで確認しましょう';

  @override
  String get statsTitle => '統計';

  @override
  String get statsToggleCalendar => 'カレンダー表示を切り替え';

  @override
  String get statsCurrentStreak => '現在の連続記録';

  @override
  String get statsLongestStreak => '最長連続記録';

  @override
  String get statsTotalSessions => '合計セッション数';

  @override
  String get statsAverage => '平均';

  @override
  String statsDays(num count) {
    return '$count日';
  }

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsProfile => 'プロフィール';

  @override
  String get settingsName => '名前';

  @override
  String get settingsNameNotSet => '未設定';

  @override
  String get settingsEditName => '名前を編集';

  @override
  String get settingsAppearance => '外観';

  @override
  String get settingsTheme => 'テーマ';

  @override
  String get settingsThemeDark => 'ダーク';

  @override
  String get settingsThemeLight => 'ライト';

  @override
  String get settingsThemeSystem => 'システム';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsColorPalette => 'カラーパレット';

  @override
  String get settingsLanguageSystem => 'システムのデフォルト';

  @override
  String get settingsTimer => 'タイマー';

  @override
  String get settingsDefaultMode => 'デフォルトモード';

  @override
  String get settingsDefaultDuration => 'デフォルト時間';

  @override
  String settingsDurationMinutes(int count) {
    return '$count分';
  }

  @override
  String get settingsCountdown => 'カウントダウン';

  @override
  String get settingsCountdownDesc => '時間を設定し、タイマーがカウントダウン';

  @override
  String get settingsStopwatch => 'ストップウォッチ';

  @override
  String get settingsStopwatchDesc => '自由時間、手動で停止';

  @override
  String get settingsBellSounds => 'ベル音';

  @override
  String get settingsStartBell => '開始ベル';

  @override
  String get settingsEndBell => '終了ベル';

  @override
  String get settingsIntervalBell => 'インターバルベル';

  @override
  String get settingsBellNone => 'なし';

  @override
  String get settingsPickFromDevice => 'デバイスから選択...';

  @override
  String get settingsEnableInterval => 'インターバルベルを有効化';

  @override
  String settingsIntervalEvery(int count) {
    return '$count分ごと';
  }

  @override
  String get settingsOff => 'オフ';

  @override
  String get settingsIntervalDuration => 'インターバル時間';

  @override
  String get settingsIntervalSound => 'インターバル音';

  @override
  String get settingsBgMusic => 'バックグラウンドミュージック';

  @override
  String get settingsMusicFile => '音楽ファイル';

  @override
  String get settingsMusicSelected => '選択済み';

  @override
  String get settingsMusicNone => 'なし';

  @override
  String get settingsRemoveMusic => 'バックグラウンドミュージックを削除';

  @override
  String get settingsTags => 'タグ';

  @override
  String get settingsAddTag => '+ 追加';

  @override
  String get settingsAddTagTitle => 'タグを追加';

  @override
  String get settingsAddTagHint => '例: 集中';

  @override
  String get settingsQuotes => '引用';

  @override
  String get settingsAddCustomQuote => 'カスタム引用を追加';

  @override
  String settingsUserQuotes(int count) {
    return 'ユーザー引用 $count件';
  }

  @override
  String get settingsData => 'データ';

  @override
  String get settingsExport => 'データをエクスポート';

  @override
  String get settingsExportDesc => 'セッションと設定をJSONで共有';

  @override
  String get settingsImport => 'データをインポート';

  @override
  String get settingsImportDesc => 'Citta JSONエクスポートファイルから読み込む';

  @override
  String get settingsImportReplaceMsg => '既存のデータをすべて置き換えますか、それとも現在のデータと統合しますか？';

  @override
  String get settingsMerge => '統合';

  @override
  String get settingsReplaceAll => 'すべて置き換え';

  @override
  String get settingsImportSuccess => 'データが正常にインポートされました';

  @override
  String get settingsImportError => '無効なインポートファイル';

  @override
  String settingsExportFailed(String error) {
    return 'エクスポートに失敗しました: $error';
  }

  @override
  String get settingsExportChooseTitle => 'データをエクスポート';

  @override
  String get settingsExportChooseMsg => '通常のJSONとして、それとも暗号化してエクスポートしますか？';

  @override
  String get settingsExportChoosePlain => '通常のJSON';

  @override
  String get settingsExportChooseEncrypted => '暗号化';

  @override
  String get settingsImportEncryptedTitle => '暗号化されたエクスポート';

  @override
  String get settingsImportEncryptedSubtitle =>
      'このエクスポートの暗号化に使用したパスワードまたは復旧キーを入力してください。';

  @override
  String get settingsImportEncryptedInputLabel => 'パスワードまたは復旧キー';

  @override
  String get settingsImportEncryptedSubmitButton => 'ロック解除';

  @override
  String get settingsImportEncryptedErrorEmpty => 'パスワードまたは復旧キーを入力してください';

  @override
  String get settingsImportEncryptedErrorWrong =>
      'パスワードまたは復旧キーが正しくありません。もう一度お試しください。';

  @override
  String get notesTitle => 'セッションノート';

  @override
  String get notesPrompt => '練習はいかがでしたか？';

  @override
  String get notesHint => '体験について書いてください... (テキストまたはMarkdown)';

  @override
  String notesWordCount(int count) {
    return '$count / 500 語';
  }

  @override
  String get notesTags => 'タグ';

  @override
  String get sessionComplete => 'セッション完了';

  @override
  String get sessionTitle => 'セッション';

  @override
  String sessionDateAt(String date, String time) {
    return '$date $time';
  }

  @override
  String get sessionCountdown => 'カウントダウン';

  @override
  String get sessionStopwatch => 'ストップウォッチ';

  @override
  String get sessionCompleted => '完了';

  @override
  String get sessionNotes => 'ノート';

  @override
  String get sessionNoNotes => 'このセッションにノートはありません';

  @override
  String get addQuoteTitle => '引用を追加';

  @override
  String get addQuoteOriginalText => '原文 *';

  @override
  String get addQuoteOriginalHint => '元のスクリプトで引用を入力...';

  @override
  String get addQuoteLanguage => '言語';

  @override
  String get addQuoteTranslation => '英語訳 *';

  @override
  String get addQuoteTranslationHint => '英語訳を入力...';

  @override
  String get addQuoteSource => '出典';

  @override
  String get addQuoteSourceHint => '例: バガヴァッド・ギーター';

  @override
  String get addQuoteReference => '参照';

  @override
  String get addQuoteReferenceHint => '例: 第2章、第47節';

  @override
  String get addQuoteSave => '引用を保存';

  @override
  String get addQuoteAdded => '引用が追加されました';

  @override
  String get langEnglish => '英語';

  @override
  String get langHindi => 'ヒンディー語';

  @override
  String get langKannada => 'カンナダ語';

  @override
  String get langSanskrit => 'サンスクリット語';

  @override
  String get langTelugu => 'テルグ語';

  @override
  String get langTamil => 'タミル語';

  @override
  String get langMalayalam => 'マラヤーラム語';

  @override
  String get langFrench => 'フランス語';

  @override
  String get langGerman => 'ドイツ語';

  @override
  String get langJapanese => '日本語';

  @override
  String get langHebrew => 'ヘブライ語';

  @override
  String get langChinese => '中国語';

  @override
  String get langMarathi => 'マラーティー語';

  @override
  String get langGujarati => 'グジャラート語';

  @override
  String get langOdia => 'オディア語';

  @override
  String get langBengali => 'ベンガル語';

  @override
  String get langTulu => 'トゥル語';

  @override
  String get langKonkani => 'コンカニ語';

  @override
  String get langUrdu => 'ウルドゥー語';

  @override
  String get langItalian => 'イタリア語';

  @override
  String get langSpanish => 'スペイン語';

  @override
  String get langArabic => 'アラビア語';

  @override
  String get langRussian => 'ロシア語';

  @override
  String get langPortuguese => 'ポルトガル語';

  @override
  String get langMaithili => 'マイティリー語';

  @override
  String get langAssamese => 'アッサム語';

  @override
  String get langPunjabi => 'パンジャブ語';

  @override
  String get langOther => 'その他';

  @override
  String get preSessionSetup => 'セッション設定';

  @override
  String get timerPaused => '一時停止';

  @override
  String get encryptionToggleTitle => '振り返りを暗号化する';

  @override
  String get encryptionToggleSubtitle => 'パスワードでこの端末上のセッションを保護します';

  @override
  String get encryptionPasswordLabel => 'パスワード';

  @override
  String get encryptionConfirmPasswordLabel => 'パスワードの確認';

  @override
  String get encryptionEnableButton => '暗号化を有効にする';

  @override
  String get encryptionErrorEmpty => 'パスワードを入力してください';

  @override
  String encryptionErrorTooShort(int minLength) {
    return 'パスワードは$minLength文字以上にしてください';
  }

  @override
  String get encryptionErrorMismatch => 'パスワードが一致しません';

  @override
  String get encryptionErrorGeneric => '暗号化を有効にできませんでした。もう一度お試しください。';

  @override
  String get recoveryKeyScreenTitle => '復旧キーを保存してください';

  @override
  String get recoveryKeyWarning =>
      'パスワードを忘れた場合、これがデータを復元する唯一の方法です。両方を失うと、データは完全に復元できなくなります。';

  @override
  String get recoveryKeyCopyButton => 'コピー';

  @override
  String get recoveryKeyShareButton => '共有';

  @override
  String get recoveryKeyAckLabel => '復旧キーを安全な場所に保存しました';

  @override
  String get recoveryKeyContinueButton => '続ける';

  @override
  String get recoveryKeyErrorGeneric => '復旧キーを生成できませんでした。もう一度お試しください。';

  @override
  String get unlockTitle => 'Cittaのロックを解除';

  @override
  String get unlockSubtitle => '振り返りにアクセスするには、パスワードまたは復旧キーを入力してください。';

  @override
  String get unlockInputLabel => 'パスワードまたは復旧キー';

  @override
  String get unlockSubmitButton => 'ロック解除';

  @override
  String get unlockErrorEmpty => 'パスワードまたは復旧キーを入力してください';

  @override
  String get unlockErrorGeneric => 'パスワードまたは復旧キーが正しくありません。もう一度お試しください。';

  @override
  String get unlockErrorCorrupted => '暗号化されたデータを読み込めませんでした。データが破損している可能性があります。';

  @override
  String get settingsEncryptionTitle => '暗号化';

  @override
  String get settingsEncryptionSubtitleEnabled => 'この端末上のセッションは暗号化されています';

  @override
  String get settingsEncryptionSubtitleDisabled => 'パスワードでセッションを保護します';

  @override
  String get enableEncryptionScreenTitle => '暗号化を有効にする';

  @override
  String get settingsEncryptionDisableConfirmTitle => '暗号化を無効にしますか？';

  @override
  String get settingsEncryptionDisableConfirmMessage =>
      'この端末上のセッションは、再び平文で保存されるようになります。';

  @override
  String get settingsEncryptionDisableConfirmButton => '無効にする';

  @override
  String get settingsEncryptionDisableError => '暗号化を無効にできませんでした。もう一度お試しください。';

  @override
  String get settingsChangePasswordTitle => 'パスワードを変更';

  @override
  String get settingsChangePasswordSubtitle => 'セッションを保護しているパスワードを更新します';

  @override
  String get changePasswordScreenTitle => 'パスワードを変更';

  @override
  String get changePasswordCurrentLabel => '現在のパスワード';

  @override
  String get changePasswordNewLabel => '新しいパスワード';

  @override
  String get changePasswordConfirmLabel => '新しいパスワードの確認';

  @override
  String get changePasswordSubmitButton => 'パスワードを変更';

  @override
  String get changePasswordErrorEmpty => '現在のパスワードと新しいパスワードを入力してください';

  @override
  String changePasswordErrorTooShort(int minLength) {
    return '新しいパスワードは$minLength文字以上にしてください';
  }

  @override
  String get changePasswordErrorMismatch => '新しいパスワードが一致しません';

  @override
  String get changePasswordErrorWrongCurrent => '現在のパスワードが正しくありません';

  @override
  String get changePasswordErrorGeneric => 'パスワードを変更できませんでした。もう一度お試しください。';

  @override
  String get changePasswordSuccess => 'パスワードが正常に変更されました';
}
