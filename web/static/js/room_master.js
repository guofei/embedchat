import nextUserAccessLog from './user_info';
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
  const accessLogs = 'access_logs';

  let channel = null;

  function getHistory(userID) {
    channel.push(messages, { uid: userID })
    .receive('ok', msgsResp => {
      store.dispatch(receiveHistoryMessages(msgsResp.messages));
    });
  }

  function getLog(userID) {
    channel.push(accessLogs, { uid: userID })
    .receive('ok', resp => {
      const logs = resp.logs;
      const newLogs = [];
      for (const log of logs) {
        const newLog = Object.assign({}, log, { uid: resp.uid });
        newLogs.push(newLog);
      }
      store.dispatch(receiveMultiAccessLogs(newLogs));
    });
  }

  store.dispatch(setCurrentUser(distinctID));

  return {
    join() {
      const userInfo = nextUserAccessLog();
      if (!roomID) { return; }
      if (userInfo.isBot()) { return; }
      socket.connect();
      channel = socket.channel(`rooms:${roomID}`, userInfo);

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
                for (const key in users) {
                  if (users.hasOwnProperty(key)) {
                    const user = { uid: key, id: users[key].id, name: users[key].name };
                    newUsers.push(user);
                  }
                }
                store.dispatch(receiveMultiUsersOnline(newUsers));
              }
              const offlineUsers = listResp.offline_users;
              if (offlineUsers) {
                const newUsers = [];
                for (const key in offlineUsers) {
                  if (offlineUsers.hasOwnProperty(key)) {
                    const info = offlineUsers[key];
                    const user = { uid: key, id: info.id, name: info.name };
                    newUsers.push(user);
                  }
                }
                store.dispatch(receiveMultiUsersOffline(newUsers));
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
        getLog(uid);
      }
    },
  };
}

export default masterRoom;
