import React from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';
import { I18nextProvider } from 'react-i18next';
import moment from 'moment';

import i18n from './i18n';
import { masterID } from './distinct_id';
import { masterSocket } from './socket';
import masterRoom from './room_master';
import ChatWebmaster from './components/chat-webmaster';

export default function webmaster(store) {
  if (i18n.language && moment.locale() !== i18n.language) {
    moment.locale(i18n.language);
  }
  const masterRoomElement = document.getElementById('webmaster-chat-room');
  if (masterRoomElement) {
    const roomID = masterRoomElement.getAttribute('data-id');
    const chatRoom = masterRoom(masterSocket, roomID, masterID, store);
    ReactDOM.render(
      <I18nextProvider i18n={i18n}>
        <Provider store={store}>
          <ChatWebmaster room={chatRoom} />
        </Provider>
      </I18nextProvider>,
      document.getElementById('webmaster-chat-room')
    );
  }
}
