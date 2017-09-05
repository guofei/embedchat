import React from 'react';

import Paper from 'material-ui/Paper';
import { Toolbar, ToolbarTitle, ToolbarGroup } from 'material-ui/Toolbar';
import IconButton from 'material-ui/IconButton';
import NavigationClose from 'material-ui/svg-icons/navigation/close';

import Mailer from './mailer';
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
    this.messages.scrollTop = this.messages.scrollHeight;
  }

  handleTouchTap() {
    this.props.onClose();
  }

  render() {
    const {
      selectedUser, currentUser, users, messages,
      onInputMessage, onSendMessagesToUser,
    } = this.props;

    return (
      <Paper zDepth={1}>
        <Toolbar>
          <ToolbarTitle
            text={`Message: ${userShortName(selectedUser, users)}`}
          />
          <ToolbarGroup>
            <IconButton onTouchTap={this.handleTouchTap}>
              <NavigationClose />
            </IconButton>
          </ToolbarGroup>
        </Toolbar>
        <div ref={node => (this.messages = node)} style={styles.messages}>
          <ListMessages
            messages={messages}
            users={users}
            currentUser={currentUser}
            sendEmail={sendEmail}
          />
          <div>
            <Mailer
              visitor={users[selectedUser]}
              onMailMessagesToUser={onSendMessagesToUser}
            />
          </div>
          <div style={styles.messageForm}>
            <MessageForm onInputMessage={onInputMessage} />
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
  onSendMessagesToUser: React.PropTypes.func.isRequired,
};

export default Messages;
