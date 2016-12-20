import fetch from 'isomorphic-fetch';

import { host } from './global';
import {
  setCurrentVisitor,
  setCurrentVisitorEmail,
  openChat,
  receiveMessage,
  receiveHistoryMessages,
  receiveAdminOnline,
  receiveAdminOffline,
  receiveMultiAdminsOnline,
} from './actions';
import { isBot } from './utils';
import sendTrack from './user_info';

function updateVisitor(data) {
  fetch(`//${host}/api/visitors`, {
    method: 'POST',
    headers: {
      Accept: 'application/json',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(data),
  });
}

function visitorRoom(socket, roomID, distinctID, store) {
  const messageEvent = 'new_message';
  // const sendEmail = 'email';
  const adminJoin = 'admin_join';
  const adminLeft = 'admin_left';
  const messages = 'messages';

  let channel = null;

  function getHistory() {
    channel.push(messages)
    .receive('ok', (msgsResp) => {
      store.dispatch(receiveHistoryMessages(msgsResp.messages));
    });
  }

  function getContactList() {
    const contactList = 'contact_list';
    channel.push(contactList)
      .receive('ok', (listResp) => {
        const admins = listResp.admins;
        if (admins) {
          const newAdmins = [];
          Object.keys(admins).forEach((key) => {
            const user = Object.assign({}, { uid: key }, admins[key]);
            newAdmins.push(user);
          });
          store.dispatch(receiveMultiAdminsOnline(newAdmins));
        }
      });
  }

  store.dispatch(setCurrentVisitor(distinctID));

  return {
    join() {
      // const userInfo = nextUserAccessLog();
      if (!roomID) { return; }
      if (isBot()) { return; }
      socket.connect();
      channel = socket.channel(`rooms:${roomID}`);

      channel.on(messageEvent, (msg) => {
        store.dispatch(receiveMessage(msg));
        store.dispatch(openChat(true));
      });

      channel.on(adminJoin, (admin) => {
        const newAdmin = { uid: admin.uid, id: admin.id, name: admin.name };
        store.dispatch(receiveAdminOnline(newAdmin));
      });

      channel.on(adminLeft, (admin) => {
        store.dispatch(receiveAdminOffline(admin));
      });

      channel.join()
        .receive('ok', () => {
          sendTrack();
          getHistory();
          getContactList();
        });
    },

    isSelf(uid) {
      return uid === distinctID;
    },

    send(text, toUser) {
      const message = { body: text, to_id: toUser };
      return channel.push(messageEvent, message);
    },

    sendEmail(mail) {
      store.dispatch(setCurrentVisitorEmail(mail));
      const data = {
        visitor: { email: mail },
        uuid: distinctID,
        room_uuid: roomID,
      };
      updateVisitor(data);
    },
  };
}

export default visitorRoom;
