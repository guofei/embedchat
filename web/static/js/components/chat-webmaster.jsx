import React from 'react';
import Paper from 'material-ui/lib/paper';

import UserLists from './user-lists';
import ListMessages from './list-messages';
import MessageForm from './message-form';

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
      currentUser: null,
    };
    this.handleInputMessage = this.handleInputMessage.bind(this);
    this.handleReceiveMessage = this.handleReceiveMessage.bind(this);
    this.handleSelectUser = this.handleSelectUser.bind(this);
    this.handleUserJoin = this.handleUserJoin.bind(this);
    this.handleUserLeft = this.handleUserLeft.bind(this);
    this.handleHistory = this.handleHistory.bind(this);
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
    if (this.state.currentUser) {
      this.props.room.send(inputText, this.state.currentUser);
    }
  }

  handleReceiveMessage(msg) {
    if (!this.state.currentUser) {
      this.setState({ currentUser: msg.from_id });
    }
    if (this.state.currentUser === msg.from_id
      || this.state.currentUser === msg.to_id) {
      const data = this.state.data;
      const newMsg = msg;
      newMsg.from_id = this.props.room.isSelf(msg.from_id) ? 'You' : msg.from_id;
      const newData = data.concat([newMsg]);
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
    if (this.state.currentUser !== history.uid) {
      return;
    }
    const messages = history.messages.map((m) => {
      if (this.props.room.isSelf(m.from_id)) {
        const newMsg = m;
        newMsg.from_id = 'You';
        return newMsg;
      }
      return m;
    });
    this.setState({ data: messages });
  }

  handleSelectUser(userName) {
    if (userName !== this.state.currentUser) {
      this.setState({ currentUser: userName });
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

  render() {
    let paper = null;
    if (this.state.currentUser) {
      paper = (
        <Paper zDepth={1}>
          <ListMessages messages={this.state.data} />
          <MessageForm onInputMessage={this.handleInputMessage} />
        </Paper>
      );
    } else {
      paper = (
        <Paper />
      );
    }
    return (
      <div className="row">
        <div className="col-xs-3">
          <Paper zDepth={1}>
            <UserLists
              onlineUsers={this.state.onlineUsers}
              offlineUsers={this.state.offlineUsers}
              onUserSelected={this.handleSelectUser}
            />
          </Paper>
        </div>
        <div className="col-xs-9">
          {paper}
        </div>
      </div>
    );
  }
}

ChatWebmaster.propTypes = {
  room: React.PropTypes.object.isRequired,
};

export default ChatWebmaster;
