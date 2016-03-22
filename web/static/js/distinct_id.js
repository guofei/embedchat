import uuid from 'uuid';

const Distinct = {
  getClient() {
    const key = 'distinct_id';
    return this.getID(key);
  },

  getMaster() {
    const key = 'm_distinct_id';
    return this.getID(key);
  },

  getID(key) {
    if (this.getCookie(key) !== '') {
      return this.getCookie(key);
    }
    const distid = uuid.v4();
    this.setCookie(key, distid, 365);
    return distid;
  },

  setCookie(cname, cvalue, exdays) {
    const d = new Date();
    d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
    const expires = `expires=${d.toUTCString()}`;
    document.cookie = `${cname}=${cvalue};${expires}`;
  },

  getCookie(cname) {
    const name = `${cname}=`;
    const ca = document.cookie.split(';');
    for (let i = 0; i < ca.length; i++) {
      let c = ca[i];
      while (c.charAt(0) === ' ') {
        c = c.substring(1);
      }
      if (c.indexOf(name) === 0) {
        return c.substring(name.length, c.length);
      }
    }
    return '';
  },
};

export const clientID = Distinct.getClient();
export const masterID = Distinct.getMaster();
