require_relative "test_helper"

class DashboardsTest < ActionDispatch::IntegrationTest
  def setup
    super
    Blazer::Query.delete_all
    Blazer::Dashboard.delete_all
  end

  def test_new
    get blazer.new_dashboard_path
    assert_response :success
  end

  def test_create
    post blazer.dashboards_path(params: {dashboard: {name: "Test"}})
    dashboard = Blazer::Dashboard.last
    assert_redirected_to blazer.dashboard_path(dashboard)
    assert_equal "Test", dashboard.name
  end

  def test_show
    dashboard = create_dashboard
    get blazer.dashboard_path(dashboard)
    assert_response :success
  end

  def test_edit
    dashboard = create_dashboard
    get blazer.edit_dashboard_path(dashboard)
    assert_response :success
  end

  def test_update
    dashboard = create_dashboard
    patch blazer.dashboard_path(dashboard, params: {dashboard: {name: "Updated"}})
    dashboard.reload
    assert_redirected_to blazer.dashboard_path(dashboard)
    assert_equal "Updated", dashboard.name
  end

  def test_show_positions
    dashboard = create_dashboard
    query = create_query
    other_query = create_query
    dashboard.queries << query
    dashboard.queries << other_query
    dashboard.update!(positions: [{id: query.id, x: 1, y: 2, w: 3, h: 4}, {id: 0, x: 0, y: 0, w: 1, h: 1}].to_json)

    get blazer.dashboard_path(dashboard)
    assert_response :success
    assert_match %("id":#{query.id},"x":1,"y":2,"w":3,"h":4), response.body
    assert_match %("id":#{other_query.id},"x":0,"y":0,"w":2,"h":2), response.body
    refute_match %("id":0), response.body
  end

  def test_update_positions
    dashboard = create_dashboard
    positions = [{id: 1, x: 1, y: 2, w: 3, h: 4}].to_json

    patch blazer.dashboard_path(dashboard, format: :json), params: {dashboard: {positions: positions}}
    assert_response :success
    assert_equal true, JSON.parse(response.body)["success"]
    assert_equal positions, dashboard.reload.positions
  end

  def test_destroy
    dashboard = create_dashboard
    delete blazer.dashboard_path(dashboard)
    assert_redirected_to blazer.root_path

    assert_raises(ActiveRecord::RecordNotFound) do
      dashboard.reload
    end
  end

  def test_refresh
    dashboard = create_dashboard
    dashboard.queries << create_query
    post blazer.refresh_dashboard_path(dashboard)
    assert_redirected_to blazer.dashboard_path(dashboard)
  end

  private

  def create_dashboard
    Blazer::Dashboard.create!(name: "Test")
  end
end
