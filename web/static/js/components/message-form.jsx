import React from 'react';
import { translate } from 'react-i18next';

import TextField from 'material-ui/TextField';
import License from './license';

class MessageForm extends React.Component {
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
    this.props.onInputMessage(text);
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
    return (
      <div>
        <TextField
          onKeyDown={this.handleEnterKeyDown}
          onChange={this.handleChange}
          fullWidth
          value={this.state.value}
          hintText={t('input')}
        />
        <License />
      </div>
    );
  }
}

MessageForm.propTypes = {
  t: React.PropTypes.func.isRequired,
  onInputMessage: React.PropTypes.func.isRequired,
};

export default translate(['translation'])(MessageForm);
