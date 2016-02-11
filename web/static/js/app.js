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

import 'bootstrap-sass/assets/javascripts/bootstrap.min.js';

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import socket from './socket';
import room from './room';

import React from 'react';
import ReactDOM from 'react-dom';
import Chat from './components/chat';
import UserLists from './components/user-lists';

const roomElement = document.getElementById('chat-room');
if (roomElement) {
  const roomID = roomElement.getAttribute('data-id');
  const chatRoom = room(socket, roomID);

  ReactDOM.render(
    <Chat room={chatRoom} />,
    document.getElementById('chat-room')
  );
}

ReactDOM.render(
  <UserLists />,
  document.getElementById('webmaster-chat-room')
);
