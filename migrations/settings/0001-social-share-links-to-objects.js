// Converts the `social_share_links` setting from a pipe/comma delimited list
// ("name, icon, title, link, height|...") into an objects type setting.

export default function migrate(settings) {
  const oldValue = settings.get("social_share_links");

  // already migrated, or never overridden
  if (typeof oldValue !== "string") {
    return settings;
  }

  const links = [];

  for (const entry of oldValue.split("|")) {
    const [name, icon, title, link, height] = entry
      .split(",")
      .map((section) => section.trim());

    // `name`, `icon` and `link` are required by the new schema, and an entry
    // missing any of them was already broken before the migration
    if (!name || !icon || !link) {
      continue;
    }

    const migrated = { name, icon, link };

    if (title) {
      migrated.title = title;
    }

    const popupHeight = parseInt(height, 10);

    if (!isNaN(popupHeight)) {
      // heights of 0 or less all meant "open in a new tab"
      migrated.popup_height = Math.max(popupHeight, 0);
    }

    links.push(migrated);
  }

  settings.set("social_share_links", links);

  return settings;
}
