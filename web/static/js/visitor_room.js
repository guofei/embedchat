import nextUserAccessLog from './user_info';
import {
  setCurrentUser,
  setCurrentUserEmail,
  openChat,
  receiveMessage,
  receiveHistoryMessages,
  receiveAdminOnline,
  receiveAdminOffline,
  receiveMultiAdminsOnline,
} from './actions';

function visitorRoom(socket, roomID, distinctID, store) {
  const messageEvent = 'new_message';
  const sendEmail = 'email';
  const adminJoin = 'admin_join';
  const adminLeft = 'admin_left';
  const messages = 'messages';

  let channel = null;

  store.dispatch(setCurrentUser(distinctID));

  return {
    join() {
      const userInfo = nextUserAccessLog();
      if (!roomID) { return; }
      if (userInfo.isBot()) { return; }
      socket.connect();
      channel = socket.channel(`rooms:${roomID}`, userInfo);

      channel.on(messages, (msgsResp) => {
        store.dispatch(receiveHistoryMessages(msgsResp.messages));
      });

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
          const contactList = 'contact_list';
          channel.push(contactList)
            .receive('ok', listResp => {
              const admins = listResp.admins;
              if (admins) {
                const newAdmins = [];
                for (const key in admins) {
                  if (admins.hasOwnProperty(key)) {
                    const user = Object.assign({}, { uid: key }, admins[key]);
                    newAdmins.push(user);
                  }
                }
                store.dispatch(receiveMultiAdminsOnline(newAdmins));
              }
            });
        });
    },

    isSelf(uid) {
      return uid === distinctID;
    },

    send(text, toUser) {
      const message = { body: text, to_id: toUser };
      return channel.push(messageEvent, message);
    },

    sendEmail(email) {
      store.dispatch(setCurrentUserEmail(email));
      channel.push(sendEmail, email);
    },
  };
}

export default visitorRoom;
