import { combineReducers } from 'redux';
import {
  RECEIVE_MESSAGE,
  RECEIVE_HISTORY_MESSAGE,
  RECEIVE_HISTORY_MESSAGES,
  READ_MESSAGE,
  READ_ALL_MESSAGES,
  CURRENT_USER,
  SELECT_USER,
  RECEIVE_USER_ONLINE,
  RECEIVE_USER_OFFLINE,
  RECEIVE_MULTI_USERS_ONLINE,
  RECEIVE_ACCESS_LOG,
  OPEN_CHAT,
} from './actions';

// state tree sample
/*
let state_tree = {
  messages: {
    1: {
      id: 1,
      from_id: 'xxx-xxx-xxx',
      from_name: 'name',
      to_id: 'xxx-xxx-xxx',
      body: 'hi',
      inserted_at: '11:10',
      unread: true,
    },
  },
  users: {
    xxx-xxx-xxx: {
      uid: 'xxx-xxx-xxx',
      name: 'name' // can be empty or null
      online: false,
    },
  },
  logs: {
    1: { id: 1, inserted_at: '11:12', href: 'http://abc.com', uid: 'xxx' },
  },
  // ui state
  currentUser: 'xxx-xxx-xxx',
  selectedUser: 'xxx-xxx-xxx',
  openChat: false,
}
*/

function openChat(state = false, action) {
  switch (action.type) {
    case OPEN_CHAT:
      return action.open;
    default:
      return state;
  }
}

function readAll(obj) {
  const newObj = Object.assign({}, obj);
  for (const k in newObj) {
    if (newObj.hasOwnProperty(k)) {
      const unread = 'unread';
      newObj[k][unread] = false;
    }
  }
  return newObj;
}

function arrWithIDToObj(arr) {
  return arr.reduce((pre, cur) =>
    Object.assign({}, pre, { [cur.id]: cur }), {});
}

function messages(state = {}, action) {
  switch (action.type) {
    case RECEIVE_MESSAGE:
      return Object.assign({}, state,
        { [action.message.id]:
          Object.assign({}, action.message, { unread: true }) });
    case RECEIVE_HISTORY_MESSAGE:
      return Object.assign({}, state,
        { [action.message.id]:
          Object.assign({}, action.message, { unread: false }) });
    case RECEIVE_HISTORY_MESSAGES:
      return Object.assign({}, state, arrWithIDToObj(action.messages));
    case READ_MESSAGE:
      return Object.assign({}, state,
        { [action.message.id]:
          Object.assign({}, action.message, { unread: false }) });
    case READ_ALL_MESSAGES:
      return readAll(state);
    default:
      return state;
  }
}

function user(state = {}, action) {
  switch (action.type) {
    case RECEIVE_USER_ONLINE:
      return Object.assign({}, state, action.user, { online: true });
    case RECEIVE_USER_OFFLINE:
      return Object.assign({}, state, action.user, { online: false });
    default:
      return state;
  }
}

function onlineUsersArrToObj(arr) {
  return arr.reduce((pre, cur) =>
    Object.assign({}, pre, {
      [cur.uid]:
      Object.assign({}, cur, { online: true }),
    }), {});
}

function users(state = {}, action) {
  switch (action.type) {
    case RECEIVE_USER_ONLINE:
    case RECEIVE_USER_OFFLINE:
      return Object.assign({}, state,
        { [action.user.uid]: user(state[action.user.uid], action) });
    case RECEIVE_MULTI_USERS_ONLINE:
      return Object.assign({}, state, onlineUsersArrToObj(action.users));
    default:
      return state;
  }
}

function currentUser(state = '', action) {
  switch (action.type) {
    case CURRENT_USER:
      return action.uid;
    default:
      return state;
  }
}

function selectedUser(state = '', action) {
  switch (action.type) {
    case SELECT_USER:
      return action.uid;
    default:
      return state;
  }
}

function logs(state = {}, action) {
  switch (action.type) {
    case RECEIVE_ACCESS_LOG:
      return Object.assign({}, state,
        { [Object.keys(state).length + 1]: action.log });
    default:
      return state;
  }
}

const chatApp = combineReducers({
  currentUser,
  selectedUser,
  users,
  messages,
  logs,
  openChat,
});

export default chatApp;
