import React from 'react';
import AppBar from 'material-ui/lib/app-bar';
import IconButton from 'material-ui/lib/icon-button';
import NavigationClose from 'material-ui/lib/svg-icons/navigation/close';

export class MenuBar extends React.Component {
  constructor(props) {
    super(props);
    this.handleTouchTap = this.handleTouchTap.bind(this);
  }

  handleTouchTap() {
    this.props.onClose();
  }

  render() {
    return (
      <AppBar
        title="Chat"
        iconElementRight={
          <IconButton onTouchTap={this.handleTouchTap}>
            <NavigationClose />
          </IconButton>
        }
      />
    );
  }
}

MenuBar.propTypes = {
  onClose: React.PropTypes.func.isRequired,
};
