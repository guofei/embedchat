import React from 'react';

import TextField from 'material-ui/lib/text-field';
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
    return (
      <div>
        <TextField
          onEnterKeyDown={this.handleEnterKeyDown}
          onChange={this.handleChange}
          fullWidth
          value={this.state.value}
          hintText="Input Message"
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
