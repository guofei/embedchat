import React from 'react';
import Paper from 'material-ui/lib/paper';

import UserLists from './webmaster/user-lists';
import Messages from './webmaster/messages';

function mergeDup(arr) {
  return arr.reduce((prev, current, index) => {
    const newArr = prev;
    if (!(current.uid in prev.keys)) {
      newArr.keys[current.uid] = index;
      newArr.result.push(current);
    } else {
      newArr.result[newArr.keys[current.uid]] = current;
    }
    return prev;
  }, { result: [], keys: {} }).result;
}

function remove(arr, uid) {
  return arr.filter(x => uid !== x.uid);
}

function createNewUsers(searched, merged, id) {
  const oldUser = searched.find((u) => u.uid === id);
  const num = oldUser ? oldUser.numMessages : 0;
  const newUser = { uid: id, numMessages: num };
  return mergeDup(merged.concat([newUser]));
}

class ChatWebmaster extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      data: [],
      onlineUsers: [],
      offlineUsers: [],
      selectedUser: null,
    };
    this.handleInputMessage = this.handleInputMessage.bind(this);
    this.handleReceiveMessage = this.handleReceiveMessage.bind(this);
    this.handleSelectUser = this.handleSelectUser.bind(this);
    this.handleUserJoin = this.handleUserJoin.bind(this);
    this.handleUserLeft = this.handleUserLeft.bind(this);
    this.handleHistory = this.handleHistory.bind(this);
    this.handleCloseMessages = this.handleCloseMessages.bind(this);
  }

  componentDidMount() {
    this.props.room.onMessage((msg) => {
      this.handleReceiveMessage(msg);
    });
    this.props.room.onUserJoin((user) => {
      this.handleUserJoin(user);
    });
    this.props.room.onUserLeft((user) => {
      this.handleUserLeft(user);
    });
    this.props.room.onHistory((his) => {
      this.handleHistory(his);
    });
    this.props.room.join();
  }

  handleInputMessage(inputText) {
    if (this.state.selectedUser) {
      this.props.room.send(inputText, this.state.selectedUser);
    }
  }

  handleReceiveMessage(msg) {
    if (!this.state.selectedUser) {
      this.setState({ selectedUser: msg.from_id });
    }
    if (this.state.selectedUser === msg.from_id
      || this.state.selectedUser === msg.to_id) {
      const data = this.state.data;
      const newData = data.concat([msg]);
      this.setState({ data: newData });
    }
    const find = (u) => {
      const user = u;
      if (user.uid === msg.from_id) {
        user.numMessages += 1;
      }
      return user;
    };
    const onlines = this.state.onlineUsers.map(find);
    this.setState({ onlineUsers: onlines });

    const offlines = this.state.offlineUsers.map(find);
    this.setState({ offlineUsers: offlines });
  }

  handleUserJoin(user) {
    if (this.props.room.isSelf(user.uid)) {
      return;
    }
    const newUsers = createNewUsers(
      this.state.offlineUsers,
      this.state.onlineUsers,
      user.uid);
    this.setState({ onlineUsers: newUsers });

    const offlines = remove(this.state.offlineUsers, user.uid);
    this.setState({ offlineUsers: offlines });
  }

  handleUserLeft(user) {
    if (this.props.room.isSelf(user.uid)) {
      return;
    }
    const newUsers = createNewUsers(
      this.state.onlineUsers,
      this.state.offlineUsers,
      user.uid);
    this.setState({ offlineUsers: newUsers });

    const onlines = remove(this.state.onlineUsers, user.uid);
    this.setState({ onlineUsers: onlines });
  }

  handleHistory(history) {
    if (this.state.selectedUser !== history.uid) {
      return;
    }
    this.setState({ data: history.messages });
  }

  handleSelectUser(userName) {
    if (userName !== this.state.selectedUser) {
      this.setState({ selectedUser: userName });
      this.setState({ data: [] });
    }
    const find = (u) => {
      const user = u;
      if (user.uid === userName) {
        user.numMessages = 0;
      }
      return user;
    };
    const onlines = this.state.onlineUsers.map(find);
    this.setState({ onlineUsers: onlines });

    const offlines = this.state.offlineUsers.map(find);
    this.setState({ offlineUsers: offlines });

    this.props.room.history(userName);
  }

  handleCloseMessages() {
    this.setState({ selectedUser: null });
  }

  render() {
    let paper = null;
    if (this.state.selectedUser) {
      paper = (
        <div className="mdl-grid">
          <div className="mdl-cell mdl-cell--8-col">
            <Messages
              messages={this.state.data}
              currentUser={this.props.room.currentUser()}
              onInputMessage={this.handleInputMessage}
              onClose={this.handleCloseMessages}
            />
          </div>
          <div className="mdl-cell mdl-cell--4-col">
            access log
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
                onlineUsers={this.state.onlineUsers}
                offlineUsers={this.state.offlineUsers}
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
};

export default ChatWebmaster;
