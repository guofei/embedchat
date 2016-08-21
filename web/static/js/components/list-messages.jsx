import React from 'react';

import { List } from 'material-ui/List';

import ListItemMessage from './list-item-message';

function messageFromName(msg, users) {
  if (users[msg.from_id]) {
    return users[msg.from_id].name;
  }
  return msg.from_name;
}

class ListMessages extends React.Component {
  render() {
    const messages = this.props.messages.map((msg) =>
      (
        <ListItemMessage
          currentUser={this.props.currentUser}
          currentUserEmail={this.props.currentUserEmail}
          key={msg.id}
          type={msg.type}
          from={msg.from_id}
          fromName={messageFromName(msg, this.props.users)}
          createdAt={msg.inserted_at}
          sendEmail={this.props.sendEmail}
        >
          {msg.body}
        </ListItemMessage>
      )
    );
    return (
      <List>
        {messages}
      </List>
    );
  }
}

ListMessages.propTypes = {
  currentUser: React.PropTypes.string.isRequired,
  currentUserEmail: React.PropTypes.string.isRequired,
  messages: React.PropTypes.array.isRequired,
  users: React.PropTypes.object.isRequired,
  sendEmail: React.PropTypes.func.isRequired,
};

export default ListMessages;
