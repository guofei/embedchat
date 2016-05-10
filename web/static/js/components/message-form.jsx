import React from 'react';

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
    // TODO use a i18n library
    let input = 'Input Message';
    if ((window.navigator.userLanguage || window.navigator.language) === 'ja') {
      input = 'メッセージを入力してください';
    }
    return (
      <div>
        <TextField
          onKeyDown={this.handleEnterKeyDown}
          onChange={this.handleChange}
          fullWidth
          value={this.state.value}
          hintText={input}
        />
        <License />
      </div>
    );
  }
}

MessageForm.propTypes = {
  onInputMessage: React.PropTypes.func.isRequired,
};

export default MessageForm;
