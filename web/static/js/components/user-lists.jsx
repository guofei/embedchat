import React from 'react';
import Avatar from 'material-ui/lib/avatar';
import List from 'material-ui/lib/lists/list';
import ListItem from 'material-ui/lib/lists/list-item';
import Divider from 'material-ui/lib/divider';
import CommunicationChatBubble from 'material-ui/lib/svg-icons/communication/chat-bubble';

const UserLists = () => (
  <div>
    <List subheader="Recent chats">
      <ListItem
        primaryText="Brendan Lim"
        leftAvatar={<Avatar>A</Avatar>}
        rightIcon={<CommunicationChatBubble />}
      />
      <ListItem
        primaryText="Eric Hoffman"
        leftAvatar={<Avatar>A</Avatar>}
        rightIcon={<CommunicationChatBubble />}
      />
      <ListItem
        primaryText="Grace Ng"
        leftAvatar={<Avatar>A</Avatar>}
        rightIcon={<CommunicationChatBubble />}
      />
      <ListItem
        primaryText="Kerem Suer"
        leftAvatar={<Avatar>A</Avatar>}
        rightIcon={<CommunicationChatBubble />}
      />
      <ListItem
        primaryText="Raquel Parrado"
        leftAvatar={<Avatar>A</Avatar>}
        rightIcon={<CommunicationChatBubble />}
      />
    </List>
    <Divider />
    <List subheader="Previous chats">
      <ListItem
        primaryText="Chelsea Otakan"
        leftAvatar={<Avatar>A</Avatar>}
      />
      <ListItem
        primaryText="James Anderson"
        leftAvatar={<Avatar>A</Avatar>}
      />
    </List>
  </div>
);

export default UserLists;
