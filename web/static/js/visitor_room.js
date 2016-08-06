import UserInfo from './user_info';
import {
  setCurrentUser,
  openChat,
  receiveMessage,
  receiveHistoryMessages,
  receiveAdminOnline,
  receiveAdminOffline,
  receiveMultiAdminsOnline,
} from './actions';

function visitorRoom(socket, roomID, distinctID, store) {
  const messageEvent = 'new_message';
  const adminJoin = 'admin_join';
  const adminLeft = 'admin_left';
  const messages = 'messages';

  let channel = null;

  function getHistory(userID) {
    channel.push(messages, { uid: userID })
    .receive('ok', msgsResp => {
      store.dispatch(receiveHistoryMessages(msgsResp.messages));
    });
  }

  store.dispatch(setCurrentUser(distinctID));

  return {
    join() {
      if (!roomID) { return; }
      if (UserInfo.isBot()) { return; }
      socket.connect();
      channel = socket.channel(`rooms:${roomID}`, UserInfo);

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
          getHistory(distinctID);
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
  };
}

export default visitorRoom;
