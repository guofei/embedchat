import { Provider } from 'react-redux';
import React from 'react';
import ReactDOM from 'react-dom';
import { I18nextProvider } from 'react-i18next';
import moment from 'moment';

import i18n from './i18n';
import { clientID } from './distinct_id';
import { clientSocket } from './socket';
import insertNormalizeCSS from './normalize_css';
import visitorRoom from './room_visitor';
import ChatVisitor from './components/chat-visitor';

const uiClassName = 'lewini-block';

export default function visitor(store, roomID) {
  if (!store || !roomID || !clientID || !clientSocket) {
    return;
  }
  if (i18n.language && moment.locale() !== i18n.language) {
    moment.locale(i18n.language);
  }

  const div = `
      <div style="position:absolute; left:0px; top:0px; z-index:99999;">
        <div id="lewini-chat-id" class="${uiClassName}"></div>
      </div>
      `;
  const node = document.createElement('div');
  node.setAttribute('style', 'position:relative;');
  node.innerHTML = div;
  document.body.appendChild(node);
  insertNormalizeCSS();

  const chatRoom = visitorRoom(clientSocket, roomID, clientID, store);
  ReactDOM.render(
    <I18nextProvider i18n={i18n}>
      <Provider store={store}>
        <ChatVisitor room={chatRoom} />
      </Provider>
    </I18nextProvider>,
    document.getElementById('lewini-chat-id')
  );
}
