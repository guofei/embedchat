import React from 'react';
import moment from 'moment';
import { translate } from 'react-i18next';
import Linkify from 'react-linkify';

import { ListItem } from 'material-ui/List';
// import Avatar from 'material-ui/lib/avatar';
import Popover from 'material-ui/Popover';
import { Card, CardText } from 'material-ui/Card';
import EmailReqeust from './email-request';

const styles = {
  pullRight: {
    float: 'right',
    color: 'gray',
    fontSize: 'small',
  },
};

const emailRequestType = 'email_request';

function textLines(text) {
  return text.length > 15 ? 2 : 1;
}

function Message({ children, createdAt, shortUserName, handleTouchTap }) {
  return (
    <ListItem
      secondaryTextLines={textLines(children)}
      primaryText={
        <div>
          {shortUserName}
          <span style={styles.pullRight}>
            {moment.utc(createdAt).fromNow()}
          </span>
        </div>
      }
      onTouchTap={handleTouchTap}
      secondaryText={
        <div>
          <Linkify properties={{ target: '_blank', rel: 'nofollow' }}>
            {children}
          </Linkify>
        </div>
      }
    />
  );
}

Message.propTypes = {
  children: React.PropTypes.string.isRequired,
  createdAt: React.PropTypes.string.isRequired,
  shortUserName: React.PropTypes.string.isRequired,
  handleTouchTap: React.PropTypes.func.isRequired,
};

function PopoverContent({ text }) {
  return (
    <div>
      <Card>
        <CardText>
          <Linkify properties={{ target: '_blank', rel: 'nofollow' }}>
            {text}
          </Linkify>
        </CardText>
      </Card>
    </div>
  );
}

PopoverContent.propTypes = {
  text: React.PropTypes.string.isRequired,
};

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
      return this.props.t('you');
    }
    if (this.props.fromName !== this.props.from) {
      return this.props.fromName;
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
    let message = (
      <div>
        <Message
          createdAt={this.props.createdAt}
          shortUserName={this.shortName()}
          handleTouchTap={this.handleTouchTap}
        >
          {this.props.children}
        </Message>
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
    if (this.props.type === emailRequestType) {
      message = (
        <EmailReqeust
          onInputEmail={this.props.sendEmail}
          currentUserEmail={this.props.currentUserEmail}
        />
      );
    }
    return (
      message
    );
  }
}

ListItemMessage.propTypes = {
  t: React.PropTypes.func.isRequired,
  type: React.PropTypes.string.isRequired,
  currentUser: React.PropTypes.string.isRequired,
  from: React.PropTypes.string.isRequired,
  fromName: React.PropTypes.string.isRequired,
  createdAt: React.PropTypes.string.isRequired,
  children: React.PropTypes.string.isRequired,
  sendEmail: React.PropTypes.func.isRequired,
  currentUserEmail: React.PropTypes.string,
};

export default translate(['translation'])(ListItemMessage);
