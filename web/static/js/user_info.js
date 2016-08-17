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

function totalPageView() {
  const key = 'lwn_total_pv_';
  return autoIncrement(key);
}

export default function nextUserAccessLog() {
  const singlePageView = visitView();
  const info = {
    agent: navigator.userAgent,
    current_url: location.href,
    referrer: document.referrer,
    screen_width: screen.width,
    screen_height: screen.height,
    language: getBrowserLanguage(),
    visit_view: singlePageView,
    single_page_view: singlePageView,
    total_page_view: totalPageView(),
    inserted_at: moment.utc().format(),
    isBot() {
      if (navigator.userAgent && navigator.userAgent.indexOf('bot') > -1) {
        return true;
      }
      return false;
    },
  };
  return info;
}
