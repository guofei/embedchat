import React from 'react';
import moment from 'moment';
import { translate } from 'react-i18next';
import ReactAutolink from 'react-autolink';

import { ListItem } from 'material-ui/List';
// import Avatar from 'material-ui/lib/avatar';
import Popover from 'material-ui/Popover';
import { Card, CardText } from 'material-ui/Card';
import EmailReqeust from './email-request';

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
          {ReactAutolink.autolink(children, { target: '_blank', rel: 'nofollow' })}
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
          {ReactAutolink.autolink(text, { target: '_blank', rel: 'nofollow' })}
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
    if (this.props.type === 'email_request') {
      message = (
        <EmailReqeust/>
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
  children: React.PropTypes.string,
};

export default translate(['translation'])(ListItemMessage);
