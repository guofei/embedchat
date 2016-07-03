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

function autoIncrement(key) {
  if (store.get(key)) {
    const oldNumber = store.get(key);
    store.set(key, oldNumber + 1);
    return oldNumber + 1;
  }
  store.set(key, 1);
  return 1;
}

function visitView() {
  const key = `${location.pathname}_vv`;
  return autoIncrement(key);
}

const currentPageView = visitView();

function totalPageView() {
  const key = 'lwn_total_pv_';
  return autoIncrement(key);
}

const UserInfo = {
  userAgent: navigator.userAgent,
  href: location.href,
  referrer: document.referrer,
  screenwidth: screen.width,
  screenHeight: screen.height,
  language: getBrowserLanguage(),
  visitView: currentPageView,
  singlePageView: currentPageView,
  totalPageView: totalPageView(),
  inserted_at: moment.utc().format(),
  isBot() {
    if (navigator.userAgent && navigator.userAgent.indexOf('bot') > -1) {
      return true;
    }
    return false;
  },
};

export default UserInfo;
