import React from 'react';
import moment from 'moment';

import ListItem from 'material-ui/lib/lists/list-item';
// import Avatar from 'material-ui/lib/avatar';
import Popover from 'material-ui/lib/popover/popover';
import Card from 'material-ui/lib/card/card';
import CardText from 'material-ui/lib/card/card-text';

moment.locale(window.navigator.userLanguage || window.navigator.language);

const styles = {
  pullRight: {
    float: 'right',
    color: 'gray',
    fontSize: 'small',
  },
};

function Message({ children, createdAt, handleTouchTap, shortName }) {
  return (
    <ListItem
      secondaryTextLines={children.length > 15 ? 2 : 1}
      // leftAvatar={<Avatar>{this.avatar()}</Avatar>}
      primaryText={
        <div>
          {shortName}
          <span style={styles.pullRight}>
            {moment.utc(createdAt).fromNow()}
          </span>
        </div>
      }
      onTouchTap={handleTouchTap}
      secondaryText={
        <div>
          {children}
        </div>
      }
    />
  );
}

function PopoverContent({ text }) {
  return (
    <div>
      <Card>
        <CardText>
          {text}
        </CardText>
      </Card>
    </div>
  );
}

class ListItemMessage extends React.Component {
  constructor(props) {
    super(props);
    this.handleTouchTap = this.handleTouchTap.bind(this);
    this.handleClose = this.handleClose.bind(this);
    this.state = {
      open: false,
    };
  }

  avatar() {
    return this.shortName()[0].toUpperCase();
  }

  shortName() {
    if (this.props.currentUser === this.props.from) {
      return 'You';
    }
    if (this.props.from_name !== this.props.from) {
      return this.props.from_name;
    }
    if (this.props.from.length > 0) {
      return this.props.from.substring(0, 7);
    }
    return 'unknown';
  }

  handleTouchTap(event) {
    this.setState({
      open: !this.state.open,
      anchorEl: event.currentTarget,
    });
  }

  handleClose() {
    this.setState({
      open: false,
    });
  }

  render() {
    return (
      <div>
        <Message
          children={this.props.children}
          createdAt={this.props.createdAt}
          handleTouchTap={this.handleTouchTap}
          shortName={this.shortName()}
        />
        <Popover
          open={this.state.open}
          anchorEl={this.state.anchorEl}
          anchorOrigin={{ horizontal: 'left', vertical: 'top' }}
          targetOrigin={{ horizontal: 'right', vertical: 'top' }}
          onRequestClose={this.handleClose}
        >
          <PopoverContent text={this.props.children} />
        </Popover>
      </div>
    );
  }
}

ListItemMessage.propTypes = {
  currentUser: React.PropTypes.string.isRequired,
  from: React.PropTypes.string.isRequired,
  from_name: React.PropTypes.string.isRequired,
  createdAt: React.PropTypes.string.isRequired,
  children: React.PropTypes.string,
};

export default ListItemMessage;
