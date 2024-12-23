require 'test_plugin_helper'

module InsightsCloud
  module Api
    class InsightsAdvisorControllerTest < ActionController::TestCase
      tests ::Api::V2::InsightsAdvisor::InsightsAdvisorController

      setup do
        @test_org = FactoryBot.create(:organization)
        @host1 = FactoryBot.create(:host, :with_insights_hits, organization: @test_org, hostname: 'insightshost1')
        @host2 = FactoryBot.create(:host, :with_insights_hits, organization: @test_org, hostname: 'insightshost2')
        @host3 = FactoryBot.create(:host, organization: @test_org)
      end

      test 'shows hosts with uuids' do
        uuids = [@host1.insights.uuid, @host2.insights.uuid]
        get :host_details, params: { organization_id: @test_org.id, host_uuids: uuids }
        assert_response :success
        assert_template 'api/v2/insights_advisor/host_details'
        assert_equal @test_org.hosts.joins(:insights).where(:insights => { :uuid => uuids }).count, assigns(:hosts).count
        refute_equal @test_org.hosts.count, assigns(:hosts).count
      end

      test 'shows error when no hosts found' do
        get :host_details, params: { organization_id: @test_org.id, host_uuids: ['nonexistentuuid'] }
        assert_response :not_found
        assert_equal 'No hosts found for the given UUIDs', JSON.parse(response.body)['error']
      end
    end
  end
end
