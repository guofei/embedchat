function lang() {
  if (navigator.userLanguage !== undefined) {
    return navigator.userLanguage;
  } else if (navigator.language !== undefined) {
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
  inserted_at: new Date().toLocaleTimeString(),
};

export default UserInfo;
