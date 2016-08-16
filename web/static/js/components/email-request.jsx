import React from 'react';
import { translate } from 'react-i18next';
import TextField from 'material-ui/TextField';
import Chip from 'material-ui/Chip';
// import RaisedButton from 'material-ui/RaisedButton';
import { lightBlue500 } from 'material-ui/styles/colors';

const styles = {
  floatingLabelStyle: {
    color: lightBlue500,
  },
  chip: {
    margin: 4,
  },
};

class EmailReqeust extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      value: '',
    };

    this.handleEnterKeyDown = this.handleEnterKeyDown.bind(this);
    this.handleChange = this.handleChange.bind(this);
  }

  handleEnterKeyDown(event) {
    const enterKeyCode = 13;
    if (event.keyCode !== enterKeyCode) {
      return;
    }
    const text = event.target.value;
    this.props.onInputEmail(text);
    this.setState({
      value: '',
    });
  }

  handleChange(event) {
    this.setState({
      value: event.target.value,
    });
  }

  render() {
    const { t } = this.props;
    let text = (
      <TextField
        hintText="email@domain.com"
        floatingLabelText={t('getEmail')}
        floatingLabelStyle={styles.floatingLabelStyle}
        floatingLabelFixed
        onKeyDown={this.handleEnterKeyDown}
        onChange={this.handleChange}
        value={this.state.value}
      />
    );
    if (this.props.currentUserEmail) {
      text = (
        <Chip style={styles.chip} backgroundColor={lightBlue500} >
          You will be notified at {this.props.currentUserEmail}
        </Chip>
      );
    }
    return (
      <div>
        <center>
          {text}
        </center>
      </div>
    );
  }
}

EmailReqeust.propTypes = {
  t: React.PropTypes.func.isRequired,
  currentUserEmail: React.PropTypes.string.isRequired,
  onInputEmail: React.PropTypes.func.isRequired,
};

export default translate(['translation'])(EmailReqeust);
