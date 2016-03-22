import React from 'react';
import Paper from 'material-ui/lib/paper';
import List from 'material-ui/lib/lists/list';
import ListItem from 'material-ui/lib/lists/list-item';

class AccessLog extends React.Component {
  render() {
    const logs = this.props.logs.map((log) =>
      (
        <ListItem
          key={log.key}
          primaryText={ log.info.createdAt }
          secondaryText={ log.info.href }
        />
      )
    );
    return (
      <Paper zDepth={2}>
        <List subheader="Real Time Log">
          { logs }
        </List>
      </Paper>
    );
  }
}

AccessLog.propTypes = {
  currentUser: React.PropTypes.string.isRequired,
  logs: React.PropTypes.array.isRequired,
};

export default AccessLog;
