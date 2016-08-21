import React from 'react';
import ReactDOM from 'react-dom';

import Paper from 'material-ui/Paper';
import { Toolbar, ToolbarTitle, ToolbarGroup } from 'material-ui/Toolbar';
import IconButton from 'material-ui/IconButton';
import NavigationClose from 'material-ui/svg-icons/navigation/close';

import ListMessages from '../common/list-messages';
import MessageForm from '../common/message-form';

import { userShortName } from '../../utils';

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

function sendEmail(mail) {
  return mail;
}

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
            text={`Message: ${userShortName(this.props.selectedUser, this.props.users)}`}
          />
          <ToolbarGroup>
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
            users={this.props.users}
            currentUser={this.props.currentUser}
            sendEmail={sendEmail}
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
  users: React.PropTypes.object.isRequired,
  onInputMessage: React.PropTypes.func.isRequired,
  onClose: React.PropTypes.func.isRequired,
};

export default Messages;
