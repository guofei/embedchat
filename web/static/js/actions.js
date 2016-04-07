/*
 * action type
 */

export const SEND_MESSAGE = 'SEND_MESSAGE';
export const RECEIVE_MESSAGE = 'RECEIVE_MESSAGE';
export const RECEIVE_USER_ONLINE = 'RECEIVE_USER_ONLINE';
export const RECEIVE_USER_OFFLINE = 'RECEIVE_USER_OFFLINE';
export const RECEIVE_ACCESS_LOG = 'RECEIVE_ACCESS_LOG';
export const CURRENT_USER = 'CURRENT_USER';
export const SELECT_USER = 'SELECT_USER';

/*
 * action function
 */

export function setCurrentUser(uid) {
  return { type: CURRENT_USER, uid };
}

export function selectUser(uid) {
  return { type: SELECT_USER, uid };
}

export function sendMessage(message) {
  return { type: SEND_MESSAGE, message };
}

export function receiveMessage(message) {
  return { type: RECEIVE_MESSAGE, message };
}

export function receiveUserOnline(user) {
  return { type: RECEIVE_USER_ONLINE, user };
}

export function receiveUserOffline(user) {
  return { type: RECEIVE_USER_OFFLINE, user };
}

export function receiveAccessLog(log) {
  return { type: RECEIVE_ACCESS_LOG, log };
}