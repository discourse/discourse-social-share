import { withPluginApi } from "discourse/lib/plugin-api";
export default {
  name: "extend-for-social-share-links",
  initialize() {
    withPluginApi("0.8.23", api => {
      // No settings, so we bail
      if (!settings.social_share_links.length) return;

      // split different links entered in the settings
      const socialShareLinks = settings.social_share_links.split("|");

      // loop through each social link
      for (let i = 0; i < socialShareLinks.length; i++) {
        const sections = socialShareLinks[i].split(",");

        // loop through each link section
        for (let i = 0; i < sections.length; i++) {
          sections[i] = sections[i].trim();
        }

        api.addSharingSource({
          id: sections[0],
          icon: sections[1].toLowerCase(),
          title: sections[2],
          generateUrl: (link, title) => {
            return (
              sections[3] +
              encodeURIComponent(link) +
              "&title=" +
              encodeURIComponent(title)
            );
          },
          shouldOpenInPopup: true,
          popupHeight: 265
        });
      }
    });
  }
};
