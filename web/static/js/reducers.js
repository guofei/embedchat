import { combineReducers } from 'redux';
import {
  RECEIVE_MESSAGE,
  CURRENT_USER,
  SELECT_USER,
  RECEIVE_USER_ONLINE,
  RECEIVE_USER_OFFLINE,
  RECEIVE_ACCESS_LOG,
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
      inserted_at: '11:10'
    },
  },
  users: {
    xxx-xxx-xxx: {
      uid: 'xxx-xxx-xxx',
      online: false,
    },
  },
  logs: {
    1: { id: 1, inserted_at: '11:12', href: 'http://abc.com', uid: 'xxx' },
  },
  // ui state
  currentUser: 'xxx-xxx-xxx',
  selectedUser: 'xxx-xxx-xxx',
}
*/

function messages(state = {}, action) {
  switch (action.type) {
    case RECEIVE_MESSAGE:
      return Object.assign({}, state,
        { [action.message.id]: action.message });
    default:
      return state;
  }
}

function user(state = {}, action) {
  switch (action.type) {
    case RECEIVE_USER_ONLINE:
      return Object.assign({}, action.user, { online: true });
    case RECEIVE_USER_OFFLINE:
      return Object.assign({}, action.user, { online: false });
    default:
      return state;
  }
}

function users(state = {}, action) {
  switch (action.type) {
    case RECEIVE_USER_ONLINE:
    case RECEIVE_USER_OFFLINE:
      return Object.assign({}, state,
        { [action.user.uid]: user(state[action.user.uid], action) });
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
});

export default chatApp;
