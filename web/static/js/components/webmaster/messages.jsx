import React from 'react';
import ReactDOM from 'react-dom';

import Paper from 'material-ui/lib/paper';
import Toolbar from 'material-ui/lib/toolbar/toolbar';
import ToolbarTitle from 'material-ui/lib/toolbar/toolbar-title';
import ToolbarGroup from 'material-ui/lib/toolbar/toolbar-group';
import IconButton from 'material-ui/lib/icon-button';
import NavigationClose from 'material-ui/lib/svg-icons/navigation/close';

import ListMessages from '../list-messages';
import MessageForm from '../message-form';

const styles = {
  messages: {
    overflow: 'auto',
    minHeight: '300px',
    maxHeight: '600px',
  },
  messageForm: {
    backgroundColor: 'white',
    marginLeft: '10px',
  },
};

class Messages extends React.Component {
  constructor(props) {
    super(props);
    this.handleTouchTap = this.handleTouchTap.bind(this);
  }

  componentDidMount() {
    this.scrollMessages();
  }

  componentDidUpdate() {
    this.scrollMessages();
  }

  scrollMessages() {
    const node = ReactDOM.findDOMNode(this.refs.messages);
    if (node) {
      node.scrollTop = node.scrollHeight;
    }
  }

  handleTouchTap() {
    this.props.onClose();
  }

  render() {
    return (
      <Paper zDepth={1}>
        <Toolbar>
          <ToolbarTitle
            text={`Message: ${this.props.selectedUser.substring(0, 7)}`}
          />
          <ToolbarGroup float="right">
            <IconButton onTouchTap={this.handleTouchTap}>
              <NavigationClose />
            </IconButton>
          </ToolbarGroup>
        </Toolbar>
        <div
          ref="messages"
          style={styles.messages}
        >
          <ListMessages
            messages={this.props.messages}
            currentUser={this.props.currentUser}
          />
          <div style={styles.messageForm}>
            <MessageForm onInputMessage={this.props.onInputMessage} />
          </div>
        </div>
      </Paper>
    );
  }
}

Messages.propTypes = {
  currentUser: React.PropTypes.string.isRequired,
  selectedUser: React.PropTypes.string.isRequired,
  messages: React.PropTypes.array.isRequired,
  onInputMessage: React.PropTypes.func.isRequired,
  onClose: React.PropTypes.func.isRequired,
};

export default Messages;
