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
import { isBot } from './utils';

function masterRoom(socket, roomUUID, distinctID, store) {
  const messageEvent = 'new_message';
  const userLeft = 'user_left';
  const userJoin = 'user_join';
  const messages = 'messages';
  const trackEvent = 'track';
  const accessLogs = 'access_logs';

  let channel = null;

  function getHistory(userID) {
    channel.push(messages, { uid: userID })
    .receive('ok', (msgsResp) => {
      store.dispatch(receiveHistoryMessages(msgsResp.messages));
    });
  }

  function getLog(userID) {
    channel.push(accessLogs, { uid: userID })
    .receive('ok', (resp) => {
      const logs = resp.logs;
      const newLogs = [];
      logs.forEach((log) => {
        const newLog = Object.assign({}, log, { uid: resp.uid });
        newLogs.push(newLog);
      });
      store.dispatch(receiveMultiAccessLogs(newLogs));
    });
  }

  function getUsers(users) {
    return Object.keys(users).map((key) => {
      const info = users[key];
      const user = {
        uid: key, id: info.id, name: info.name, email: info.email, note: info.note,
      };
      return user;
    });
  }

  function getContactList() {
    const contactList = 'contact_list';
    channel.push(contactList)
      .receive('ok', (listResp) => {
        const onlineUsers = listResp.online_users;
        if (onlineUsers) {
          const newUsers = getUsers(onlineUsers);
          store.dispatch(receiveMultiUsersOnline(newUsers));
        }
        const offlineUsers = listResp.offline_users;
        if (offlineUsers) {
          const newUsers = getUsers(offlineUsers);
          store.dispatch(receiveMultiUsersOffline(newUsers));
        }
      });
  }

  store.dispatch(setCurrentUser(distinctID));

  return {
    join() {
      // const userInfo = nextUserAccessLog();
      if (!roomUUID) { return; }
      if (isBot()) { return; }
      socket.connect();
      channel = socket.channel(`rooms:${roomUUID}`);

      channel.on(messageEvent, (msg) => {
        store.dispatch(receiveMessage(msg));
      });

      channel.on(trackEvent, (accesslog) => {
        store.dispatch(receiveAccessLog(accesslog));
      });

      channel.on(userLeft, (user) => {
        store.dispatch(receiveUserOffline(user));
      });

      channel.on(userJoin, (user) => {
        const newUser = {
          uid: user.uid, id: user.id, name: user.name, email: user.email, note: user.note,
        };
        store.dispatch(receiveUserOnline(newUser));
        getHistory(user.uid);
      });

      channel.join()
        .receive('ok', () => {
          getHistory(distinctID);
          getContactList();
        });
    },

    getRoomUUID() {
      return roomUUID;
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
