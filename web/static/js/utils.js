export function arrayToObject(arr, key, assignSource = {}) {
  return arr.reduce((pre, cur) => {
    const obj = Object.assign({}, cur, assignSource);
    return Object.assign({}, pre, { [obj[key]]: obj });
  }, {});
}

export function objectToArray(obj) {
  return Object.keys(obj).map((k) => obj[k]);
}

export function userName(uuid, users, name = '') {
  if (users[uuid]) {
    return users[uuid].name;
  }
  if (name) {
    return name;
  }
  return uuid;
}

export function shortName(fullName) {
  if (fullName.length > 0) {
    if (fullName.includes('@')) {
      return fullName;
    }
    return fullName.substring(0, 7);
  }
  return 'unknown';
}

export function avatar(fullName) {
  return shortName(fullName)[0].toUpperCase();
}

export function userShortName(uuid, users, name = '') {
  if (users[uuid]) {
    return shortName(users[uuid].name);
  }
  if (name) {
    return shortName(name);
  }
  return shortName(uuid);
}
