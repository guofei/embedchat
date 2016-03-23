import React from 'react';
import List from 'material-ui/lib/lists/list';

import ListItemMessage from './list-item-message';

class ListMessages extends React.Component {
  render() {
    const messages = this.props.messages.map((msg) =>
      (
        <ListItemMessage
          currentUser={this.props.currentUser}
          key={msg.id}
          from={msg.from_id}
          from_name={msg.from_name}
          createdAt={msg.inserted_at}
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
  messages: React.PropTypes.array.isRequired,
};

export default ListMessages;
