import React from 'react';
import Paper from 'material-ui/lib/paper';

import UserLists from './user-lists';
import ListMessages from './list-messages';
import MessageForm from './message-form';

// const dataMoc = [
//   { id: 1, name: 'abc', text: 'helll', createdAt: 'Thu, 11 Feb 2016 14:54:07 GMT' },
//   { id: 2, name: 'aghh', text: 'fsadf lkj sdlf ', createdAt: 'Thu, 11 Feb 2016 14:54:07 GMT' },
//   { id: 3, name: 'dds', text: 'abcd lkj sdlf ', createdAt: 'Thu, 11 Feb 2016 14:54:07 GMT' },
// ];

// TODO refactoring
function shortName(fullName) {
  return fullName.substring(0, 7);
}

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
    this.props.room.join();
  }

  handleInputMessage(inputText) {
    if (this.state.currentUser) {
      this.props.room.send(inputText, this.state.currentUser);
    }
  }

  handleReceiveMessage(msg) {
    if (!this.state.currentUser) {
      this.setState({ currentUser: msg.from });
    }
    if (this.state.currentUser === msg.from) {
      const data = this.state.data;
      const newMsg = msg;
      newMsg.from = this.props.room.isSelf(msg.from) ? 'You' : msg.from;
      const newData = data.concat([newMsg]);
      this.setState({ data: newData });
    }
    const users = this.state.onlineUsers + this.state.offlineUsers;
    const oldUser = users.find((u) => u.uid === msg.from);
    if (oldUser) {
      oldUser.numMessages += 1;
      const newUsers = mergeDup(users.concat([oldUser]));
      this.setState({ onlineUsers: newUsers });
    }
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

  handleSelectUser(userName) {
    if (userName !== this.state.currentUser) {
      this.setState({ currentUser: userName });
      this.setState({ data: [] });
    }
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
