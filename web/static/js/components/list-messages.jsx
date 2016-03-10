import React from 'react';
import List from 'material-ui/lib/lists/list';

import ListItemMessage from './list-item-message';

class ListMessages extends React.Component {
  render() {
    const messages = this.props.messages.map((msg) =>
      (
        <ListItemMessage
          key={msg.id}
          name={msg.from}
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
  messages: React.PropTypes.array.isRequired,
};

export default ListMessages;
