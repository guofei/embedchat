/*
 * action type
 */

export const SEND_MESSAGE = 'SEND_MESSAGE';
export const RECEIVE_MESSAGE = 'RECEIVE_MESSAGE';
export const RECEIVE_HISTORY_MESSAGE = 'RECEIVE_HISTORY_MESSAGE';
export const RECEIVE_HISTORY_MESSAGES = 'RECEIVE_HISTORY_MESSAGES';
export const RECEIVE_USER_ONLINE = 'RECEIVE_USER_ONLINE';
export const RECEIVE_ADMIN_ONLINE = 'RECEIVE_ADMIN_ONLINE';
export const RECEIVE_MULTI_USERS_ONLINE = 'RECEIVE_MULTI_USERS_ONLINE';
export const RECEIVE_MULTI_ADMINS_ONLINE = 'RECEIVE_MULTI_ADMINS_ONLINE';
export const RECEIVE_USER_OFFLINE = 'RECEIVE_USER_OFFLINE';
export const RECEIVE_MULTI_USERS_OFFLINE = 'RECEIVE_MULTI_USERS_OFFLINE';
export const RECEIVE_ADMIN_OFFLINE = 'RECEIVE_ADMIN_OFFLINE';
export const RECEIVE_ACCESS_LOG = 'RECEIVE_ACCESS_LOG';
export const RECEIVE_MULTI_ACCESS_LOGS = 'RECEIVE_MULTI_ACCESS_LOGS';
export const CURRENT_USER = 'CURRENT_USER';
export const CURRENT_USER_EMAIL = 'CURRENT_USER_EMAIL';
export const SELECT_USER = 'SELECT_USER';
export const READ_MESSAGE = 'READ_MESSAGE';
export const READ_ALL_MESSAGES = 'READ_ALL_MESSAGES';
export const OPEN_CHAT = 'OPEN_CHAT';

/*
 * action function
 */

export function openChat(open) {
  return { type: OPEN_CHAT, open };
}

export function setCurrentUser(uid) {
  return { type: CURRENT_USER, uid };
}

export function setCurrentUserEmail(email) {
  return { type: CURRENT_USER_EMAIL, email };
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

export function receiveHistoryMessage(message) {
  return { type: RECEIVE_HISTORY_MESSAGE, message };
}

export function receiveHistoryMessages(messages) {
  return { type: RECEIVE_HISTORY_MESSAGES, messages };
}

export function readMessage(message) {
  return { type: READ_MESSAGE, message };
}

export function readAllMessages() {
  return { type: READ_ALL_MESSAGES };
}

export function receiveUserOnline(user) {
  return { type: RECEIVE_USER_ONLINE, user };
}

export function receiveAdminOnline(user) {
  return { type: RECEIVE_ADMIN_ONLINE, user };
}

export function receiveMultiAdminsOnline(users) {
  return { type: RECEIVE_MULTI_ADMINS_ONLINE, users };
}

export function receiveMultiUsersOnline(users) {
  return { type: RECEIVE_MULTI_USERS_ONLINE, users };
}

export function receiveUserOffline(user) {
  return { type: RECEIVE_USER_OFFLINE, user };
}

export function receiveMultiUsersOffline(users) {
  return { type: RECEIVE_MULTI_USERS_OFFLINE, users };
}

export function receiveAdminOffline(user) {
  return { type: RECEIVE_ADMIN_OFFLINE, user };
}

export function receiveAccessLog(log) {
  return { type: RECEIVE_ACCESS_LOG, log };
}

export function receiveMultiAccessLogs(logs) {
  return { type: RECEIVE_MULTI_ACCESS_LOGS, logs };
}
