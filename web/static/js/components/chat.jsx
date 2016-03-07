import React from 'react';
import ReactDOM from 'react-dom';

import LeftNav from 'material-ui/lib/left-nav';
import FloatingActionButton from 'material-ui/lib/floating-action-button';
import CommunicationMessage from 'material-ui/lib/svg-icons/communication/message';
import injectTapEventPlugin from 'react-tap-event-plugin';

import MenuBar from './menu-bar';
import ListMessages from './list-messages';
import MessageForm from './message-form';

injectTapEventPlugin();

const styles = {
  fixed: {
    position: 'fixed',
    bottom: '20px',
    right: '40px',
  },
  messagesAndForm: {
    position: 'fixed',
    height: '100%',
    top: '0px',
    marginTop: '60px',
  },
  messages: {
    overflow: 'auto',
    height: '77%',
  },
  messageForm: {
    minWidth: '300px',
    height: '23%',
    backgroundColor: 'white',
    marginLeft: '10px',
  },
};

function shortName(fullName) {
  return fullName.substring(0, 7);
}

class Chat extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      open: false,
      data: [],
    };
    this.handleTouchTap = this.handleTouchTap.bind(this);
    this.handleClose = this.handleClose.bind(this);
    this.handleInputMessage = this.handleInputMessage.bind(this);
  }

  componentDidMount() {
    this.props.room.onMessage((msg) => {
      this.handleReceiveMessage(msg);
    });
    this.props.room.join();
  }

  componentDidUpdate() {
    const node = ReactDOM.findDOMNode(this.refs.messages);
    node.scrollTop = node.scrollHeight;
  }

  handleTouchTap() {
    this.setState({ open: true });
  }

  handleClose() {
    this.setState({ open: false });
  }

  handleInputMessage(inputText) {
    this.props.room.send(inputText);
  }

  handleReceiveMessage(msg) {
    const msgs = this.state.data;
    const newID = msgs.length + 1;
    const now = new Date();
    const nm = this.props.room.isSelf(msg.name) ? 'You' : shortName(msg.name);
    const newMsg = { id: newID, name: nm, text: msg.body, createdAt: now.toUTCString() };
    const newMsgs = msgs.concat([newMsg]);
    this.setState({ data: newMsgs });
  }

  render() {
    return (
      <div>
        <div style={styles.fixed}>
          <FloatingActionButton
            secondary
            onTouchTap={this.handleTouchTap}
          >
            <CommunicationMessage />
          </FloatingActionButton>
        </div>
        <LeftNav
          width={300}
          openRight
          open={this.state.open}
        >
          <div>
          <div style={styles.menu}>
            <MenuBar onClose={this.handleClose}/>
          </div>
          <div style={styles.messagesAndForm}>
            <div ref="messages" style={styles.messages}>
              <ListMessages messages={this.state.data} />
            </div>
            <div style={styles.messageForm}>
              <MessageForm onInputMessage={this.handleInputMessage} />
            </div>
          </div>
          </div>
        </LeftNav>
      </div>
    );
  }
}

Chat.propTypes = {
  room: React.PropTypes.object.isRequired,
};

export default Chat;
