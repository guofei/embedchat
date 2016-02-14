import React from 'react';
import Paper from 'material-ui/lib/paper';

import UserLists from './user-lists';
import ListMessages from './list-messages';
import MessageForm from './message-form';

const dataMoc = [
  { id: 1, name: 'abc', text: 'helll', createdAt: 'Thu, 11 Feb 2016 14:54:07 GMT' },
  { id: 2, name: 'aghh', text: 'fsadf lkj sdlf ', createdAt: 'Thu, 11 Feb 2016 14:54:07 GMT' },
  { id: 3, name: 'dds', text: 'abcd lkj sdlf ', createdAt: 'Thu, 11 Feb 2016 14:54:07 GMT' },
];

const userMoc = [
  { uid: 'ADAF9924-EEC8-467A-A822-AA4DB2887814' },
  { uid: 'EDAF9924-EEC8-467A-A822-AA4DB2887814' },
];

class ChatWebmaster extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      data: dataMoc,
      onlineUsers: userMoc,
      offlineUsers: userMoc,
    };
    this.handleInputMessage = this.handleInputMessage.bind(this);
    this.handleSelectUser = this.handleSelectUser.bind(this);
  }

  handleInputMessage(inputText) {
    console.log(inputText);
  }

  handleSelectUser(name) {
    console.log(name);
  }

  render() {
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
          <Paper zDepth={1}>
            <ListMessages messages={this.state.data} />
            <MessageForm onInputMessage={this.handleInputMessage} />
          </Paper>
        </div>
      </div>
    );
  }
}

export default ChatWebmaster;
