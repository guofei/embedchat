import React from 'react';
import { translate } from 'react-i18next';
import TextField from 'material-ui/TextField';
// import RaisedButton from 'material-ui/RaisedButton';
import { lightBlue500 } from 'material-ui/styles/colors';

const styles = {
  floatingLabelStyle: {
    color: lightBlue500,
  },
};

class EmailReqeust extends React.Component {
  render() {
    const { t } = this.props;
    return (
      <div>
        <center>
          <TextField
            hintText="email@domain.com"
            floatingLabelText={t('getEmail')}
            floatingLabelStyle={styles.floatingLabelStyle}
            floatingLabelFixed
          />
        </center>
      </div>
    );
  }
}

EmailReqeust.propTypes = {
  t: React.PropTypes.func.isRequired,
};

export default translate(['translation'])(EmailReqeust);
