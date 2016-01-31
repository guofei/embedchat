import React from "react"

import AppBar from 'material-ui/lib/app-bar'
import IconButton from 'material-ui/lib/icon-button'
import NavigationClose from 'material-ui/lib/svg-icons/navigation/close'

import List from 'material-ui/lib/lists/list'
import ListItem from 'material-ui/lib/lists/list-item'
import Avatar from 'material-ui/lib/avatar'
import TextField from 'material-ui/lib/text-field'
import Popover from 'material-ui/lib/popover/popover'
import RaisedButton from 'material-ui/lib/raised-button'
import injectTapEventPlugin from 'react-tap-event-plugin'

injectTapEventPlugin()

const data = [
  {id: 1, name: "Pete Hunt", text: "This is one comment", createdAt: "2016/01/31 15:00"},
  {id: 2, name: "Jordan Walke", text: "This is another comment", createdAt: "2016/01/31 15:30"},
  {id: 3, name: "Jordan Walke", text: "This is another comment", createdAt: "2016/01/31 15:30"},
  {id: 4, name: "Jordan Walke", text: "This is another comment", createdAt: "2016/01/31 15:30"},
  {id: 5, name: "Jordan Walke", text: "This is another comment", createdAt: "2016/01/31 15:30"},
]

const styles = {
  fixed: {
    position: "fixed",
    bottom: 5,
    right: 5,
    width: "350px",
  },
  message: {
    minWidth: "350px",
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
        style={styles.message}
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
    var messages = data.map(function(msg) {
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
      <div>
        <List>
          {messages}
        </List>
      </div>
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
  render: function() {
    return (
      <List>
        <ListItem disabled={true}>
          <TextField
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
    }
  },

  handleTouchTap: function(event) {
    this.setState({
      open: true,
      anchorEl: event.currentTarget,
    })
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
        <Popover
          open={this.state.open}
          anchorEl={this.state.anchorEl}
          anchorOrigin={{horizontal: 'left', vertical: 'bottom'}}
          targetOrigin={{horizontal: 'left', vertical: 'bottom'}}
          autoCloseWhenOffScreen={false}
          >
          <MenuBar />
          <ListMessages />
          <MessageForm />
        </Popover>
      </div>
    )
  }
})

export default Chat
