import React from 'react';
import Paper from 'material-ui/lib/paper';
import { connect } from 'react-redux';
// import injectTapEventPlugin from 'react-tap-event-plugin';

import { selectUser } from '../actions';

import UserLists from './webmaster/user-lists';
import Messages from './webmaster/messages';
import EmptyMessage from './webmaster/empty-message';
import AccessLogs from './webmaster/access-logs';

// injectTapEventPlugin();

function CurrentMessages({ selected, current, msgs, input, close }) {
  return (
    <Messages
      messages={msgs}
      currentUser={current}
      selectedUser={selected}
      onInputMessage={input}
      onClose={close}
    />
  );
}

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

    let msgElement = (<EmptyMessage />);
    if (selectedUser) {
      msgElement = (
        <CurrentMessages
          current={currentUser}
          selected={selectedUser}
          msgs={messages}
          input={this.handleInputMessage}
          close={this.handleCloseMessages}
        />
      );
    }

    const paper = (
        <div className="mdl-grid">
          <div className="mdl-cell mdl-cell--3-col">
            <Paper zDepth={1}>
              <UserLists
                onlineUsers={onlineUsers}
                offlineUsers={offlineUsers}
                onUserSelected={this.handleSelectUser}
              />
            </Paper>
          </div>
          <div className="mdl-cell mdl-cell--6-col">
            {msgElement}
          </div>
          <div className="mdl-cell mdl-cell--3-col">
            <AccessLogs
              currentUser={currentUser}
              logs={logs}
            />
          </div>
        </div>
      );

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

function updateUserMessage(user, uid, msg) {
  if (!user || user.uid !== uid) {
    return user;
  }

  if (user.message) {
    if (user.message.id < msg.id) {
      return Object.assign({}, user, { message: msg });
    }
  } else {
    return Object.assign({}, user, { message: msg });
  }

  return user;
}

function usersWithMessage(state) {
  const usersObjCopy = Object.assign({}, state.users);
  const messagesObj = state.messages;
  for (const msgID in messagesObj) {
    if (messagesObj.hasOwnProperty(msgID)) {
      const msg = messagesObj[msgID];
      const uids = [msg.from_id, msg.to_id];
      for (const uid of uids) {
        const newUser = updateUserMessage(usersObjCopy[uid], uid, msg);
        if (newUser) {
          usersObjCopy[uid] = newUser;
        }
      }
    }
  }
  return usersObjCopy;
}

function select(state) {
  const current = state.currentUser;
  const users = toArr(usersWithMessage(state));
  const selected = state.selectedUser;
  return {
    messages: toArr(state.messages).filter(x =>
      x.from_id === selected || x.to_id === selected
    ),
    onlineUsers: users.filter(x => x.online && x.uid !== current),
    offlineUsers: users.filter(x => !x.online && x.uid !== current),
    logs: toArr(state.logs).filter(x => x.uid === selected),
    currentUser: current,
    selectedUser: selected,
  };
}

export default connect(select)(ChatWebmaster);
