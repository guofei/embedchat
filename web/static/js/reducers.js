import { combineReducers } from 'redux';
import {
  RECEIVE_MESSAGE,
  RECEIVE_HISTORY_MESSAGE,
  RECEIVE_HISTORY_MESSAGES,
  READ_MESSAGE,
  READ_ALL_MESSAGES,
  CURRENT_USER,
  CURRENT_USER_EMAIL,
  SELECT_USER,
  RECEIVE_USER_ONLINE,
  RECEIVE_USER_OFFLINE,
  RECEIVE_MULTI_USERS_ONLINE,
  RECEIVE_MULTI_USERS_OFFLINE,
  RECEIVE_ADMIN_ONLINE,
  RECEIVE_ADMIN_OFFLINE,
  RECEIVE_MULTI_ADMINS_ONLINE,
  RECEIVE_ACCESS_LOG,
  RECEIVE_MULTI_ACCESS_LOGS,
  OPEN_CHAT,
} from './actions';

// state tree sample
/*
let state_tree = {
  messages: {
    1: {
      id: 1,
      type: 'normal',
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
      id: 1,
      uid: 'xxx-xxx-xxx',
      name: 'name' // can be empty or null
      online: false,
      admin: false,
    },
  },
  logs: {
    1: {
      id: 1,
      uid: 'xxx'
      agent: 'IE',
      inserted_at: '11:12',
      current_url: 'http://abc.com',
      referrer: 'http://ref.com',
      screen_width: 100,
      screen_height: 100,
      visit_view: 1,
      single_page_view: 1,
      total_page_view: 1,
    },
  },
  // ui state
  currentUser: 'xxx-xxx-xxx',
  currentUserEmail: 'email@domain.com',
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
  return arr.reduce((pre, cur) => {
    const obj = Object.assign({}, cur, { unread: false });
    return Object.assign({}, pre, { [obj.id]: obj });
  }, {});
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
      return Object.assign({}, state,
        action.user, { online: true, admin: false });
    case RECEIVE_USER_OFFLINE:
      return Object.assign({}, state,
        action.user, { online: false });
    case RECEIVE_ADMIN_ONLINE:
      return Object.assign({}, state,
        action.user, { online: true, admin: true });
    case RECEIVE_ADMIN_OFFLINE:
      return Object.assign({}, state,
        action.user, { online: false });
    default:
      return state;
  }
}

function usersArrToObj(arr, isOnline, isAdmin) {
  return arr.reduce((pre, cur) =>
    Object.assign({}, pre, {
      [cur.uid]:
      Object.assign({}, cur, { online: isOnline, admin: isAdmin }),
    }), {});
}

function users(state = {}, action) {
  switch (action.type) {
    case RECEIVE_USER_ONLINE:
    case RECEIVE_USER_OFFLINE:
    case RECEIVE_ADMIN_ONLINE:
    case RECEIVE_ADMIN_OFFLINE:
      return Object.assign({}, state,
        { [action.user.uid]: user(state[action.user.uid], action) });
    case RECEIVE_MULTI_USERS_ONLINE:
      return Object.assign({}, state,
        usersArrToObj(action.users, true, false));
    case RECEIVE_MULTI_USERS_OFFLINE:
      return Object.assign({}, state,
        usersArrToObj(action.users, false, false));
    case RECEIVE_MULTI_ADMINS_ONLINE:
      return Object.assign({}, state,
        usersArrToObj(action.users, true, true));
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

function currentUserEmail(state = '', action) {
  switch (action.type) {
    case CURRENT_USER_EMAIL:
      return action.email;
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

function logsArrToObj(arr, startID) {
  return arr.reduce((pre, cur, i) =>
    Object.assign({}, pre, {
      [startID + i]:
      Object.assign({}, cur),
    }), {});
}

function logs(state = {}, action) {
  switch (action.type) {
    case RECEIVE_ACCESS_LOG:
      return Object.assign({}, state,
        { [Object.keys(state).length + 1]: action.log });
    case RECEIVE_MULTI_ACCESS_LOGS: {
      const len = Object.keys(state).length + 1;
      const obj = logsArrToObj(action.logs, len);
      return Object.assign({}, state, obj);
    }
    default:
      return state;
  }
}

const chatApp = combineReducers({
  currentUser,
  currentUserEmail,
  selectedUser,
  users,
  messages,
  logs,
  openChat,
});

export default chatApp;
