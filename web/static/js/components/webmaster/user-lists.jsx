import React from 'react';
import moment from 'moment';
import { List, ListItem } from 'material-ui/List';
import Subheader from 'material-ui/Subheader';
import Divider from 'material-ui/Divider';
import Avatar from 'material-ui/Avatar';
import Paper from 'material-ui/Paper';
import { Toolbar, ToolbarTitle } from 'material-ui/Toolbar';

import { avatar, shortName } from '../../utils';

const styles = {
  pullRight: {
    float: 'right',
    color: 'gray',
    fontSize: 'small',
  },
};

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

function User({ name, email, uid, message, onSelected }) {
  return (
    <ListItem
      primaryText={
        <div>
          {shortName(name || email || uid)}
          <div style={styles.pullRight}>
            {messsageTime(message)}
          </div>
        </div>
      }
      secondaryText={messageText(message)}
      leftAvatar={<Avatar>{avatar(name || email || uid)}</Avatar>}
      onTouchTap={function touch() { onSelected(uid); }}
    />
  );
}

function UserLists({ onlineUsers, offlineUsers, onUserSelected }) {
  const onlines = onlineUsers.map((user) =>
    (<User key={user.uid}
      name={user.name}
      email={user.email}
      uid={user.uid}
      message={user.message}
      onSelected={onUserSelected}
    />)
  );
  const offlines = offlineUsers.map((user) =>
    (<User key={user.uid}
      name={user.name}
      email={user.email}
      uid={user.uid}
      message={user.message}
      onSelected={onUserSelected}
    />)
  );
  return (
    <Paper zDepth={1}>
      <Toolbar>
        <ToolbarTitle text="Visitor" />
      </Toolbar>
      <List>
        <Subheader>Online</Subheader>
        {onlines}
      </List>
      <Divider />
      <List>
        <Subheader>Offline</Subheader>
        {offlines}
      </List>
    </Paper>
  );
}

export default UserLists;
