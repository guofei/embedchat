import React from 'react';
import ReactDOM from 'react-dom';

import Paper from 'material-ui/lib/paper';
import Toolbar from 'material-ui/lib/toolbar/toolbar';
import ToolbarTitle from 'material-ui/lib/toolbar/toolbar-title';
import List from 'material-ui/lib/lists/list';
import ListItem from 'material-ui/lib/lists/list-item';

const styles = {
  logs: {
    overflow: 'auto',
    minHeight: '300px',
    maxHeight: '600px',
  },
};

class AccessLog extends React.Component {
  componentDidUpdate() {
    const node = ReactDOM.findDOMNode(this.refs.logs);
    node.scrollTop = node.scrollHeight;
  }

  render() {
    const logs = this.props.logs.map((log, index) =>
      (
        <ListItem
          key={index + 1}
          primaryText={ log.info.createdAt }
          secondaryText={ log.info.href }
        />
      )
    );
    return (
      <Paper zDepth={2}>
        <Toolbar>
          <ToolbarTitle text="Real Time Log" />
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

AccessLog.propTypes = {
  currentUser: React.PropTypes.string.isRequired,
  logs: React.PropTypes.array.isRequired,
};

export default AccessLog;
