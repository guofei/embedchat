import isbot from 'is-bot';

export function isBot() {
  if (window.navigator.userAgent) {
    return isbot(window.navigator.userAgent);
  }
  return false;
}

export function arrayToObject(arr, key, assignSource = {}) {
  return arr.reduce((pre, cur) => {
    const obj = Object.assign({}, cur, assignSource);
    return Object.assign({}, pre, { [obj[key]]: obj });
  }, {});
}

export function objectToArray(obj) {
  return Object.keys(obj).map(k => obj[k]);
}

export function shortName(fullName) {
  if (fullName && fullName.length > 0) {
    if (fullName.includes('@')) {
      return fullName;
    }
    return fullName.substring(0, 7);
  }
  const defaultName = 'unknown';
  return defaultName.substring(0, 7);
}

export function avatar(fullName) {
  if (fullName && fullName.length > 0) {
    return shortName(fullName)[0].toUpperCase();
  }
  const defaultName = 'unknown';
  return defaultName[0].toUpperCase();
}

export function userName(uuid, users, name = '') {
  if (users[uuid]) {
    const user = users[uuid];
    if (user.name || user.email) {
      return user.name || user.email;
    }
  }
  if (name) {
    return name;
  }
  return uuid;
}

export function userShortName(uuid, users, name = '') {
  if (users[uuid]) {
    const user = users[uuid];
    if (user.name || user.email) {
      return user.name || shortName(user.email);
    }
  }
  if (name) {
    return name;
  }
  return shortName(uuid);
}
