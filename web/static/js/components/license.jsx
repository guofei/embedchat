import React from 'react';
import Colors from 'material-ui/lib/styles/colors';

class License extends React.Component {
  render() {
    return (
      <div
        style={{ color: Colors.grey500 }}
      >
        <center>
          Powered by&nbsp;
          <a
            style={{ color: Colors.grey500 }}
            href="https://www.lewini.com"
          >
            lewini
          </a>
        </center>
      </div>
    );
  }
}

export default License;
