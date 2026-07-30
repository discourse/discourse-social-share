# frozen_string_literal: true

# rubocop:disable RSpec/DescribeClass -- describes a theme settings migration, not a class
RSpec.describe "0001-social-share-links-to-objects" do
  let!(:component) { upload_theme_component }

  def migrate(old_value)
    component.theme_settings.create!(
      name: "social_share_links",
      data_type: ThemeSetting.types[:list],
      value: old_value,
    )

    run_theme_migration(component, "0001-social-share-links-to-objects")

    component.reload.settings[:social_share_links].value
  end

  it "converts a delimited setting into objects" do
    expect(
      migrate(
        "X, fab-x-twitter, Share on X, https://x.com/intent/tweet?url=|" \
          "Reddit, fab-reddit, Share on Reddit, https://www.reddit.com/submit?url=, 400",
      ),
    ).to eq(
      [
        {
          "name" => "X",
          "icon" => "fab-x-twitter",
          "title" => "Share on X",
          "link" => "https://x.com/intent/tweet?url=",
        },
        {
          "name" => "Reddit",
          "icon" => "fab-reddit",
          "title" => "Share on Reddit",
          "link" => "https://www.reddit.com/submit?url=",
          "popup_height" => 400,
        },
      ],
    )
  end

  it "normalizes a negative height, which used to mean 'open in a new tab'" do
    migrated = migrate("X, fab-x-twitter, Share on X, https://x.com/intent/tweet?url=, -1")

    expect(migrated.first["popup_height"]).to eq(0)
  end

  it "drops entries that are missing a property required by the new schema" do
    migrated =
      migrate(
        "Broken, fab-x-twitter|" \
          "Reddit, fab-reddit, Share on Reddit, https://www.reddit.com/submit?url=",
      )

    expect(migrated.map { |link| link["name"] }).to eq(["Reddit"])
  end
end
# rubocop:enable RSpec/DescribeClass
