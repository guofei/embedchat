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
    bottom: 20,
    right: 40,
  },
  messagesAndForm: {
    overflow: 'auto',
    height: '95%',
  },
  messages: {
    overflow: 'auto',
    height: '80%',
  },
  messageForm: {
    minWidth: '300px',
    height: '20%',
    backgroundColor: 'white',
    padding: '10px',
    WebkitBoxSizing: 'border-box',
    MozBoxSizing: 'border-box',
    boxSizing: 'border-box',
  },
};

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
    const msgs = this.state.data;
    const newID = msgs.length + 1;
    const now = new Date();
    const newMsg = { id: newID, name: 'you', text: inputText, createdAt: now.toLocaleString() };
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
          <MenuBar onClose={this.handleClose}/>
          <div style={styles.messagesAndForm}>
            <div ref="messages" style={styles.messages}>
              <ListMessages messages={this.state.data} />
            </div>
            <div style={styles.messageForm}>
              <MessageForm onInputMessage={this.handleInputMessage} />
            </div>
          </div>
        </LeftNav>
      </div>
    );
  }
}

export default Chat;
