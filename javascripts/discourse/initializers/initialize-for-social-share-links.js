import { withPluginApi } from "discourse/lib/plugin-api";

const DEFAULT_POPUP_HEIGHT = 265;

export default {
  name: "extend-for-social-share-links",
  initialize() {
    withPluginApi((api) => {
      for (const link of settings.social_share_links) {
        // a height of 0 opens the link in a new tab instead of a popup
        const popupHeight = link.popup_height ?? DEFAULT_POPUP_HEIGHT;

        api.addSharingSource({
          id: link.name,
          icon: link.icon.toLowerCase(),
          title: link.title,
          generateUrl: (url, title) => {
            return (
              link.link +
              encodeURIComponent(url) +
              "&title=" +
              encodeURIComponent(title)
            );
          },
          shouldOpenInPopup: popupHeight > 0,
          popupHeight,
        });
      }
    });
  },
};
