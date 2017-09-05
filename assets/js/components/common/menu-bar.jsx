import React from 'react';
import { translate } from 'react-i18next';

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
    const { t } = this.props;
    return (
      <AppBar
        title={t('chat')}
        onLeftIconButtonTouchTap={this.props.onTouchMenu}
        titleStyle={{ fontSize: '18px', textAlign: 'left' }}
        iconElementRight={
          <IconButton onTouchStart={this.props.onClose}>
            <NavigationClose />
          </IconButton>
        }
        onRightIconButtonTouchTap={this.props.onClose}
      />
    );
  }
}

MenuBar.childContextTypes = {
  muiTheme: React.PropTypes.object,
};

MenuBar.propTypes = {
  t: React.PropTypes.func.isRequired,
  onClose: React.PropTypes.func.isRequired,
  onTouchMenu: React.PropTypes.func.isRequired,
};

export default translate(['translation'])(MenuBar);
