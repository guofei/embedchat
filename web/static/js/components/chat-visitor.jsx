import React from 'react';
import ReactDOM from 'react-dom';
import { connect } from 'react-redux';
import { readAllMessages, openChat } from '../actions';

import getMuiTheme from 'material-ui/styles/getMuiTheme';
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import Drawer from 'material-ui/Drawer';
import FloatingActionButton from 'material-ui/FloatingActionButton';
import CommunicationMessage from 'material-ui/svg-icons/communication/message';
import injectTapEventPlugin from 'react-tap-event-plugin';

import MenuBar from './common/menu-bar';
import ListMessages from './common/list-messages';
import MessageForm from './common/message-form';

import { objectToArray } from '../utils';

injectTapEventPlugin();

const styles = {
  fixed: {
    position: 'fixed',
    bottom: '20px',
    right: '40px',
  },
  messageMenu: {
    position: 'absolute',
    minWidth: '300px',
    top: '0px',
  },
  messagesBox: {
    height: '100%',
    paddingTop: '40px',
    paddingBottom: '80px',
    boxSizing: 'border-box',
    WebkitBoxSizing: 'border-box',
    MozBoxSizing: 'border-box',
  },
  messages: {
    overflow: 'auto',
    height: '100%',
    minWidth: '300px',
    textAlign: 'left',
  },
  messageForm: {
    position: 'absolute',
    bottom: '0px',
    minWidth: '290px',
    height: '80px',
    backgroundColor: 'white',
    marginLeft: '10px',
  },
};

class ChatVisitor extends React.Component {
  constructor(props) {
    super(props);
    this.handleTouchTap = this.handleTouchTap.bind(this);
    this.handleClose = this.handleClose.bind(this);
    this.handleTouchMenu = this.handleTouchMenu.bind(this);
    this.handleInputMessage = this.handleInputMessage.bind(this);
  }

  componentDidMount() {
    this.scrollMessages();
    this.props.room.join();
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
    this.props.dispatch(readAllMessages());
    this.props.dispatch(openChat(true));
  }

  handleClose() {
    this.props.dispatch(readAllMessages());
    this.props.dispatch(openChat(false));
  }

  handleTouchMenu() {
    // users = this.props.users
  }

  handleInputMessage(inputText) {
    if (this.props.selectedAdmin) {
      this.props.room.send(inputText, this.props.selectedAdmin);
    } else {
      this.props.room.send(inputText, 'admin');
    }
  }

  render() {
    // console.log(this.props);
    const left =
        (
          <Drawer
            width={300}
            openSecondary
            open={this.props.openChat}
          >
            <div style={styles.messagesBox}>
              <div ref="messages" style={styles.messages}>
                <ListMessages
                  messages={this.props.messages}
                  users={this.props.allUsers}
                  currentUser={this.props.currentUser}
                  currentUserEmail={this.props.currentUserEmail}
                  sendEmail={this.props.room.sendEmail}
                />
              </div>
            </div>
            <div style={styles.messageMenu}>
              <MenuBar onClose={this.handleClose} onTouchMenu={this.handleTouchMenu}/>
            </div>
            <div style={styles.messageForm}>
              <MessageForm onInputMessage={this.handleInputMessage} />
            </div>
          </Drawer>
        );
    return (
      <MuiThemeProvider muiTheme={getMuiTheme()}>
      <div>
        <div style={styles.fixed}>
          <FloatingActionButton
            onTouchTap={this.handleTouchTap}
          >
            <CommunicationMessage />
          </FloatingActionButton>
        </div>
        { left }
      </div>
      </MuiThemeProvider>
    );
  }
}

ChatVisitor.propTypes = {
  room: React.PropTypes.shape({
    join: React.PropTypes.func.isRequired,
    send: React.PropTypes.func.isRequired,
    sendEmail: React.PropTypes.func.isRequired,
  }),
  messages: React.PropTypes.array.isRequired,
  allUsers: React.PropTypes.object.isRequired,
  admins: React.PropTypes.array.isRequired,
  currentUser: React.PropTypes.string.isRequired,
  currentUserEmail: React.PropTypes.string.isRequired,
  selectedAdmin: React.PropTypes.string.isRequired,
  openChat: React.PropTypes.bool.isRequired,
  dispatch: React.PropTypes.func.isRequired,
};

function select(state) {
  const msgs = objectToArray(state.messages).filter(x =>
    x.type !== 'email_response' &&
    (x.from_id === state.currentUser || x.to_id === state.currentUser)
  );
  const adminUsers = objectToArray(state.users).filter(x => x.online && x.admin);
  return {
    messages: msgs,
    currentUser: state.currentUser,
    currentUserEmail: state.currentUserEmail,
    selectedAdmin: state.selectedUser,
    allUsers: state.users,
    admins: adminUsers,
    openChat: state.openChat,
  };
}

export default connect(select)(ChatVisitor);
