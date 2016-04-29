import React from 'react';
import ListItem from 'material-ui/lib/lists/list-item';
import Dialog from 'material-ui/lib/dialog';
import FlatButton from 'material-ui/lib/flat-button';


const styles = {
  pullRight: {
    float: 'right',
    color: 'gray',
    fontSize: 'small',
  },
};

function Item({ title, moment, handleTouchTap, content }) {
  return (
    <ListItem
      secondaryTextLines={2}
      primaryText={
        <div style={{ fontSize: 'small' }}>
          {title}
          <div style={styles.pullRight}>
            {moment}
          </div>
        </div>
      }
      onTouchTap={handleTouchTap}
      secondaryText={
        <div>
          <div style={{ fontSize: 'small' }}>{content}</div>
        </div>
      }
    />
  );
}

class ItemWithDialog extends React.Component {
  constructor(props) {
    super(props);
    this.handleTouchTap = this.handleTouchTap.bind(this);
    this.handleClose = this.handleClose.bind(this);
    this.state = {
      open: false,
    };
  }

  handleTouchTap() {
    this.setState({
      open: !this.state.open,
    });
  }

  handleClose() {
    this.setState({
      open: false,
    });
  }

  render() {
    const actions = [
      <FlatButton
        label="OK"
        onTouchTap={this.handleClose}
      />,
    ];

    return (
      <div>
        <Item
          title={this.props.title}
          moment={this.props.moment}
          handleTouchTap={this.handleTouchTap}
          content={this.props.children}
        />
        <Dialog
          title={this.props.title}
          actions={actions}
          modal={false}
          open={this.state.open}
          onRequestClose={this.handleClose}
        >
          {this.props.children}
        </Dialog>
      </div>
    );
  }
}

ItemWithDialog.propTypes = {
  title: React.PropTypes.string.isRequired,
  moment: React.PropTypes.string.isRequired,
  // content: React.PropTypes.string.isRequired,
  children: React.PropTypes.element.isRequired,
};

export default ItemWithDialog;
