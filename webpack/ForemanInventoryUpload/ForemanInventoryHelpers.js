import URI from 'urijs';
import { foremanUrl } from '../ForemanRhCloudHelpers';

export const inventoryUrl = path =>
  foremanUrl(`/foreman_inventory_upload/${path}`);

export const getInventoryDocsUrl = () =>
  foremanUrl(
    `/links/manual/?root_url=${URI.encode(
      'https://access.redhat.com/documentation/en-us/red_hat_insights/2023/html/red_hat_insights_remediations_guide/host-communication-with-insights_red-hat-insights-remediation-guide#uploading-satellite-host-inventory-to-insights_configuring-satellite-cloud-connector'
    )}`
  );

export const getActionsHistoryUrl = () =>
  foremanUrl(
    '/foreman_tasks/tasks?search=label+%3D+ForemanInventoryUpload%3A%3AAsync%3A%3AGenerateReportJob+or+label+%3D+ForemanInventoryUpload%3A%3AAsync%3A%3AGenerateAllReportsJob&page=1'
  );

export const isExitCodeLoading = exitCode => {
  const exitCodeLC = exitCode.toLowerCase();
  return (
    exitCodeLC.indexOf('running') !== -1 ||
    exitCodeLC.indexOf('restarting') !== -1
  );
};
