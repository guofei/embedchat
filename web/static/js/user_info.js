import moment from 'moment';
import { getCookie, setCookie } from './cookies';

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
  const key = 'visit_view';
  if (getCookie(key) !== '') {
    const oldNumber = parseInt(getCookie(key), 10);
    setCookie(key, oldNumber + 1, 365);
    return oldNumber + 1;
  }
  setCookie(key, 1, 365);
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
