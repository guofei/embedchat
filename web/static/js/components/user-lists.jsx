import React from 'react';
import List from 'material-ui/lib/lists/list';
import ListItem from 'material-ui/lib/lists/list-item';
import Divider from 'material-ui/lib/divider';
import Avatar from 'material-ui/lib/avatar';
import CommunicationChatBubble from 'material-ui/lib/svg-icons/communication/chat-bubble';
import Colors from 'material-ui/lib/styles/colors';

// TODO refactoring
function shortName(fullName) {
  return fullName.substring(0, 7);
}

function User({ name, onSelected }) {
  return (
    <ListItem
      primaryText={
        <p>{shortName(name)}&nbsp;&nbsp;
          <span style={{ color: Colors.lightBlack }}>4</span>
        </p>
      }
      rightIcon={<CommunicationChatBubble />}
      leftAvatar={<Avatar>{name[0]}</Avatar>}
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
