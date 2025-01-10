import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import SearchBar from 'foremanReact/components/SearchBar';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Grid,
  GridItem,
  Dropdown,
  DropdownItem,
  KebabToggle,
} from '@patternfly/react-core';
import { ExternalLinkAltIcon } from '@patternfly/react-icons';
import InsightsTable from '../InsightsCloudSync/Components/InsightsTable';
import RemediationModal from '../InsightsCloudSync/Components/RemediationModal';
import Pagination from '../InsightsCloudSync/Components/InsightsTable/Pagination';
import { INSIGHTS_SEARCH_PROPS } from '../InsightsCloudSync/InsightsCloudSyncConstants';
import { fetchInsights } from '../InsightsCloudSync/Components/InsightsTable/InsightsTableActions';
import {
  selectSearch,
  selectHits,
} from '../InsightsCloudSync/Components/InsightsTable/InsightsTableSelectors';
import { redHatAdvisorSystems } from '../InsightsCloudSync/InsightsCloudSyncHelpers';
import { useAdvisorEngineConfig } from '../common/Hooks/ConfigHooks';

const NewHostDetailsTab = ({ hostName, router }) => {
  const dispatch = useDispatch();
  const query = useSelector(selectSearch);
  const hits = useSelector(selectHits);
  const isLocalAdvisorEngine = useAdvisorEngineConfig();

  useEffect(() => () => router.replace({ search: null }), [router]);

  const onSearch = q => dispatch(fetchInsights({ query: q, page: 1 }));

  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const onSatInsightsClick = () =>
    router.push({ pathname: '/foreman_rh_cloud/insights_cloud' });

  const dropdownItems = [
    <DropdownItem key="insights-link" ouiaId="insights-link">
      <a onClick={onSatInsightsClick}>{__('Go to Foreman Insights page')}</a>
    </DropdownItem>,
  ];

  if (hits.length && !isLocalAdvisorEngine) {
    const { host_uuid: uuid } = hits[0];
    dropdownItems.push(
      <DropdownItem key="insights-advisor-link" ouiaId="insights-advisor-link">
        <a
          href={redHatAdvisorSystems(uuid)}
          target="_blank"
          rel="noopener noreferrer"
        >
          {__('View in Red Hat Insights')}
          {'  '}
          <ExternalLinkAltIcon />
        </a>
      </DropdownItem>
    );
  }

  return (
    <Grid id="new_host_details_insights_tab" hasGutter>
      <GridItem span={5}>
        <SearchBar
          data={INSIGHTS_SEARCH_PROPS}
          onSearch={onSearch}
          initialQuery={query}
        />
      </GridItem>
      <GridItem span={4}>
        <RemediationModal />
        <Dropdown
          className="insights-dropdown"
          ouiaId="insights-dropdown"
          onSelect={() => setIsDropdownOpen(false)}
          toggle={
            <KebabToggle onToggle={isOpen => setIsDropdownOpen(isOpen)} />
          }
          isOpen={isDropdownOpen}
          isPlain
          dropdownItems={dropdownItems}
        />
      </GridItem>
      <GridItem span={3}>
        <Pagination ouiaId="insights-pagination" variant="top" isCompact />
      </GridItem>
      <GridItem>
        <InsightsTable hideHost hostname={hostName} />
      </GridItem>
    </Grid>
  );
};

NewHostDetailsTab.propTypes = {
  hostName: PropTypes.string,
  router: PropTypes.object,
};

NewHostDetailsTab.defaultProps = {
  hostName: '',
  router: {},
};

export default NewHostDetailsTab;
