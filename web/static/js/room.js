import DistinctID from './distinct_id';

function room(socket, roomID) {
  const messageEvent = 'new_message';
  const userLeft = 'user_left';
  const userJoin = 'user_join';

  let channel = null;
  let onMessageCallback = function func(res) { return res; };
  let onUserJoinCallback = function func(res) { return res; };
  let onUserLeftCallback = function func(res) { return res; };

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

      channel.join()
        .receive('ok', resp => {
          console.log('Joined successfully', resp);
          channel.push('contact_list')
          .receive('ok', listResp => {
            for (const user of listResp.users) {
              onUserJoinCallback({ uid: user });
            }
          });
        });
        // .receive('error', resp => { console.log('Unable to join', resp); });
    },

    onMessage(callback) {
      onMessageCallback = callback;
    },

    isSelf(uid) {
      return uid === DistinctID;
    },

    send(text, toUser) {
      const message = { body: text, to: toUser };
      channel.push(messageEvent, message);
    },

    onUserJoin(callback) {
      onUserJoinCallback = callback;
    },

    onUserLeft(callback) {
      onUserLeftCallback = callback;
    },
  };
}

export default room;
