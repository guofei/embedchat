import { Provider } from 'react-redux';
import React from 'react';
import ReactDOM from 'react-dom';

import { clientID } from './distinct_id';
import { clientSocket } from './socket';
import room from './room';
import ChatVisitor from './components/chat-visitor';

export default function visitor(store, roomID) {
  if (!roomID) {
    return;
  }

  const div = '<div style="position:absolute; left:0px; top:0px; z-index:99999;">' +
  '<div id="lewini-chat-id"></div>' +
  '</div>';
  const node = document.createElement('div');
  node.setAttribute('style', 'position:relative;');
  node.innerHTML = div;
  document.body.appendChild(node);

  const chatRoom = room(clientSocket, roomID, clientID, store);
  ReactDOM.render(
    <Provider store={store}>
    <ChatVisitor room={chatRoom} />
    </Provider>,
    document.getElementById('lewini-chat-id')
  );
}
