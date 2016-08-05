import React from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';

import { masterID } from './distinct_id';
import { masterSocket } from './socket';
import masterRoom from './master_room';
import ChatWebmaster from './components/chat-webmaster';

export default function webmaster(store) {
  const masterRoomElement = document.getElementById('webmaster-chat-room');
  if (masterRoomElement) {
    const roomID = masterRoomElement.getAttribute('data-id');
    const chatRoom = masterRoom(masterSocket, roomID, masterID, store);
    ReactDOM.render(
      <Provider store={store}>
        <ChatWebmaster room={chatRoom} />
      </Provider>,
      document.getElementById('webmaster-chat-room')
    );
  }
}
