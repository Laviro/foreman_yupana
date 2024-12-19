import React from 'react';
import PropTypes from 'prop-types';
import { Grid, Button, Icon } from 'patternfly-react';
import { noop } from 'foremanReact/common/helpers';
import { sprintf, translate as __ } from 'foremanReact/common/I18n';
import { isExitCodeLoading } from '../../ForemanInventoryHelpers';
import './tabHeader.scss';

const TabHeader = ({ exitCode, onRestart, onDownload, toggleFullScreen }) => (
  <Grid.Row className="tab-header">
    <Grid.Col sm={6}>
      <p>{sprintf(__('Exit Code: %s'), exitCode)}</p>
    </Grid.Col>
    <Grid.Col sm={6}>
      <div className="tab-action-buttons">
        {onRestart ? (
          <Button
            bsStyle="primary"
            onClick={onRestart}
            disabled={isExitCodeLoading(exitCode)}
          >
            {__('Generate and upload report')}
          </Button>
        ) : null}
        {onDownload ? (
          <Button onClick={onDownload}>
            {__('Download Report')} <Icon name="download" />
          </Button>
        ) : null}
        <Button onClick={toggleFullScreen}>
          {__('Full Screen')}
          <Icon name="arrows-alt" />
        </Button>
      </div>
    </Grid.Col>
  </Grid.Row>
);

TabHeader.propTypes = {
  onRestart: PropTypes.func,
  onDownload: PropTypes.func,
  exitCode: PropTypes.string,
  toggleFullScreen: PropTypes.func,
};

TabHeader.defaultProps = {
  onRestart: null,
  exitCode: '',
  onDownload: null,
  toggleFullScreen: noop,
};

export default TabHeader;
