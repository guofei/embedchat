import React from 'react';
import Colors from 'material-ui/lib/styles/colors';

class License extends React.Component {
  render() {
    return (
      <div
        style={{ color: Colors.grey500 }}
      >
        <center>
          We run on&nbsp;
          <a
            style={{ color: Colors.grey500 }}
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
