import React from 'react';

import Paper from 'material-ui/Paper';
import { Toolbar, ToolbarTitle } from 'material-ui/Toolbar';

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
