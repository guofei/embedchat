import React from 'react';

import Dialog from 'material-ui/Dialog';
import CommunicationEmail from 'material-ui/svg-icons/communication/email';
import FlatButton from 'material-ui/FlatButton';
import TextField from 'material-ui/TextField';

class Mailer extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      open: false,
    };

    this.handleEmailMessages = this.handleEmailMessages.bind(this);
    this.handleOpen = this.handleOpen.bind(this);
    this.handleClose = this.handleClose.bind(this);
  }

  handleOpen() {
    this.setState({ open: true });
  }

  handleClose() {
    this.setState({ open: false });
  }

  handleEmailMessages() {
    this.setState({ open: false });
    this.props.onMailMessagesToUser(this.props.visitor);
  }

  render() {
    const { visitor } = this.props;
    const actions = [
      <FlatButton
        label="Cancel"
        primary
        onTouchTap={this.handleClose}
      />,
      <FlatButton
        label="Send"
        primary
        keyboardFocused
        onTouchTap={this.handleEmailMessages}
      />,
    ];
    if (visitor.email) {
      return (
        <div>
          <FlatButton
            label="Send Email"
            onTouchTap={this.handleOpen}
            primary
            icon={<CommunicationEmail />}
          />
          <Dialog
            title="Send Email"
            actions={actions}
            modal={false}
            open={this.state.open}
            onRequestClose={this.handleClose}
          >
            <TextField hintText="Title" /><br /><br />
            Send current <TextField hintText="10" /> messages to user&apos;s email.
          </Dialog>
        </div>
      );
    }
    return (<div />);
  }
}

Mailer.propTypes = {
  visitor: React.PropTypes.shape({
    id: React.PropTypes.number.isRequired,
    uid: React.PropTypes.string.isRequired,
    name: React.PropTypes.string,
    email: React.PropTypes.string,
  }).isRequired,
  onMailMessagesToUser: React.PropTypes.func.isRequired,
};

export default Mailer;
