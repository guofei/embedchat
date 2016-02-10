import DistinctID from './distinct_id';

function room(socket, roomID) {
  let channel = null;
  let onNewMessage = null;
  const messageEvent = 'new_message';

  return {
    join() {
      if (!roomID) { return; }
      socket.connect();
      channel = socket.channel(`rooms:${roomID}`);

      channel.on(messageEvent, (resp) => {
        console.log('Receive message', resp);
        onNewMessage(resp);
      });

      const userLeft = 'User left';
      channel.on('user_left', (resp) => {
        console.log(userLeft, resp);
      });

      channel.join()
        .receive('ok', resp => { console.log('Joined successfully', resp); })
        .receive('error', resp => { console.log('Unable to join', resp); });
    },

    onMessage(callback) {
      onNewMessage = callback;
    },

    isSentBySelf(newMsg) {
      return newMsg.name === DistinctID;
    },

    send(text) {
      const message = { body: text };
      channel.push(messageEvent, message)
        .receive('ok', e => console.log(e))
        .receive('error', e => console.log(e));
    },
  };
}

export default room;
