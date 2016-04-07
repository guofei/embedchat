import React from 'react';
import Paper from 'material-ui/lib/paper';
import { connect } from 'react-redux';
import injectTapEventPlugin from 'react-tap-event-plugin';

import { selectUser } from '../actions';

import UserLists from './webmaster/user-lists';
import Messages from './webmaster/messages';
import AccessLog from './webmaster/access-log';

injectTapEventPlugin();

class ChatWebmaster extends React.Component {
  constructor(props) {
    super(props);
    this.handleInputMessage = this.handleInputMessage.bind(this);
    this.handleSelectUser = this.handleSelectUser.bind(this);
    this.handleCloseMessages = this.handleCloseMessages.bind(this);
  }

  componentDidMount() {
    this.props.room.join();
  }

  handleInputMessage(inputText) {
    if (this.props.selectedUser) {
      this.props.room.send(inputText, this.props.selectedUser);
    }
  }

  handleSelectUser(userName) {
    this.props.dispatch(selectUser(userName));
  }

  handleCloseMessages() {
    this.props.dispatch(selectUser(''));
  }

  render() {
    const {
      onlineUsers, offlineUsers, messages, currentUser, selectedUser, logs,
    } = this.props;

    let paper = null;
    if (selectedUser) {
      paper = (
        <div className="mdl-grid">
          <div className="mdl-cell mdl-cell--8-col">
            <Messages
              messages={messages}
              currentUser={currentUser}
              onInputMessage={this.handleInputMessage}
              onClose={this.handleCloseMessages}
            />
          </div>
          <div className="mdl-cell mdl-cell--4-col">
            <AccessLog
              currentUser={currentUser}
              logs={logs}
            />
          </div>
        </div>
      );
    } else {
      paper = (
        <div className="mdl-grid">
          <div className="mdl-cell mdl-cell--1-col"></div>
          <div className="mdl-cell mdl-cell--10-col">
            <Paper zDepth={1}>
              <UserLists
                onlineUsers={onlineUsers}
                offlineUsers={offlineUsers}
                onUserSelected={this.handleSelectUser}
              />
            </Paper>
          </div>
          <div className="mdl-cell mdl-cell--1-col"></div>
        </div>
      );
    }
    return (
      <div>
        { paper }
      </div>
    );
  }
}

ChatWebmaster.propTypes = {
  room: React.PropTypes.object.isRequired,
  dispatch: React.PropTypes.func.isRequired,
  messages: React.PropTypes.array.isRequired,
  onlineUsers: React.PropTypes.array.isRequired,
  offlineUsers: React.PropTypes.array.isRequired,
  currentUser: React.PropTypes.string.isRequired,
  selectedUser: React.PropTypes.string.isRequired,
  logs: React.PropTypes.array.isRequired,
};

// TODO refactoring
function toArr(obj) {
  return Object.keys(obj).map((k) => obj[k]);
}

function select(state) {
  const current = state.currentUser;
  const users = state.users;
  const selected = state.selectedUser;
  return {
    messages: toArr(state.messages).filter(x =>
      x.from_id === selected || x.to_id === selected
    ),
    onlineUsers: toArr(users).filter(x => x.online && x.uid !== current),
    offlineUsers: toArr(users).filter(x => !x.online && x.uid !== current),
    logs: toArr(state.logs).filter(x => x.uid === selected),
    currentUser: current,
    selectedUser: selected,
  };
}

export default connect(select)(ChatWebmaster);
