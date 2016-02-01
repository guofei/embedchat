import React from "react"

import AppBar from 'material-ui/lib/app-bar'
import LeftNav from 'material-ui/lib/left-nav'
import IconButton from 'material-ui/lib/icon-button'
import NavigationClose from 'material-ui/lib/svg-icons/navigation/close'

import List from 'material-ui/lib/lists/list'
import ListItem from 'material-ui/lib/lists/list-item'
import Avatar from 'material-ui/lib/avatar'
import TextField from 'material-ui/lib/text-field'
import RaisedButton from 'material-ui/lib/raised-button'
import injectTapEventPlugin from 'react-tap-event-plugin'

injectTapEventPlugin()

const data = [
  {id: 1, name: "Pete Hunt", text: "This is one comment", createdAt: "2016/01/31 15:00"},
]

const styles = {
  fixed: {
    position: "fixed",
    bottom: 5,
    right: 0,
    width: "300px",
  },
  messageForm: {
    minWidth: "300px",
  },
  list: {
    maxHeight: "500px",
    overflow: "scroll",
  },
  popover: {
    position: "fixed",
    bottom: 5,
    right: 5,
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
        leftAvatar={<Avatar>{this.avatar()}</Avatar>}
        primaryText={this.props.name}
        secondaryText={
          <p>
            {this.props.createdAt}<br />
            {this.props.children}
          </p>
        }
        secondaryTextLines={2}
        />
    )
  }
})

const ListMessages = React.createClass({
  render: function() {
    var messages = this.props.messages.map(function(msg) {
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
  render: function() {
    return (
      <AppBar
        title="Chat"
        iconElementRight={<IconButton><NavigationClose /></IconButton>}
        />
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
      <List>
        <ListItem
          style={styles.messageForm}
          disabled={true}>
          <TextField
            onEnterKeyDown={this.handleEnterKyeDown}
            fullWidth={true}
            hintText="Input Message"
            />
        </ListItem>
      </List>
    )
  }
})

const Chat = React.createClass({
  getInitialState: function() {
    return {
      open: false,
      anchorEl: null,
      data: data,
    }
  },

  handleTouchTap: function(event) {
    this.setState({
      open: true,
      anchorEl: event.currentTarget,
    })
  },

  handleInputMessage: function(text) {
    const msgs = this.state.data
    const newID = msgs.length + 1
    const newMsg = {id: newID, name: "you", text: text, createdAt: Date.now()}
    const newMsgs = msgs.concat([newMsg])
    this.setState({data: newMsgs})
  },

  render: function() {
    return (
      <div>
        <RaisedButton
          label="Secondary"
          secondary={true}
          style={styles.fixed}
          onTouchTap={this.handleTouchTap}
          label="Click me to chat"
          />
        <LeftNav width={300} openRight={true} open={this.state.open} >
          <MenuBar />
          <ListMessages messages={this.state.data}/>
          <MessageForm onInputMessage={this.handleInputMessage}/>
        </LeftNav>
      </div>
    )
  }
})

export default Chat
