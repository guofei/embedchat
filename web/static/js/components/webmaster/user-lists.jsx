import React from 'react';
import moment from 'moment';
import List from 'material-ui/lib/lists/list';
import ListItem from 'material-ui/lib/lists/list-item';
import Divider from 'material-ui/lib/divider';
import Avatar from 'material-ui/lib/avatar';
import Paper from 'material-ui/lib/paper';
import Toolbar from 'material-ui/lib/toolbar/toolbar';
import ToolbarTitle from 'material-ui/lib/toolbar/toolbar-title';

const styles = {
  pullRight: {
    float: 'right',
    color: 'gray',
    fontSize: 'small',
  },
};

// TODO refactoring
function shortName(fullName) {
  return fullName.substring(0, 7);
}

function messageText(msg) {
  let text = '';
  if (msg) {
    text = msg.body;
  }
  return text;
}

function messsageTime(msg) {
  let text = '';
  if (msg) {
    text = moment.utc(msg.inserted_at).fromNow(true);
  }
  return text;
}

function User({ name, message, onSelected }) {
  return (
    <ListItem
      primaryText={
        <div>
          {shortName(name)}
          <div style={styles.pullRight}>
            {messsageTime(message)}
          </div>
        </div>
      }
      secondaryText={messageText(message)}
      leftAvatar={<Avatar>{name[0]}</Avatar>}
      onTouchTap={function touch() { onSelected(name); }}
    />
  );
}

function UserLists({ onlineUsers, offlineUsers, onUserSelected }) {
  const onlines = onlineUsers.map((user) =>
    (<User name={user.uid}
      key={user.uid}
      message={user.message}
      onSelected={onUserSelected}
    />)
  );
  const offlines = offlineUsers.map((user) =>
    (<User name={user.uid}
      key={user.uid}
      message={user.message}
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
