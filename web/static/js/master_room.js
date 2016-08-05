import UserInfo from './user_info';
import {
  selectUser,
  setCurrentUser,
  receiveMessage,
  receiveHistoryMessages,
  receiveUserOnline,
  receiveUserOffline,
  receiveMultiUsersOnline,
  receiveMultiUsersOffline,
  receiveAccessLog,
  receiveMultiAccessLogs,
} from './actions';

function masterRoom(socket, roomID, distinctID, store) {
  const messageEvent = 'new_message';
  const userLeft = 'user_left';
  const userJoin = 'user_join';
  const messages = 'messages';

  let channel = null;

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

      channel.join()
        .receive('ok', () => {
          getHistory(distinctID);
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
                  }
                }
                store.dispatch(receiveMultiUsersOffline(newUsers));
                store.dispatch(receiveMultiAccessLogs(newLogs));
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

    selectUser(uid) {
      store.dispatch(selectUser(uid));
      if (uid) {
        getHistory(uid);
      }
    },
  };
}

export default masterRoom;
