import React from 'react';
import TextField from 'material-ui/TextField';
import FlatButton from 'material-ui/FlatButton';

import { shortName } from '../../utils';

const styles = {
  profile: {
    padding: '4px 24px 10px',
    margin: 0,
  },
};

class Profile extends React.Component {
  constructor(props) {
    super(props);

    const { user } = this.props;
    const userName = user.name ? user.name : shortName(user.uid);
    const userEmail = user.email ? user.email : '';
    const userNote = user.note ? user.note : '';

    this.state = {
      name: userName,
      email: userEmail,
      note: userNote,
    };

    this.handleNameChange = this.handleNameChange.bind(this);
    this.handleEmailChange = this.handleEmailChange.bind(this);
    this.handleNoteChange = this.handleNoteChange.bind(this);
    this.handleTouchTap = this.handleTouchTap.bind(this);
  }

  componentWillReceiveProps(nextProps) {
    const user = nextProps.user;
    const userName = user.name ? user.name : shortName(user.uid);
    const userEmail = user.email ? user.email : '';
    const userNote = user.note ? user.note : '';

    this.setState({
      name: userName,
      email: userEmail,
      note: userNote,
    });
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

  handleTouchTap() {
    console.log(this.state);
  }

  render() {
    const { user } = this.props;

    let profile = (<div></div>);
    if (user && Object.keys(user).length > 0) {
      profile = (
        <div>
          <div style={styles.profile}>
            <TextField
              fullWidth
              value={this.state.name}
              onChange={this.handleNameChange}
              hintText="Name"
            />
            <TextField
              fullWidth
              value={this.state.email}
              onChange={this.handleEmailChange}
              hintText="Email"
            />
            <TextField
              fullWidth
              multiLine
              hintText="Note"
              value={this.state.note}
              onChange={this.handleNoteChange}
              floatingLabelText="Note"
            />
          </div>
          <center>
            <FlatButton label="Update" onTouchTap={this.handleTouchTap} primary />
          </center>
        </div>
      );
    }
    return profile;
  }
}

Profile.propTypes = {
  user: React.PropTypes.shape({
    id: React.PropTypes.number.isRequired,
    uid: React.PropTypes.string.isRequired,
    name: React.PropTypes.string,
    email: React.PropTypes.string,
    note: React.PropTypes.string,
  }),
};

export default Profile;
