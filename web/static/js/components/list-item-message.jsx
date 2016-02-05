import React from 'react';

import ListItem from 'material-ui/lib/lists/list-item';
import Avatar from 'material-ui/lib/avatar';

class ListItemMessage extends React.Component {
  avatar() {
    if (this.props.name.length > 0) {
      return this.props.name[0].toUpperCase();
    }
    return 'A';
  }

  render() {
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
    );
  }
}

ListItemMessage.propTypes = {
  name: React.PropTypes.string.isRequired,
  createdAt: React.PropTypes.string.isRequired,
  children: React.PropTypes.string,
};

export default ListItemMessage;
