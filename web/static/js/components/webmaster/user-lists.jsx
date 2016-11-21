import React from 'react';
import moment from 'moment';
import { List, ListItem, makeSelectable } from 'material-ui/List';
import Subheader from 'material-ui/Subheader';
import Divider from 'material-ui/Divider';
import Avatar from 'material-ui/Avatar';
import Paper from 'material-ui/Paper';
import { Toolbar, ToolbarTitle, ToolbarGroup } from 'material-ui/Toolbar';
import ActionOpenInNew from 'material-ui/svg-icons/action/open-in-new';
import FlatButton from 'material-ui/FlatButton';

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

function userItem(user, onSelected) {
  return (
    <ListItem
      key={user.uid}
      value={user.uid}
      primaryText={
        <div>
          {user.name || shortName(user.email || user.uid)}
          <div style={styles.pullRight}>
            {messsageTime(user.message)}
          </div>
        </div>
      }
      secondaryText={messageText(user.message)}
      leftAvatar={<Avatar>{avatar(user.name || user.email || user.uid)}</Avatar>}
      onTouchTap={function touch() { onSelected(user.uid); }}
    />
  );
}

const SelectableList = makeSelectable(List);

function UserLists({ onlineUsers, offlineUsers, selectedUser, onUserSelected }) {
  const onlines = onlineUsers.map((user) =>
    userItem(user, onUserSelected)
  );
  const offlines = offlineUsers.map((user) =>
    userItem(user, onUserSelected)
  );
  return (
    <Paper zDepth={1}>
      <Toolbar>
        <ToolbarTitle text="Visitor" />
        <ToolbarGroup>
          <FlatButton
            href="/addresses"
            label="all"
            primary
            icon={<ActionOpenInNew />}
          />
        </ToolbarGroup>
      </Toolbar>
      <SelectableList value={selectedUser} onChange={function fun() {}}>
        <Subheader>Online</Subheader>
        {onlines}
      </SelectableList>
      <Divider />
      <SelectableList value={selectedUser} onChange={function fun() {}}>
        <Subheader>Offline</Subheader>
        {offlines}
      </SelectableList>
    </Paper>
  );
}

export default UserLists;
