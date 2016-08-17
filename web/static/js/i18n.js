import i18n from 'i18next';
import LngDetector from 'i18next-browser-languagedetector';

i18n
.use(LngDetector)
.init({
  fallbackLng: 'en',
  resources: {
    en: {
      translation: {
        chat: 'Chat',
        input: 'Input Message',
        you: 'You',
        getEmail: 'Get replies by email',
        youWillBeNotifiedAt: 'You will be notified at {{email}}',
      },
    },
    ja: {
      translation: {
        chat: 'チャット',
        input: 'メッセージを入力してください',
        you: 'あなた',
        getEmail: 'メールで返信を取得する',
        youWillBeNotifiedAt: 'You will be notified at {{email}}',
      },
    },
  },
});

export default i18n;
