import DistinctID from './distinct_id';

function room(socket, roomID) {
  let channel = null;
  const channelID = 'new_message';

  return {
    join(onNewMessage) {
      if (!roomID) { return; }
      socket.connect();
      channel = socket.channel(`rooms:${roomID}`);
      channel.on(channelID, (resp) => {
        console.log('Receive message', resp);
        onNewMessage(resp);
      });
      channel.join()
        .receive('ok', resp => { console.log('Joined successfully', resp); })
        .receive('error', resp => { console.log('Unable to join', resp); });
    },

    isSentBySelf(newMsg) {
      return newMsg.name === DistinctID;
    },

    send(text) {
      const message = { body: text };
      channel.push(channelID, message)
        .receive('ok', e => console.log(e))
        .receive('error', e => console.log(e));
    },
  };
}

export default room;
