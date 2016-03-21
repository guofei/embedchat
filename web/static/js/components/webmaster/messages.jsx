import React from 'react';
import Paper from 'material-ui/lib/paper';
import Toolbar from 'material-ui/lib/toolbar/toolbar';
import ToolbarGroup from 'material-ui/lib/toolbar/toolbar-group';
import IconButton from 'material-ui/lib/icon-button';
import NavigationClose from 'material-ui/lib/svg-icons/navigation/close';

import ListMessages from '../list-messages';
import MessageForm from '../message-form';

class Messages extends React.Component {
  constructor(props) {
    super(props);
    this.handleTouchTap = this.handleTouchTap.bind(this);
  }

  handleTouchTap() {
    this.props.onClose();
  }

  render() {
    return (
      <Paper zDepth={2}>
        <Toolbar>
          <ToolbarGroup float="right">
            <IconButton onTouchTap={this.handleTouchTap}>
              <NavigationClose />
            </IconButton>
          </ToolbarGroup>
        </Toolbar>
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
  onClose: React.PropTypes.func.isRequired,
};

export default Messages;
