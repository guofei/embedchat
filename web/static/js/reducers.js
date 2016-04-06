import { combineReducers } from 'redux';
import {
  RECEIVE_MESSAGE,
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
      to_id: 'xxx-xxx-xxx',
      body: 'hi',
      inserted_at: '11:10'
    },
  },
  users: {
    xxx-xxx-xxx: {
      id: 1,
      uuid: 'xxx-xxx-xxx',
      name: 'name',
      email: 'a@a.com',
      online: false,
    },
  },
  logs: {
    1: { id: 1, inserted_at: '11:12', href: 'http://abc.com', user_id: 1 },
  },
  // ui state
  masterUUID: 'xxx-xxx-xxx',
  visitorUUID: 'xxx-xxx-xxx',
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
        { [action.user.uuid]: user(state[action.user.uuid], action) });
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
  users,
  messages,
  logs,
});

export default chatApp;
