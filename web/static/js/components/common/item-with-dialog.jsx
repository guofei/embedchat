import React from 'react';
import { ListItem } from 'material-ui/List';
import Dialog from 'material-ui/Dialog';
import FlatButton from 'material-ui/FlatButton';


const styles = {
  pullRight: {
    float: 'right',
    color: 'gray',
    fontSize: 'small',
  },
};

function shortTitle(title) {
  const maxLenght = 40;
  if (title.length > maxLenght) {
    return `${title.substring(0, maxLenght)}...`;
  }
  return title;
}

function Item({ title, moment, handleTouchTap, content }) {
  return (
    <ListItem
      secondaryTextLines={2}
      primaryText={
        <div style={{ fontSize: 'small' }}>
          {shortTitle(title)}
          <div style={styles.pullRight}>
            {moment}
          </div>
        </div>
      }
      onTouchTap={handleTouchTap}
      secondaryText={
        <div style={{ fontSize: 'small' }}>{content}</div>
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
