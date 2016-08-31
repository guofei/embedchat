import React from 'react';
import ReactDOM from 'react-dom';
import moment from 'moment';

import Paper from 'material-ui/Paper';
import { Toolbar, ToolbarTitle, ToolbarGroup } from 'material-ui/Toolbar';
import { List } from 'material-ui/List';
import DropDownMenu from 'material-ui/DropDownMenu';
import MenuItem from 'material-ui/MenuItem';
import IconButton from 'material-ui/IconButton';
import FlatButton from 'material-ui/FlatButton';
import MoreVertIcon from 'material-ui/svg-icons/navigation/more-vert';
import IconMenu from 'material-ui/IconMenu';
import Person from 'material-ui/svg-icons/social/person';
import Timeline from 'material-ui/svg-icons/action/Timeline';


import ItemWithDialog from '../common/item-with-dialog';

const styles = {
  logs: {
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
  componentDidMount() {
    this.scrollLogs();
  }

  componentDidUpdate() {
    this.scrollLogs();
  }

  scrollLogs() {
    const node = ReactDOM.findDOMNode(this.refs.logs);
    if (node) {
      node.scrollTop = node.scrollHeight;
    }
  }

  render() {
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
    return (
      <Paper zDepth={1}>
        <Toolbar>
          <ToolbarTitle text="Detail" />
            <ToolbarGroup>
              <IconMenu
                iconButtonElement={<IconButton><MoreVertIcon /></IconButton>}
                anchorOrigin={{ horizontal: 'left', vertical: 'bottom' }}
                targetOrigin={{ horizontal: 'left', vertical: 'top' }}
              >
                <MenuItem primaryText="Log" leftIcon={<Timeline />} />
                <MenuItem primaryText="Visitor" leftIcon={<Person />} />
              </IconMenu>
            </ToolbarGroup>
        </Toolbar>
        <div
          ref="logs"
          style={styles.logs}
        >
          <List>
            { logs }
          </List>
        </div>
      </Paper>
    );
  }
}

AccessLogs.propTypes = {
  currentUser: React.PropTypes.string.isRequired,
  logs: React.PropTypes.array.isRequired,
};

export default AccessLogs;
