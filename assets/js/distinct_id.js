import uuid from 'uuid';
import { getCookie, setCookie } from './cookies';

const Distinct = {
  getClient() {
    const key = 'distinct_id';
    return this.getID(key);
  },

  getMaster() {
    return window.userAddress;
  },

  getID(key) {
    if (getCookie(key) !== '') {
      return getCookie(key);
    }
    const distid = uuid.v4();
    setCookie(key, distid, 365);
    return distid;
  },
};

export const clientID = Distinct.getClient();
export const masterID = Distinct.getMaster();
