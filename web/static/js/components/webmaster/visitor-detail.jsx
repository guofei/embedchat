import React from 'react';
import moment from 'moment';
import parser from 'ua-parser-js';

import Paper from 'material-ui/Paper';
import { Toolbar, ToolbarTitle, ToolbarGroup } from 'material-ui/Toolbar';
import { List } from 'material-ui/List';
import Person from 'material-ui/svg-icons/social/person';
import Timeline from 'material-ui/svg-icons/action/timeline';
import FlatButton from 'material-ui/FlatButton';

import { USERMENU } from '../common/ui-const.js';
import ItemWithDialog from '../common/item-with-dialog';
import Profile from './profile';

const styles = {
  content: {
    overflow: 'auto',
    minHeight: '300px',
    maxHeight: '600px',
  },
  profile: {
    padding: '4px 24px 10px',
    margin: 0,
  },
};

function LogContent({ log }) {
  const ua = parser(log.agent);
  return (
    <div>
      IP Address: {log.ip}<br />
      PageView: {log.single_page_view}<br />
      TotalPageView: {log.total_page_view}<br />
      OS: {`${ua.os.name} ${ua.os.version}`}<br />
      Browser: {`${ua.browser.name} ${ua.browser.version}`}<br />
      Referrer: {log.referrer}<br />
      Language: {log.language}<br />
      screenWidth: {log.screen_width}<br />
      ScreenHeight: {log.screen_height}<br />
    </div>
  );
}

function Logs({ allLogs }) {
  const logs = allLogs.map((log) =>
    (
      <ItemWithDialog
        key={log.id}
        title={log.current_url}
        moment={moment.utc(log.inserted_at).fromNow()}
      >
        <LogContent log={log} />
      </ItemWithDialog>
    )
  );
  return (
    <div style={styles.content} >
      <List>
        { logs }
      </List>
    </div>
  );
}

function menuName(menu) {
  if (menu === USERMENU.TRACKING) {
    return 'Tracking';
  } else if (menu === USERMENU.PROFILE) {
    return 'Profile';
  }
  return 'Unknown';
}

function MenuButton({ menu, handleChangeMenu }) {
  let button = (<div/>);
  if (menu === USERMENU.TRACKING) {
    button = (
      <FlatButton
        primary
        icon={<Person />}
        label={menuName(USERMENU.PROFILE)}
        onTouchTap={handleChangeMenu}
      />
    );
  } else if (menu === USERMENU.PROFILE) {
    button = (
      <FlatButton
        primary
        icon={<Timeline />}
        label={menuName(USERMENU.TRACKING)}
        onTouchTap={handleChangeMenu}
      />
    );
  }
  return button;
}

class UserDetail extends React.Component {
  constructor(props) {
    super(props);

    this.handleChangeMenu = this.handleChangeMenu.bind(this);
  }

  handleChangeMenu() {
    let value = USERMENU.PROFILE;
    if (this.props.selectedMenu === USERMENU.TRACKING) {
      value = USERMENU.PROFILE;
    } else if (this.props.selectedMenu === USERMENU.PROFILE) {
      value = USERMENU.TRACKING;
    }
    this.props.onSelectedMenu(value);
  }

  render() {
    const { selectedMenu, logs, visitor } = this.props;

    let content = (<div style={styles.content} ></div>);
    if (selectedMenu === USERMENU.TRACKING) {
      content = (<Logs allLogs={logs} />);
    } else if (selectedMenu === USERMENU.PROFILE) {
      if (visitor && Object.keys(visitor).length > 0) {
        content = (
          <div style={styles.content}>
            <Profile onUpdateVisitor={this.props.onUpdateVisitor} visitor={visitor} />
          </div>);
      } else {
        content = (<div style={styles.content}></div>);
      }
    }

    return (
      <Paper zDepth={1}>
        <Toolbar>
          <ToolbarTitle text={menuName(selectedMenu)} />
          <ToolbarGroup>
            <MenuButton menu={selectedMenu} handleChangeMenu={this.handleChangeMenu} />
          </ToolbarGroup>
        </Toolbar>
        {content}
      </Paper>
    );
  }
}

UserDetail.propTypes = {
  selectedMenu: React.PropTypes.number.isRequired,
  visitor: React.PropTypes.object,
  logs: React.PropTypes.array.isRequired,
  onSelectedMenu: React.PropTypes.func.isRequired,
  onUpdateVisitor: React.PropTypes.func.isRequired,
};

export default UserDetail;
