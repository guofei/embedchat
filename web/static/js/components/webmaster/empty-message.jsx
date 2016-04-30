import React from 'react';

import Paper from 'material-ui/lib/paper';
import Toolbar from 'material-ui/lib/toolbar/toolbar';
import ToolbarTitle from 'material-ui/lib/toolbar/toolbar-title';

const styles = {
  messages: {
    overflow: 'auto',
    minHeight: '300px',
    maxHeight: '600px',
  },
};

export default function EmptyMessage() {
  return (
    <Paper zDepth={1}>
      <Toolbar>
        <ToolbarTitle text="Message" />
      </Toolbar>
      <div style={styles.messages} />
    </Paper>
  );
}
