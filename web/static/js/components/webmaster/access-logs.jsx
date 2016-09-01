import React from 'react';
import moment from 'moment';

import Paper from 'material-ui/Paper';
import { Toolbar, ToolbarTitle, ToolbarGroup } from 'material-ui/Toolbar';
import { List } from 'material-ui/List';
import MenuItem from 'material-ui/MenuItem';
import IconButton from 'material-ui/IconButton';
import MoreVertIcon from 'material-ui/svg-icons/navigation/more-vert';
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

class AccessLogs extends React.Component {
  constructor(props) {
    super(props);

    this.handleMenuChange = this.handleMenuChange.bind(this);
  }

  handleMenuChange(event, value) {
    this.props.onSelectedMenu(value);
  }

  render() {
    let content = (
      <div style={styles.content} ></div>
    );
    if (this.props.selectedMenu === 'log') {
      const logs = this.props.logs.map((log) =>
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
      content = (
        <div style={styles.content} >
          <List>
            { logs }
          </List>
        </div>
      );
    } else if (this.props.selectedMenu === 'profile') {
      content = (
        <div style={styles.content} >
        </div>
      );
    }
    return (
      <Paper zDepth={1}>
        <Toolbar>
          <ToolbarTitle text="Detail" />
            <ToolbarGroup>
              <IconMenu
                iconButtonElement={<IconButton><MoreVertIcon /></IconButton>}
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

AccessLogs.propTypes = {
  selectedMenu: React.PropTypes.string.isRequired,
  currentUser: React.PropTypes.string.isRequired,
  logs: React.PropTypes.array.isRequired,
  onSelectedMenu: React.PropTypes.func.isRequired,
};

export default AccessLogs;
