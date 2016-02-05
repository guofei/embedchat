import React from 'react';
import TextField from 'material-ui/lib/text-field';
import License from './license';

class MessageForm extends React.Component {
  constructor(props) {
    super(props);
    this.handleEnterKyeDown = this.handleEnterKyeDown.bind(this);
  }

  handleEnterKyeDown(event) {
    const text = event.target.value;
    this.props.onInputMessage(text);
  }

  render() {
    return (
      <div>
        <TextField
          onEnterKeyDown={this.handleEnterKyeDown}
          fullWidth
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
