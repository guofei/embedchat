import DistinctID from './distinct_id';
import UserInfo from './user_info';

function room(socket, roomID) {
  const messageEvent = 'new_message';
  const userLeft = 'user_left';
  const userJoin = 'user_join';
  const userInfo = 'user_info';

  let channel = null;
  let onMessageCallback = function func(res) { return res; };
  let onUserJoinCallback = function func(res) { return res; };
  let onUserLeftCallback = function func(res) { return res; };
  let onHistoryMessagesCallback = function func(res) { return res; };
  let onUserInfoCallback = function func(res) { return res; };

  return {
    join() {
      if (!roomID) { return; }
      socket.connect();
      channel = socket.channel(`rooms:${roomID}`);

      channel.on(messageEvent, (resp) => {
        onMessageCallback(resp);
      });

      channel.on(userLeft, (resp) => {
        onUserLeftCallback(resp);
      });

      channel.on(userJoin, (resp) => {
        onUserJoinCallback(resp);
      });

      channel.on(userInfo, (resp) => {
        onUserInfoCallback(resp);
      });

      channel.join()
        .receive('ok', () => {
          channel.push('contact_list')
            .receive('ok', listResp => {
              for (const user of listResp.users) {
                onUserJoinCallback({ uid: user });
              }
            });
          channel.push('messages', { uid: DistinctID })
            .receive('ok', msgsResp => {
              onHistoryMessagesCallback(msgsResp);
            });
          channel.push(userInfo, UserInfo)
            .receive('ok', info => {
              onUserInfoCallback(info);
            });
        });
    },

    onMessage(callback) {
      onMessageCallback = callback;
    },

    isSelf(uid) {
      return uid === DistinctID;
    },

    currentUser() {
      return DistinctID;
    },

    send(text, toUser) {
      const message = { body: text, to_id: toUser };
      return channel.push(messageEvent, message);
    },

    history(userID) {
      if (typeof userID === 'undefined') {
        return channel.push('messages')
        .receive('ok', msgsResp => {
          onHistoryMessagesCallback(msgsResp);
        });
      }
      channel.push('messages', { uid: userID })
      .receive('ok', msgsResp => {
        onHistoryMessagesCallback(msgsResp);
      });
    },

    onHistory(callback) {
      onHistoryMessagesCallback = callback;
    },

    onUserJoin(callback) {
      onUserJoinCallback = callback;
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
