import React from 'react';

import { List } from 'material-ui/List';

import ListItemMessage from './list-item-message';

import { userName } from '../../utils';

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
          fromName={userName(msg.from_id, this.props.users, msg.from_name)}
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
  currentUserEmail: React.PropTypes.string,
  currentUser: React.PropTypes.string.isRequired,
  messages: React.PropTypes.array.isRequired,
  users: React.PropTypes.object.isRequired,
  sendEmail: React.PropTypes.func.isRequired,
};

export default ListMessages;
