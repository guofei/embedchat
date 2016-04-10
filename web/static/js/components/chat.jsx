import React from 'react';
import ReactDOM from 'react-dom';
import { connect } from 'react-redux';

import LeftNav from 'material-ui/lib/left-nav';
import FloatingActionButton from 'material-ui/lib/floating-action-button';
import CommunicationMessage from 'material-ui/lib/svg-icons/communication/message';
import Badge from 'material-ui/lib/badge';
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

class Chat extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      open: false,
    };
    this.handleTouchTap = this.handleTouchTap.bind(this);
    this.handleClose = this.handleClose.bind(this);
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
    this.setState({ open: true });
  }

  handleClose() {
    this.setState({ open: false });
  }

  handleInputMessage(inputText) {
    this.props.room.send(inputText, 'admin');
  }

  render() {
    const left =
        (
          <LeftNav
            width={300}
            openRight
            open={this.state.open}
          >
            <div style={styles.messagesBox}>
              <div ref="messages" style={styles.messages}>
                <ListMessages
                  messages={this.props.messages}
                  currentUser={this.props.currentUser}
                />
              </div>
            </div>
            <div style={styles.messageMenu}>
              <MenuBar onClose={this.handleClose}/>
            </div>
            <div style={styles.messageForm}>
              <MessageForm onInputMessage={this.handleInputMessage} />
            </div>
          </LeftNav>
        );
    return (
      <div>
        <div style={styles.fixed}>
          <Badge
            badgeContent={"new"}
            primary
            badgeStyle={{ top: 18, right: 18 }}
          >
            <FloatingActionButton
              secondary
              onTouchTap={this.handleTouchTap}
            >
              <CommunicationMessage />
            </FloatingActionButton>
          </Badge>
        </div>
        { left }
      </div>
    );
  }
}

Chat.propTypes = {
  room: React.PropTypes.object.isRequired,
  messages: React.PropTypes.array.isRequired,
  currentUser: React.PropTypes.string.isRequired,
};

// TODO refactoring
function toArr(obj) {
  return Object.keys(obj).map((k) => obj[k]);
}

function select(state) {
  return {
    messages: toArr(state.messages).filter(x =>
      x.from_id === state.currentUser || x.to_id === state.currentUser
    ),
    currentUser: state.currentUser,
  };
}

export default connect(select)(Chat);
