// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
// import "deps/phoenix_html/web/static/js/phoenix_html"
// import 'phoenix_html';

// import 'bootstrap-sass/assets/javascripts/bootstrap.min.js';

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".
import { createStore } from 'redux';
import { Provider } from 'react-redux';

import { clientID } from './distinct_id';
import { clientSocket } from './socket';
import room from './room';

import React from 'react';
import ReactDOM from 'react-dom';
import Chat from './components/chat';

import chatApp from './reducers';
const store = createStore(chatApp);

function getRoomID() {
  if (!window.lwn || !window.lwn.q) {
    return null;
  }
  let rid = null;
  window.lwn.q.forEach((e) => {
    if (e[0] === 'init') {
      rid = e[1];
    }
  });
  return rid;
}

function runChat() {
  const roomID = getRoomID();
  if (roomID) {
    const chatRoom = room(clientSocket, roomID, clientID, store);

    const div = '<div style="position:relative;">' +
    '<div style="position:absolute; left:0px; top:0px; z-index:99999;">' +
    '<div id="lewini-chat-id"></div>' +
    '</div>' +
    '</div>';
    document.body.innerHTML = document.body.innerHTML + div;

    ReactDOM.render(
      <Provider store={store}>
        <Chat room={chatRoom} />
      </Provider>,
      document.getElementById('lewini-chat-id')
    );
  }
}

runChat();
