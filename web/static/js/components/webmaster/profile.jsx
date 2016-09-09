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

    const { visitor } = this.props;
    const userName = visitor.name ? visitor.name : shortName(visitor.uid);
    const userEmail = visitor.email ? visitor.email : '';
    const userNote = visitor.note ? visitor.note : '';

    this.state = {
      name: userName,
      email: userEmail,
      note: userNote,
    };

    this.handleNameChange = this.handleNameChange.bind(this);
    this.handleEmailChange = this.handleEmailChange.bind(this);
    this.handleNoteChange = this.handleNoteChange.bind(this);
    this.handleUpdateVisitor = this.handleUpdateVisitor.bind(this);
  }

  componentWillReceiveProps(nextProps) {
    const visitor = nextProps.visitor;
    const userName = visitor.name ? visitor.name : shortName(visitor.uid);
    const userEmail = visitor.email ? visitor.email : '';
    const userNote = visitor.note ? visitor.note : '';

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

  handleUpdateVisitor() {
    const v = Object.assign({}, this.state, { uid: this.props.visitor.uid });
    this.props.onUpdateVisitor(v);
  }

  render() {
    const { visitor } = this.props;

    let profile = (<div></div>);
    if (visitor && Object.keys(visitor).length > 0) {
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
            <FlatButton label="Update" onTouchTap={this.handleUpdateVisitor} primary />
          </center>
        </div>
      );
    }
    return profile;
  }
}

Profile.propTypes = {
  visitor: React.PropTypes.shape({
    id: React.PropTypes.number.isRequired,
    uid: React.PropTypes.string.isRequired,
    name: React.PropTypes.string,
    email: React.PropTypes.string,
    note: React.PropTypes.string,
  }),
  onUpdateVisitor: React.PropTypes.func.isRequired,
};

export default Profile;
