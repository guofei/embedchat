import React from 'react';
import TextField from 'material-ui/TextField';
import FlatButton from 'material-ui/FlatButton';


const styles = {
  profile: {
    padding: '4px 24px 10px',
    margin: 0,
  },
};

class Profile extends React.Component {
  constructor(props) {
    super(props);

    const user = this.props.user;
    const userName = user && user.name ? user.name : '';
    const userEmail = user && user.email ? user.email : '';
    const userNote = user && user.note ? user.note : '';

    this.state = {
      name: userName,
      email: userEmail,
      note: userNote,
    };

    this.handleNameChange = this.handleNameChange.bind(this);
    this.handleEmailChange = this.handleEmailChange.bind(this);
    this.handleNoteChange = this.handleNoteChange.bind(this);
  }

  handleNameChange(event) {
    this.setState({
      name: event.target.value,
    });
  }

  handleEmailChange(event) {
    this.setState({
      email: event.target.value,
    });
  }

  handleNoteChange(event) {
    this.setState({
      note: event.target.value,
    });
  }

  render() {
    const user = this.props.user;
    const userName = user && user.name ? user.name : '';
    const userEmail = user && user.email ? user.email : '';
    const userNote = user && user.note ? user.note : '';

    return (
      <div>
        <div style={styles.profile}>
          <TextField
            fullWidth
            value={userName}
            onChange={this.handleNameChange}
            hintText="Name"
          />
          <TextField
            fullWidth
            value={userEmail}
            onChange={this.handleEmailChange}
            hintText="Email"
          />
          <TextField
            fullWidth
            multiLine
            hintText="Note"
            value={userNote}
            onChange={this.handleNoteChange}
            floatingLabelText="Note"
          />
        </div>
        <center>
          <FlatButton label="Update" primary />
        </center>
      </div>
    );
  }
}

Profile.propTypes = {
  user: React.PropTypes.object,
};

export default Profile;
