function lang() {
  if (navigator.userLanguage === 'string') {
    return navigator.userLanguage;
  } else if (navigator.language === 'string') {
    return navigator.language;
  }
  return '(Not supported)';
}

const UserInfo = {
  userAgent: navigator.userAgent,
  href: location.href,
  referrer: document.referrer,
  screenidth: screen.width,
  screenHeight: screen.height,
  language: lang(),
};

export default UserInfo;
