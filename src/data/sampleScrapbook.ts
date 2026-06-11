import type { Scrapbook, ScrapbookElement } from "../types/scrapbook";

export const colors = {
  ink: "#38456b",
  deepInk: "#263452",
  paper: "#f6f1e7",
  coral: "#ef2d4b",
  blue: "#3f68ca",
  cream: "#fff9ec",
  charcoal: "#222222",
  toolbar: "#272725"
};

export const canvas = {
  width: 340,
  height: 460
};

const element = (
  kind: ScrapbookElement["kind"],
  x: number,
  y: number,
  width: number,
  height: number,
  rotation: number,
  zIndex: number,
  text = "",
  style = ""
): ScrapbookElement => ({
  id: `${kind}-${zIndex}-${x}-${y}`,
  kind,
  x,
  y,
  width,
  height,
  rotation,
  zIndex,
  text,
  style
});

export const sampleScrapbook: Scrapbook = {
  id: "sample",
  title: "Paper Memories",
  updatedAt: new Date().toISOString(),
  pages: [
    {
      id: "page-1",
      background: "warmPaper",
      elements: [
        element("dateNumber", 72, 100, 96, 92, -2, 1, "2", "blue"),
        element("dateNumber", 88, 236, 122, 100, -1, 2, "26", "blue"),
        element("photo", 186, 170, 136, 104, -5, 3, "Memory", "placeholder"),
        element("sticker", 90, 208, 64, 64, -10, 4, "★", "red"),
        element("tape", 188, 132, 94, 28, 7, 5, "", "cream"),
        element("text", 190, 76, 150, 58, 3, 6, "favorite little everyday things", "caption")
      ]
    },
    {
      id: "page-2",
      background: "blushStripe",
      elements: [
        element("paperScrap", 170, 164, 164, 130, 2, 1, "tiny keepsakes", "redStripe"),
        element("photo", 150, 158, 126, 102, -7, 2, "Photo", "placeholder"),
        element("photo", 222, 236, 128, 104, 6, 3, "Photo", "placeholder"),
        element("tape", 152, 102, 96, 28, -8, 4, "", "cream"),
        element("sticker", 90, 122, 52, 52, 12, 5, "✦", "cream"),
        element("sticker", 278, 292, 52, 52, -8, 6, "♡", "red"),
        element("text", 222, 88, 128, 52, -3, 7, "remember this", "label")
      ]
    },
    {
      id: "page-3",
      background: "blueGrid",
      elements: [
        element("paperScrap", 92, 170, 150, 120, -8, 1, "freeform pages", "cream"),
        element("photo", 190, 186, 142, 112, 6, 2, "Weekend", "placeholder"),
        element("text", 150, 72, 170, 58, 4, 3, "stickers, tape, photos, dates", "caption"),
        element("sticker", 78, 304, 54, 54, -12, 4, "✿", "red"),
        element("tape", 222, 130, 98, 28, 10, 5, "", "cream")
      ]
    }
  ]
};

export const backgroundLabels = {
  warmPaper: "Warm paper",
  blushStripe: "Blush stripes",
  blueGrid: "Blue grid",
  kraft: "Kraft",
  mintDots: "Mint dots"
} as const;
