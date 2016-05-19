import moment from 'moment';
import store from 'store';

function getBrowserLanguage() {
  const first = window.navigator.languages
    ? window.navigator.languages[0]
    : null;

  const lang = first
    || window.navigator.language
    || window.navigator.browserLanguage
    || window.navigator.userLanguage;

  return lang;
}

function visitView() {
  const key = `${location.pathname}_vv`;
  if (store.get(key)) {
    const oldNumber = store.get(key);
    store.set(key, oldNumber + 1);
    return oldNumber + 1;
  }
  store.set(key, 1);
  return 1;
}

const UserInfo = {
  userAgent: navigator.userAgent,
  href: location.href,
  referrer: document.referrer,
  screenwidth: screen.width,
  screenHeight: screen.height,
  language: getBrowserLanguage(),
  visitView: visitView(),
  inserted_at: moment.utc().format(),
};

export default UserInfo;
