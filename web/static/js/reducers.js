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
  SELECT_USER_DETAIL_MENU,
  RECEIVE_USER_ONLINE,
  RECEIVE_USER_OFFLINE,
  RECEIVE_MULTI_USERS_ONLINE,
  RECEIVE_MULTI_USERS_OFFLINE,
  RECEIVE_ADMIN_ONLINE,
  RECEIVE_ADMIN_OFFLINE,
  RECEIVE_MULTI_ADMINS_ONLINE,
  RECEIVE_ACCESS_LOG,
  RECEIVE_MULTI_ACCESS_LOGS,
  UPDATE_VISITOR,
  OPEN_CHAT,
} from './actions';
import { USERMENU } from './components/common/ui-const.js';
import { arrayToObject } from './utils.js';

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
      name: 'name',
      email: 'email', // can be null
      note: 'note', // can be null
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
  selectedUserDetailMenu: USERMENU,
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

function selectedUserDetailMenu(state = USERMENU.TRACKING, action) {
  switch (action.type) {
    case SELECT_USER_DETAIL_MENU:
      return action.menu;
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
      return Object.assign({}, state, arrayToObject(action.messages, 'id', { unread: false }));
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
    case UPDATE_VISITOR:
      return Object.assign({}, state, action.user);
    default:
      return state;
  }
}

function users(state = {}, action) {
  switch (action.type) {
    case RECEIVE_USER_ONLINE:
    case RECEIVE_USER_OFFLINE:
    case RECEIVE_ADMIN_ONLINE:
    case RECEIVE_ADMIN_OFFLINE:
    case UPDATE_VISITOR:
      return Object.assign({}, state,
        { [action.user.uid]: user(state[action.user.uid], action) });
    case RECEIVE_MULTI_USERS_ONLINE:
      return Object.assign({}, state,
        arrayToObject(action.users, 'uid', { online: true, admin: false }));
    case RECEIVE_MULTI_USERS_OFFLINE:
      return Object.assign({}, state,
        arrayToObject(action.users, 'uid', { online: false, admin: false }));
    case RECEIVE_MULTI_ADMINS_ONLINE:
      return Object.assign({}, state,
        arrayToObject(action.users, 'uid', { online: true, admin: true }));
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

function log(state = {}, action) {
  switch (action.type) {
    case RECEIVE_ACCESS_LOG:
      return Object.assign({}, state, action.log);
    default:
      return state;
  }
}

function logs(state = {}, action) {
  switch (action.type) {
    case RECEIVE_ACCESS_LOG:
      return Object.assign({}, state, { [action.log.id]: log(state[action.log.id], action) });
    case RECEIVE_MULTI_ACCESS_LOGS: {
      return Object.assign({}, state, arrayToObject(action.logs, 'id'));
    }
    default:
      return state;
  }
}

const chatApp = combineReducers({
  currentUser,
  currentUserEmail,
  selectedUser,
  selectedUserDetailMenu,
  users,
  messages,
  logs,
  openChat,
});

export default chatApp;
