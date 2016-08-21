import React from 'react';
import { grey500 } from 'material-ui/styles/colors';

const styles = {
  license: {
    color: grey500,
    fontSize: '12px',
  },
};

class License extends React.Component {
  render() {
    return (
      <div
        style={styles.license}
      >
        <center>
          We run on&nbsp;
          <a
            style={{ color: grey500 }}
            href="http://www.lewini.com"
            target="_blank"
          >
            Lewini
          </a>
        </center>
      </div>
    );
  }
}

export default License;
