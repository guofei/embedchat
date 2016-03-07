import React from 'react';
import List from 'material-ui/lib/lists/list';
import ListItem from 'material-ui/lib/lists/list-item';
import Divider from 'material-ui/lib/divider';
import CommunicationChatBubble from 'material-ui/lib/svg-icons/communication/chat-bubble';

function shortName(fullName) {
  return fullName.substring(0, 7);
}

function User({ name, onSelected }) {
  return (
    <ListItem
      primaryText={shortName(name)}
      rightIcon={<CommunicationChatBubble />}
      onTouchTap={function touch() { onSelected(name); }}
    />
  );
}

function UserLists({ onlineUsers, offlineUsers, onUserSelected }) {
  const onlines = onlineUsers.map((user) =>
  (<User name={user.uid} key={user.uid} onSelected={onUserSelected} />)
  );
  const offlines = offlineUsers.map((user) =>
  (<User name={user.uid} key={user.uid} onSelected={onUserSelected} />)
  );
  return (
    <div>
      <List subheader="Online">
        {onlines}
      </List>
      <Divider />
      <List subheader="Offline">
        {offlines}
      </List>
    </div>
  );
}

export default UserLists;
