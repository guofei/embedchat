/*
 * action type
 */

export const NEW_MESSAGE = 'NEW_MESSAGE';
export const USER_ONLINE = 'USER_ONLINE';
export const NEW_ACCESS_LOG = 'NEW_ACCESS_LOG';

/*
 * action function
 */

export function newMessage(message) {
  return { type: NEW_MESSAGE, message };
}

export function userOnline(user) {
  return { type: USER_ONLINE, user };
}

export function newAccessLog(log) {
  return { type: NEW_ACCESS_LOG, log };
}
