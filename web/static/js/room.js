import UserInfo from './user_info';
import {
  setCurrentUser,
  openChat,
  receiveMessage,
  receiveHistoryMessages,
  receiveUserOnline,
  receiveUserOffline,
  receiveMultiUsersOnline,
  receiveMultiUsersOffline,
  receiveAdminOnline,
  receiveAdminOffline,
  receiveMultiAdminsOnline,
  receiveAccessLog,
  receiveMultiAccessLogs,
} from './actions';

function room(socket, roomID, distinctID, store) {
  const messageEvent = 'new_message';
  const userLeft = 'user_left';
  const userJoin = 'user_join';
  const adminJoin = 'admin_join';
  const adminLeft = 'admin_left';
  const messages = 'messages';
  // const userInfo = 'user_info';

  let channel = null;
  let onUserJoinedCallback = function func() { };

  function getHistory(userID) {
    if (typeof userID === 'undefined') {
      return channel.push(messages)
        .receive('ok', msgsResp => {
          store.dispatch(receiveHistoryMessages(msgsResp.messages));
        });
    }
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

      channel.on(userLeft, (user) => {
        store.dispatch(receiveUserOffline(user));
      });

      channel.on(userJoin, (user) => {
        const newUser = { uid: user.uid, id: user.id };
        store.dispatch(receiveUserOnline(newUser));
        if (user.info) {
          const accesslog = Object.assign({}, user.info, { uid: user.uid });
          store.dispatch(receiveAccessLog(accesslog));
        }
        getHistory(user.uid);
      });

      channel.on(adminJoin, (admin) => {
        const newAdmin = { uid: admin.uid, id: admin.id };
        store.dispatch(receiveAdminOnline(newAdmin));
      });

      channel.on(adminLeft, (admin) => {
        store.dispatch(receiveAdminOffline(admin));
      });

      // channel.on(userInfo, (resp) => {
      //   const accesslog = Object.assign({}, resp.info, { uid: resp.uid });
      //   store.dispatch(receiveAccessLog(accesslog));
      // });

      channel.join()
        .receive('ok', () => {
          onUserJoinedCallback();
          // channel.push(userInfo, UserInfo);
          const contactList = 'contact_list';
          channel.push(contactList)
            .receive('ok', listResp => {
              const users = listResp.online_users;
              if (users) {
                const newUsers = [];
                const newLogs = [];
                for (const key in users) {
                  if (users.hasOwnProperty(key)) {
                    const user = { uid: key, id: users[key].id };
                    newUsers.push(user);
                    for (const log of users[key].logs) {
                      const newLog = Object.assign({}, log, { uid: key });
                      newLogs.push(newLog);
                    }
                    getHistory(key);
                  }
                }
                store.dispatch(receiveMultiUsersOnline(newUsers));
                store.dispatch(receiveMultiAccessLogs(newLogs));
              }
              const offlineUsers = listResp.offline_users;
              if (offlineUsers) {
                const newUsers = [];
                const newLogs = [];
                for (const key in offlineUsers) {
                  if (offlineUsers.hasOwnProperty(key)) {
                    const user = { uid: key, id: offlineUsers[key].id };
                    newUsers.push(user);
                    for (const log of offlineUsers[key].logs) {
                      const newLog = Object.assign({}, log, { uid: key });
                      newLogs.push(newLog);
                    }
                    getHistory(key);
                  }
                }
                store.dispatch(receiveMultiUsersOffline(newUsers));
                store.dispatch(receiveMultiAccessLogs(newLogs));
              }
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
                getHistory(distinctID);
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

    onUserJoined(callback) {
      onUserJoinedCallback = callback;
    },
  };
}

export default room;
