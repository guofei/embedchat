import React from 'react';
import { connect } from 'react-redux';

// import injectTapEventPlugin from 'react-tap-event-plugin';
import getMuiTheme from 'material-ui/styles/getMuiTheme';
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import Paper from 'material-ui/Paper';

import UserLists from './webmaster/user-lists';
import Messages from './webmaster/messages';
import EmptyMessage from './webmaster/empty-message';
import VisitorDetail from './webmaster/visitor-detail';

import fetch from 'isomorphic-fetch';

import { selectUserDetailMenu, updateVisitor } from '../actions';
import { objectToArray } from '../utils';
import { host } from '../global';

// injectTapEventPlugin();

function CurrentMessages({ selected, current, msgs, users, input, close }) {
  return (
    <Messages
      messages={msgs}
      users={users}
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
    this.handleSelectUserDetailMenu = this.handleSelectUserDetailMenu.bind(this);
    this.handleUpdateVisitorInfo = this.handleUpdateVisitorInfo.bind(this);
  }

  componentDidMount() {
    this.props.room.join();
  }

  handleInputMessage(inputText) {
    if (this.props.selectedUser) {
      this.props.room.send(inputText, this.props.selectedUser);
    }
  }

  handleUpdateVisitorInfo(visitor) {
    this.props.dispatch(updateVisitor(visitor));
    const data = {
      visitor: { name: visitor.name, email: visitor.email, note: visitor.note },
      uuid: visitor.uid,
      room_uuid: this.props.room.getRoomUUID(),
    };
    fetch(`//${host}/api/visitors?token=${window.userToken}`, {
      method: 'POST',
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });
  }

  handleSelectUser(uid) {
    this.props.room.selectUser(uid);
  }

  handleSelectUserDetailMenu(menu) {
    this.props.dispatch(selectUserDetailMenu(menu));
  }

  handleCloseMessages() {
    this.props.room.selectUser('');
  }

  render() {
    const {
      onlineUsers, offlineUsers, messages, allUsers,
      currentUser, selectedUser, logs, selectedUserDetailMenu,
    } = this.props;

    let msgElement = (<EmptyMessage />);
    if (selectedUser) {
      msgElement = (
        <CurrentMessages
          current={currentUser}
          selected={selectedUser}
          msgs={messages}
          users={allUsers}
          input={this.handleInputMessage}
          close={this.handleCloseMessages}
        />
      );
    }
    const paper = (
        <div className="mdl-grid">
          <div className="mdl-cell mdl-cell--3-col mdl-cell--8-col-tablet mdl-cell--4-col-phone">
            <Paper zDepth={1}>
              <UserLists
                onlineUsers={onlineUsers}
                offlineUsers={offlineUsers}
                onUserSelected={this.handleSelectUser}
              />
            </Paper>
          </div>
          <div className="mdl-cell mdl-cell--6-col mdl-cell--8-col-tablet mdl-cell--4-col-phone">
            {msgElement}
          </div>
          <div className="mdl-cell mdl-cell--3-col mdl-cell--8-col-tablet mdl-cell--4-col-phone">
            <VisitorDetail
              visitor={Object.assign({}, allUsers[selectedUser])}
              onSelectedMenu={this.handleSelectUserDetailMenu}
              selectedMenu={selectedUserDetailMenu}
              onUpdateVisitor={this.handleUpdateVisitorInfo}
              logs={logs}
            />
          </div>
        </div>
      );

    return (
      <MuiThemeProvider muiTheme={getMuiTheme()}>
      <div>
        { paper }
      </div>
      </MuiThemeProvider>
    );
  }
}

ChatWebmaster.propTypes = {
  room: React.PropTypes.shape({
    join: React.PropTypes.func.isRequired,
    send: React.PropTypes.func.isRequired,
    selectUser: React.PropTypes.func.isRequired,
    getRoomUUID: React.PropTypes.func.isRequired,
  }),
  dispatch: React.PropTypes.func.isRequired,
  messages: React.PropTypes.array.isRequired,
  onlineUsers: React.PropTypes.array.isRequired,
  offlineUsers: React.PropTypes.array.isRequired,
  allUsers: React.PropTypes.object.isRequired,
  currentUser: React.PropTypes.string.isRequired,
  selectedUser: React.PropTypes.string.isRequired,
  selectedUserDetailMenu: React.PropTypes.string.isRequired,
  logs: React.PropTypes.array.isRequired,
};

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
  const users = objectToArray(usersWithMessage(state));
  const selected = state.selectedUser;
  return {
    messages: objectToArray(state.messages).filter(x =>
      x.from_id === selected || x.to_id === selected
    ),
    allUsers: state.users,
    onlineUsers: users.filter(x =>
      x.online && x.uid !== current && !x.admin
    ).sort((a, b) => b.id - a.id),
    offlineUsers: users.filter(x =>
      !x.online && x.uid !== current && !x.admin
    ).sort((a, b) => b.id - a.id),
    logs: objectToArray(state.logs).filter(x => x.uid === selected).sort((a, b) => b.id - a.id),
    currentUser: current,
    selectedUser: selected,
    selectedUserDetailMenu: state.selectedUserDetailMenu,
  };
}

export default connect(select)(ChatWebmaster);
