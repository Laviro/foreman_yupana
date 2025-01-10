import React from 'react';
import { IntegrationTestHelper } from '@theforeman/test';

import AccountList from '../index';
import reducers from '../../../../ForemanRhCloudReducers';

jest.mock('foremanReact/common/hooks/API/APIHooks', () => ({
  useAPI: jest.fn(),
}));

describe('AccountList integration test', () => {
  it('should flow', async () => {
    const integrationTestHelper = new IntegrationTestHelper(reducers);
    const component = integrationTestHelper.mount(<AccountList />);
    component.update();
    /** Create a Flow test */
  });
});
