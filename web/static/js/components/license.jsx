import React from 'react';
import Colors from 'material-ui/lib/styles/colors';

export class License extends React.Component {
  render() {
    return (
      <div
        style={{ color: Colors.grey500 }}
      >
        <center>
          Powered by&nbsp;
          <a
            style={{ color: Colors.grey500 }}
            href="#"
          >
            XXX
          </a>
        </center>
      </div>
    );
  }
}
