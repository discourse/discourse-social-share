# frozen_string_literal: true

RSpec.describe "Social share links", system: true do
  fab!(:user)
  fab!(:topic) { Fabricate(:topic, title: "A topic about sharing links") }
  fab!(:post) { Fabricate(:post, topic: topic) }

  let!(:component) { upload_theme_component }

  before do
    component.update_setting(
      :social_share_links,
      [
        {
          "name" => "x",
          "icon" => "fab-x-twitter",
          "title" => "Share on X",
          "link" => "https://x.com/intent/tweet?url=",
        },
        {
          "name" => "linkedin",
          "icon" => "fab-linkedin",
          "title" => "Share on LinkedIn",
          "link" => "https://www.linkedin.com/shareArticle?mini=true&url=",
          "popup_height" => 400,
        },
        {
          "name" => "reddit",
          "icon" => "fab-reddit",
          "title" => "Share on Reddit",
          "link" => "https://www.reddit.com/submit?url=",
          "popup_height" => 0,
        },
      ],
    )
    component.update_setting(:svg_icons, "fab-x-twitter|fab-linkedin|fab-reddit")
    component.save!

    sign_in(user)
  end

  def open_share_modal
    visit("/t/#{topic.slug}/#{topic.id}")
    find("#topic-footer-buttons button.share-and-invite").click
    expect(page).to have_css(".share-topic-modal")
  end

  # stubbed so that the share target can be asserted on without actually
  # opening a popup or a tab
  def stub_window_open
    page.execute_script(<<~JS)
      window.__sharedWith = [];
      window.open = (url, target, features) => {
        window.__sharedWith.push({ url, target, features });
      };
    JS
  end

  def shared_with
    page.evaluate_script("window.__sharedWith")
  end

  it "adds a share button for each configured link" do
    open_share_modal

    expect(page).to have_css(".share-topic-modal .share-x[title='Share on X']")
    expect(page).to have_css(".share-topic-modal .share-x svg.d-icon-fab-x-twitter")
    expect(page).to have_css(".share-topic-modal .share-linkedin[title='Share on LinkedIn']")
    expect(page).to have_css(".share-topic-modal .share-reddit[title='Share on Reddit']")
  end

  it "shares the topic url and title through the configured link" do
    open_share_modal
    stub_window_open

    find(".share-topic-modal .share-x").click
    shared_url = shared_with.first["url"]

    expect(shared_url).to start_with("https://x.com/intent/tweet?url=")
    expect(shared_url).to include(ERB::Util.url_encode("/t/#{topic.slug}/#{topic.id}"))
    expect(shared_url).to end_with("&title=#{ERB::Util.url_encode(topic.title)}")
  end

  it "opens the link in a popup of the configured height" do
    open_share_modal
    stub_window_open

    find(".share-topic-modal .share-x").click
    find(".share-topic-modal .share-linkedin").click

    expect(shared_with[0]["features"]).to include("height=265")
    expect(shared_with[1]["features"]).to include("height=400")
  end

  it "opens the link in a new tab when the popup height is 0" do
    open_share_modal
    stub_window_open

    find(".share-topic-modal .share-reddit").click

    expect(shared_with.first["target"]).to eq("_blank")
  end
end
