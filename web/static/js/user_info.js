import moment from 'moment';

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

const UserInfo = {
  userAgent: navigator.userAgent,
  href: location.href,
  referrer: document.referrer,
  screenwidth: screen.width,
  screenHeight: screen.height,
  language: getBrowserLanguage(),
  inserted_at: moment.utc().format(),
};

export default UserInfo;
