require_relative "test_helper"

class AssetsTest < ActionDispatch::IntegrationTest
  JAVASCRIPTS = Pathname.new(__dir__).join("../app/assets/javascripts")
  STYLESHEETS = Pathname.new(__dir__).join("../app/assets/stylesheets")

  # Sprockets compiles blazer/application.js and blazer/application.css from the `require` lines,
  # while with Propshaft the layout links every file itself
  def test_layout_links_the_files_of_the_sprockets_bundles
    get blazer.root_path
    assert_response :success

    scripts = css_select("script[src]").map { |script| asset_name(script["src"]) }
    assert_equal required_javascripts("blazer/application") + ["blazer/application"], scripts

    stylesheets = css_select("link[rel=stylesheet]").map { |link| asset_name(link["href"]) } - ["blazer/bootstrap-propshaft"]
    required = STYLESHEETS.join("blazer/application.css").read.scan(%r{^ \*= require \./(\S+)}).flatten - ["bootstrap-sprockets"]
    assert_equal required.map { |name| "blazer/#{name}" } + ["blazer/application"], stylesheets
  end

  private

  def asset_name(path)
    path.delete_prefix("/assets/").sub(/-[0-9a-f]{8,}\.(js|css)\z/, "")
  end

  # the files a Sprockets bundle includes, in order, with nested bundles (like ace.js) expanded
  def required_javascripts(asset)
    file = JAVASCRIPTS.join("#{asset}.js")
    return [asset] unless file.exist?

    requires = file.read.scan(%r{^//= require (\S+)}).flatten
    return [asset] if requires.empty?

    requires.flat_map { |name| required_javascripts(name.start_with?("./") ? "blazer/#{name.delete_prefix("./")}" : name) }
  end
end
