import React from 'react';
import Paper from 'material-ui/lib/paper';
import ListMessages from '../list-messages';
import MessageForm from '../message-form';

class Messages extends React.Component {
  render() {
    return (
      <Paper zDepth={1}>
        <ListMessages
          messages={this.props.messages}
          currentUser={this.props.currentUser}
        />
        <MessageForm onInputMessage={this.props.onInputMessage} />
      </Paper>
    );
  }
}

Messages.propTypes = {
  currentUser: React.PropTypes.string.isRequired,
  messages: React.PropTypes.array.isRequired,
  onInputMessage: React.PropTypes.func.isRequired,
};

export default Messages;
