import React from 'react';

import AppBar from 'material-ui/AppBar';
import IconButton from 'material-ui/IconButton';
import NavigationClose from 'material-ui/svg-icons/navigation/close';
import LightRawTheme from 'material-ui/styles/baseThemes/lightBaseTheme';
import getMuiTheme from 'material-ui/styles/getMuiTheme';

class MenuBar extends React.Component {
  getChildContext() {
    const appCustom = getMuiTheme(LightRawTheme);
    appCustom.appBar.height = 40;
    return {
      muiTheme: appCustom,
    };
  }

  render() {
    // TODO use a i18n library
    let chat = 'Chat';
    if ((window.navigator.userLanguage || window.navigator.language) === 'ja') {
      chat = 'チャット';
    }
    return (
      <AppBar
        title={chat}
        onLeftIconButtonTouchTap={this.props.onTouchMenu}
        titleStyle={{ fontSize: 18 }}
        iconElementRight={
          <IconButton onTouchTap={this.props.onClose}>
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
  onTouchMenu: React.PropTypes.func.isRequired,
};

export default MenuBar;
