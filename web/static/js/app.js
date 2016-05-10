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
import 'phoenix_html';
import { createStore } from 'redux';
import { Provider } from 'react-redux';

require('../css/app.css');

// import 'bootstrap-sass/assets/javascripts/bootstrap.min.js';

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import { masterID, clientID } from './distinct_id';
import { masterSocket, clientSocket } from './socket';
import room from './room';

import React from 'react';
import ReactDOM from 'react-dom';
import getMuiTheme from 'material-ui/styles/getMuiTheme';
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import Chat from './components/chat';
import ChatWebmaster from './components/chat-webmaster';

import chatApp from './reducers';
const store = createStore(chatApp);

const masterRoomElement = document.getElementById('webmaster-chat-room');
if (masterRoomElement) {
  const roomID = masterRoomElement.getAttribute('data-id');
  const chatRoom = room(masterSocket, roomID, masterID, store);
  ReactDOM.render(
    <Provider store={store}>
      <MuiThemeProvider muiTheme={getMuiTheme()}>
        <ChatWebmaster room={chatRoom} />
      </MuiThemeProvider>
    </Provider>,
    document.getElementById('webmaster-chat-room')
  );
}

const roomElement = document.getElementById('lewini-chat');
if (roomElement) {
  const roomID = roomElement.getAttribute('data-id');
  const chatRoom = room(clientSocket, roomID, clientID, store);

  document.body.innerHTML += ('<div style="position:relative;">' +
    '<div style="position:absolute; left:0px; top:0px; z-index:99999;">' +
    '<div id="lewini-chat-id"></div>' +
    '</div>' +
    '</div>');

  ReactDOM.render(
    <Provider store={store}>
      <MuiThemeProvider muiTheme={getMuiTheme()}>
        <Chat room={chatRoom} />
      </MuiThemeProvider>
    </Provider>,
    document.getElementById('lewini-chat-id')
  );
}

import showEmbedSite from 'embedded_site';
showEmbedSite();
