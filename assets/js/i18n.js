import i18n from 'i18next';
import LngDetector from 'i18next-browser-languagedetector';
import moment from 'moment';

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
        youWillBeNotifiedAt: '{{email}}にご返答致します',
      },
    },
  },
}, () => {
  moment.locale(i18n.language || window.navigator.userLanguage || window.navigator.language);
});

export default i18n;
