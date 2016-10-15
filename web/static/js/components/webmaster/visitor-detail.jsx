import React from 'react';
import moment from 'moment';
import parser from 'ua-parser-js';

import Paper from 'material-ui/Paper';
import { Toolbar, ToolbarTitle, ToolbarGroup } from 'material-ui/Toolbar';
import { List } from 'material-ui/List';
import MenuItem from 'material-ui/MenuItem';
import IconButton from 'material-ui/IconButton';
import NavigationExpandMoreIcon from 'material-ui/svg-icons/navigation/expand-more';
import IconMenu from 'material-ui/IconMenu';
import Person from 'material-ui/svg-icons/social/person';
import Timeline from 'material-ui/svg-icons/action/timeline';


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
      PageView: {log.single_page_view}<br/>
      TotalPageView: {log.total_page_view}<br/>
      OS: {`${ua.os.name} ${ua.os.version}`}<br/>
      Browser: {`${ua.browser.name} ${ua.browser.version}`}<br/>
      Referrer: {log.referrer}<br/>
      Language: {log.language}<br/>
      screenWidth: {log.screen_width}<br/>
      ScreenHeight: {log.screen_height}<br/>
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
  let title = 'Tracking';
  if (menu === 'tracking') {
    title = 'Tracking';
  } else if (menu === 'profile') {
    title = 'Profile';
  }
  return title;
}

class UserDetail extends React.Component {
  constructor(props) {
    super(props);

    this.handleMenuChange = this.handleMenuChange.bind(this);
  }

  handleMenuChange(event, value) {
    this.props.onSelectedMenu(value);
  }

  render() {
    const { selectedMenu, logs, visitor } = this.props;

    let content = (<div style={styles.content} ></div>);
    if (selectedMenu === 'tracking') {
      content = (<Logs allLogs={logs} />);
    } else if (selectedMenu === 'profile') {
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
          <ToolbarTitle text={ menuName(selectedMenu) } />
            <ToolbarGroup>
              <IconMenu
                iconButtonElement={<IconButton><NavigationExpandMoreIcon /></IconButton>}
                onChange={this.handleMenuChange}
                anchorOrigin={{ horizontal: 'left', vertical: 'bottom' }}
                targetOrigin={{ horizontal: 'left', vertical: 'top' }}
              >
                <MenuItem value="tracking" primaryText="Tracking" leftIcon={<Timeline />} />
                <MenuItem value="profile" primaryText="Profile" leftIcon={<Person />} />
              </IconMenu>
            </ToolbarGroup>
        </Toolbar>
        {content}
      </Paper>
    );
  }
}

UserDetail.propTypes = {
  selectedMenu: React.PropTypes.string.isRequired,
  visitor: React.PropTypes.object,
  logs: React.PropTypes.array.isRequired,
  onSelectedMenu: React.PropTypes.func.isRequired,
  onUpdateVisitor: React.PropTypes.func.isRequired,
};

export default UserDetail;
