require 'test_plugin_helper'

class SettingsControllerTest < ActionController::TestCase
  tests InsightsCloud::SettingsController
  def setup
    ForemanRhCloud.stubs(:with_local_advisor_engine?).returns(false)
  end

  test 'should return error if insights on premise' do
    ForemanRhCloud.stubs(:with_local_advisor_engine?).returns(true)

    get :show, session: set_session_user

    assert_response :unprocessable_entity
    actual = JSON.parse(response.body)
    assert_equal 'This Foreman is configured to use Insights on Premise. Syncing to Insights Cloud is disabled.', actual['error']
  end

  test 'should return allow_auto_insights_sync setting' do
    Setting[:allow_auto_insights_sync] = false

    assert_equal false, Setting[:allow_auto_insights_sync]

    get :show, session: set_session_user

    assert_response :success
    actual = JSON.parse(response.body)
    assert_equal false, actual['insightsSyncEnabled']
  end

  test 'should update allow_auto_insights_sync setting' do
    Setting[:allow_auto_insights_sync] = false

    assert_equal false, Setting[:allow_auto_insights_sync]

    patch :update, params: { insightsSyncEnabled: true }, session: set_session_user

    assert_response :success
    actual = JSON.parse(response.body)
    assert_equal true, actual['insightsSyncEnabled']
    assert_equal true, Setting[:allow_auto_insights_sync]
  end

  test 'Should update an organization parameter' do
    FactoryBot.create(:common_parameter, name: InsightsCloud.enable_cloud_remediations_param, value: false)
    host = FactoryBot.create(:host)

    # make sure the parameter is there
    assert_equal false, host.host_params[InsightsCloud.enable_cloud_remediations_param]

    post :set_org_parameter, params: { parameter: InsightsCloud.enable_cloud_remediations_param, value: true, organization_id: host.organization.id }, session: set_session_user

    # needed for properly access host_params
    User.as_anonymous_admin do
      # refresh the host record
      host = Host.find(host.id)
      assert_equal true, host.host_params[InsightsCloud.enable_cloud_remediations_param]
    end
  end
end
