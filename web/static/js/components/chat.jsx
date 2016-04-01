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
  messageMenu: {
    minWidth: '300px',
    position: 'fixed',
    top: '0px',
  },
  messagesBox: {
    position: 'fixed',
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
  },
  messageForm: {
    position: 'fixed',
    bottom: '0px',
    minWidth: '290px',
    height: '80px',
    backgroundColor: 'white',
    marginLeft: '10px',
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
    this.handleReceiveMessage = this.handleReceiveMessage.bind(this);
    this.handleHistory = this.handleHistory.bind(this);
  }

  componentDidMount() {
    this.props.room.onMessage((msg) => {
      this.handleReceiveMessage(msg);
    });
    this.props.room.onHistory((history) => {
      this.handleHistory(history);
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
    this.props.room.send(inputText, 'admin');
  }

  handleReceiveMessage(msg) {
    const msgs = this.state.data;
    const newMsgs = msgs.concat([msg]);
    this.setState({ data: newMsgs });
  }

  handleHistory(history) {
    this.setState({ data: history.messages });
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
          style={styles.abs}
          width={300}
          openRight
          open={this.state.open}
        >
          <div style={styles.messageMenu}>
            <MenuBar onClose={this.handleClose}/>
          </div>
          <div style={styles.messagesBox}>
            <div ref="messages" style={styles.messages}>
              <ListMessages
                messages={this.state.data}
                currentUser={this.props.room.currentUser()}
              />
            </div>
          </div>
          <div style={styles.messageForm}>
            <MessageForm onInputMessage={this.handleInputMessage} />
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
