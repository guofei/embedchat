import UserInfo from './user_info';
import {
  receiveMessage,
  receiveUserOnline,
  receiveUserOffline,
  receiveAccessLog
} from './actions';

function room(socket, roomID, distinctID, store) {
  const messageEvent = 'new_message';
  const userLeft = 'user_left';
  const userJoin = 'user_join';
  const messages = 'messages';
  const userInfo = 'user_info';

  let channel = null;
  let onMessageCallback = function func(res) { return res; };
  let onUserJoinCallback = function func(res) { return res; };
  let onUserLeftCallback = function func(res) { return res; };
  let onHistoryMessagesCallback = function func(res) { return res; };
  let onUserInfoCallback = function func(res) { return res; };
  let onUserJoinedCallback = function func() { };

  return {
    join() {
      if (!roomID) { return; }
      socket.connect();
      channel = socket.channel(`rooms:${roomID}`);

      channel.on(messageEvent, (user) => {
        store.dispatch(user);
        onMessageCallback(user);
      });

      channel.on(userLeft, (resp) => {
        console.log(resp);
        onUserLeftCallback(resp);
      });

      channel.on(userJoin, (resp) => {
        console.log(resp);
        onUserJoinCallback(resp);
      });

      channel.on(userInfo, (resp) => {
        console.log(resp);
        onUserInfoCallback(resp);
      });

      channel.join()
        .receive('ok', () => {
          onUserJoinedCallback();
          channel.push(userInfo, UserInfo)
            .receive('ok', info => {
              onUserInfoCallback(info);
            });
          const contactList = 'contact_list';
          channel.push(contactList)
            .receive('ok', listResp => {
              const users = listResp.users;
              console.log(users);
              for (const key of Object.keys(users)) {
                onUserJoinCallback({ uid: key });
              }
            });
          // FIXME master need not do this
          channel.push(messages, { uid: distinctID })
            .receive('ok', msgsResp => {
              msgsResp.messages.map(m => store.dispatch(receiveMessage(m)));
              onHistoryMessagesCallback(msgsResp);
            });
        });
    },

    onMessage(callback) {
      onMessageCallback = callback;
    },

    isSelf(uid) {
      return uid === distinctID;
    },

    currentUser() {
      return distinctID;
    },

    send(text, toUser) {
      const message = { body: text, to_id: toUser };
      return channel.push(messageEvent, message);
    },

    history(userID) {
      if (typeof userID === 'undefined') {
        return channel.push(messages)
          .receive('ok', msgsResp => {
            msgsResp.messages.map(m => store.dispatch(receiveMessage(m)));
            onHistoryMessagesCallback(msgsResp);
          });
      }
      channel.push(messages, { uid: userID })
      .receive('ok', msgsResp => {
        msgsResp.messages.map(m => store.dispatch(receiveMessage(m)));
        onHistoryMessagesCallback(msgsResp);
      });
    },

    onHistory(callback) {
      onHistoryMessagesCallback = callback;
    },

    onUserJoin(callback) {
      onUserJoinCallback = callback;
    },

    onUserJoined(callback) {
      onUserJoinedCallback = callback;
    },

    onUserLeft(callback) {
      onUserLeftCallback = callback;
    },

    onUserInfo(callback) {
      onUserInfoCallback = callback;
    },
  };
}

export default room;
