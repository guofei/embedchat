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
        console.log('Receive message', resp);
        onMessageCallback(resp);
      });

      channel.on(userLeft, (resp) => {
        console.log('User left', resp);
        onUserLeftCallback(resp);
      });

      channel.on(userJoin, (resp) => {
        console.log('User Join', resp);
        onUserJoinCallback(resp);
      });

      channel.join()
        .receive('ok', resp => {
          channel.push('contact_list', { test: 'test' })
          .receive('ok', listResp => {
            for (const user of listResp.users) {
              onUserJoinCallback({ distinct_id: user });
            }
          });
          console.log('Join', resp);
        })
        .receive('error', resp => { console.log('Unable to join', resp); });
    },

    onMessage(callback) {
      onMessageCallback = callback;
    },

    isSelf(uid) {
      return uid === DistinctID;
    },

    send(text) {
      const message = { body: text };
      channel.push(messageEvent, message)
        .receive('ok', e => console.log(e))
        .receive('error', e => console.log(e));
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
