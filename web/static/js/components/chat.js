import React from "react"
import ReactDOM from "react-dom"

import AppBar from 'material-ui/lib/app-bar'
import LeftNav from 'material-ui/lib/left-nav'
import IconButton from 'material-ui/lib/icon-button'
import FloatingActionButton from 'material-ui/lib/floating-action-button'
import NavigationClose from 'material-ui/lib/svg-icons/navigation/close'
import CommunicationMessage from 'material-ui/lib/svg-icons/communication/message'
import List from 'material-ui/lib/lists/list'
import ListItem from 'material-ui/lib/lists/list-item'
import Avatar from 'material-ui/lib/avatar'
import TextField from 'material-ui/lib/text-field'
import Colors from 'material-ui/lib/styles/colors'
import injectTapEventPlugin from 'react-tap-event-plugin'

injectTapEventPlugin()

const data = [
  {id: 1, name: "Pete Hunt", text: "This is one comment", createdAt: "1/2/2016, 1:54:37 PM"},
]

const styles = {
  fixed: {
    position: "fixed",
    bottom: 20,
    right: 40,
  },
  messagesAndForm: {
    overflow: "auto",
    height: "95%",
  },
  messages: {
    overflow: "auto",
    height: "80%",
  },
  messageForm: {
    minWidth: "300px",
    height: "20%",
    backgroundColor: "white",
    padding: "10px",
    WebkitBoxSizing: "border-box",
    MozBoxSizing: "border-box",
    boxSizing: "border-box",
  },
}

const ListItemMessage = React.createClass({
  avatar: function() {
    if (this.props.name.length > 0)
      return this.props.name[0].toUpperCase()
    else
      return "A"
  },

  render: function() {
    return (
      <ListItem
        secondaryTextLines={2}
        leftAvatar={<Avatar>{this.avatar()}</Avatar>}
        primaryText={this.props.name}
        secondaryText={
          <div>
            {this.props.createdAt}<br />
            {this.props.children}
          </div>
        }
        />
    )
  }
})

const ListMessages = React.createClass({
  render: function() {
    const messages = this.props.messages.map(function(msg) {
      return (
        <ListItemMessage
          key={msg.id}
          name={msg.name}
          createdAt={msg.createdAt}>
          {msg.text}
        </ListItemMessage>
      )
    })
    return (
      <List>
        {messages}
      </List>
    )
  }
})

const MenuBar = React.createClass({
  handleTouchTap: function(event) {
    this.props.onClose()
  },

  render: function() {
    return (
      <AppBar
        title="Chat"
        iconElementRight={
          <IconButton onTouchTap={this.handleTouchTap}>
            <NavigationClose />
          </IconButton>
        }
        />
    )
  }
})

const License = React.createClass({
  render: function() {
    return (
      <div
        style={{color: Colors.grey500}}
        >
        <center>
          Powered by&nbsp;
          <a
            style={{color: Colors.grey500}}
            href="#">
            XXX
          </a>
        </center>
      </div>
    )
  }
})

const MessageForm = React.createClass({
  handleEnterKyeDown: function(event) {
    const text = event.target.value
    this.props.onInputMessage(text)
    event.target.value = ""
    return
  },

  render: function() {
    return (
      <div>
        <TextField
          onEnterKeyDown={this.handleEnterKyeDown}
          fullWidth={true}
          hintText="Input Message"
          />
        <License />
      </div>
    )
  }
})

const Chat = React.createClass({
  getInitialState: function() {
    return {
      open: false,
      data: data,
    }
  },

  handleTouchTap: function(event) {
    this.setState({open: true})
  },

  handleClose: function() {
    this.setState({open: false})
  },

  handleInputMessage: function(text) {
    const msgs = this.state.data
    const newID = msgs.length + 1
    const now = new Date()
    const newMsg = {id: newID, name: "you", text: text, createdAt: now.toLocaleString()}
    const newMsgs = msgs.concat([newMsg])
    this.setState({data: newMsgs})
  },

  componentDidUpdate: function() {
    const node = ReactDOM.findDOMNode(this.refs.messages)
    node.scrollTop = node.scrollHeight
  },

  render: function() {
    return (
      <div>
        <div style={styles.fixed}>
          <FloatingActionButton
            secondary={true}
            onTouchTap={this.handleTouchTap}>
            <CommunicationMessage />
          </FloatingActionButton>
        </div>
        <LeftNav
          width={300}
          openRight={true}
          open={this.state.open} >
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
    )
  }
})

export default Chat
