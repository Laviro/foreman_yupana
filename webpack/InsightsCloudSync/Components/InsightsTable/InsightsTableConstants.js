/* eslint-disable camelcase */
import React from 'react';
import {
  InsightsLabel,
  Section,
} from '@redhat-cloud-services/frontend-components';
import { DropdownItem } from '@patternfly/react-core';
import { sortable, cellWidth } from '@patternfly/react-table';
import { AnsibeTowerIcon, ExternalLinkAltIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { foremanUrl } from '../../../ForemanRhCloudHelpers';
import DropdownToggle from '../../../common/DropdownToggle';

export const totalRiskFormatter = ({ title: totalRisk }) => ({
  children: (
    <Section className="insights-total-risk" type="icon-group">
      <InsightsLabel value={totalRisk} />
    </Section>
  ),
});

export const hasPlaybookFormatter = ({ title: hasPlaybook }) => ({
  children: hasPlaybook ? (
    <span className="td-insights-remediate-playbook">
      <AnsibeTowerIcon />
      {__('Playbook')}
    </span>
  ) : (
    <span className="td-insights-remediate-manual">{__('Manual')}</span>
  ),
});

export const actionsFormatter = (props, { rowData = {} }) => {
  const { recommendationUrl, accessRHUrl, isLocalAdvisorEngine } = rowData;
  const dropdownItems = [];

  recommendationUrl &&
    !isLocalAdvisorEngine &&
    dropdownItems.push(
      <DropdownItem key="recommendation-url">
        <a href={recommendationUrl} target="_blank" rel="noopener noreferrer">
          {__('View in Red Hat Insights')} <ExternalLinkAltIcon />
        </a>
      </DropdownItem>
    );

  accessRHUrl &&
    dropdownItems.push(
      <DropdownItem key="access-url">
        <a href={accessRHUrl} target="_blank" rel="noopener noreferrer">
          {__('Knowledgebase article')} <ExternalLinkAltIcon />
        </a>
      </DropdownItem>
    );

  return {
    children: <DropdownToggle items={dropdownItems} />,
  };
};

export const columns = [
  {
    id: 'hostname',
    sortKey: 'hostname',
    title: __('Hostname'),
    transforms: [cellWidth(20), sortable],
  },
  {
    id: 'recommendation',
    sortKey: 'title',
    title: __('Recommendation'),
    transforms: [cellWidth(50), sortable],
  },
  {
    id: 'total risk',
    sortKey: 'total_risk',
    title: __('Total risk'),
    transforms: [cellWidth(15), sortable],
    cellTransforms: [totalRiskFormatter],
  },
  {
    id: 'remediate',
    title: __('Remediate'),
    transforms: [cellWidth(10)],
    cellTransforms: [hasPlaybookFormatter],
  },
  {
    id: 'actions',
    title: '',
    transforms: [cellWidth(5)],
    cellTransforms: [actionsFormatter],
  },
];

export const getColumnsWithoutHostname = () => {
  const nextCols = columns.slice(1);
  nextCols[0].transforms = [cellWidth(70), sortable];
  return nextCols;
};

export const paginationTitles = {
  items: __('items'),
  page: __('page'),
  itemsPerPage: __('Items per page'),
  perPageSuffix: __('per page'),
  toFirstPage: __('Go to first page'),
  toPreviousPage: __('Go to previous page'),
  toLastPage: __('Go to last page'),
  toNextPage: __('Go to next page'),
  optionsToggle: __('Items per page'),
  currPage: __('Current page'),
  paginationTitle: __('Pagination'),
};

export const INSIGHTS_HITS_PATH = foremanUrl('/insights_cloud/hits');

export const INSIGHTS_HITS_API_KEY = 'INSIGHTS_HITS';

export const INSIGHTS_SET_SELECTED_IDS = 'INSIGHTS_SET_SELECTED_IDS';

export const INSIGHTS_SET_SELECT_ALL_ALERT = 'INSIGHTS_SET_SELECT_ALL_ALERT';

export const INSIGHTS_SET_SELECT_ALL = 'INSIGHTS_SET_SELECT_ALL';

export const ADVISOR_ENGINE_CONFIG_KEY = 'ADVISOR_ENGINE_CONFIG';

export const ADVISOR_ENGINE_CONFIG_PATH = foremanUrl(
  '/api/v2/rh_cloud/advisor_engine_config'
);

export const NEW_HOST_PATH = '/new/hosts/';
