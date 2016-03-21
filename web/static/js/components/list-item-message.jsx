import React from 'react';

import ListItem from 'material-ui/lib/lists/list-item';
import Avatar from 'material-ui/lib/avatar';

class ListItemMessage extends React.Component {
  avatar() {
    return this.shortName()[0].toUpperCase();
  }

  shortName() {
    if (this.props.currentUser === this.props.from) {
      return 'You';
    }
    if (this.props.from.length > 0) {
      return this.props.from.substring(0, 7);
    }
    return 'A';
  }

  render() {
    return (
      <ListItem
        secondaryTextLines={2}
        leftAvatar={<Avatar>{this.avatar()}</Avatar>}
        primaryText={this.shortName()}
        secondaryText={
          <div>
            {this.props.createdAt}<br />
            {this.props.children}
          </div>
        }
      />
    );
  }
}

ListItemMessage.propTypes = {
  currentUser: React.PropTypes.string.isRequired,
  from: React.PropTypes.string.isRequired,
  createdAt: React.PropTypes.string.isRequired,
  children: React.PropTypes.string,
};

export default ListItemMessage;
