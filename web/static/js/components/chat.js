import React from "react"

import AppBar from 'material-ui/lib/app-bar'

import List from 'material-ui/lib/lists/list'
import ListItem from 'material-ui/lib/lists/list-item'
import Divider from 'material-ui/lib/divider'
import Avatar from 'material-ui/lib/avatar'
import TextField from 'material-ui/lib/text-field'

const data = [
  {id: 1, name: "Pete Hunt", text: "This is one comment", createdAt: "2016/01/31 15:00"},
  {id: 2, name: "Jordan Walke", text: "This is *another* comment", createdAt: "2016/01/31 15:30"}
]

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
        iconClassNameRight="muidocs-icon-navigation-expand-more"
        />
    )
  }
})

const MessageForm = React.createClass({
  render: function() {
    return (
      <div>
        <TextField
          hintText="Input Message"
          />
      </div>
    )
  }
})

const Chat = React.createClass({
  render: function() {
    return (
      <div>
        <MenuBar />
        <ListMessages />
        <MessageForm />
      </div>
    )
  }
})

export default Chat
