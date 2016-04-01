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

// import 'bootstrap-sass/assets/javascripts/bootstrap.min.js';

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import { clientID, masterID } from './distinct_id';
import { clientSocket, masterSocket } from './socket';
import room from './room';

import React from 'react';
import ReactDOM from 'react-dom';
import Chat from './components/chat';
import ChatWebmaster from './components/chat-webmaster';

const roomElement = document.getElementById('chat-room');
if (roomElement) {
  const roomID = roomElement.getAttribute('data-id');
  const chatRoom = room(clientSocket, roomID, clientID);

  ReactDOM.render(
    <Chat room={chatRoom} />,
    document.getElementById('chat-room')
  );
}

const masterRoomElement = document.getElementById('webmaster-chat-room');
if (masterRoomElement) {
  const roomID = masterRoomElement.getAttribute('data-id');
  const chatRoom = room(masterSocket, roomID, masterID);
  ReactDOM.render(
    <ChatWebmaster room={chatRoom} />,
    document.getElementById('webmaster-chat-room')
  );
}
