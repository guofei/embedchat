import React from 'react';
import AppBar from 'material-ui/lib/app-bar';
import IconButton from 'material-ui/lib/icon-button';
import NavigationClose from 'material-ui/lib/svg-icons/navigation/close';
import LightRawTheme from 'material-ui/lib/styles/raw-themes/light-raw-theme';
import getMuiTheme from 'material-ui/lib/styles/getMuiTheme';

class MenuBar extends React.Component {
  constructor(props) {
    super(props);
    this.handleTouchTap = this.handleTouchTap.bind(this);
  }

  getChildContext() {
    const appCustom = getMuiTheme(LightRawTheme);
    appCustom.appBar.height = 40;
    return {
      muiTheme: appCustom,
    };
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

MenuBar.childContextTypes = {
  muiTheme: React.PropTypes.object,
};

MenuBar.propTypes = {
  onClose: React.PropTypes.func.isRequired,
};

export default MenuBar;
