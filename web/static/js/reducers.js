import { combineReducers } from 'redux';
import { NEW_MESSAGE, USER_ONLINE, NEW_ACCESS_LOG } from './actions';

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
    1: {
      id: 1,
      uuid: 'xxx-xxx-xxx',
      name: 'name',
      email: 'a@a.com',
    },
  },
  logs: {
    1: { id: 1, inserted_at: '11:12', href: 'http://abc.com', user_id: 1 },
  },
}
*/

function messages(state = {}, action) {
  switch (action.type) {
    case NEW_MESSAGE:
      return Object.assign(state,
        { [Object.keys(state).length + 1]: action.message }
      );
    default:
      return state;
  }
}

function users(state = {}, action) {
  switch (action.type) {
    case USER_ONLINE:
      return Object.assign(state,
        { [Object.keys(state).length + 1]: action.user }
      );
    default:
      return state;
  }
}

function logs(state = {}, action) {
  switch (action.type) {
    case NEW_ACCESS_LOG:
      return Object.assign(state,
        { [Object.keys(state).length + 1]: action.log }
      );
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
