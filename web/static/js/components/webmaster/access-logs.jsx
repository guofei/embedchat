import React from 'react';
import ReactDOM from 'react-dom';
import moment from 'moment';

import Paper from 'material-ui/Paper';
import { Toolbar, ToolbarTitle } from 'material-ui/Toolbar';
import { List } from 'material-ui/List';

import ItemWithDialog from '../item-with-dialog';


moment.locale(window.navigator.userLanguage || window.navigator.language);

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
      User Agent: {log.userAgent}<br/>
      Referrer: {log.referrer}<br/>
      Language: {log.language}<br/>
      screenWidth: {log.screenWidth}<br/>
      ScreenHeight: {log.screenHeight}<br/>
      PageView: {log.totalPageView}<br/>
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
    const logs = this.props.logs.map((log, index) =>
      (
        <ItemWithDialog
          key={index}
          title={log.href}
          moment={moment.utc(log.inserted_at).fromNow()}
        >
          <LogContent log={log} />
        </ItemWithDialog>
      )
    );
    return (
      <Paper zDepth={1}>
        <Toolbar>
          <ToolbarTitle text="AccessLog" />
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
