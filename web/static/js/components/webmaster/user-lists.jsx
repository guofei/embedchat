import React from 'react';
import List from 'material-ui/lib/lists/list';
import ListItem from 'material-ui/lib/lists/list-item';
import Divider from 'material-ui/lib/divider';
import Avatar from 'material-ui/lib/avatar';
import Paper from 'material-ui/lib/paper';
import Toolbar from 'material-ui/lib/toolbar/toolbar';
import ToolbarTitle from 'material-ui/lib/toolbar/toolbar-title';
import CommunicationChatBubble from 'material-ui/lib/svg-icons/communication/chat-bubble';
import Colors from 'material-ui/lib/styles/colors';

// TODO refactoring
function shortName(fullName) {
  return fullName.substring(0, 7);
}

function User({ name, numMessages, onSelected }) {
  return (
    <ListItem
      primaryText={
        <p>{shortName(name)}&nbsp;&nbsp;
          <span style={{ color: Colors.lightBlack }}>{numMessages}</span>
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
    (<User name={user.uid}
      key={user.uid}
      numMessages={user.numMessages}
      onSelected={onUserSelected}
    />)
  );
  const offlines = offlineUsers.map((user) =>
    (<User name={user.uid}
      key={user.uid}
      numMessages={user.numMessages}
      onSelected={onUserSelected}
    />)
  );
  return (
    <Paper zDepth={1}>
      <Toolbar>
        <ToolbarTitle text="User" />
      </Toolbar>
      <List subheader="Online">
        {onlines}
      </List>
      <Divider />
      <List subheader="Offline">
        {offlines}
      </List>
    </Paper>
  );
}

export default UserLists;
