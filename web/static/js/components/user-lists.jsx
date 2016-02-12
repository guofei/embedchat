import React from 'react';
import List from 'material-ui/lib/lists/list';
import ListItem from 'material-ui/lib/lists/list-item';
import Divider from 'material-ui/lib/divider';
import Paper from 'material-ui/lib/paper';
import CommunicationChatBubble from 'material-ui/lib/svg-icons/communication/chat-bubble';

import ListMessages from './list-messages';
import MessageForm from './message-form';

const data = [
  { id: 1, name: 'abc', text: 'helll', createdAt: 'Thu, 11 Feb 2016 14:54:07 GMT' },
  { id: 2, name: 'aghh', text: 'fsadf lkj sdlf ', createdAt: 'Thu, 11 Feb 2016 14:54:07 GMT' },
  { id: 3, name: 'dds', text: 'abcd lkj sdlf ', createdAt: 'Thu, 11 Feb 2016 14:54:07 GMT' },
];

const UserLists = () => (
  <div className="row">
    <div className="col-xs-3">
      <Paper zDepth={1}>
        <List subheader="Online chats">
          <ListItem
            primaryText="Brendan Lim"
            rightIcon={<CommunicationChatBubble />}
          />
          <ListItem
            primaryText="Eric Hoffman"
            rightIcon={<CommunicationChatBubble />}
          />
        </List>
        <Divider />
        <List subheader="Offline chats">
          <ListItem
            primaryText="Chelsea Otakan"
            rightIcon={<CommunicationChatBubble />}
          />
        </List>
      </Paper>
    </div>
    <div className="col-xs-9">
      <Paper zDepth={1}>
        <ListMessages messages={data} />
        <MessageForm onInputMessage={ function(){console.log(msg)} } />
      </Paper>
    </div>
  </div>
);

export default UserLists;
