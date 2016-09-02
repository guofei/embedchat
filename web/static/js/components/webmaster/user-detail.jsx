import React from 'react';
import moment from 'moment';

import Paper from 'material-ui/Paper';
import { Toolbar, ToolbarTitle, ToolbarGroup } from 'material-ui/Toolbar';
import { List } from 'material-ui/List';
import MenuItem from 'material-ui/MenuItem';
import IconButton from 'material-ui/IconButton';
import NavigationExpandMoreIcon from 'material-ui/svg-icons/navigation/expand-more';
import IconMenu from 'material-ui/IconMenu';
import Person from 'material-ui/svg-icons/social/person';
import Timeline from 'material-ui/svg-icons/action/Timeline';


import ItemWithDialog from '../common/item-with-dialog';

const styles = {
  content: {
    overflow: 'auto',
    minHeight: '300px',
    maxHeight: '600px',
  },
};

function LogContent({ log }) {
  return (
    <div>
      User Agent: {log.agent}<br/>
      Referrer: {log.referrer}<br/>
      Language: {log.language}<br/>
      screenWidth: {log.screen_width}<br/>
      ScreenHeight: {log.screen_height}<br/>
      PageView: {log.total_page_view}<br/>
      Time: {moment.utc(log.inserted_at).fromNow()}
    </div>
  );
}

function Profile({}) {
  return (
    <div style={styles.content} >
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
  let title = 'Detail';
  if (menu === 'log') {
    title = 'Log';
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
    const { selectedMenu, logs } = this.props;

    let content = (<div style={styles.content} ></div>);
    if (selectedMenu === 'log') {
      content = (<Logs allLogs={logs} />);
    } else if (selectedMenu === 'profile') {
      content = (<Profile/>);
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
                <MenuItem value="log" primaryText="Log" leftIcon={<Timeline />} />
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
  currentUser: React.PropTypes.string.isRequired,
  logs: React.PropTypes.array.isRequired,
  onSelectedMenu: React.PropTypes.func.isRequired,
};

export default UserDetail;
