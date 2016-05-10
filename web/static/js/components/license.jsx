import React from 'react';
import { grey500 } from 'material-ui/styles/colors';

class License extends React.Component {
  render() {
    return (
      <div
        style={{ color: grey500 }}
      >
        <center>
          We run on&nbsp;
          <a
            style={{ color: grey500 }}
            href="https://www.lewini.com"
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
